import database

def inspect_financial_tables(inv_id, prov_id):
    conn = database.get_db_connection()
    cursor = conn.cursor()
    print(f"--- ANALYZING SAINT ERP MATHEMATICS FOR INVOICE {inv_id} ---")
    
    # Check SAACXP (Accounts Payable Master)
    print("\n1. SAACXP (Documentos de CxP):")
    cursor.execute("""
    SELECT NumeroD, TipoCxP, Document, Monto, Saldo, FechaE 
    FROM EnterpriseAdmin_AMC.dbo.SAACXP 
    WHERE NumeroD = ? AND CodProv = ?
    """, (inv_id, prov_id))
    for row in cursor.fetchall():
        print(row)

    # Check SACOMP (Purchases)
    print("\n2. SACOMP (Compras):")
    cursor.execute("""
    SELECT NumeroD, MtoTotal, MtoPagos, SaldoAct 
    FROM EnterpriseAdmin_AMC.dbo.SACOMP 
    WHERE NumeroD = ? AND CodProv = ?
    """, (inv_id, prov_id))
    for row in cursor.fetchall():
        print(row)

    # Check SAPAGCXP (Payment application details)
    print("\n3. SAPAGCXP (Detalle de pagos aplicados por documento):")
    cursor.execute("""
    SELECT NumPago, NumeroD, Monto 
    FROM EnterpriseAdmin_AMC.dbo.SAPAGCXP 
    WHERE NumeroD = ? AND CodProv = ?
    """, (inv_id, prov_id))
    rows = cursor.fetchall()
    if not rows:
        print("No se encontraron registros de pagos aplicados en SAPAGCXP para este documento.")
    for row in rows:
        print(row)

    conn.close()

if __name__ == "__main__":
    # Test with the Biogenetica invoice that is currently 'poisoned'
    inspect_financial_tables('00108152', 'J-305007020')
