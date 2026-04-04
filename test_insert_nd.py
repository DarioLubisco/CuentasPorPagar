import database
import uuid
import datetime

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    # 1. Simulate data
    inv_numeroD = '64700083' # Use the one we saw earlier
    cod_prov = 'J- 08518977-7'
    nd_numeroD = '99999'
    nd_control = '00-99999'
    surplus_amount = 0.0 # Just for the syntax test
    
    # 2. Get MAX NroUnico
    cursor.execute("SELECT ISNULL(MAX(NroUnico), 0) FROM EnterpriseAdmin_AMC.dbo.SAACXP")
    max_unico = cursor.fetchone()[0] + 1
    print("New NroUnico:", max_unico)
    
    # 3. Test insert SAACXP
    # We will wrap in a transaction and rollback just to test syntactic correctness
    cursor.execute("BEGIN TRANSACTION")
    
    cursor.execute("""
        INSERT INTO EnterpriseAdmin_AMC.dbo.SAACXP (
            CodSucu, CodProv, NroUnico, NroRegi, FechaI, FechaE, FechaT, FechaR, FechaV,
            CodEsta, CodUsua, CodOper, NumeroD, NumeroN, Monto, Saldo, TipoCxP,
            CancelC, CancelT, CancelG, CancelD, EsUnPago, EsReten, DetalChq, AfectaCom, Descrip)
        VALUES (
            '00000', ?, ?, 0, GETDATE(), GETDATE(), GETDATE(), GETDATE(), GETDATE(),
            '0', 'API', 'API', ?, ?, ?, 0, '20',
            ?, 0, 0, 0, 0, 0, '', 0, 'Nota de Debito por Indexacion'
        )
    """, (cod_prov, max_unico, nd_numeroD, nd_control, surplus_amount, surplus_amount))
    print("Inserted SAACXP successfully!")
    
    # 4. Test insert SACOMP
    cursor.execute("""
        INSERT INTO EnterpriseAdmin_AMC.dbo.SACOMP (
            CodSucu, NumeroD, CodProv, TipoCom, FechaI, FechaE, FechaV, FechaT,
            CodEsta, CodUsua, CodOper, MtoTotal, Contado, MtoPagos, Descrip,
            Factor, Tasa, MontoMEx)
        VALUES (
            '00000', ?, ?, 'J', GETDATE(), GETDATE(), GETDATE(), GETDATE(),
            '0', 'API', 'API', ?, 0, ?, 'ND Indexacion',
            1, 1, ?
        )
    """, (nd_numeroD, cod_prov, surplus_amount, surplus_amount, surplus_amount))
    print("Inserted SACOMP successfully!")
    
    cursor.execute("ROLLBACK")
    print("Rolled back! Syntax is correct.")
    
except Exception as e:
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
