import psycopg2

try:
    conn = psycopg2.connect(
        host="ss-bift-db-m1.mayora.co.id",
        user="postgres",
        password="m@yor40l4p",
        dbname="olap-live",
        port=5432
    )
    cur = conn.cursor()
    cur.execute("""
        SELECT table_schema, table_name 
        FROM information_schema.tables 
        WHERE table_name ILIKE '%cycle%'
           OR table_name ILIKE '%fcycle%'
           OR table_name ILIKE '%m_f%'
        ORDER BY table_schema, table_name;
    """)
    rows = cur.fetchall()
    print("=== Matches for cycle/fcycle/m_f ===")
    for row in rows:
        print(f"{row[0]}.{row[1]}")
    cur.close()
    conn.close()
except Exception as e:
    print("Error:", e)
