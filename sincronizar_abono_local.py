import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoice = '64700083'
    prov = 'J- 08518977-7'
    monto = 2884.15
    
    cursor.execute("SELECT ISNULL(MAX(AbonoID), 0) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos")
    new_abono_id = int(cursor.fetchone()[0]) + 1
    
    cursor.execute("""
        INSERT INTO EnterpriseAdmin_AMC.dbo.CxP_Abonos (
            AbonoID, NumeroD, CodProv, FechaAbono, MontoBsAbonado, MontoUsdAbonado, 
            TasaCambioDiaAbono, AplicaIndexacion, Referencia, 
            FechaRegistro, RutaComprobante, NotificarCorreo, TipoAbono
        ) VALUES (
            ?, ?, ?, GETDATE(), ?, 0, 
            1, 0, 'SYNC_SAINT_MASIVO', 
            GETDATE(), '', 0, 'PAGO_MASIVO_SAINT'
        )
    """, (new_abono_id, invoice, prov, monto))
    
    conn.commit()
    print(f"Abono de conciliación insertado para la factura {invoice}.")

except Exception as e:
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
