import database

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    # Select all abonos from the massive batch on March 28th
    cursor.execute("""
        SELECT AbonoID, TipoAbono, MontoBsAbonado, NumeroD, CodProv 
        FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos 
        WHERE FechaAbono = '2026-03-28' AND Referencia = '' AND TipoAbono = 'PAGO'
    """)
    abonos_malos = cursor.fetchall()
    print(f"Encontrados {len(abonos_malos)} abonos masivos para revertir.")
    
    for row in abonos_malos:
        abono_id, tipo_abono, monto_bs, num_d, cod_prov = row
        monto_bs = float(monto_bs) if monto_bs else 0.0
        
        # Revert in SACOMP
        cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SACOMP WITH (ROWLOCK) SET MtoPagos = ISNULL(MtoPagos,0) - ?, SaldoAct = SaldoAct + ? WHERE NumeroD = ? AND CodProv = ?", (monto_bs, monto_bs, num_d, cod_prov))
        
        # Revert in SAACXP
        cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SAACXP WITH (ROWLOCK) SET Saldo = Saldo + ? WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'", (monto_bs, num_d, cod_prov))
        
        # Revert in SAPROV
        cursor.execute("UPDATE EnterpriseAdmin_AMC.dbo.SAPROV WITH (ROWLOCK) SET Saldo = Saldo + ? WHERE CodProv = ?", (monto_bs, cod_prov))
        
        # Delete Abono
        cursor.execute("DELETE FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE AbonoID = ?", (abono_id,))

    # Also check if any other negative balance remains and print them
    conn.commit()
    print("Limpieza masiva ejecutada con éxito (SACOMP, SAACXP, SAPROV, CxP_Abonos actualizados).")

    cursor.execute("""
        SELECT COUNT(*)
        FROM EnterpriseAdmin_AMC.dbo.SAACXP
        WHERE TipoCxP = '10' AND Saldo < 0
    """)
    leftover = cursor.fetchone()[0]
    print(f"Facturas que TODAVIA quedan con saldo negativo: {leftover}")
    
except Exception as e:
    if 'conn' in locals():
        conn.rollback()
    print("Error:", e)
finally:
    if 'conn' in locals():
        conn.close()
