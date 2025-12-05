# scripts/
import torch
from typing import List

def sanitize_models(libraries: List[str]):
    for lib in libraries:
        if lib == "pytorch":
            torch.set_flush_denormal(True)
            torch.backends.cudnn.benchmark = False
        # Add library-specific sanitization here
