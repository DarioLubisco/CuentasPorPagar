import pyodbc
conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};Server=10.200.8.5\efficacis3;Database=EnterpriseAdmin_AMC;UID=sa;PWD=Twinc3pt.')
cursor = conn.cursor()
cursor.execute("IF COL_LENGTH('EnterpriseAdmin_AMC.Procurement.ProveedorCondiciones', 'DecimalesTasa') IS NULL BEGIN ALTER TABLE EnterpriseAdmin_AMC.Procurement.ProveedorCondiciones ADD DecimalesTasa INT NOT NULL DEFAULT 4; END")
conn.commit()
print('Success')
conn.close()
