import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoice = '64700083'
    prov = 'J- 08518977-7'
    monto = 2884.15
    
    # 1. Revertir cambio local en Cxp_Abonos
    cursor.execute("""
        DELETE FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos 
        WHERE NumeroD = ? AND CodProv = ? AND TipoAbono = 'PAGO_MASIVO_SAINT'
    """, (invoice, prov))
    
    # 2. Revertir progreso nativo de Saint (devolver a cero pagos)
    cursor.execute("""
        UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
        SET CancelC = 0, Saldo = Monto
        WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'
    """, (invoice, prov))
    
    cursor.execute("""
        UPDATE EnterpriseAdmin_AMC.dbo.SACOMP 
        SET MtoPagos = 0
        WHERE NumeroD = ? AND CodProv = ? AND TipoCom = 'H'
    """, (invoice, prov))
    
    conn.commit()
    print(f"La factura {invoice} ha sido restaurada completamente al estado PENDIENTE.")

except Exception as e:
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
