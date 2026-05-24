# train.py
import torch
import torch.nn as nn
from torch.optim import AdamW
from torch.optim.lr_scheduler import CosineAnnealingWarmRestarts
from pathlib import Path

class MUSSTrainer:
    def __init__(self, model, tokenizer, config):
        self.model     = model
        self.tokenizer = tokenizer
        self.config    = config
        self.device    = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        self.model.to(self.device)
        
        # Label smoothing cross entropy — standard for seq2seq
        self.criterion = nn.CrossEntropyLoss(
            ignore_index=0,            # ignore PAD
            label_smoothing=0.1,       # prevents overconfidence
        )
        
        # AdamW with weight decay
        self.optimizer = AdamW(
            model.parameters(),
            lr=config['lr'],
            betas=(0.9, 0.98),         # standard transformer betas
            eps=1e-9,
            weight_decay=0.01,
        )
        
        # Transformer learning rate schedule (warmup + decay)
        self.scheduler = self._get_transformer_schedule(
            warmup_steps=config['warmup_steps']
        )
        
        self.scaler = torch.cuda.amp.GradScaler()  # mixed precision
        
        num_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
        print(f"✅ Model: {num_params:,} parameters")
        print(f"   Device: {self.device}")
    
    def _get_transformer_schedule(self, warmup_steps):
        """Original 'Attention is All You Need' LR schedule."""
        d_model = self.config['d_model']
        
        def lr_lambda(step):
            step = max(step, 1)
            return (d_model ** -0.5) * min(
                step ** -0.5,
                step * (warmup_steps ** -1.5)
            )
        
        return torch.optim.lr_scheduler.LambdaLR(self.optimizer, lr_lambda)
    
    def train_step(self, batch):
        self.model.train()
        
        src_ids     = batch['src_ids'].to(self.device)
        tgt_ids     = batch['tgt_ids'].to(self.device)
        src_mask    = batch['src_mask'].to(self.device)
        control_vec = batch['control_vec'].to(self.device)
        
        # Teacher forcing: input is tgt[:-1], label is tgt[1:]
        tgt_input  = tgt_ids[:, :-1]
        tgt_labels = tgt_ids[:, 1:]
        
        # Causal mask for decoder
        tgt_len  = tgt_input.size(1)
        tgt_mask = torch.tril(
            torch.ones(tgt_len, tgt_len, device=self.device)
        ).unsqueeze(0).unsqueeze(0)
        
        # Mixed precision forward
        with torch.cuda.amp.autocast():
            logits = self.model(
                src_ids, tgt_input, 
                src_mask, tgt_mask, 
                control_vec
            )
            
            # Reshape for cross entropy
            loss = self.criterion(
                logits.reshape(-1, logits.size(-1)),
                tgt_labels.reshape(-1)
            )
        
        # Backward
        self.optimizer.zero_grad()
        self.scaler.scale(loss).backward()
        
        # Gradient clipping (critical for transformers)
        self.scaler.unscale_(self.optimizer)
        torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
        
        self.scaler.step(self.optimizer)
        self.scaler.update()
        self.scheduler.step()
        
        return loss.item()
    
    @torch.no_grad()
    def validate(self, val_loader):
        self.model.eval()
        total_loss = 0
        
        for batch in val_loader:
            src_ids     = batch['src_ids'].to(self.device)
            tgt_ids     = batch['tgt_ids'].to(self.device)
            src_mask    = batch['src_mask'].to(self.device)
            control_vec = batch['control_vec'].to(self.device)
            
            tgt_input  = tgt_ids[:, :-1]
            tgt_labels = tgt_ids[:, 1:]
            tgt_len    = tgt_input.size(1)
            tgt_mask   = torch.tril(
                torch.ones(tgt_len, tgt_len, device=self.device)
            ).unsqueeze(0).unsqueeze(0)
            
            with torch.cuda.amp.autocast():
                logits = self.model(src_ids, tgt_input, src_mask, tgt_mask, control_vec)
                loss = self.criterion(
                    logits.reshape(-1, logits.size(-1)),
                    tgt_labels.reshape(-1)
                )
            total_loss += loss.item()
        
        return total_loss / len(val_loader)
    
    def fit(self, train_loader, val_loader, epochs: int, save_dir: str = "./checkpoints"):
        Path(save_dir).mkdir(exist_ok=True)
        best_val_loss = float('inf')
        
        for epoch in range(epochs):
            train_losses = []
            
            for step, batch in enumerate(train_loader):
                loss = self.train_step(batch)
                train_losses.append(loss)
                
                if step % 100 == 0:
                    lr = self.scheduler.get_last_lr()[0]
                    print(f"Epoch {epoch+1} | Step {step} | Loss: {loss:.4f} | LR: {lr:.2e}")
            
            val_loss = self.validate(val_loader)
            avg_train = sum(train_losses) / len(train_losses)
            
            print(f"\n{'='*50}")
            print(f"Epoch {epoch+1} complete")
            print(f"  Train loss: {avg_train:.4f}")
            print(f"  Val   loss: {val_loss:.4f}")
            print(f"{'='*50}\n")
            
            # Save best
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                torch.save({
                    'epoch': epoch,
                    'model_state_dict': self.model.state_dict(),
                    'optimizer_state_dict': self.optimizer.state_dict(),
                    'val_loss': val_loss,
                    'config': self.config,
                }, f"{save_dir}/best_model.pt")
                print(f"  ✅ Saved best model (val_loss={val_loss:.4f})")


# ─── Main entry point ───────────────────────────────────────────────
if __name__ == "__main__":
    from model.muss_model import MUSSArabicModel, CONFIGS
    from data.dataset import ArabicSimplificationDataset, collate_fn
    from torch.utils.data import DataLoader
    from tokenizers import Tokenizer
    from functools import partial
    import os
    
    # Load tokenizer
    tokenizer = Tokenizer.from_file("tokenizer/arabic_bpe.json")
    
    # Build model
    config = CONFIGS["tiny"]  # Use tiny config for faster training
    model  = MUSSArabicModel(config)
    
    # Build datasets
    train_ds = ArabicSimplificationDataset("data/train.csv", tokenizer, augment=True)
    val_ds   = ArabicSimplificationDataset("data/val.csv",   tokenizer, augment=False)
    
    pad_id   = tokenizer.token_to_id("[PAD]")
    collate  = partial(collate_fn, pad_id=pad_id)
    
    train_loader = DataLoader(train_ds, batch_size=8, shuffle=True,  collate_fn=collate)
    val_loader   = DataLoader(val_ds,   batch_size=8, shuffle=False, collate_fn=collate)
    
    # Train
    train_config = {
        "lr": 1.0,               # Scaled by LR schedule
        "warmup_steps": 200,     # Increased for larger dataset
        "d_model": config['d_model'],
    }
    
    # Create checkpoints directory
    os.makedirs("checkpoints", exist_ok=True)
    
    trainer = MUSSTrainer(model, tokenizer, train_config)
    trainer.fit(train_loader, val_loader, epochs=20)  # Increased epochs for better training