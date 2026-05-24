# data/dataset.py
import torch
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import random

class ArabicSimplificationDataset(Dataset):
    """
    Expects CSV with columns: complex, simple, lang
    Handles control token injection automatically.
    """
    
    def __init__(
        self,
        data_path: str,
        tokenizer,
        max_src_len: int = 256,
        max_tgt_len: int = 256,
        augment: bool = True,
    ):
        self.data = pd.read_csv(data_path)
        self.tokenizer = tokenizer
        self.max_src_len = max_src_len
        self.max_tgt_len = max_tgt_len
        self.augment = augment
    
    def compute_control_vector(self, src: str, tgt: str, lang: str) -> torch.Tensor:
        """
        Compute continuous control vector from a pair.
        Shape: (4,) — [len_ratio, lex_score, syn_score, lang_id]
        """
        src_tokens = src.split()
        tgt_tokens = tgt.split()
        
        # Feature 1: Length ratio
        len_ratio = len(tgt_tokens) / max(len(src_tokens), 1)
        len_ratio = min(max(len_ratio, 0.3), 1.2)
        
        # Feature 2: Lexical overlap (word-level)
        src_vocab = set(src_tokens)
        tgt_vocab = set(tgt_tokens)
        lex_score = len(src_vocab & tgt_vocab) / max(len(src_vocab), 1)
        
        # Feature 3: Syntactic proxy (avg word length as complexity proxy)
        src_avg_wl = sum(len(w) for w in src_tokens) / max(len(src_tokens), 1)
        tgt_avg_wl = sum(len(w) for w in tgt_tokens) / max(len(tgt_tokens), 1)
        syn_score = tgt_avg_wl / max(src_avg_wl, 1)
        
        # Feature 4: Language ID
        lang_id = {"ar": 0.0, "en": 1.0, "darija": 0.5}.get(lang, 0.0)
        
        return torch.tensor(
            [len_ratio, lex_score, syn_score, lang_id], 
            dtype=torch.float32
        )
    
    def __len__(self):
        return len(self.data)
    
    def __getitem__(self, idx):
        row = self.data.iloc[idx]
        src = str(row['complex'])
        tgt = str(row['simple'])
        lang = str(row.get('lang', 'ar'))
        
        # Augmentation: randomly perturb control values during training
        if self.augment and random.random() < 0.15:
            # Sometimes train with slightly wrong controls → robustness
            noise = torch.randn(4) * 0.05
        else:
            noise = torch.zeros(4)
        
        control_vec = self.compute_control_vector(src, tgt, lang) + noise
        control_vec = control_vec.clamp(0.0, 1.0)
        
        # Tokenize
        src_enc = self.tokenizer.encode(src)
        tgt_enc = self.tokenizer.encode(tgt)
        
        src_ids = src_enc.ids[:self.max_src_len]
        tgt_ids = tgt_enc.ids[:self.max_tgt_len]
        
        return {
            "src_ids":      torch.tensor(src_ids,  dtype=torch.long),
            "tgt_ids":      torch.tensor(tgt_ids,  dtype=torch.long),
            "control_vec":  control_vec,
            "lang":         lang,
        }


def collate_fn(batch, pad_id: int = 0):
    """Pad sequences to same length in batch."""
    
    max_src = max(b['src_ids'].size(0) for b in batch)
    max_tgt = max(b['tgt_ids'].size(0) for b in batch)
    
    src_padded = torch.zeros(len(batch), max_src, dtype=torch.long)
    tgt_padded = torch.zeros(len(batch), max_tgt, dtype=torch.long)
    src_mask   = torch.zeros(len(batch), 1, 1, max_src)
    
    for i, b in enumerate(batch):
        s = b['src_ids'].size(0)
        t = b['tgt_ids'].size(0)
        src_padded[i, :s] = b['src_ids']
        tgt_padded[i, :t] = b['tgt_ids']
        src_mask[i, 0, 0, :s] = 1.0
    
    return {
        "src_ids":     src_padded,
        "tgt_ids":     tgt_padded,
        "src_mask":    src_mask,
        "control_vec": torch.stack([b['control_vec'] for b in batch]),
    }