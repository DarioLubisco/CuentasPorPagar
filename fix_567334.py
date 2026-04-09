import database
conn = database.get_db_connection()
cursor = conn.cursor()

inv_id = '0567334'
prov = 'J-41200226-0'

print(f"--- Fixing Invoice {inv_id} ---")

# 1. Reset Saldo for the Invoice (Tipo 10)
print("Fixing SAACXP Invoice...")
cursor.execute("""
    UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
    SET Saldo = Monto 
    WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'
""", (inv_id, prov))
print(f"Rows affected (SAACXP 10): {cursor.rowcount}")

# 2. Reset Saldo for the related document (Tipo 41)
print("Fixing SAACXP Document 41...")
cursor.execute("""
    UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
    SET Saldo = Monto 
    WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '41'
""", (inv_id, prov))
print(f"Rows affected (SAACXP 41): {cursor.rowcount}")

# 3. Synchronize SACOMP
print("Synchronizing SACOMP...")
cursor.execute("""
    UPDATE EnterpriseAdmin_AMC.dbo.SACOMP 
    SET MtoPagos = 0, SaldoAct = MtoTotal 
    WHERE NumeroD = ? AND CodProv = ?
""", (inv_id, prov))
print(f"Rows affected (SACOMP): {cursor.rowcount}")

conn.commit()
print("\n--- Fix Completed and Committed ---")

# Verify
cursor.execute("SELECT NumeroD, Saldo, Monto, TipoCxP FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD = ? AND CodProv = ?", (inv_id, prov))
print("\nNew SAACXP State:")
for row in cursor.fetchall():
    print(row)
