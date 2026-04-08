import database

conn = database.get_db_connection()
cursor = conn.cursor()

query = """
SELECT NumeroD, CodProv, Monto, FechaV, FechaI, CodUsua, CodEsta 
FROM EnterpriseAdmin_AMC.dbo.SAACXP 
WHERE TipoCxP = '10' AND NumeroD = '58'
"""
cursor.execute(query)
row = cursor.fetchone()
if row:
    print(f"Factura: {row.NumeroD}")
    print(f"Proveedor: {row.CodProv}")
    print(f"Monto: {row.Monto}")
    print(f"Vencimiento: {row.FechaV}")
    print(f"Ingreso: {row.FechaI}")
    print(f"Usuario: {row.CodUsua}")
    print(f"Estacion: {row.CodEsta}")
else:
    print("No se encontró la factura con NumeroD = '58'")
