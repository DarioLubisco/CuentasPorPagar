import database

def insert_historical_payment():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    try:
        # Get Max AbonoID
        cursor.execute("SELECT ISNULL(MAX(AbonoID), 0) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos")
        new_id = int(cursor.fetchone()[0]) + 1
        
        # Insert historical payment mirroring the TipoCxP '41' record
        cursor.execute("""
            INSERT INTO EnterpriseAdmin_AMC.dbo.CxP_Abonos 
            (AbonoID, NumeroD, CodProv, FechaAbono, MontoBsAbonado, 
             TasaCambioDiaAbono, MontoUsdAbonado, AplicaIndexacion, 
             Referencia, TipoAbono, NotificarCorreo, AfectaSaldo)
            VALUES (?, '00092540', 'J-409166989', '2026-03-11', 67437.85, 
                    1.0, 0, 0, 'PAGO HISTÓRICO SAINT (Surgical)', 'PAGO_MANUAL', 0, 1)
        """, (new_id,))
        
        conn.commit()
        print("Historical record successfully mirrored to CxP_Abonos.")
    except Exception as e:
        conn.rollback()
        print("Error:", e)
    finally:
        conn.close()

if __name__ == '__main__':
    insert_historical_payment()
