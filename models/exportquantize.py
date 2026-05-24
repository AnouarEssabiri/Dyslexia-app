# export/quantize.py
import torch
from torch.quantization import quantize_dynamic
from model.muss_model import MUSSArabicModel, CONFIGS

def export_for_mobile(model_path: str, output_path: str):
    """Quantize INT8 + export to TorchScript for Flutter."""
    
    checkpoint = torch.load(model_path, map_location='cpu')
    # Use the tiny config since that's what we trained with
    config = CONFIGS["tiny"]
    model = MUSSArabicModel(config)
    model.load_state_dict(checkpoint['model_state_dict'])
    model.eval()
    
    # Dynamic INT8 quantization → 4x smaller, 2x faster on CPU
    quantized = quantize_dynamic(
        model,
        {torch.nn.Linear},
        dtype=torch.qint8
    )
    
    # Export to TorchScript
    scripted = torch.jit.script(quantized)
    scripted.save(output_path)
    
    # Size comparison
    import os
    orig_size = os.path.getsize(model_path) / 1e6
    quant_size = os.path.getsize(output_path) / 1e6
    print(f"Original: {orig_size:.1f} MB → Quantized: {quant_size:.1f} MB")
    print(f"Compression: {orig_size/quant_size:.1f}x")

if __name__ == "__main__":
    export_for_mobile("checkpoints/best_model.pt", "checkpoints/quantized_model.pt")