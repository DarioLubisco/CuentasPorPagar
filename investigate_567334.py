import database
conn = database.get_db_connection()
cursor = conn.cursor()

inv_id = '567334'
print(f"--- Investigating Invoice {inv_id} ---")

# Search in SAACXP
cursor.execute("SELECT NumeroD, CodProv, Saldo, Monto, FechaE, TipoCxP, NroUnico FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD LIKE ?", (f'%{inv_id}%',))
saacxp_rows = cursor.fetchall()
print("\nSAACXP Records:")
for row in saacxp_rows:
    print(row)

# Search in SACOMP
cursor.execute("SELECT NumeroD, CodProv, MtoTotal, Factor, MontoMEx, MtoPagos, SaldoAct, NroUnico FROM EnterpriseAdmin_AMC.dbo.SACOMP WHERE NumeroD LIKE ?", (f'%{inv_id}%',))
sacomp_rows = cursor.fetchall()
print("\nSACOMP Records:")
for row in sacomp_rows:
    print(row)

# Search in CxP_Abonos
cursor.execute("SELECT * FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD LIKE ?", (f'%{inv_id}%',))
abonos_rows = cursor.fetchall()
print("\nCxP_Abonos (Portal) Records:")
for row in abonos_rows:
    print(row)
