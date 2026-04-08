import pyodbc
from database import get_db_connection

conn = get_db_connection()
cursor = conn.cursor()

query = """
            SELECT 
                cxp.NumeroD, cxp.CodProv, cxp.Monto, cxp.Saldo, 
                cxp.FechaE, cxp.FechaV AS FechaVSaint,
                comp.FechaI, comp.Notas10,
                comp.TGravable, cxp.MtoTax,
                comp.Factor, comp.MontoMEx,
                ISNULL(cond.DiasNoIndexacion, 0) AS DiasNoIndexacion,
                ISNULL(cond.IndexaIVA, 1) AS IndexaIVA,
                ISNULL(cond.BaseDiasCredito, 'EMISION') AS BaseDiasCredito,
                ISNULL(cond.DiasVencimiento, prov.diascred) AS DiasVencimiento,
                ISNULL(cond.ProntoPago1_Dias, 0) AS ProntoPago1_Dias,
                ISNULL(cond.ProntoPago1_Pct, 0) AS ProntoPago1_Pct,
                ISNULL(cond.ProntoPago2_Dias, 0) AS ProntoPago2_Dias,
                ISNULL(cond.ProntoPago2_Pct, 0) AS ProntoPago2_Pct,
                prov.Descrip AS ProveedorNombre,
                prov.NumeroUP, prov.FechaUP, prov.MontoUP,
                dt_emision.dolarbcv AS TasaEmision,
                ISNULL(abonos.TotalUsdAbonado, 0) AS TotalUsdAbonado,
                ISNULL(abonos.TotalBsAbonado, 0) AS TotalBsAbonado,
                ISNULL(abonos.TotalIVA, 0) AS RetencionIvaAbonada,
                ISNULL(abonos.TotalISLR, 0) AS RetencionIslrAbonada,
                ISNULL(prov.PorctRet, 0) AS PorctRet,
                ISNULL(prov.EsReten, 0) AS EsReten,
                prov.ID3 AS RIF,
                -- Effective TipoPersona: LOCAL override wins, then SAINT (ID3 prefix), then NULL
                COALESCE(
                    cond.TipoPersona,
                    CASE WHEN LEFT(LTRIM(ISNULL(prov.ID3,'')),1) IN ('J','G','C') THEN 'PJ'
                         WHEN LEFT(LTRIM(ISNULL(prov.ID3,'')),1) IN ('V','E','P') THEN 'PN'
                         ELSE NULL END
                ) AS TipoPersona,
                cond.TipoPersona AS TipoPersonaLocal
            FROM dbo.SAACXP cxp
            LEFT JOIN dbo.SACOMP comp ON cxp.CodProv = comp.CodProv AND cxp.NumeroD = comp.NumeroD
            LEFT JOIN dbo.SAPROV prov ON cxp.CodProv = prov.CodProv
            LEFT JOIN EnterpriseAdmin_AMC.Procurement.ProveedorCondiciones cond ON cxp.CodProv = cond.CodProv
            OUTER APPLY (
                SELECT SUM(MontoUsdAbonado) as TotalUsdAbonado, SUM(MontoBsAbonado) as TotalBsAbonado,
                       SUM(CASE WHEN TipoAbono = 'RETENCION_IVA' THEN MontoBsAbonado ELSE 0 END) AS TotalIVA,
                       SUM(CASE WHEN TipoAbono = 'RETENCION_ISLR' THEN MontoBsAbonado ELSE 0 END) AS TotalISLR
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos
                WHERE CodProv = cxp.CodProv AND NumeroD = cxp.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(cxp.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            WHERE cxp.NumeroD = 'B0119408' AND cxp.TipoCxP = '10'
"""
try:
    cursor.execute(query)
    print("Success")
    # print(cursor.fetchall())
except Exception as e:
    print('Error executing query:')
    print(e)
