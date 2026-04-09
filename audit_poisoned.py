import database
import decimal

def check_poisoned_balances():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    print("--- DETECTANDO SALDOS ENVENENADOS (NEGATIVOS O INCOHERENTES) ---")
    
    # 1. Facturas con Saldo Negativo (Causa principal de $0.00 fantasma)
    query_neg = """
    SELECT NumeroD, CodProv, Saldo, Monto, TipoCxP, FechaE 
    FROM EnterpriseAdmin_AMC.dbo.SAACXP 
    WHERE Saldo < -0.1 AND Saldo <> 0
    ORDER BY FechaE DESC
    """
    cursor.execute(query_neg)
    neg_rows = cursor.fetchall()
    
    print(f"\n[!] Documentos con Saldo NEGATIVO ({len(neg_rows)} encontrados):")
    for row in neg_rows:
        print(f"Factura: {row.NumeroD} | Prov: {row.CodProv} | Saldo: {row.Saldo} | Monto Orig: {row.Monto} | Tipo: {row.TipoCxP}")

    # 2. Descalce entre SACOMP y SAACXP (Donde la suma de lo que cree Saint Compra no coincide con Saint CxP)
    # Sumamos SAACXP por NumeroD para comparar con SACOMP.SaldoAct
    query_match = """
    SELECT c.NumeroD, c.CodProv, c.SaldoAct AS Saldo_SACOMP, SUM(x.Saldo) AS SaldoSum_SAACXP, c.MtoTotal
    FROM EnterpriseAdmin_AMC.dbo.SACOMP c
    JOIN EnterpriseAdmin_AMC.dbo.SAACXP x ON c.NumeroD = x.NumeroD AND c.CodProv = x.CodProv
    WHERE c.TipoCom = 'H'
    GROUP BY c.NumeroD, c.CodProv, c.SaldoAct, c.MtoTotal
    HAVING ABS(c.SaldoAct - SUM(x.Saldo)) > 0.5
    """
    cursor.execute(query_match)
    mismatch_rows = cursor.fetchall()
    
    print(f"\n[!] Descalces entre SACOMP y SAACXP ({len(mismatch_rows)} encontrados):")
    for row in mismatch_rows:
        print(f"Factura: {row.NumeroD} | Prov: {row.CodProv} | SACOMP: {row.Saldo_SACOMP} | SAACXP_Sum: {row.SaldoSum_SAACXP} | Total: {row.MtoTotal}")

    # 3. Facturas que el Portal marcaría como PAGADAS pero tienen Saldo (Posible envenenamiento inverso)
    # Esto es más difícil de detectar sin la lógica de CxP_Abonos, pero buscaremos saldos que superen el monto original.
    query_over = """
    SELECT NumeroD, CodProv, Saldo, Monto, TipoCxP
    FROM EnterpriseAdmin_AMC.dbo.SAACXP
    WHERE Saldo > Monto + 1.0 AND TipoCxP = '10'
    """
    cursor.execute(query_over)
    over_rows = cursor.fetchall()
    
    print(f"\n[!] Documentos con Saldo MAYOR al Monto Original ({len(over_rows)} encontrados):")
    for row in over_rows:
        print(f"Factura: {row.NumeroD} | Prov: {row.CodProv} | Saldo: {row.Saldo} | Monto: {row.Monto}")

    conn.close()

if __name__ == "__main__":
    check_poisoned_balances()
