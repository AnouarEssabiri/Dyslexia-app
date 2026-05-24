from tokenizers import Tokenizer
from tokenizers.models import BPE
from tokenizers.trainers import BpeTrainer
from tokenizers.pre_tokenizers import Whitespace

# Create a simple BPE tokenizer for Arabic
tokenizer = Tokenizer(BPE(unk_token="[UNK]"))
tokenizer.pre_tokenizer = Whitespace()

# Trainer configuration
trainer = BpeTrainer(
    special_tokens=["[UNK]", "[PAD]", "[CLS]", "[SEP]", "[MASK]"],
    vocab_size=1000,
    min_frequency=2,
)

# Train on some Arabic text
files = ["data/train.csv"]
tokenizer.train(files, trainer)

# Save the tokenizer
tokenizer.save("tokenizer/arabic_bpe.json")
print("✅ Tokenizer created and saved to tokenizer/arabic_bpe.json")
