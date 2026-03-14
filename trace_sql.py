import time
import pyodbc
from dotenv import load_dotenv
import os
import socket

load_dotenv()

DB_SERVER = os.getenv("DB_SERVER")
DB_DATABASE = "EnterpriseAdmin_AMC"
DB_USERNAME = "sa"
DB_PASSWORD = "Twinc3pt."
DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

def get_db_connection():
    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    return pyodbc.connect(conn_str)

def trace_queries():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    machine_name = socket.gethostname()
    
    print(f"==================================================")
    print(f"Starting SQL Trace for machine client: {machine_name}")
    print(f"==================================================")
    print("Capturing currently executing SQL statements...")
    print("Execute actions in your application now. Press Ctrl+C in terminal to stop.\n")
    
    # Query to fetch currently executing SQL requests
    # Filters by host_name = this machine, and ignores the connection running the trace itself
    query = """
    SELECT 
        r.session_id,
        s.login_name,
        s.host_name,
        s.program_name,
        r.start_time,
        r.status,
        r.command,
        t.text AS query_text
    FROM sys.dm_exec_requests r
    JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
    WHERE s.host_name = ? 
      AND s.session_id <> @@SPID
    """
    
    seen_queries = set()
    
    try:
        while True:
            cursor.execute(query, (machine_name,))
            rows = cursor.fetchall()
            
            for row in rows:
                if row.query_text:
                    query_body = row.query_text.strip()
                else:
                    query_body = "-- [Encrypted or Unavailable Query Text]"

                query_info = (row.session_id, query_body)
                
                if query_info not in seen_queries:
                    log_entry = (
                        f"-- Time: {row.start_time} | SPID: {row.session_id} | App: {row.program_name}\n"
                        f"{query_body}\n"
                        f"GO\n\n"
                    )
                    
                    with open("trace_log.sql", "a", encoding="utf-8") as f:
                        f.write(log_entry)
                        
                    print(f"Captured query from SPID {row.session_id}")
                    
                    seen_queries.add(query_info)
                    
                    if len(seen_queries) > 500:
                        seen_queries.clear()
                        
            # Polling interval (seconds). Get from ENV or default to 0.1 (100ms)
            poll_interval = float(os.getenv("POLL_INTERVAL", 0.1))
            time.sleep(poll_interval) 
            
    except KeyboardInterrupt:
        print("\nStopping trace.")
    finally:
        conn.close()

if __name__ == "__main__":
    trace_queries()
