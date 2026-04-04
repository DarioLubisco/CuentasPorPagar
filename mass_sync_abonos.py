import database
import datetime

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_table = f"EnterpriseAdmin_AMC.dbo.CxP_Abonos_BKP_{timestamp_str}"
    print(f"--- [PASO 1: RESPALDANDO TABLA CxP_Abonos] ---")
    
    # 1. Hacer Backup
    cursor.execute(f"SELECT * INTO {backup_table} FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos")
    print(f"Respaldo creado exitosamente: {backup_table}")

    # 2. Identificar Incongruencias
    print(f"\n--- [PASO 2: DETECTANDO INCONGRUENCIAS] ---")
    cursor.execute("""
        SELECT 
            cxp.NumeroD, 
            cxp.CodProv, 
            cxp.Monto,
            cxp.CancelC,
            ISNULL(portal.TotalBs, 0) as Pagos_Portal
        FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
        LEFT JOIN (
            SELECT NumeroD, CodProv, SUM(MontoBsAbonado) as TotalBs
            FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
            GROUP BY NumeroD, CodProv
        ) portal ON cxp.NumeroD = portal.NumeroD AND cxp.CodProv = portal.CodProv
        WHERE cxp.TipoCxP = '10' 
        AND (cxp.CancelC >= cxp.Monto - 0.1 OR cxp.Saldo <= 0) -- ESTA PAGADA O SOBREPAGADA EN SAINT
        AND ISNULL(portal.TotalBs, 0) < cxp.Monto - 0.1 -- PERO LE FALTA DINERO EN EL PORTAL WEB
    """)
    incongruencias = cursor.fetchall()
    
    if not incongruencias:
        print("No se encontraron facturas pendientes por sincronizar en el Portal Web.")
    else:
        print(f"Encontradas {len(incongruencias)} facturas que están pagadas nativamente pero huérfanas en la Web.")
        
        # Obtener el MAX(AbonoID) actual
        cursor.execute("SELECT ISNULL(MAX(AbonoID), 0) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WITH (UPDLOCK)")
        current_abono_id = int(cursor.fetchone()[0])
        
        count_synced = 0
        for row in incongruencias:
            numeroD = row[0]
            codProv = row[1]
            monto_orig = float(row[2])
            pagos_portal = float(row[4])
            
            diferencial_faltante = monto_orig - pagos_portal
            if diferencial_faltante > 0.01:
                current_abono_id += 1
                cursor.execute("""
                    INSERT INTO EnterpriseAdmin_AMC.dbo.CxP_Abonos (
                        AbonoID, NumeroD, CodProv, FechaAbono, MontoBsAbonado, MontoUsdAbonado, 
                        TasaCambioDiaAbono, AplicaIndexacion, Referencia, 
                        FechaRegistro, RutaComprobante, NotificarCorreo, TipoAbono
                    ) VALUES (
                        ?, ?, ?, GETDATE(), ?, 0, 
                        1, 0, 'SYNC_BKP_RESTAURACION', 
                        GETDATE(), '', 0, 'PAGO_MASIVO_SAINT'
                    )
                """, (current_abono_id, numeroD, codProv, diferencial_faltante))
                count_synced += 1
                
        conn.commit()
        print(f"\n--- [ÉXITO: {count_synced} facturas sincronizadas y eliminadas de Pendientes] ---")

except Exception as e:
    print("Error:", e)
    if 'conn' in locals():
        conn.rollback()
finally:
    if 'conn' in locals():
        conn.close()
