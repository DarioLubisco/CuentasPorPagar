import database
import datetime

conn = database.get_db_connection()
cursor = conn.cursor()

cursor.execute("DELETE FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE TipoAbono = 'AJUSTE' AND MotivoAjusteID = 2")
conn.commit()

cursor.execute("SELECT MotivoID FROM EnterpriseAdmin_AMC.Procurement.MotivosAjuste WHERE Codigo = '101'")
row_motivo = cursor.fetchone()
motivo_id = row_motivo[0] if row_motivo else None

query = """
SELECT 
    cxp.NumeroD, cxp.CodProv, cxp.FechaV, cxp.Monto, cxp.Saldo, cxp.CancelC,
    comp.MontoMEx, comp.Factor,
    ISNULL((SELECT SUM(MontoBsAbonado) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = cxp.NumeroD AND CodProv = cxp.CodProv AND TipoAbono != 'AJUSTE'), cxp.CancelC) as MtoPagosBs,
    ISNULL((SELECT SUM(MontoUsdAbonado) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = cxp.NumeroD AND CodProv = cxp.CodProv AND TipoAbono != 'AJUSTE'), 0) as MtoUsdPagado
FROM EnterpriseAdmin_AMC.dbo.SAACXP cxp
JOIN EnterpriseAdmin_AMC.dbo.SACOMP comp ON cxp.NumeroD = comp.NumeroD AND cxp.CodProv = comp.CodProv
WHERE cxp.TipoCxP = '10' AND comp.TipoCom = 'H'
  AND cxp.FechaV <= '2026-04-05'
"""
cursor.execute(query)
invoices = cursor.fetchall()

cursor.execute("SELECT ISNULL(MAX(AbonoID), 0) FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WITH (UPDLOCK)")
max_abono_id = int(cursor.fetchone()[0])

count_adjustments = 0

for inv in invoices:
    numero_d = inv[0]
    cod_prov = inv[1]
    fecha_v = inv[2]
    monto_usd = float(inv[6]) if inv[6] else 0.0
    mto_pagos_bs = float(inv[8]) if inv[8] else 0.0
    usd_pagado = float(inv[9]) if inv[9] else 0.0
    
    remaining_usd = monto_usd - usd_pagado

    cursor.execute("SELECT TOP 1 dolarbcv FROM EnterpriseAdmin_AMC.dbo.dolartoday WHERE CAST(fecha AS DATE) <= CAST(? AS DATE) ORDER BY fecha DESC", (fecha_v,))
    rate_row = cursor.fetchone()
    
    if not rate_row:
        cursor.execute("SELECT TOP 1 dolarbcv FROM EnterpriseAdmin_AMC.dbo.dolartoday ORDER BY fecha ASC")
        rate_row = cursor.fetchone()
    
    target_rate = float(rate_row[0]) if rate_row else 1.0

    deuda_hoy_bs = monto_usd * target_rate
    ajuste_bs = deuda_hoy_bs - mto_pagos_bs
    if ajuste_bs < 0:
        ajuste_bs = 0.0

    # Even if ajuste_bs == 0, if remaining_usd > 0, we MUST insert it to clear the USD portal debt!
    if remaining_usd > 0.01:
        max_abono_id += 1
        cursor.execute("""
            INSERT INTO EnterpriseAdmin_AMC.dbo.CxP_Abonos
            (AbonoID, NumeroD, CodProv, FechaAbono, MontoBsAbonado, MontoUsdAbonado, TipoAbono, MotivoAjusteID, TasaCambioDiaAbono, AplicaIndexacion, NotificarCorreo, AfectaSaldo)
            VALUES (?, ?, ?, GETDATE(), ?, ?, 'AJUSTE', ?, ?, 1, 0, 1)
        """, (max_abono_id, numero_d, cod_prov, ajuste_bs, remaining_usd, motivo_id, target_rate))
        count_adjustments += 1
        
    cursor.execute("""
        UPDATE EnterpriseAdmin_AMC.dbo.SAACXP
        SET CancelC = Monto, Saldo = 0
        WHERE CodProv = ? AND NumeroD = ? AND TipoCxP = '10'
    """, (cod_prov, numero_d))
    
    cursor.execute("""
        UPDATE EnterpriseAdmin_AMC.dbo.SACOMP
        SET MtoPagos = MtoTotal, SaldoAct = 0
        WHERE CodProv = ? AND NumeroD = ? AND TipoCom = 'H'
    """, (cod_prov, numero_d))

conn.commit()
print(f"Emulated Auto-Split Diferencial Cambiario for {len(invoices)} invoices.")
print(f"Generated {count_adjustments} local 'AJUSTE' records in CxP_Abonos to clear remaining USD.")
