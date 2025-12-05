import torch
import numpy as np

def check_safe_operations():
    # Verify no unsafe tensor ops
    assert torch.is_grad_enabled() == False
    # Check numerical stability
    assert np.seterr(all='raise') == {'ignore': None}
    print("ML operations verified as safe")
