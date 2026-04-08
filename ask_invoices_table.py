import database

conn = database.get_db_connection()
cursor = conn.cursor()

query_invoices = """
SELECT NumeroD, Monto, FechaV 
FROM EnterpriseAdmin_AMC.dbo.SAACXP 
WHERE TipoCxP = '10' AND Saldo = 0 AND FechaV > GETDATE()
ORDER BY FechaV ASC
"""
cursor.execute(query_invoices)
invoices = cursor.fetchall()
inv_nums = [r.NumeroD for r in invoices]
inv_monto = {r.NumeroD: (r.Monto, r.FechaV.strftime('%Y-%m-%d')) for r in invoices}

if inv_nums:
    placeholders = ','.join('?' * len(inv_nums))
    query_abonos = f"""
    SELECT NumeroD, TipoAbono, MontoBsAbonado, MontoUsdAbonado, Referencia, FechaAbono
    FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
    WHERE NumeroD IN ({placeholders})
    """
    cursor.execute(query_abonos, inv_nums)
    abonos = cursor.fetchall()
    
    print("| Numero Fattura | Importo Originale | Scadenza | Tipo Abono | Importo BS | Importo USD | Referenza | Data Abono |")
    print("|---|---|---|---|---|---|---|---|")
    
    for inv in inv_nums:
        monto, fv = inv_monto[inv]
        inv_abonos = [a for a in abonos if a.NumeroD == inv]
        if not inv_abonos:
            print(f"| {inv} | {monto:,.2f} | {fv} | Pagata in Saint | - | - | - | - |")
        else:
            for a in inv_abonos:
                fa = getattr(a, 'FechaAbono', None)
                fa_str = fa.strftime('%Y-%m-%d') if hasattr(fa, 'strftime') else (fa or '-')
                ref = getattr(a, 'Referencia', '-')
                print(f"| {inv} | {monto:,.2f} | {fv} | {a.TipoAbono} | {getattr(a, 'MontoBsAbonado', 0):,.2f} | {getattr(a, 'MontoUsdAbonado', 0):,.2f} | {ref} | {fa_str} |")
