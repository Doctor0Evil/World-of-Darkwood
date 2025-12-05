use serde_json::Value;

#[no_mangle]
pub extern "C" fn validate(input_ptr: *const u8, input_len: usize) -> i32 {
    let slice = unsafe { std::slice::from_raw_parts(input_ptr, input_len) };
    let json: Value = serde_json::from_slice(slice).unwrap();

    // Required fields
    let required = ["asset_id", "world_coordinate", "seed", "context"];
    for key in required.iter() {
        if json.get(*key).is_none() {
            return 1; // fail
        }
    }

    // Example: enforce occlusion budget
    if let Some(ctx) = json.get("context") {
        if ctx["visibility_budget_ms"].as_i64().unwrap_or(0) > 250 {
            return 2; // fail
        }
    }

    0 // success
}
