import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    # Select all invoices with negative balance
    cursor.execute("""
        SELECT NumeroD, CodProv 
        FROM EnterpriseAdmin_AMC.dbo.SAACXP 
        WHERE TipoCxP = '10' AND Saldo < 0
    """)
    broken = cursor.fetchall()
    print(f"Encontrados {len(broken)} facturas adicionales con Saldo negativo para reparar.")
    
    for row in broken:
        num_d, cod_prov = row[0], row[1]
        
        # Get total Abonos for this invoice
        cursor.execute("SELECT ISNULL(SUM(MontoBsAbonado),0) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = ? AND CodProv = ?", (num_d, cod_prov))
        total_abonos = float(cursor.fetchone()[0])
        
        if total_abonos > 0:
            # Revert in SACOMP
            cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SACOMP WITH (ROWLOCK) SET MtoPagos = ISNULL(MtoPagos,0) - ?, SaldoAct = SaldoAct + ? WHERE NumeroD = ? AND CodProv = ?", (total_abonos, total_abonos, num_d, cod_prov))
            
            # Revert in SAACXP
            cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SAACXP WITH (ROWLOCK) SET Saldo = Saldo + ? WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'", (total_abonos, num_d, cod_prov))
            
            # Revert in SAPROV
            cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SAPROV WITH (ROWLOCK) SET Saldo = Saldo + ? WHERE CodProv = ?", (total_abonos, cod_prov))
            
            # Delete Abonos
            cursor.execute("DELETE FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = ? AND CodProv = ?", (num_d, cod_prov))

    conn.commit()
    print("Reparación completa. Ya no debería haber facturas rotas.")

except Exception as e:
    if 'conn' in locals():
        conn.rollback()
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
