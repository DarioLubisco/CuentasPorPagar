CREATE OR ALTER VIEW dbo.CUSTOM_Utilidad_Venta_Dario
AS
WITH DolartodayCTE AS (
    SELECT CONVERT(DATE, fecha) AS Fecha, dolarbcv
    FROM dbo.dolartoday
)
SELECT
    Doc.TipoFac AS TipoDoc,
    Item.NumeroD AS NroFactDevol,
    CASE WHEN Doc.TipoFac = 'B' THEN Doc.NumeroR ELSE '0' END AS NroFactAsoc,
    Doc.CodVend,
    Vend.Descrip AS Vendedor,
    CASE WHEN Doc.TipoFac = 'A' THEN CONVERT(VARCHAR, Doc.FechaE, 23) ELSE NULL END AS FechaFact,
    CASE WHEN Doc.TipoFac = 'A' THEN CONVERT(VARCHAR, Doc.FechaE, 108) ELSE NULL END AS HoraFact,
    CASE WHEN Doc.TipoFac = 'B' THEN CONVERT(VARCHAR, Doc.FechaE, 23) ELSE NULL END AS FechaDevol,
    CASE WHEN Doc.TipoFac = 'B' THEN CONVERT(VARCHAR, Doc.FechaE, 108) ELSE NULL END AS HoraDevol,
    Doc.CodClie,
    Doc.Descrip AS Cliente,
    
    Item.CodItem,
    Item.Descrip1 AS DescripcionItem,
    Item.Cantidad,
    
    Doc.Factor,
    
    CalcBs.Costo_Bs,
    CalcBs.Monto_Bs,
    
    ROUND(CalcBs.Costo_Bs / NULLIF(LoteRate.dolarbcv, 0), 4) AS Costo_$,
    ROUND(Calc.Monto_$, 4) AS Monto_$,
    
    ROUND(
        (Calc.Monto_$ - ROUND(CalcBs.Costo_Bs / NULLIF(LoteRate.dolarbcv, 0), 4)) / NULLIF(Calc.Monto_$, 0),
        4
    ) AS Margen_$,
    
    ROUND(
        (CalcBs.Monto_Bs - CalcBs.Costo_Bs) / NULLIF(CalcBs.Monto_Bs, 0),
        4
    ) AS Margen_Bs,
    
    ItemRate.dolarbcv AS FactorC

FROM dbo.SAITEMFAC AS Item
INNER JOIN dbo.SAFACT AS Doc ON Item.NumeroD = Doc.NumeroD AND Item.TipoFac = Doc.TipoFac
INNER JOIN dbo.SAVEND AS Vend ON Doc.CodVend = Vend.CodVend
OUTER APPLY (
    SELECT TOP 1 L.FechaE
    FROM dbo.SALOTE AS L
    WHERE (Item.NroUnicoL > 0 AND L.NroUnico = Item.NroUnicoL)
       OR (Item.NroUnicoL <= 0 AND Item.NroLote != '' AND L.NroLote = Item.NroLote AND L.CodProd = Item.CodItem)
    ORDER BY L.NroUnico DESC
) AS Lote
CROSS APPLY (
    SELECT 
        CAST(CASE WHEN Item.TipoFac = 'B' THEN -1 ELSE 1 END AS DECIMAL(18,4)) AS SignoMultiplier
) AS Cfg
CROSS APPLY (
    SELECT
        Item.TotalItem * Cfg.SignoMultiplier AS Monto_Bs,
        Item.Cantidad * Item.Costo AS Costo_Bs
) AS CalcBs
OUTER APPLY (
    SELECT TOP 1 dolarbcv
    FROM DolartodayCTE
    WHERE Fecha = CONVERT(DATE, Doc.FechaE)
) AS DocRate
CROSS APPLY (
    SELECT
        CASE 
            WHEN Doc.Factor > 0 THEN CalcBs.Monto_Bs / Doc.Factor
            ELSE CalcBs.Monto_Bs / NULLIF(DocRate.dolarbcv, 0)
        END AS Monto_$
) AS Calc
OUTER APPLY (
    SELECT TOP 1 dolarbcv
    FROM DolartodayCTE
    WHERE Fecha = CONVERT(DATE, COALESCE(Lote.FechaE, Item.FechaL))
) AS LoteRate
OUTER APPLY (
    SELECT TOP 1 dolarbcv
    FROM DolartodayCTE
    WHERE Fecha = CONVERT(DATE, Item.FechaL)
) AS ItemRate
WHERE Doc.TipoFac IN ('A', 'B')
  AND Doc.FechaE >= DATEADD(DAY, -365, GETDATE());
GO
