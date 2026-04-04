import database
import logging

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoices = ['64624180', '10723', '02816']
    
    for inv in invoices:
        print(f"Fixing {inv}...")
        
        # We assume 0 payments in CxP_Abonos because they were deleted
        cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SACOMP WITH (ROWLOCK) SET MtoPagos = 0, SaldoAct = MtoTotal WHERE NumeroD = ? AND TipoCom = 'H'", (inv,))
        
        # Restore SAACXP.Saldo to equal original Monto
        cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SAACXP WITH (ROWLOCK) SET Saldo = Monto WHERE NumeroD = ? AND TipoCxP = '10'", (inv,))
        
    conn.commit()
    print("Invoices restored to unpaid status successfully!")

except Exception as e:
    print(f"Error: {e}")
finally:
    if 'conn' in locals():
        conn.close()
