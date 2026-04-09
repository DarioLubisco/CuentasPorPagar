import database
from decimal import Decimal

def verify_financial_mathematics():
    """
    Auditor de Coherencia Matemática Financiera para Cuentas por Pagar.
    Compara la deuda real (sumando facturas/notas de débito y restando
    abonos/notas de crédito) contra el saldo final registrado en Saint (SAACXP Tipo 10).
    """
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    print("--- INICIANDO AUDITORÍA MATEMÁTICA FINANCIERA (SAACXP) ---")
    
    # Esta consulta agrupa todos los documentos por NumeroD y CodProv, 
    # asumiendo que comparten NumeroD.
    # Nota: En Saint, a veces los pagos (81/41) tienen NroPpal diferente,
    # pero para los casos que vimos las compras estaban atadas al mismo NumeroD.
    query = """
    WITH CalculoReal AS (
        SELECT 
            NumeroD, 
            CodProv,
            SUM(CASE WHEN TipoCxP IN ('10', '20') THEN Monto ELSE 0 END) AS Monto_Deuda,
            SUM(CASE WHEN TipoCxP IN ('41', '81', '31') THEN Monto ELSE 0 END) AS Monto_Abonado,
            MAX(FechaE) AS FechaUltimoDoc
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        GROUP BY NumeroD, CodProv
    ),
    SaldosActuales AS (
        SELECT NumeroD, CodProv, Saldo AS Saldo_Saint_Factura, Monto AS Monto_Saint_Factura
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        WHERE TipoCxP = '10'
    )
    SELECT 
        c.NumeroD, 
        c.CodProv, 
        c.Monto_Deuda, 
        c.Monto_Abonado, 
        (c.Monto_Deuda - c.Monto_Abonado) AS Saldo_Matematico_Real,
        s.Saldo_Saint_Factura,
        c.FechaUltimoDoc
    FROM CalculoReal c
    JOIN SaldosActuales s ON c.NumeroD = s.NumeroD AND c.CodProv = s.CodProv
    WHERE ABS((c.Monto_Deuda - c.Monto_Abonado) - s.Saldo_Saint_Factura) > 0.5
      AND c.FechaUltimoDoc >= '2025-01-01'
    ORDER BY c.FechaUltimoDoc DESC
    """
    
    cursor.execute(query)
    incongruencias = cursor.fetchall()
    
    print(f"\n[!] ALERT: Se detectaron {len(incongruencias)} facturas con incongruencia matemática.\n")
    
    for row in incongruencias:
        print(f"Factura: {row.NumeroD:<15} | Prov: {row.CodProv:<15}")
        print(f"  -> Suma Deudas (Fact/ND): {row.Monto_Deuda:,.2f} Bs")
        print(f"  -> Suma Pagado (Abo/NC):  {row.Monto_Abonado:,.2f} Bs")
        print(f"  -> Saldo Debería Ser:     {row.Saldo_Matematico_Real:,.2f} Bs")
        print(f"  -> Saint Dice (Saldo):    {row.Saldo_Saint_Factura:,.2f} Bs")
        print("-" * 60)

    conn.close()

if __name__ == "__main__":
    verify_financial_mathematics()
