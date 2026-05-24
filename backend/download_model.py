from transformers import AutoModelForSeq2SeqLM, AutoTokenizer
import torch

def download_model():
    model_name = "google/flan-t5-small"
    print(f"Downloading tokenizer for {model_name}...")
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    print(f"Downloading model {model_name}...")
    model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
    print("Done!")

if __name__ == "__main__":
    download_model()
