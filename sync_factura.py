import database
import datetime
import sys

def sync_factura(numeroD):
    try:
        conn = database.get_db_connection()
        cursor = conn.cursor()
        
        print(f"\n--- [AUDITORÍA DE SINCRONIZACIÓN PARA FACTURA: {numeroD}] ---")
        
        # 1. Identificar Incongruencia para esa factura específica
        # Restamos también los descuentos base y de pronto pago aplicados
        cursor.execute("""
            SELECT 
                cxp.NumeroD, 
                cxp.CodProv, 
                cxp.Monto as Deuda_Total_Saint,
                cxp.CancelC as Pagado_Nativo,
                ISNULL(portal.TotalBsAfecta, 0) as Pagos_Caja_Portal,
                ISNULL(portal.TotalDsctos, 0) as Descuentos_Portal
            FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
            LEFT JOIN (
                SELECT 
                    NumeroD, 
                    CodProv, 
                    SUM(CASE WHEN TipoAbono NOT IN ('DESCUENTO', 'DESCUENTO_BASE') THEN MontoBsAbonado ELSE 0 END) as TotalBsAfecta,
                    SUM(CASE WHEN TipoAbono IN ('DESCUENTO', 'DESCUENTO_BASE') THEN MontoBsAbonado ELSE 0 END) as TotalDsctos
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
                GROUP BY NumeroD, CodProv
            ) portal ON cxp.NumeroD = portal.NumeroD AND cxp.CodProv = portal.CodProv
            WHERE cxp.NumeroD = ? AND cxp.TipoCxP = '10' 
        """, (numeroD,))
        
        row = cursor.fetchone()
        
        if not row:
            print("Factura no encontrada en SAACXP.")
            return

        codProv = row[1]
        monto_orig = float(row[2])
        cancelado_saint = float(row[3])
        pagos_efectivos = float(row[4])
        descuentos_portal = float(row[5])
        
        print(f"Factura: {numeroD} | Proveedor: {codProv}")
        print(f"-> Deuda Original (Saint): {monto_orig:,.2f} Bs")
        print(f"-> Saldo Cancelado (Saint): {cancelado_saint:,.2f} Bs")
        print(f"-> Pagos Efectivos (Portal): {pagos_efectivos:,.2f} Bs")
        print(f"-> Descuentos (Portal): {descuentos_portal:,.2f} Bs")
        
        if cancelado_saint < monto_orig - 0.1:
            # Factura tiene saldo pendiente en Saint
            diferencial_faltante = cancelado_saint - (pagos_efectivos + descuentos_portal)
        else:
            # Factura pagada en Saint
            diferencial_faltante = monto_orig - (pagos_efectivos + descuentos_portal)
        
        if abs(diferencial_faltante) <= 0.01:
            print("\n[x] La factura ya está en perfecto balance entre Saint y el Portal. No requiere sincronización.")
            return
            
        print(f"\n[!] CONFLICTO DETECTADO: Hay una diferencia de {abs(diferencial_faltante):,.2f} Bs.")
        print("¿Qué sistema tiene LA VERDAD ABSOLUTA para esta factura?")
        print("  [1] SAINT (Crear asientos faltantes en el Portal para igualar a Saint).")
        print("  [2] APLICACIÓN PORTAL (Eliminar abonos nativos en Saint para restaurar la deuda).")
        print("  [3] CANCELAR")
        
        eleccion = input("\nSeleccione opción [1, 2 o 3]: ").strip()
        
        if eleccion == '1':
            print(f"\n[+] RESOLVIENDO: Inyectando asiento espejo en el Portal por {diferencial_faltante:,.2f} Bs...")
            cursor.execute("SELECT ISNULL(MAX(AbonoID), 0) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WITH (UPDLOCK)")
            current_abono_id = int(cursor.fetchone()[0]) + 1
            
            cursor.execute("""
                INSERT INTO EnterpriseAdmin_AMC.dbo.CxP_Abonos (
                    AbonoID, NumeroD, CodProv, FechaAbono, MontoBsAbonado, MontoUsdAbonado, 
                    TasaCambioDiaAbono, AplicaIndexacion, Referencia, 
                    FechaRegistro, RutaComprobante, NotificarCorreo, TipoAbono
                ) VALUES (
                    ?, ?, ?, GETDATE(), ?, 0, 
                    1, 0, 'AUTO-SYNC: CIERRE DE DEUDA EN SAINT', 
                    GETDATE(), '', 0, 'PAGO_MASIVO_SAINT'
                )
            """, (current_abono_id, numeroD, codProv, diferencial_faltante))
            
            conn.commit()
            print("\n--- [ÉXITO: El Portal ha sido sincronizado para coincidir con Saint] ---")
            
        elif eleccion == '2':
            print("\n[+] RESOLVIENDO: Forzando a Saint a coincidir con el Portal...")
            
            # Borrar Pagos en Saint (TipoCxP '41' vinculados a esta factura)
            cursor.execute("""
                DELETE FROM EnterpriseAdmin_AMC.dbo.SAACXP 
                WHERE NumeroD = ? AND CodProv = ? AND TipoCxP IN ('41')
            """, (numeroD, codProv))
            pagos_borrados = cursor.rowcount
            print(f" -> {pagos_borrados} registros de pago (Tipo 41) eliminados en Saint.")
            
            # Restaurar Factura Principal (TipoCxP '10') en base a lo que dictan los abonos del Portal
            nuevo_cancelC = pagos_efectivos + descuentos_portal
            nuevo_saldo = monto_orig - nuevo_cancelC
            cursor.execute("""
                UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
                SET CancelC = ?, Saldo = ?
                WHERE NumeroD = ? AND CodProv = ? AND TipoCxP = '10'
            """, (nuevo_cancelC, nuevo_saldo, numeroD, codProv))
            
            # Restaurar Tabla de Compras (SACOMP)
            cursor.execute("""
                UPDATE EnterpriseAdmin_AMC.dbo.SACOMP 
                SET MtoPagos = ?
                WHERE NumeroD = ? AND CodProv = ? AND TipoCom = 'H'
            """, (nuevo_cancelC, numeroD, codProv))
            
            # Limpieza especial: Si el usuario había forzado una sincrónia hacia la app antes, se borra el espejo.
            cursor.execute("DELETE FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD=? AND CodProv=? AND TipoAbono='PAGO_MASIVO_SAINT'", (numeroD, codProv))
            if cursor.rowcount > 0:
                print(f" -> Se eliminaron {cursor.rowcount} asientos espejo antiguos en el Portal.")
                
            conn.commit()
            print("\n--- [ÉXITO: Saint ha sido restaurado a la matemática del Portal] ---")
        else:
            print("\nOperación cancelada.")

    except Exception as e:
        print("Error:", e)
        if 'conn' in locals():
            conn.rollback()
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python sync_factura.py <Numero_de_Factura>")
    else:
        sync_factura(sys.argv[1])
