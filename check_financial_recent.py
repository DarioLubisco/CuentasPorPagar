import database
from decimal import Decimal

def verify_financial_mathematics_recent():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    # Filter for documents from March 1st, 2026 to today
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
    SELECT TOP 30
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
      AND c.FechaUltimoDoc >= '2026-03-01'
    ORDER BY c.FechaUltimoDoc DESC
    """
    
    cursor.execute(query)
    rows = cursor.fetchall()
    
    # Print as a nice markdown table directly
    print("| Factura | Proveedor | Deuda Total | Abonado Saint | Saldo Real (Math) | Saldo Saint (ERP) | Fecha |")
    print("| :--- | :--- | :---: | :---: | :---: | :---: | :--- |")
    
    for row in rows:
        print(f"| {row.NumeroD} | {row.CodProv} | {row.Monto_Deuda:,.2f} | {row.Monto_Abonado:,.2f} | **{row.Saldo_Matematico_Real:,.2f}** | *{row.Saldo_Saint_Factura:,.2f}* | {row.FechaUltimoDoc.strftime('%d/%m/%Y')} |")
    
    conn.close()

if __name__ == "__main__":
    verify_financial_mathematics_recent()
