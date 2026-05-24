# tokenizer/arabic_bpe.py
from tokenizers import Tokenizer, models, trainers, pre_tokenizers, decoders
from tokenizers.processors import TemplateProcessing
import re

def build_arabic_tokenizer(
    corpus_files: list,
    vocab_size: int = 32000,
    save_path: str = "tokenizer/arabic_bpe.json"
):
    """
    Train BPE tokenizer on Arabic + English corpus.
    Handles Arabic morphology better than off-the-shelf tokenizers.
    """
    
    tokenizer = Tokenizer(models.BPE(unk_token="<unk>"))
    
    # Arabic-aware pre-tokenization
    # Split on whitespace AND keep Arabic script together
    tokenizer.pre_tokenizer = pre_tokenizers.Sequence([
        pre_tokenizers.WhitespaceSplit(),
        pre_tokenizers.ByteLevel(add_prefix_space=False),
    ])
    
    # Special tokens
    special_tokens = [
        "<pad>", "<unk>", "<bos>", "<eos>", "<mask>",
        
        # Language tokens
        "<ar>", "<en>", "<darija>",
        
        # MUSS Control tokens — continuous values discretized
        # Length ratio
        "<LEN_0.5>", "<LEN_0.6>", "<LEN_0.7>", "<LEN_0.8>", "<LEN_0.9>", "<LEN_1.0>",
        # Lexical simplicity
        "<LEX_0.3>", "<LEX_0.4>", "<LEX_0.5>", "<LEX_0.6>", "<LEX_0.7>", "<LEX_0.8>",
        # Syntactic depth
        "<SYN_0.3>", "<SYN_0.5>", "<SYN_0.7>",
        # Dyslexia-specific
        "<DYSLEXIA_EASY>", "<DYSLEXIA_MEDIUM>",
    ]
    
    trainer = trainers.BpeTrainer(
        vocab_size=vocab_size,
        special_tokens=special_tokens,
        min_frequency=2,
        show_progress=True,
        # Arabic script gets its own merges
        initial_alphabet=pre_tokenizers.ByteLevel.alphabet(),
    )
    
    tokenizer.train(corpus_files, trainer)
    
    # Post-processing: auto add bos/eos
    tokenizer.post_processor = TemplateProcessing(
        single="<bos> $A <eos>",
        pair="<bos> $A <eos> $B:1 <eos>:1",
        special_tokens=[
            ("<bos>", tokenizer.token_to_id("<bos>")),
            ("<eos>", tokenizer.token_to_id("<eos>")),
        ],
    )
    
    tokenizer.decoder = decoders.ByteLevel()
    tokenizer.save(save_path)
    
    print(f"✅ Tokenizer trained: {vocab_size} vocab")
    print(f"   Arabic coverage: check with tokenizer.encode('مرحبا بالعالم')")
    
    return tokenizer


def normalize_arabic_text(text: str) -> str:
    """
    Normalize Arabic before tokenization.
    Critical step for consistency.
    """
    # Normalize Alef variants → ا
    text = re.sub('[إأآا]', 'ا', text)
    
    # Normalize Yeh variants  
    text = re.sub('[يى]', 'ي', text)
    
    # Normalize Teh Marbuta
    text = re.sub('ة', 'ه', text)
    
    # Remove Tashkeel (diacritics) — model learns without them
    text = re.sub('[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8]', '', text)
    
    # Remove Tatweel (stretching character)
    text = re.sub('\u0640', '', text)
    
    # Normalize whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text