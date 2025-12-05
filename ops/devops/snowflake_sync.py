import snowflake.connector
import json

def push_to_snowflake(file_path, table_name):
    conn = snowflake.connector.connect(
        user="WOLFMAN_AI",
        account="your-enterprise",
        warehouse="GAME_DEV_WH"
    )
    cursor = conn.cursor()
    with open(file_path) as f:
        data = json.load(f)
        cursor.execute(f"INSERT INTO {table_name} VALUES (%s)", (json.dumps(data),))
    conn.close()

# Example usage:
push_to_snowflake("map_grid_config.json", "GAME_MAPS.GRID_CONFIG")
