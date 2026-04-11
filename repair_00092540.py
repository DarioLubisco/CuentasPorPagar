import database

def repair():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    try:
        # Update SAACXP
        cursor.execute("UPDATE dbo.SAACXP SET Saldo = 0, CancelC = Monto WHERE NroUnico = 62815")
        
        # Verify
        cursor.execute("SELECT NumeroD, Saldo, CancelC FROM dbo.SAACXP WHERE NroUnico = 62815")
        row = cursor.fetchone()
        print(f"Update Result [SAACXP 62815]: NumeroD={row[0]}, Saldo={row[1]}, CancelC={row[2]}")
        
        conn.commit()
        print("Surgical repair committed successfully.")
    except Exception as e:
        conn.rollback()
        print(f"Error during repair: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    repair()
