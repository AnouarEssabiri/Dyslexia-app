# model/muss_model.py
import torch
import torch.nn as nn
import math
from .transformer import EncoderLayer, DecoderLayer

class PositionalEncoding(nn.Module):
    def __init__(self, d_model: int, max_len: int = 1024, dropout: float = 0.1):
        super().__init__()
        self.dropout = nn.Dropout(dropout)
        
        pe = torch.zeros(max_len, d_model)
        pos = torch.arange(0, max_len).unsqueeze(1).float()
        div = torch.exp(
            torch.arange(0, d_model, 2).float() * -(math.log(10000.0) / d_model)
        )
        pe[:, 0::2] = torch.sin(pos * div)
        pe[:, 1::2] = torch.cos(pos * div)
        self.register_buffer('pe', pe.unsqueeze(0))  # (1, max_len, d_model)
    
    def forward(self, x):
        x = x + self.pe[:, :x.size(1)]
        return self.dropout(x)


class MUSSArabicModel(nn.Module):
    """
    Seq2Seq Transformer with MUSS control tokens.
    Supports Arabic (MSA + Darija) + English.
    """
    
    def __init__(self, config: dict):
        super().__init__()
        
        self.config = config
        vocab_size  = config['vocab_size']
        d_model     = config['d_model']      # e.g. 512
        n_heads     = config['n_heads']      # e.g. 8
        n_enc       = config['n_enc_layers'] # e.g. 6
        n_dec       = config['n_dec_layers'] # e.g. 6
        d_ff        = config['d_ff']         # e.g. 2048
        dropout     = config['dropout']      # e.g. 0.1
        max_len     = config['max_len']      # e.g. 512
        
        # Shared embeddings (encoder + decoder share weights = less params)
        self.embedding = nn.Embedding(vocab_size, d_model, padding_idx=0)
        self.pos_enc   = PositionalEncoding(d_model, max_len, dropout)
        self.scale     = math.sqrt(d_model)
        
        # Encoder stack
        self.encoder_layers = nn.ModuleList([
            EncoderLayer(d_model, n_heads, d_ff, dropout) 
            for _ in range(n_enc)
        ])
        
        # Decoder stack
        self.decoder_layers = nn.ModuleList([
            DecoderLayer(d_model, n_heads, d_ff, dropout) 
            for _ in range(n_dec)
        ])
        
        self.enc_norm = nn.LayerNorm(d_model)
        self.dec_norm = nn.LayerNorm(d_model)
        
        # Output projection (tie with embedding weights = standard trick)
        self.output_proj = nn.Linear(d_model, vocab_size, bias=False)
        self.output_proj.weight = self.embedding.weight  # Weight tying
        
        # Control token projector
        # Maps continuous control values → embedding space
        self.control_projector = nn.Sequential(
            nn.Linear(4, d_model // 4),   # 4 control dims
            nn.GELU(),
            nn.Linear(d_model // 4, d_model),
        )
        
        self._init_weights()
    
    def _init_weights(self):
        for p in self.parameters():
            if p.dim() > 1:
                nn.init.xavier_uniform_(p)
    
    def encode(self, src_ids, src_mask, control_vector=None):
        """
        src_ids:        (B, T)
        control_vector: (B, 4) — [len_ratio, lex_score, dep_score, lang_id]
        """
        x = self.pos_enc(self.embedding(src_ids) * self.scale)
        
        # Inject control signal as extra learned token at position 0
        if control_vector is not None:
            ctrl_embed = self.control_projector(control_vector).unsqueeze(1)  # (B,1,D)
            x = torch.cat([ctrl_embed, x], dim=1)
            # Extend mask to cover control token
            if src_mask is not None:
                ctrl_mask = torch.ones(src_mask.size(0), 1, 1, 1).to(src_mask.device)
                src_mask = torch.cat([ctrl_mask, src_mask], dim=-1)
        
        for layer in self.encoder_layers:
            x = layer(x, src_mask)
        
        return self.enc_norm(x), src_mask
    
    def decode(self, tgt_ids, enc_output, src_mask, tgt_mask):
        x = self.pos_enc(self.embedding(tgt_ids) * self.scale)
        
        all_cross_weights = []
        for layer in self.decoder_layers:
            x, cross_w = layer(x, enc_output, src_mask, tgt_mask)
            all_cross_weights.append(cross_w)
        
        x = self.dec_norm(x)
        logits = self.output_proj(x)
        
        return logits, all_cross_weights
    
    def forward(self, src_ids, tgt_ids, src_mask=None, tgt_mask=None, 
                control_vector=None):
        enc_out, src_mask = self.encode(src_ids, src_mask, control_vector)
        logits, _ = self.decode(tgt_ids, enc_out, src_mask, tgt_mask)
        return logits
    
    @torch.no_grad()
    def simplify(self, src_ids, tokenizer, control_vector=None,
                 max_len=256, beam_size=4):
        """Beam search inference."""
        self.eval()
        device = src_ids.device
        
        enc_out, src_mask = self.encode(src_ids, None, control_vector)
        
        # Initialize beams: (score, token_ids)
        bos_id = tokenizer.token_to_id("[CLS]") if tokenizer.token_to_id("[CLS]") is not None else 1
        eos_id = tokenizer.token_to_id("[SEP]") if tokenizer.token_to_id("[SEP]") is not None else 2
        
        beams = [(0.0, [bos_id])]
        completed = []
        
        for step in range(max_len):
            candidates = []
            
            for score, tokens in beams:
                if tokens[-1] == eos_id:
                    completed.append((score, tokens))
                    continue
                
                tgt = torch.tensor([tokens], device=device)
                tgt_mask = self._causal_mask(len(tokens), device)
                
                logits, _ = self.decode(tgt, enc_out, src_mask, tgt_mask)
                log_probs = torch.log_softmax(logits[0, -1], dim=-1)
                
                topk_probs, topk_ids = log_probs.topk(beam_size)
                
                for prob, tok_id in zip(topk_probs, topk_ids):
                    candidates.append((
                        score + prob.item(),
                        tokens + [tok_id.item()]
                    ))
            
            # Keep top beam_size
            beams = sorted(candidates, key=lambda x: x[0], reverse=True)[:beam_size]
            
            if len(completed) >= beam_size:
                break
        
        completed.extend(beams)
        best = max(completed, key=lambda x: x[0] / len(x[1]))
        
        return best[1]
    
    def _causal_mask(self, size, device):
        mask = torch.tril(torch.ones(size, size, device=device)).unsqueeze(0).unsqueeze(0)
        return mask


# Model configs — choose based on your hardware
CONFIGS = {
    "tiny": {   # CPU / low RAM — for testing
        "vocab_size": 32000, "d_model": 256, "n_heads": 4,
        "n_enc_layers": 3, "n_dec_layers": 3,
        "d_ff": 1024, "dropout": 0.1, "max_len": 512
    },
    "small": {  # Single GPU (4–8GB) — recommended for you
        "vocab_size": 32000, "d_model": 512, "n_heads": 8,
        "n_enc_layers": 6, "n_dec_layers": 6,
        "d_ff": 2048, "dropout": 0.1, "max_len": 512
    },
    "base": {   # Multi-GPU (16GB+)
        "vocab_size": 32000, "d_model": 768, "n_heads": 12,
        "n_enc_layers": 8, "n_dec_layers": 8,
        "d_ff": 3072, "dropout": 0.1, "max_len": 512
    },
}