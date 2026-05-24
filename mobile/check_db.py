import psycopg2
import json

try:
    conn = psycopg2.connect(
        host="localhost",
        database="delivery_app",
        user="postgres",
        password="1",
        port="5432"
    )
    cursor = conn.cursor()
    
    print("--- USERS ---")
    cursor.execute("SELECT id, email, full_name, role, avatar_url FROM users;")
    for row in cursor.fetchall():
        print(row)
        
    print("\n--- SHOPS ---")
    cursor.execute("SELECT id, seller_id, shop_name, is_active, is_verified, email, phone FROM shops;")
    for row in cursor.fetchall():
        print(row)
        
    print("\n--- PRODUCTS FROM SHOP GIÀY ĐẸP ---")
    cursor.execute("""
        SELECT p.id, p.name, p.shop_id, s.shop_name, u.avatar_url 
        FROM products p 
        JOIN shops s ON p.shop_id = s.id 
        LEFT JOIN users u ON s.seller_id = u.id
        WHERE s.shop_name ILIKE '%giày%';
    """)
    for row in cursor.fetchall():
        print(row)
        
    cursor.close()
    conn.close()
except Exception as e:
    print("Error:", e)
