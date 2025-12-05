import json

def check_ethical_compliance(input_path: str):
    with open(input_path) as f:
        data = json.load(f)
        for item in data:
            assert "ethics_approve" in item, "Missing ethics approval"
            assert item["ethics_approve"] in ["safe", "reviewed"]
        return True
