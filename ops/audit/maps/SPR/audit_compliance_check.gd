func validate_map(map_data):
    var checksum = calculate_sha256(map_data)
    if not checksum.match("registry.yml"):
        push_error("Checksum mismatch in registry.yml")
