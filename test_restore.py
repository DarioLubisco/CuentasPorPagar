import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    # 1. Test basic API query to see if it throws an error
    print("--- [TESTING MAIN API QUERY] ---")
    query = """
        SELECT TOP 10
            SACOMP.FechaI,
            SAPROV.Descrip,
            SAACXP.SaldoAct,
            SAACXP.Monto,
            (ISNULL(SACOMP.MtoTotal, SAACXP.Monto) - ISNULL(SACOMP.Contado, 0) - ISNULL(SACOMP.MtoPagos, 0)) AS Saldo,
            abonos.TotalBs AS TotalBsAbonado
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        OUTER APPLY (
            SELECT SUM(MontoBsAbonado) AS TotalBs
            FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
            WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
        ) abonos
        LEFT OUTER JOIN EnterpriseAdmin_AMC.dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
        LEFT OUTER JOIN EnterpriseAdmin_AMC.dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
        WHERE SAACXP.TipoCxP = '10'
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    print("API Query successful. Fetched", len(rows), "rows.")
    
    # 2. Check Negatives
    print("\n--- [CHECKING NEGATIVES] ---")
    cursor.execute("""
        SELECT NumeroD, CodProv, Monto, Saldo
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        WHERE TipoCxP = '10' AND Saldo < 0
    """)
    neg_saacxp = cursor.fetchall()
    print(f"Facturas en SAACXP con Saldo < 0: {len(neg_saacxp)}")
    
    cursor.execute("""
        SELECT COUNT(*)
        FROM EnterpriseAdmin_AMC.dbo.SACOMP 
        WHERE TipoCom = 'H' AND (MtoTotal - ISNULL(Contado, 0) - ISNULL(MtoPagos, 0)) < 0
    """)
    neg_sacomp = cursor.fetchone()[0]
    print(f"Facturas en SACOMP calculadas con Saldo < 0: {neg_sacomp}")

except Exception as e:
    print("ERROR DURING EXECUTION:", e)
finally:
    if 'conn' in locals():
        conn.close()
