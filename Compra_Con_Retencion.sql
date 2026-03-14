SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='1417'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='6971077610802') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1543.38 
ELSE ((CostPro*Existen)+9260.28)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=1543.38,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 18:40:28.390'
 WHERE (CodProd='6971077610802')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='6971077610802')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='6971077610802' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','6971077610802','AMR001',6.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','6971077610802','AMR001','1')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1543.38,Precio2=1543.38,Precio3=1543.38,Costo=1543.38,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='6971077610802') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1543.38,Precio2=1543.38,Precio3=1543.38
 WHERE (CodSucu='00000') And (CodProd='6971077610802') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='6971077610802') And 
                     (CodProv='J-41024423-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'6971077610802','J-41024423-2');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=1543.38,
       FechaE='2026-03-12',
       EsServ=0,
       Refere=''
 WHERE (TipoCom='H') And 
       (CodItem='6971077610802') And 
       (CodProv='J-41024423-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[CodUbic],[Descrip1],[Cantidad],[Costo],[MtoTax],[Precio1],[Precio2],[Precio3],[TotalItem],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-41024423-2','H',@NUMEROCOM,1,'2026-03-12 18:40:28.390','6971077610802','AMR001','KIT DE NEBULIZADOR ADULTO DIPHOCARE',6.00,1543.38,1481.642659,1543.38,1543.38,1543.38,9260.28,1,ISNULL(@NROUNICOLOT,0),'1','2026-03-12 18:40:28.390',@EXISTANTUND,@EXISTANT)
INSERT INTO SATAXITC ([CodSucu],[TipoCom],[NumeroD],[CodTaxs],[CodProv],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','H',@NUMEROCOM,'IVA','J-41024423-2','6971077610802',9260.28,16.00,1481.64,1)
-- ... (rest of items deleted for brevity in preview, actual file will have all) ...
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Contado],[Monto],[MtoTax],[RetenIVA],[TGravable],[TExento],[TotalPrd],[CodOper],[Credito])
       VALUES (1,'H','00000','LREYES','ADM-3',GETDATE(),'2026-03-12 18:40:28.390','2026-03-12 18:40:28.390','2026-03-20 18:40:28.390',@NUMEROCOM,'J-41024423-2','AMR001','SUMINISTROS PHARMA GLOBAL 446 C.A.',440.96,52.830778,'00-001417','J-41024423-2',26617.26,2490.75,23296.26,3321.00,2490.75,20756.28,2539.98,23296.26,'CXP',24126.51)
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[MtoTax],[OrgTax],[RetenIVA],[BaseImpo],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-41024423-2','1417','00-001417','LREYES','ADM-3','10','SUMINISTROS PHARMA GLOBAL 446 C.A.','J-41024423-2',GETDATE(),'1417 00-001417','2026-03-12 18:40:28.390','2026-03-12 18:40:28.390','2026-03-20 18:40:28.390',440.96,52.830778,54.713602,26617.26,23296.26,24126.51,24126.51,3321.00,3321.00,2490.75,20756.28,2539.98,1,'CXP')
EXEC SP_ADM_PROXCORREL '00000','','PrxRetenIVA',@NUMERORETIVA OUTPUT;
SET @NUMERORETIVA='202603'+@NUMERORETIVA
INSERT INTO SAACXP ([CodSucu],[NroRegi],@NroUnicoCxp,'81','J-41024423-2',@NUMERORETIVA,'1417','00-001417','LREYES','ADM-3','RET. IVA DOC.: 1417',GETDATE(),'2026-03-12 18:40:28.390','2026-03-12 18:40:28.390','2026-03-20 18:40:28.390',440.96,5.648472,2490.75,'SUMINISTROS PHARMA GLOBAL 446 C.A.','J-41024423-2','008',2490.75,20756.28,2539.98,3321.00,23296.26,1)
INSERT INTO SAPAGCXP ([CodSucu],[NroPpal],[NroRegi],[CodProv],[FechaE],[FechaO],[Monto],[Descrip],[TipoCxP],[NumeroD],[MontoDocA],[BaseReten],[CodRete],[EsReten])
       VALUES ('00000',@NROUNICORETIVA,@NroUnicoCxp,'J-41024423-2','2026-03-12 18:40:28.923','2026-03-12 18:40:28.390',2490.75,'Retencion de IVA','81',@NUMERORETIVA,23296.26,20756.28,'IVA',1)
COMMIT TRANSACTION;

-- Session: 54 | Start: 2026-03-12 18:44:46.393000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'IVERGOT%') OR (SP.DescripAll LIKE 'IVERGOT%') OR (SP.Refere LIKE 'IVERGOT%') OR (SP.Existen LIKE 'IVERGOT%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 36
GO

-- Session: 62 | Start: 2026-03-12 18:45:01.067000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 62 | Start: 2026-03-12 18:45:34.377000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 62 | Start: 2026-03-12 18:46:00.573000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 54 | Start: 2026-03-12 18:46:49.633000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 54 | Start: 2026-03-12 18:46:51.583000 | Status: runnable | Cmd: SELECT
create procedure sys.sp_tableswc
(
    @table_name         nvarchar(384)   = null,
    @table_owner        nvarchar(384)   = null,
    @table_qualifier    sysname = null,
    @table_type         varchar(100) = null,
    @fUsePattern        bit = 1, -- To allow users to explicitly disable all pattern matching.
    @fTableCreated      bit = 0  -- whether our caller created the table #sptableswc for us to insert into or we should create/drop it ourselves
)
as
    declare @databasename   sysname
    declare @qualprocname   nvarchar(142) -- 128 + '.sys.sp_tables'

    if (@fUsePattern = 1) -- Does the user want it?
    begin
        if ((@table_name is not null) and
            (@table_owner is not null) and
            (isnull(charindex('%', @table_name),0) = 0) and
            (isnull(charindex('_', @table_name),0) = 0) and
            (isnull(charindex('%', @table_owner),0) = 0) and
            (isnull(charindex('_', @table_owner),0) = 0))
        begin
             select @fUsePattern = 0 -- not a single wild char, so go the fast way.
        end
    end

    if @fTableCreated = 0
    begin
        create table #sptableswc
        (
            TABLE_QUALIFIER sysname collate catalog_default null,
            TABLE_OWNER sysname collate catalog_default null,
            TABLE_NAME sysname collate catalog_default null,
            TABLE_TYPE  varchar(32) collate catalog_default null,
            REMARKS varchar(254) collate catalog_default null
        )
    end

    if @fUsePattern = 0
    begin
        select @qualprocname = quotename(@table_qualifier) + '.sys.sp_tables'

        if object_id(@qualprocname) is null
        begin
            -- DB doesn't exist - request an empty resultset from current DB.
            select @qualprocname = 'sys.sp_tables'
            select @table_name = ' ' -- no tables with that name could possibly exist
        end

        /* -- Debug output, do not remove it.
        print '*************'
        print 'No pattern matching.'
        print @fUsePattern
        print isnull(@qualprocname, '@qualprocname = null')
        print isnull(@table_name, '@table_name = null')
        print isnull(@table_owner, '@table_owner = null')
        print isnull(@table_qualifier, '@table_qualifier = null')
        print isnull(@table_type, '@table_type = null')
        print '*************'
        */
        insert into #sptableswc exec @qualprocname @table_name, @table_owner, @table_qualifier, @table_type, @fUsePattern
    end
    else
    begin

        declare cursDB cursor local for
            select
                name
            from
                sys.databases d
            where
                d.name like @table_qualifier and
                d.name <> 'model' and
                has_dbaccess(d.name)=1
            for read only

        open cursDB

        fetch next from cursDB into @databasename
        while (@@FETCH_STATUS <> -1)
        begin
            if (charindex('%', @databasename) = 0)
            begin   -- Skip dbnames w/wildcard characters to prevent loop.
                select @qualprocname = quotename(@databasename) + '.sys.sp_tables'

                /* -- Debug output, do not remove it.
                print '*************'
                print 'THERE IS pattern matching!'
                print @fUsePattern
                print isnull(@qualprocname, '@qualprocname = null')
                print isnull(@table_name, '@table_name = null')
                print isnull(@table_owner, '@table_owner = null')
                print isnull(@databasename, '@databasename = null')
                print isnull(@table_type, '@table_type = null')
                print '*************'
                */
                insert into #sptableswc
                exec @qualprocname @table_name, @table_owner, @databasename, @table_type, @fUsePattern
            end
            fetch next from cursDB into @databasename
        end

        deallocate cursDB


    end

    if @fTableCreated = 0
    begin
        select
            *
        from
            #sptableswc
        order by 4, 1, 2, 3

        drop table #sptableswc
    end
GO

-- Session: 72 | Start: 2026-03-12 18:49:33.637000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 57 | Start: 2026-03-12 18:50:00.603000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 60 | Start: 2026-03-12 18:53:33.730000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 66 | Start: 2026-03-12 18:54:08.497000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 66 | Start: 2026-03-12 18:54:13.547000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ROSA%') OR (Descrip LIKE 'ROSA%') OR (ID3 LIKE 'ROSA%') OR (Clase LIKE 'ROSA%') OR (Saldo LIKE 'ROSA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 66 | Start: 2026-03-12 18:55:33.797000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 58 | Start: 2026-03-12 18:56:07.210000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select Fecha
     , Sum(VNeta) VNetas
     , sum(VImpuesto) VImpuestos
     , sum (VCredito) VCredito
     , sum(VContado) VContado
     , sum(VAdelanto) VAdelantos
     , sum(VCobros) VCobros
     , sum(VAdelanto)+sum(VCobros) VTotalIngreso
     , sum(VCosto) VCostos
     ,(Sum(VNeta)-sum(VCosto)) VUtilidad
     , Sum(NFact) NFact
     , Sum(NDev) NDev
  from
      (select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
            , sum(F.Monto_Neto) VNeta 
            , sum(F.MtoTax) VImpuesto
            , Sum(F.Credito) VCredito 
            , sum(F.Contado) VContado
            , sum(F.CancelA)VAdelanto
            , 0 VCobros
            , sum((F.CostoPrd+F.CostoSrv)) VCosto
            , sum(IIF(F.TipoFac = 'A',1,0)) NFact
            , sum(IIF(F.TipoFac = 'B',1,0)) NDev
          from vw_adm_facturas F 
               left join SACLIE C 
                      on F.CodClie = C.CodClie
          where (F.FechaE >= (CONVERT(DATETIME,'2026-03-12',120)+' 00:00:00') and F.FechaE<= (CONVERT(DATETIME,'2026-03-12',120)+ ' 23:59:59')) 
            and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),F.FechaE,112))
       union all
       select convert(datetime,convert(varchar(8),CXC.FechaE,112)) Fecha
            , 0,0,0,0,0,sum(Monto),0,0,0
         from SAACXC CXC 
              left join SACLIE C 
                     on CXC.CodClie = C.CodClie
         where (CXC.TipoCxc in (41))  And (CXC.EsUnPago=1)  
           and (CXC.FechaE>=(CONVERT(DATETIME,'2026-03-12',120)+' 00:00:00') and CXC.FechaE<=(CONVERT(DATETIME,'2026-03-12',120)+' 23:59:59')) 
           and (SUBSTRING(ISNULL(CXC.CODOPER,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodClie,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CODVEND,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodUsua,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),CXC.FechaE,112))) as Ventas
  group by Fecha
  order by Fecha
GO

-- Session: 58 | Start: 2026-03-12 18:56:07.733000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
     , (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) Tipo
     , Numerod Numero
     , F.CodClie Codigo
     , C.Descrip Cliente
     ,(F.Monto_Neto) VNeta
     , F.MtoTax VImpuesto
     , F.Credito VCredito 
     , F.Contado VContado
     , F.CancelA VAdelanto
     , 0 VCobros
     , (F.CostoPrd+F.CostoSrv) VCosto
     , (F.MontoTotal) VMtoTotal
  from VW_ADM_FACTURAS F 
       left join SACLIE C 
              on F.CodClie = C.CodClie
  where (F.FechaE >= CONVERT(DATETIME,'2026-03-12',120) and F.FechaE<= CONVERT(DATETIME,'2026-03-12',120)+ ' 23:59:59' ) 
    and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'')
	  and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
  order by convert(datetime,convert(varchar(8),F.FechaE,112)),
          (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) desc
GO

-- Session: 60 | Start: 2026-03-12 18:57:39.293000 | Status: running | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 59 | Start: 2026-03-12 18:59:34.900000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='CLODO' OR P.CodProd='CLODO')
GO

-- Session: 69 | Start: 2026-03-12 19:00:00.670000 | Status: suspended | Cmd: SELECT
declare 
@Invdia as decimal = (SELECT total_inv FROM CUSTOM_INVENTARIO_DIVISAS), 
@pro as real = (SELECT COSTO_PROMEDIO FROM CUSTOM_INVENTARIO_DIVISAS),
@uni as decimal = (SELECT TOTAL_UNIDADES FROM CUSTOM_INVENTARIO_DIVISAS)
insert costo_inventario_divisas values (@Invdia,@pro,@uni,GETDATE())
GO

-- Session: 70 | Start: 2026-03-12 19:00:00.673000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 69 | Start: 2026-03-12 19:00:34.227000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 70 | Start: 2026-03-12 19:00:34.230000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 69 | Start: 2026-03-12 19:01:34.443000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 59 | Start: 2026-03-12 19:02:47.563000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 64 | Start: 2026-03-12 19:04:37.140000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MARIA%') OR (Descrip LIKE 'MARIA%') OR (ID3 LIKE 'MARIA%') OR (Clase LIKE 'MARIA%') OR (Saldo LIKE 'MARIA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 19:04:40.197000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='ALERGO' OR P.CodProd='ALERGO')
GO

-- Session: 64 | Start: 2026-03-12 19:05:01.300000 | Status: suspended | Cmd: INSERT
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V1001087'
  ,@FACTORM      DECIMAL(28,4)=440.96
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-12 19:05:00.584','2026-03-12 19:05:00.756','2026-03-12 19:05:00.584',1,1,'V1001087','ADMBK02','22036825','22036825','AMR001','MARIA','CARACAS','V1001087',2618.82,2618.82,440.96,5.94,2618.82,2618.82,2618.82,2618.82);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1056683;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 19:05:00.818'
 WHERE (CodProd='7591821802957');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7591821802957') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591821802957','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7591821802957') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056683
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-12 19:05:00.849','7591821802957','2.4402','AMR001','NINAZO GTS ADLT X 15 ML',1.00,1.00,1049.55,1.00,1735.533,1735.533,3,1735.533,'22036825','22036825',1,1,'655',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-05 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056773;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 19:05:00.865'
 WHERE (CodProd='7591020005012');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7591020005012') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591020005012','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7591020005012') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056773
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,2,1,'2026-03-12 19:05:00.881','7591020005012','1.1618','AMR001','DUROVAL X 1',1.00,1.00,500.40,1.00,883.288,883.288,3,883.288,'22036825','22036825',1,1,'671',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-07 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=1549.95   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,2618.82,1.00,'2026-03-12 19:04:57.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 64 | Start: 2026-03-12 19:05:01.503000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 59 | Start: 2026-03-12 19:05:34.187000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 59 | Start: 2026-03-12 19:05:40.593000 | Status: running | Cmd: AWAITING COMMAND
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 61 | Start: 2026-03-12 19:10:00.730000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 64 | Start: 2026-03-12 19:10:18.797000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7597767001034') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-12 19:11:14.037000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 64 | Start: 2026-03-12 19:13:55.273000 | Status: runnable | Cmd: INSERT
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V1001087'
  ,@FACTORM      DECIMAL(28,4)=440.96
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-12 19:13:54.502','2026-03-12 19:13:54.674','2026-03-12 19:13:54.502',1,1,'V1001087','ADMBK02','22036825','22036825','AMR001','MARIA','CARACAS','V1001087',5747.80,5747.80,440.96,13.03,5747.80,5747.80,5747.80,5747.80);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1056353;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 19:13:54.752'
 WHERE (CodProd='7597767001034');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7597767001034') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597767001034','AMR001',-2.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7597767001034') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056353
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-2.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-12 19:13:54.783','7597767001034','2.5044','AMR001','SUEROLITO SABOR DE COCO 23.5GR X1 BALKER',2.00,1.00,1038.48,1.00,3562.388,1781.194,3,1781.194,'22036825','22036825',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-23 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056446;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 19:13:54.799'
 WHERE (CodProd='7597533001589');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7597533001589') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597533001589','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7597533001589') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056446
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,2,1,'2026-03-12 19:13:54.815','7597533001589','1.3769','AMR001','AMOXICILINA 500      MG TAB X 10',1.00,1.00,572.30,1.00,1046.824,1046.824,3,1046.824,'22036825','22036825',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-26 00:00:00.000','1899-12-29 00:00:00.000');
INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','7597533001589',1046.824,16.00,167.49,2);
SET @NROUNICOLOT=1047174;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 19:13:54.830'
 WHERE (CodProd='BLI_ACICLO_400M');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='BLI_ACICLO_400M') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','BLI_ACICLO_400M','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='BLI_ACICLO_400M') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1047174
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,3,1,'2026-03-12 19:13:54.861','BLI_ACICLO_400M','1.4976','AMR001','ACICLOVIR 400        MG X 10 TAB BRIXM',1.00,1.00,296.73,1.00,1138.589,1138.589,3,1138.589,'22036825','22036825',1,1,'58',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2025-10-24 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=2945.99   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,4000.00,1.00,'2026-03-12 00:00:00.000');
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,100.00,1.00,'2026-03-12 00:00:00.000');
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1647.80,1.00,'2026-03-12 00:00:00.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 64 | Start: 2026-03-12 19:14:37.567000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '7592616362014%') OR (SP.DESCRIPALL LIKE '7592616362014%') OR (SP.REFERE LIKE '7592616362014%') OR (SP.EXISTEN LIKE '7592616362014%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 60 | Start: 2026-03-12 19:15:00.300000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 64 | Start: 2026-03-12 19:16:47.060000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 19:16:48.977000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'CARMEN%') OR (Descrip LIKE 'CARMEN%') OR (ID3 LIKE 'CARMEN%') OR (Clase LIKE 'CARMEN%') OR (Saldo LIKE 'CARMEN%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 58 | Start: 2026-03-12 19:17:43.350000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 67 | Start: 2026-03-12 19:22:04.700000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 67 | Start: 2026-03-12 19:29:46.653000 | Status: suspended | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 67 | Start: 2026-03-12 19:30:00.833000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 69 | Start: 2026-03-12 19:30:00.837000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 67 | Start: 2026-03-12 19:30:40.920000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 64 | Start: 2026-03-12 19:33:54.617000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JUANA%') OR (Descrip LIKE 'JUANA%') OR (ID3 LIKE 'JUANA%') OR (Clase LIKE 'JUANA%') OR (Saldo LIKE 'JUANA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 19:34:08.033000 | Status: running | Cmd: SELECT
(@P1 varchar(15))SELECT *
  FROM SAIPRD IG WITH (NOLOCK)
 WHERE IG.CODPROD=@P1
GO

-- Session: 64 | Start: 2026-03-12 19:38:55.363000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'BRUNO%') OR (Descrip LIKE 'BRUNO%') OR (ID3 LIKE 'BRUNO%') OR (Clase LIKE 'BRUNO%') OR (Saldo LIKE 'BRUNO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 59 | Start: 2026-03-12 19:45:00.473000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 54 | Start: 2026-03-12 19:49:38.330000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 64 | Start: 2026-03-12 19:49:44.140000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.EXISTEN ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'AZITROMI%') OR (SP.DESCRIPALL LIKE 'AZITROMI%') OR (SP.REFERE LIKE 'AZITROMI%') OR (SP.EXISTEN LIKE 'AZITROMI%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 54 | Start: 2026-03-12 19:50:00.993000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 64 | Start: 2026-03-12 19:56:04.657000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='ALKA' OR P.CodProd='ALKA')
GO

-- Session: 64 | Start: 2026-03-12 19:56:07.957000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='BLI_ALKASE' OR P.CodProd='BLI_ALKASE')
GO

-- Session: 64 | Start: 2026-03-12 19:58:12.633000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591196006097') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 64 | Start: 2026-03-12 19:58:44.253000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='DIAPOST' OR P.CodProd='DIAPOST')
GO

-- Session: 64 | Start: 2026-03-12 19:58:46.283000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='8906005119292') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 64 | Start: 2026-03-12 19:58:53.317000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='LORATADINA' OR P.CodProd='LORATADINA')
GO

-- Session: 63 | Start: 2026-03-12 20:00:00.907000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_requested_date]
    @session_id               INT,
    @job_id                   UNIQUEIDENTIFIER,
    @is_system             TINYINT = 0,
    @run_requested_source_id  TINYINT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

    -- update sysjobactivity for user jobs
    UPDATE [msdb].[dbo].[sysjobactivity]
    SET run_requested_date = DATEADD(ms, -DATEPART(ms, GETDATE()),  GETDATE()),
        run_requested_source = CONVERT(SYSNAME, @run_requested_source_id),
        queued_date = NULL,
        start_execution_date = NULL,
        last_executed_step_id = NULL,
        last_executed_step_date = NULL,
        stop_execution_date = NULL,
        job_history_id = NULL,
        next_scheduled_run_date = NULL
    WHERE job_id = @job_id
    AND session_id = @session_id
END
GO

-- Session: 67 | Start: 2026-03-12 20:00:00.990000 | Status: suspended | Cmd: INSERT
CREATE PROCEDURE [dbo].[UpdateRotacion]
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpia cualquier tabla temporal que haya quedado de una ejecución anterior fallida.
    IF OBJECT_ID('tempdb..#CalculatedRotation') IS NOT NULL
        DROP TABLE #CalculatedRotation;

    -- Verifica si la columna RotacionMensual existe en la tabla de destino y la agrega si no.
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'RotacionMensual' AND Object_ID = Object_ID('Procurement.Rotacion'))
    BEGIN
        ALTER TABLE Procurement.Rotacion ADD RotacionMensual DECIMAL(38, 6) NULL;
    END

    DECLARE @Today DATE = GETDATE();
    DECLARE @StartDate DATETIME = DATEADD(DAY, -539, @Today);

    CREATE TABLE #CalculatedRotation (
        CodItem VARCHAR(15) PRIMARY KEY, NumeroD VARCHAR(20), TotalVenta DECIMAL(38, 4), Signo SMALLINT, FechaT DATETIME, Descrip VARCHAR(40),
        RotacionMensual DECIMAL(38, 6), -- Nueva columna para el cálculo ponderado
        dias_1_30 DECIMAL(38, 6), dias_31_60 DECIMAL(38, 6), dias_61_90 DECIMAL(38, 6), dias_91_120 DECIMAL(38, 6), dias_121_150 DECIMAL(38, 6), dias_151_180 DECIMAL(38, 6),
        dias_181_210 DECIMAL(38, 6), dias_211_240 DECIMAL(38, 6), dias_241_270 DECIMAL(38, 6), dias_271_300 DECIMAL(38, 6), dias_301_330 DECIMAL(38, 6), dias_331_360 DECIMAL(38, 6),
        dias_361_390 DECIMAL(38, 6), dias_391_420 DECIMAL(38, 6), dias_421_450 DECIMAL(38, 6), dias_451_480 DECIMAL(38, 6), dias_481_510 DECIMAL(38, 6), dias_511_540 DECIMAL(38, 6)
    );

    BEGIN TRY
        -- Paso 1: Calcular las ventas y la rotación ponderada.
        INSERT INTO #CalculatedRotation
        SELECT
            LTRIM(RTRIM(sif.CodItem)),
            MAX(sif.NumeroD),
            SUM(sif.Signo * sif.Cantidad),
            MAX(sif.Signo),
            MAX(sf.FechaT),
            MAX(sp.Descrip),

            -- Cálculo de la RotacionMensual Ponderada
            (
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -29, @Today) AND @Today THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 1) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -59, @Today) AND DATEADD(DAY, -30, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 2) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -89, @Today) AND DATEADD(DAY, -60, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 3) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -119, @Today) AND DATEADD(DAY, -90, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 4) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -149, @Today) AND DATEADD(DAY, -120, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 5) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -179, @Today) AND DATEADD(DAY, -150, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 6) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -209, @Today) AND DATEADD(DAY, -180, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 7) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -239, @Today) AND DATEADD(DAY, -210, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 8) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -269, @Today) AND DATEADD(DAY, -240, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 9) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -299, @Today) AND DATEADD(DAY, -270, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 10) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -329, @Today) AND DATEADD(DAY, -300, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 11) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -359, @Today) AND DATEADD(DAY, -330, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 12) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -389, @Today) AND DATEADD(DAY, -360, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 13) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -419, @Today) AND DATEADD(DAY, -390, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 14) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -449, @Today) AND DATEADD(DAY, -420, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 15) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -479, @Today) AND DATEADD(DAY, -450, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 16) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -509, @Today) AND DATEADD(DAY, -480, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 17) +
                SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -539, @Today) AND DATEADD(DAY, -510, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END) * (SELECT FactorPonderacion FROM Procurement.Distribucion_Rotacion WHERE Periodo = 18)
            ) / 100.0,

            -- Ventas por cada período (para mantener el detalle)
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -29, @Today) AND @Today THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -59, @Today) AND DATEADD(DAY, -30, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -89, @Today) AND DATEADD(DAY, -60, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -119, @Today) AND DATEADD(DAY, -90, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -149, @Today) AND DATEADD(DAY, -120, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -179, @Today) AND DATEADD(DAY, -150, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -209, @Today) AND DATEADD(DAY, -180, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -239, @Today) AND DATEADD(DAY, -210, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -269, @Today) AND DATEADD(DAY, -240, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -299, @Today) AND DATEADD(DAY, -270, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -329, @Today) AND DATEADD(DAY, -300, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -359, @Today) AND DATEADD(DAY, -330, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -389, @Today) AND DATEADD(DAY, -360, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -419, @Today) AND DATEADD(DAY, -390, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -449, @Today) AND DATEADD(DAY, -420, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -479, @Today) AND DATEADD(DAY, -450, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -509, @Today) AND DATEADD(DAY, -480, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END),
            SUM(CASE WHEN CAST(sf.FechaT AS DATE) BETWEEN DATEADD(DAY, -539, @Today) AND DATEADD(DAY, -510, @Today) THEN sif.Signo * sif.Cantidad ELSE 0 END)
        FROM [dbo].[SAFACT] AS sf
        INNER JOIN [dbo].[SAITEMFAC] AS sif ON sf.CodSucu = sif.CodSucu AND sf.NumeroD = sif.NumeroD
        LEFT JOIN [dbo].[SAPROD] AS sp ON LTRIM(RTRIM(sif.CodItem)) = LTRIM(RTRIM(sp.CodProd))
        WHERE sf.FechaT >= @StartDate AND sif.CodItem IS NOT NULL
        GROUP BY LTRIM(RTRIM(sif.CodItem));

        PRINT 'Paso 1: Se calcularon ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas en la tabla temporal.';

        -- Paso 2.1: Actualizar los registros que ya existen.
        UPDATE Target
        SET
            Target.NumeroD = Source.NumeroD, Target.TotalVenta = Source.TotalVenta, Target.Signo = Source.Signo, Target.FechaT = Source.FechaT, Target.Descrip1 = Source.Descrip,
            Target.RotacionMensual = Source.RotacionMensual, -- Actualizar con el nuevo cálculo ponderado
            Target.dias_1_30 = Source.dias_1_30, Target.dias_31_60 = Source.dias_31_60, Target.dias_61_90 = Source.dias_61_90, Target.dias_91_120 = Source.dias_91_120,
            Target.dias_121_150 = Source.dias_121_150, Target.dias_151_180 = Source.dias_151_180, Target.dias_181_210 = Source.dias_181_210, Target.dias_211_240 = Source.dias_211_240,
            Target.dias_241_270 = Source.dias_241_270, Target.dias_271_300 = Source.dias_271_300, Target.dias_301_330 = Source.dias_301_330, Target.dias_331_360 = Source.dias_331_360,
            Target.dias_361_390 = Source.dias_361_390, Target.dias_391_420 = Source.dias_391_420, Target.dias_421_450 = Source.dias_421_450, Target.dias_451_480 = Source.dias_451_480,
            Target.dias_481_510 = Source.dias_481_510, Target.dias_511_540 = Source.dias_511_540, Target.UltimaActualizacion = GETDATE()
        FROM [EnterpriseAdmin_AMC].[Procurement].[Rotacion] AS Target
        INNER JOIN #CalculatedRotation AS Source ON Target.CodItem = Source.CodItem;

        PRINT 'Paso 2.1: Se actualizaron ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas existentes.';

        -- Paso 2.2: Insertar los nuevos registros que no existen.
        INSERT INTO [EnterpriseAdmin_AMC].[Procurement].[Rotacion] (
            CodItem, NumeroD, TotalVenta, Signo, FechaT, Descrip1, RotacionMensual,
            dias_1_30, dias_31_60, dias_61_90, dias_91_120, dias_121_150, dias_151_180,
            dias_181_210, dias_211_240, dias_241_270, dias_271_300, dias_301_330, dias_331_360,
            dias_361_390, dias_391_420, dias_421_450, dias_451_480, dias_481_510, dias_511_540
        )
        SELECT
            Source.CodItem, Source.NumeroD, Source.TotalVenta, Source.Signo, Source.FechaT, Source.Descrip, Source.RotacionMensual,
            Source.dias_1_30, Source.dias_31_60, Source.dias_61_90, Source.dias_91_120, Source.dias_121_150, Source.dias_151_180,
            Source.dias_181_210, Source.dias_211_240, Source.dias_241_270, Source.dias_271_300, Source.dias_301_330, Source.dias_331_360,
            Source.dias_361_390, Source.dias_391_420, Source.dias_421_450, Source.dias_451_480, Source.dias_481_510, Source.dias_511_540
        FROM #CalculatedRotation AS Source
        WHERE NOT EXISTS (SELECT 1 FROM [EnterpriseAdmin_AMC].[Procurement].[Rotacion] AS Target WHERE Target.CodItem = Source.CodItem);

        PRINT 'Paso 2.2: Se insertaron ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas nuevas.';

        -- Paso 3: Actualizar los niveles de stock en SAPROD usando la nueva rotación ponderada.
        UPDATE sp
        SET
            sp.Maximo = cr.RotacionMensual,
            sp.Minimo = cr.RotacionMensual * 0.7
        FROM dbo.SAPROD AS sp
        INNER JOIN #CalculatedRotation AS cr ON sp.CodProd = cr.CodItem
        WHERE cr.RotacionMensual > 0;

        PRINT 'Paso 3: Se actualizaron los niveles de stock para ' + CAST(@@ROWCOUNT AS VARCHAR) + ' productos en SAPROD.';

    END TRY
    BEGIN CATCH
        INSERT INTO Procurement.Rotacion_ErrorLog (ErrorMessage, ErrorLine, ErrorProcedure, ErrorTime)
        VALUES (ERROR_MESSAGE(), ERROR_LINE(), ERROR_PROCEDURE(), GETDATE());
        PRINT 'ERROR: Se ha producido un error. Revise la tabla Procurement.Rotacion_ErrorLog para más detalles.';
        THROW;
    END CATCH;

    IF OBJECT_ID('tempdb..#CalculatedRotation') IS NOT NULL 
        DROP TABLE #CalculatedRotation;

END
GO

-- Session: 67 | Start: 2026-03-12 20:00:02.457000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_job_completion_state]
    @job_id               UNIQUEIDENTIFIER,
    @last_run_outcome     TINYINT,
    @last_outcome_message NVARCHAR(4000),
    @last_run_date        INT,
    @last_run_time        INT,
    @last_run_duration    INT
AS
BEGIN
    -- Update last run date, time for specific job_id in local server
    UPDATE msdb.dbo.sysjobservers
    SET last_run_outcome =  @last_run_outcome,
        last_outcome_message = @last_outcome_message,
        last_run_date = @last_run_date,
        last_run_time = @last_run_time,
        last_run_duration = @last_run_duration
    WHERE job_id  = @job_id
    AND server_id = 0
END
GO

-- Session: 64 | Start: 2026-03-12 20:01:13.827000 | Status: running | Cmd: SELECT
SELECT SAFACT.AutSRI, SAFACT.Cambio, 
       SAFACT.CancelA, SAFACT.CancelC, 
       SAFACT.CancelE, SAFACT.CancelG, 
       SAFACT.CancelI, SAFACT.CancelP, 
       SAFACT.CancelT, SAFACT.CancelTips, 
       SAFACT.CodClie, SAFACT.CodAlte, 
       SAFACT.CodConv, SAFACT.CodEsta, 
       SAFACT.CodOper, SAFACT.CodSucu, 
       SAFACT.CodUbic, SAFACT.CodUsua, 
       SAFACT.CodTarj, SAFACT.CodVend, 
       SAFACT.CodTran, SAFACT.Contado, 
       SAFACT.CostoPrd, SAFACT.CostoSrv, 
       SAFACT.Credito, SAFACT.Descrip, 
       SAFACT.Descto1, SAFACT.Descto2, 
       SAFACT.DesctoP, SAFACT.DetalChq, 
       SAFACT.Direc1, SAFACT.Direc2, 
       SAFACT.Direc3, SAFACT.EsCorrel, 
       SAFACT.Factor, SAFACT.FechaE, 
       SAFACT.FechaI, SAFACT.FechaR, 
       SAFACT.FechaV, SAFACT.Fletes, SAFACT.ID3, 
       SAFACT.Monto, SAFACT.MontoMEx, 
       SAFACT.MtoComiCob, SAFACT.MtoComiCobD, 
       SAFACT.MtoComiVta, SAFACT.MtoComiVtaD, 
       SAFACT.MtoExtra, SAFACT.MtoFinanc, 
       SAFACT.MtoInt1, SAFACT.MtoInt2, 
       SAFACT.MtoNCredito, SAFACT.MtoNDebito, 
       SAFACT.MtoPagos, SAFACT.MtoTax, 
       SAFACT.MtoTotal, SAFACT.NGiros, 
       SAFACT.NMeses, SAFACT.Notas1, 
       SAFACT.Notas10, SAFACT.Notas2, 
       SAFACT.Notas3, SAFACT.Notas4, 
       SAFACT.Notas5, SAFACT.Notas6, 
       SAFACT.Notas7, SAFACT.Notas8, 
       SAFACT.Notas9, SAFACT.NroCtrol, 
       SAFACT.NroEstable, SAFACT.NroUnico, 
       SAFACT.NumeroD, SAFACT.NumeroE, 
       SAFACT.NumeroF, SAFACT.NroTurno, 
       SAFACT.NumeroNCF, SAFACT.OrdenC, 
       SAFACT.NumeroP, SAFACT.NroUnicoL, 
       SAFACT.NumeroR, SAFACT.NumeroT, 
       SAFACT.NumeroZ, SAFACT.RetenIVA, 
       SAFACT.PctAnual, SAFACT.PctManejo, 
       SAFACT.PtoEmision, SAFACT.NumeroU, 
       SAFACT.SaldoAct, SAFACT.Signo, 
       SAFACT.Telef, SAFACT.Parcial, 
       SAFACT.TExento, SAFACT.TGravable, 
       SAFACT.TipoFac, SAFACT.TipoTraE, 
       SAFACT.TotalPrd, SAFACT.TotalSrv, 
       SAFACT.ValorPtos, SAFACT.ZipCode, 
       SAVEND.Activo, SAVEND.Clase, 
       SAVEND.Descrip Descrip_2, 
       SAFACT.TGravable0, 
       SAVEND.CodVend CodVend_2, SAFACT.TipoDev, 
       SAVEND.Direc1 Direc1_2, 
       SACONV.Descrip Descrip_3, 
       SAVEND.Direc2 Direc2_2, SAVEND.Email, 
       SAVEND.FechaUC, SAVEND.FechaUV, 
       SAVEND.ID3 ID3_2, SAVEND.Movil, 
       SAVEND.Telef Telef_2, SAVEND.TipoID, 
       SAVEND.TipoID3, SACLIE.Activo Activo_2, 
       SACLIE.Ciudad, SACLIE.Clase Clase_2, 
       SACLIE.CodAlte CodAlte_2, 
       SACLIE.CodClie CodClie_2, 
       SACLIE.CodConv CodConv_2, 
       SACLIE.CodVend CodVend_3, SACLIE.CodZona, 
       SACLIE.Descrip Descrip_4, 
       SACLIE.DescripExt, SACLIE.Descto, 
       SACLIE.DiasCred, SACLIE.DiasTole, 
       SACLIE.Direc1 Direc1_3, 
       SACLIE.Direc2 Direc2_3, 
       SACLIE.Email Email_2, SACLIE.EsCredito, 
       SACLIE.EsMoneda, SACLIE.Estado, 
       SACLIE.EsToleran, SACLIE.Fax, 
       SACLIE.FechaE FechaE_2, SACLIE.FechaUP, 
       SACLIE.FechaUV FechaUV_2, 
       SACLIE.ID3 ID3_3, SACLIE.IntMora, 
       SACLIE.LimiteCred, SACLIE.MontoMax, 
       SACLIE.EsReten, SACLIE.MontoUP, 
       SACLIE.MontoUV, SACLIE.Movil Movil_2, 
       SACLIE.MtoMaxCred, SACLIE.Municipio, 
       SACLIE.NumeroUP, SACLIE.NumeroUV, 
       SACLIE.Observa, SACLIE.PagosA, 
       SACLIE.Pais, SACLIE.PromPago, 
       SACLIE.Represent, 
       SACLIE.RetenIVA RetenIVA_2, SACLIE.Saldo, 
       SACLIE.SaldoPtos, SACLIE.Telef Telef_3, 
       SACLIE.TipoCli, SACLIE.TipoID TipoID_2, 
       SACLIE.TipoID3 TipoID3_2, SACLIE.TipoPVP, 
       SACLIE.ZipCode ZipCode_2, 
       SACONV.Activo Activo_3, SACONV.Autori, 
       SACONV.CodConv CodConv_3, SACONV.EsFijo, 
       SACONV.FechaE FechaE_3, 
       SACONV.FechaV FechaV_2, SACONV.Respon, 
       SACONV.TipoCnv, SACLIE.TipoReg
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44358' )
GO

-- Session: 64 | Start: 2026-03-12 20:07:54.767000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 20:09:57.160000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MARCOS%') OR (Descrip LIKE 'MARCOS%') OR (ID3 LIKE 'MARCOS%') OR (Clase LIKE 'MARCOS%') OR (Saldo LIKE 'MARCOS%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 20:10:01.720000 | Status: runnable | Cmd: SET COMMAND
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'ACEITE%') OR (SP.DescripAll LIKE 'ACEITE%') OR (SP.Refere LIKE 'ACEITE%') OR (SP.Existen LIKE 'ACEITE%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 20:10:10.677000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY CodServ ASC) AS ROWNUM   FROM VW_ADM_SERVICIOS WITH (NOLOCK) 
  WHERE ((CodServ LIKE 'ACEITE%') OR (DescripAll LIKE 'ACEITE%') OR (Clase LIKE 'ACEITE%')) AND (ACTIVO=1) AND (EsVenta=1))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 15
GO

-- Session: 64 | Start: 2026-03-12 20:12:57.493000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'DICLOFEN%') OR (SP.DescripAll LIKE 'DICLOFEN%') OR (SP.Refere LIKE 'DICLOFEN%') OR (SP.Existen LIKE 'DICLOFEN%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 54 | Start: 2026-03-12 20:15:00.480000 | Status: running | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 54 | Start: 2026-03-12 20:17:41.453000 | Status: running | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 62 | Start: 2026-03-12 20:22:15.873000 | Status: running | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 69 | Start: 2026-03-12 20:30:00.207000 | Status: runnable | Cmd: UPDATE
CREATE PROCEDURE [dbo].[Maintenance]
AS
BEGIN
    SET NOCOUNT ON;


    -- Set Activo and EsOferta and UsaLotes and  DesLote to 1 where fechaUC is less than 550 days ago or Existen is greater than 0
    UPDATE EnterpriseAdmin_AMC.dbo.SAPROD
    SET Activo = 1,
        EsOferta = 1,
        DEsLote = 1
    WHERE DATEADD(day, -550, GETDATE()) < fechaUC OR Existen > 0;

    -- Set Activo and EsOferta to 0 where fechaUC is greater than or equal to 550 days ago and Existen is 0
    UPDATE EnterpriseAdmin_AMC.dbo.SAPROD
    SET Activo = 0,
        EsOferta = 1
    WHERE DATEADD(day, -550, GETDATE()) >= fechaUC AND Existen = 0;

  -- Set EsExento  to 1 where CodInst is equal  to "2"
    UPDATE EnterpriseAdmin_AMC.dbo.SAPROD
    SET  EsExento = 1
       
    WHERE CodInst LIKE 2;
END
GO

-- Session: 70 | Start: 2026-03-12 20:30:00.207000 | Status: suspended | Cmd: INSERT
CREATE PROCEDURE [dbo].[NPAE] AS
BEGIN
    WITH FF AS (
        SELECT 
            e.codbarras, 
            (SELECT STRING_AGG(f.descripcion, ', ') WITHIN GROUP (ORDER BY f.descripcion) 
             FROM (
                 SELECT DISTINCT descripcion 
                 FROM Procurement.ff 
                 WHERE codigo = e.Forma_farmaceutica
             ) f) AS FF_List
        FROM Procurement.equivalencias e
    )
    INSERT INTO [EnterpriseAdmin_AMC].[Procurement].[por_aprobacion_equivalencias] (descrip1art, codbarras, PA_Alter_FF)
    SELECT SAPROD.Descrip, SAPROD.CodProd, FF.FF_List
    FROM dbo.SAPROD
    LEFT OUTER JOIN (
        SELECT
            SAPROD.Descrip
            ,SAPROD.CodProd
            ,SAPROD.Marca
            ,SAPROD.UndEmpaq
            ,SAPROD.CantEmpaq
            ,SAPROD.Unidad
            ,SAPROD.Existen
            ,SAPROD.ExUnidad
            ,SAPROD.Pedido
            ,SAPROD.Minimo
            ,SAPROD.Maximo
            ,SAPROD.Compro
            ,SAPROD.FechaUV
            ,SAPROD.FechaUC
            ,SAPROD.Descrip2
            ,SAPROD.Descrip3
            ,GETDATE() AS DataRefreshTime
            ,SAPROD.CodInst
            ,SAINSTA.Descrip AS Instancia 
            ,SAPROD.EsImport
        FROM dbo.SAPROD
        LEFT OUTER JOIN SAINSTA
            ON SAPROD.CodInst = SAINSTA.CodInst
        WHERE SAPROD.Existen > 0
            OR SAPROD.Activo = 1
            AND SAPROD.FechaUC > GETDATE() - 300
            AND SAINSTA.CodInst = 2
            AND SAPROD.CodProd NOT IN (SELECT codbarras FROM [EnterpriseAdmin_AMC].[Procurement].[por_aprobacion_equivalencias])
    ) AS NPAE
        ON SAPROD.CodProd = NPAE.CodProd
    LEFT OUTER JOIN FF
        ON SAPROD.CodProd = FF.codbarras
    WHERE (SAPROD.Existen > 0 OR SAPROD.Activo = 1)
        AND SAPROD.FechaUC > GETDATE() - 300
        AND SAPROD.CodProd NOT IN (SELECT codbarras FROM [EnterpriseAdmin_AMC].[Procurement].[por_aprobacion_equivalencias])
END;
GO

-- Session: 70 | Start: 2026-03-12 20:30:00.207000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePAPorAprobacionEquivalencias] AS
BEGIN
    DECLARE @totalRowsAffected INT = 0

    -- Update forma_farmaceutica
    UPDATE paq
    SET forma_farmaceutica = ff.codigo
    FROM EnterpriseAdmin_AMC.Procurement.por_aprobacion_equivalencias paq
    JOIN EnterpriseAdmin_AMC.Procurement.ff ff ON CHARINDEX(' ' + ff.descripcion + ' ', ' ' + paq.descrip1art + ' ') > 0
    WHERE (paq.forma_farmaceutica IS NULL OR paq.forma_farmaceutica = 0)

    SET @totalRowsAffected = @totalRowsAffected + @@ROWCOUNT

    PRINT 'Updated forma_farmaceutica: ' + CAST(@@ROWCOUNT AS VARCHAR)

    -- Update principio_activo
    UPDATE paq
    SET principio_activo = CAST(pa.codigo AS VARCHAR(50)) -- Convertimos el valor de pa.codigo a VARCHAR
    FROM EnterpriseAdmin_AMC.Procurement.por_aprobacion_equivalencias paq
    JOIN EnterpriseAdmin_AMC.Procurement.principio_activo pa ON CHARINDEX(pa.descripcion, paq.descrip1art) > 0
    WHERE (paq.principio_activo IS NULL OR paq.principio_activo = '')

    SET @totalRowsAffected = @totalRowsAffected + @@ROWCOUNT

    PRINT 'Updated principio_activo: ' + CAST(@@ROWCOUNT AS VARCHAR)

    -- Update forma_farmaceutica_des with the description from ff.descripcion
    UPDATE paq
    SET forma_farmaceutica_Des = ff.descripcion
    FROM EnterpriseAdmin_AMC.Procurement.por_aprobacion_equivalencias paq
    JOIN EnterpriseAdmin_AMC.Procurement.ff ff ON paq.forma_farmaceutica = ff.codigo
    WHERE paq.forma_farmaceutica_Des IS NULL OR paq.forma_farmaceutica_Des = ''

    SET @totalRowsAffected = @totalRowsAffected + @@ROWCOUNT

    PRINT 'Updated forma_farmaceutica_Des: ' + CAST(@@ROWCOUNT AS VARCHAR)

    -- Update principio_activo_des with the description from principio_activo.descripcion
    UPDATE paq
    SET principio_activo_Des = pa.descripcion
    FROM EnterpriseAdmin_AMC.Procurement.por_aprobacion_equivalencias paq
    JOIN EnterpriseAdmin_AMC.Procurement.principio_activo pa ON paq.principio_activo = pa.codigo
    WHERE paq.principio_activo_Des IS NULL OR paq.principio_activo_Des = ''

    SET @totalRowsAffected = @totalRowsAffected + @@ROWCOUNT

    PRINT 'Updated principio_activo_Des: ' + CAST(@@ROWCOUNT AS VARCHAR)

    PRINT 'Total rows affected: ' + CAST(@totalRowsAffected AS VARCHAR)
END;
GO

-- Session: 69 | Start: 2026-03-12 20:30:01.273000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_jobstep_completion_state]
    @job_id                UNIQUEIDENTIFIER,
    @step_id               INT,
    @last_run_outcome      INT,
    @last_run_duration     INT,
    @last_run_retries      INT,
    @last_run_date         INT,
    @last_run_time         INT,
    @session_id            INT
AS
BEGIN
    -- Update job step completion state in sysjobsteps as well as sysjobactivity
    UPDATE [msdb].[dbo].[sysjobsteps]
    SET last_run_outcome      = @last_run_outcome,
        last_run_duration     = @last_run_duration,
        last_run_retries      = @last_run_retries,
        last_run_date         = @last_run_date,
        last_run_time         = @last_run_time
    WHERE job_id   = @job_id
    AND   step_id  = @step_id

    DECLARE @last_executed_step_date DATETIME
    SET @last_executed_step_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET last_executed_step_date = @last_executed_step_date,
        last_executed_step_id   = @step_id
    WHERE job_id     = @job_id
    AND   session_id = @session_id
END
GO

-- Session: 69 | Start: 2026-03-12 20:30:01.757000 | Status: suspended | Cmd: INSERT
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END
GO

-- Session: 62 | Start: 2026-03-12 20:31:08.983000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 64 | Start: 2026-03-12 20:32:27.233000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MARIO%') OR (Descrip LIKE 'MARIO%') OR (ID3 LIKE 'MARIO%') OR (Clase LIKE 'MARIO%') OR (Saldo LIKE 'MARIO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 20:33:25.310000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='8906005116987' OR P.CodProd='8906005116987')
GO

-- Session: 64 | Start: 2026-03-12 20:34:25.690000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='TORSIL' OR P.CodProd='TORSIL')
GO

-- Session: 64 | Start: 2026-03-12 20:34:28.223000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='BLI_TORSIL' OR P.CodProd='BLI_TORSIL')
GO

-- Session: 59 | Start: 2026-03-12 20:45:03.833000 | Status: runnable | Cmd: DELETE
CREATE PROCEDURE sp_jobhistory_row_limiter
  @job_id UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @max_total_rows         INT -- This value comes from the registry (MaxJobHistoryTableRows)
  DECLARE @max_rows_per_job       INT -- This value comes from the registry (MaxJobHistoryRows)
  DECLARE @rows_to_delete         INT
  DECLARE @current_rows           INT
  DECLARE @current_rows_per_job   INT

  SET NOCOUNT ON

  -- Get max-job-history-rows from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @max_total_rows OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysjobhistory rows
  IF (ISNULL(@max_total_rows, -1) = -1)
    RETURN(0)

  -- Check that max_total_rows is more than 1
  IF (ISNULL(@max_total_rows, 0) < 2)
  BEGIN
    -- It isn't, so set the default to 1000 rows
    SELECT @max_total_rows = 1000
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @max_total_rows
  END

  -- Get the per-job maximum number of rows to keep
  SELECT @max_rows_per_job = 0
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @max_rows_per_job OUTPUT,
                                         N'no_output'

  -- Check that max_rows_per_job is <= max_total_rows
  IF ((@max_rows_per_job > @max_total_rows) OR (@max_rows_per_job < 1))
  BEGIN
    -- It isn't, so default the rows_per_job to max_total_rows
    SELECT @max_rows_per_job = @max_total_rows
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @max_rows_per_job
  END

  BEGIN TRANSACTION

  SELECT @current_rows_per_job = COUNT(*)
  FROM msdb.dbo.sysjobhistory with (TABLOCKX)
  WHERE (job_id = @job_id)

  -- Delete the oldest history row(s) for the job being inserted if the new row has
  -- pushed us over the per-job row limit (MaxJobHistoryRows)
  SELECT @rows_to_delete = @current_rows_per_job - @max_rows_per_job

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      WHERE (job_id = @job_id)
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  -- Delete the oldest history row(s) if inserting the new row has pushed us over the
  -- global MaxJobHistoryTableRows limit.
  SELECT @current_rows = COUNT(*)
  FROM msdb.dbo.sysjobhistory

  SELECT @rows_to_delete = @current_rows - @max_total_rows

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  IF (@@trancount > 0)
    COMMIT TRANSACTION

  RETURN(0) -- Success
END
GO

-- Session: 58 | Start: 2026-03-12 20:49:43.833000 | Status: suspended | Cmd: UPDATE
(@1 int,@2 int,@3 varbinary(8000),@4 smallint)UPDATE [msdb].[dbo].[sysjobschedules] set [next_run_date] = @1,[next_run_time] = @2  WHERE [job_id]=@3 AND [schedule_id]=@4
GO

-- Session: 64 | Start: 2026-03-12 20:57:54.543000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='TORSILAX' OR P.CodProd='TORSILAX')
GO

-- Session: 64 | Start: 2026-03-12 20:58:00.610000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'BLI%') OR (SP.DescripAll LIKE 'BLI%') OR (SP.Refere LIKE 'BLI%') OR (SP.Existen LIKE 'BLI%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 21:09:05.720000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7591818116043' OR P.CodProd='7591818116043')
GO

-- Session: 62 | Start: 2026-03-12 21:10:00.113000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 64 | Start: 2026-03-12 21:17:54.027000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'FNAL%') OR (SP.DESCRIPALL LIKE 'FNAL%') OR (SP.REFERE LIKE 'FNAL%') OR (SP.EXISTEN LIKE 'FNAL%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 21:18:45.713000 | Status: running | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V1001087'
  ,@FACTORM      DECIMAL(28,4)=440.96
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TGravable],[TExento],[MtoTax],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-12 21:18:45.076','2026-03-12 21:18:45.263','2026-03-12 21:18:45.076',1,1,'V1001087','ADMBK02','22036825','22036825','AMR001','MARIA','CARACAS','V1001087',6306.70,6681.62,440.96,15.15,6681.62,6306.70,2343.28,3963.42,374.92,6681.62);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
INSERT INTO SATAXVTA ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[MtoTax],[TGravable],[Monto])
       VALUES ('00000','A',@NUMEROFAC,'IVA',16.00,2343.28,374.92);
SET @NROUNICOLOT=1055915;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 21:18:45.342'
 WHERE (CodProd='7591818116043');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7591818116043') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591818116043','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7591818116043') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1055915
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-12 21:18:45.373','7591818116043','2.299','AMR001','CLORACE TAB X 10',1.00,1.00,911.45,1.00,1635.108,1635.108,3,1635.108,'22036825','22036825',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-04 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056749;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 21:18:45.388'
 WHERE (CodProd='7593255000176');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7593255000176') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7593255000176','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7593255000176') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056749
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[MtoTax],[MtoTaxO],[CodVend],[CodUsua],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,2,1,'2026-03-12 21:18:45.420','7593255000176','2.545','AMR001','ALGODON ALGOBAP 100 GRAMOS',1.00,1.00,1096.17,1.00,1810.07,1810.07,3,1810.07,289.6112,289.6112,'22036825','22036825',1,'2',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-06 00:00:00.000','1899-12-29 00:00:00.000');
INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','7593255000176',1810.07,16.00,289.61,2);
SET @NROUNICOLOT=1056747;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 21:18:45.435'
 WHERE (CodProd='7593255000145');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7593255000145') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7593255000145','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7593255000145') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056747
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[MtoTax],[MtoTaxO],[CodVend],[CodUsua],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,3,1,'2026-03-12 21:18:45.467','7593255000145','0.6046','AMR001','ALGODON ALGOBAP 10 GRAMOS',1.00,1.00,260.39,1.00,533.209,533.209,3,533.209,85.31344,85.31344,'22036825','22036825',1,'24',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-06 00:00:00.000','1899-12-29 00:00:00.000');
INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','7593255000145',533.209,16.00,85.31,3);
SET @NROUNICOLOT=1056371;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 21:18:45.482'
 WHERE (CodProd='8902297024955');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='8902297024955') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8902297024955','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='8902297024955') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056371
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,4,1,'2026-03-12 21:18:45.513','8902297024955','2.0414','AMR001','FIN-AL-GRIP FORTE X 10 TAB DROTAFARMA',1.00,1.00,850.26,1.00,1500.293,1500.293,3,1500.293,'22036825','22036825',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-23 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056016;
UPDATE SAPROD SET 
       FechaUV='2026-03-12 21:18:45.529'
 WHERE (CodProd='7591821904293');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7591821904293') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591821904293','AMR001',-1.00,0,'2026-03-12';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7591821904293') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056016
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,5,1,'2026-03-12 21:18:45.545','7591821904293','1.0891','AMR001','FITEX 20      MG',1.00,1.00,505.27,1.00,828.016,828.016,3,828.016,'22036825','22036825',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-09 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=3623.54   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','003','TRANSFERENCIA',2,3100.00,1.00,'2026-03-12 00:00:00.000');
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1800.00,1.00,'2026-03-12 00:00:00.000');
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1781.62,1.00,'2026-03-12 00:00:00.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 64 | Start: 2026-03-12 21:23:37.817000 | Status: running | Cmd: SET COMMAND
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='OMEG' OR P.CodProd='OMEG')
GO

-- Session: 54 | Start: 2026-03-12 21:29:35.610000 | Status: running | Cmd: SELECT
create procedure sys.sp_datatype_info_100
(
    @data_type int = 0,
    @ODBCVer tinyint = 2
)
as
    declare @mintype int
    declare @maxtype int

    set @ODBCVer = isnull(@ODBCVer, 2)
    if @ODBCVer < 3 -- includes ODBC 1.0 as well
        set @ODBCVer = 2
    else
        set @ODBCVer = 3

    if @data_type = 0
    begin
        select @mintype = -32768
        select @maxtype = 32767
    end
    else
    begin
        select @mintype = @data_type
        select @maxtype = @data_type
    end

    select
        TYPE_NAME           = v.TYPE_NAME,
        DATA_TYPE           = v.DATA_TYPE,
        PRECISION           = v.PRECISION,
        LITERAL_PREFIX      = v.LITERAL_PREFIX,
        LITERAL_SUFFIX      = v.LITERAL_SUFFIX,
        CREATE_PARAMS       = v.CREATE_PARAMS,
        NULLABLE            = v.NULLABLE,
        CASE_SENSITIVE      = v.CASE_SENSITIVE,
        SEARCHABLE          = v.SEARCHABLE,
        UNSIGNED_ATTRIBUTE  = v.UNSIGNED_ATTRIBUTE,
        MONEY               = v.MONEY,
        AUTO_INCREMENT      = v.AUTO_INCREMENT,
        LOCAL_TYPE_NAME     = v.LOCAL_TYPE_NAME,
        MINIMUM_SCALE       = v.MINIMUM_SCALE,
        MAXIMUM_SCALE       = v.MAXIMUM_SCALE,
        SQL_DATA_TYPE       = v.SQL_DATA_TYPE,
        SQL_DATETIME_SUB    = v.SQL_DATETIME_SUB,
        NUM_PREC_RADIX      = v.NUM_PREC_RADIX,
        INTERVAL_PRECISION  = v.INTERVAL_PRECISION,
        USERTYPE            = v.USERTYPE

    from
        sys.spt_datatype_info_view v

    where
        v.DATA_TYPE between @mintype and @maxtype and
        v.ODBCVer = @ODBCVer

    order by 2, 12, 11, 20
GO

-- Session: 67 | Start: 2026-03-12 21:41:39.430000 | Status: running | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 58 | Start: 2026-03-12 21:45:00.867000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 58 | Start: 2026-03-12 21:45:41.313000 | Status: running | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 64 | Start: 2026-03-12 21:51:28.177000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MAURICIO%') OR (Descrip LIKE 'MAURICIO%') OR (ID3 LIKE 'MAURICIO%') OR (Clase LIKE 'MAURICIO%') OR (Saldo LIKE 'MAURICIO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 21:51:34.720000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'CLORURO%') OR (SP.DescripAll LIKE 'CLORURO%') OR (SP.Refere LIKE 'CLORURO%') OR (SP.Existen LIKE 'CLORURO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 64 | Start: 2026-03-12 21:51:43.253000 | Status: runnable | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7597285000052') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 54 | Start: 2026-03-12 22:09:40.307000 | Status: runnable | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 54 | Start: 2026-03-12 22:31:05.280000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 59 | Start: 2026-03-12 23:07:23.020000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 64 | Start: 2026-03-12 23:30:34.297000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 54 | Start: 2026-03-12 23:50:00.940000 | Status: suspended | Cmd: INSERT
INSERT INTO SAEVTA
SELECT B.* FROM SAEVTA AS A FULL OUTER JOIN CUSTOM_CARGA_SAEVTA AS B ON A.Periodo=B.Periodo WHERE A.Periodo IS NULL
GO

-- Session: 58 | Start: 2026-03-13 01:00:34.417000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 51 | Start: 2026-03-13 01:19:34.523000 | Status: running | Cmd: ALTER EVENT SESSION
if exists(select * from sys.server_event_sessions where name='telemetry_xevents')
	drop event session telemetry_xevents on server

create event session telemetry_xevents on server
 ADD EVENT [sqlserver].[error_reported]
(
WHERE severity >= 16
or (error_number = 18456
    or error_number = 17803 or error_number = 701 or error_number = 802 or error_number = 8645 or error_number = 8651
    or error_number = 8657 or error_number = 8902 or error_number = 41354 or error_number = 41355 or error_number = 41367
    or error_number = 41384 or error_number = 41336 or error_number = 41309 or error_number = 41312 or error_number = 41313
    or error_number = 33065 or error_number = 33066)
),

 ADD EVENT [sqlserver].[missing_column_statistics],

 ADD EVENT [sqlserver].[missing_join_predicate],

 ADD EVENT [sqlserver].[server_memory_change],

 ADD EVENT [sqlserver].[stretch_database_disable_completed],

 ADD EVENT [sqlserver].[stretch_database_enable_completed],

 ADD EVENT [sqlserver].[stretch_database_reauthorize_completed],

 ADD EVENT [sqlserver].[stretch_index_reconciliation_codegen_completed],

 ADD EVENT [sqlserver].[stretch_remote_column_execution_completed],

 ADD EVENT [sqlserver].[stretch_remote_column_reconciliation_codegen_completed],

 ADD EVENT [sqlserver].[stretch_remote_index_execution_completed],

 ADD EVENT [sqlserver].[stretch_table_codegen_completed],

 ADD EVENT [sqlserver].[stretch_table_alter_ddl],

 ADD EVENT [sqlserver].[stretch_table_create_ddl],

 ADD EVENT [sqlserver].[stretch_table_predicate_not_specified],

 ADD EVENT [sqlserver].[stretch_table_predicate_specified],

 ADD EVENT [sqlserver].[stretch_table_remote_creation_completed],

 ADD EVENT [sqlserver].[stretch_table_row_migration_results_event],

 ADD EVENT [sqlserver].[stretch_table_row_unmigration_results_event],

 ADD EVENT [sqlserver].[stretch_table_data_reconciliation_results_event],

 ADD EVENT [sqlserver].[stretch_table_unprovision_completed],

 ADD EVENT [sqlserver].[stretch_table_validation_error],

 ADD EVENT [sqlserver].[stretch_table_hinted_admin_update_event],

 ADD EVENT [sqlserver].[stretch_table_hinted_admin_delete_event],

 ADD EVENT [sqlserver].[stretch_table_query_error],

 ADD EVENT [sqlserver].[stretch_remote_error],

 ADD EVENT [sqlserver].[stretch_query_telemetry],

 ADD EVENT [sqlserver].[temporal_ddl_system_versioning],

 ADD EVENT [sqlserver].[temporal_dml_transaction_fail],

 ADD EVENT [sqlserver].[temporal_ddl_period_add],

 ADD EVENT [sqlserver].[temporal_ddl_period_drop],

 ADD EVENT [sqlserver].[temporal_ddl_schema_check_fail],

 ADD EVENT [sqlserver].[data_masking_ddl_column_definition],

 ADD EVENT [sqlserver].[data_masking_traffic],

 ADD EVENT [sqlserver].[data_masking_traffic_masked_only],

 ADD EVENT [sqlserver].[data_classification_ddl_column_definition],

 ADD EVENT [sqlserver].[data_classification_traffic],

 ADD EVENT [sqlserver].[data_classification_auditing_traffic],

 ADD EVENT [sqlserver].[feature_restriction_ddl],

 ADD EVENT [sqlserver].[feature_restriction_usage],

 ADD EVENT [sqlserver].[always_encrypted_query_count],

 ADD EVENT [sqlserver].[rls_query_count],

 ADD EVENT [sqlserver].[auto_stats],

 ADD EVENT [sqlserver].[database_cmptlevel_change],

 ADD EVENT [sqlserver].[database_created],

 ADD EVENT [sqlserver].[database_dropped],

 ADD EVENT [sqlserver].[reason_many_foreign_keys_operator_not_used],

 ADD EVENT [sqlserver].[interleaved_exec_status],

 ADD EVENT [sqlserver].[table_variable_deferred_compilation],

 ADD EVENT [sqlserver].[graph_match_query_compiled],

 ADD EVENT [sqlserver].[approximate_count_distinct_query_compiled],

 ADD EVENT [sqlserver].[login_protocol_count],

 ADD EVENT [sqlserver].[column_store_index_build_low_memory],

 ADD EVENT [sqlserver].[column_store_index_build_throttle],

 ADD EVENT [sqlserver].[columnstore_delete_buffer_flush_failed],

 ADD EVENT [sqlserver].[columnstore_delta_rowgroup_closed],

 ADD EVENT [sqlserver].[columnstore_index_reorg_failed],

 ADD EVENT [sqlserver].[columnstore_log_exception],

 ADD EVENT [sqlserver].[columnstore_rowgroup_merge_failed],

 ADD EVENT [sqlserver].[columnstore_tuple_mover_delete_buffer_truncate_timed_out],

 ADD EVENT [sqlserver].[columnstore_tuple_mover_end_compress],

 ADD EVENT [sqlserver].[query_memory_grant_blocking],

 ADD EVENT [sqlserver].[natively_compiled_module_inefficiency_detected],

 ADD EVENT [sqlserver].[natively_compiled_proc_slow_parameter_passing],

 ADD EVENT [sqlserver].[xtp_alter_table],

 ADD EVENT [sqlserver].[xtp_db_delete_only_mode_updatedhktrimlsn],

 ADD EVENT [sqlserver].[xtp_stgif_container_added],

 ADD EVENT [sqlserver].[xtp_stgif_container_deleted],

 ADD EVENT [xtpcompile].[cl_duration],

 ADD EVENT [xtpengine].[xtp_physical_db_restarted],

 ADD EVENT [xtpengine].[xtp_db_delete_only_mode_enter],

 ADD EVENT [xtpengine].[xtp_db_delete_only_mode_update],

 ADD EVENT [xtpengine].[xtp_db_delete_only_mode_exit],

 ADD EVENT [xtpengine].[parallel_alter_stats],

 ADD EVENT [xtpengine].[serial_alter_stats],

 ADD EVENT [sqlserver].[json_function_compiled]
(
ACTION ([database_id])
),

 ADD EVENT [sqlserver].[string_escape_compiled]
(
ACTION ([database_id])
),

 ADD EVENT [sqlserver].[window_function_used]
(
ACTION ([database_id])
),

 ADD EVENT [sqlserver].[sequence_function_used]
(
ACTION ([database_id])
),

 ADD EVENT [qds].[query_store_db_diagnostics],

 ADD EVENT [sqlserver].[index_defragmentation],

 ADD EVENT [sqlserver].[create_index_event],

 ADD EVENT [sqlserver].[index_build_error_event],

 ADD EVENT [sqlserver].[alter_column_event],

 ADD EVENT [sqlserver].[cardinality_estimation_version_usage],

 ADD EVENT [sqlserver].[query_optimizer_compatibility_level_hint_usage],

 ADD EVENT [sqlserver].[query_tsql_scalar_udf_inlined],

 ADD EVENT [sqlserver].[tsql_scalar_udf_not_inlineable],

 ADD EVENT [sqlserver].[recovery_checkpoint_stats],

 ADD EVENT [sqlserver].[multistep_execution]
(
ACTION ([database_id])
),

 ADD EVENT [sqlserver].[fulltext_filter_usage],

 ADD EVENT [sqlserver].[tx_commit_abort_stats],

 ADD EVENT [sqlserver].[server_start_stop]
add target package0.ring_buffer
(set occurrence_number = 100)
with
(
	MAX_DISPATCH_LATENCY = 120 SECONDS,
	MAX_MEMORY = 4 MB,
	startup_state = on
)
if not exists (select * from sys.dm_xe_sessions where name = 'telemetry_xevents')
	alter event session telemetry_xevents on server state=start
GO

-- Session: 54 | Start: 2026-03-13 06:30:00.383000 | Status: suspended | Cmd: INSERT
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END
GO

-- Session: 58 | Start: 2026-03-13 06:30:00.347000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 51 | Start: 2026-03-13 06:30:19.810000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_jobstep_completion_state]
    @job_id                UNIQUEIDENTIFIER,
    @step_id               INT,
    @last_run_outcome      INT,
    @last_run_duration     INT,
    @last_run_retries      INT,
    @last_run_date         INT,
    @last_run_time         INT,
    @session_id            INT
AS
BEGIN
    -- Update job step completion state in sysjobsteps as well as sysjobactivity
    UPDATE [msdb].[dbo].[sysjobsteps]
    SET last_run_outcome      = @last_run_outcome,
        last_run_duration     = @last_run_duration,
        last_run_retries      = @last_run_retries,
        last_run_date         = @last_run_date,
        last_run_time         = @last_run_time
    WHERE job_id   = @job_id
    AND   step_id  = @step_id

    DECLARE @last_executed_step_date DATETIME
    SET @last_executed_step_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET last_executed_step_date = @last_executed_step_date,
        last_executed_step_id   = @step_id
    WHERE job_id     = @job_id
    AND   session_id = @session_id
END
GO

-- Session: 54 | Start: 2026-03-13 06:31:00.830000 | Status: running | Cmd: INSERT
INSERT INTO dolartoday
SELECT B.* FROM dolartoday AS A FULL OUTER JOIN CUSTOM_CARGA_DOLARTODAY AS B ON convert(date,A.fecha)=convert(date,B.fecha) WHERE convert(date,A.fecha) IS NULL
GO

-- Session: 61 | Start: 2026-03-13 06:53:36.970000 | Status: runnable | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 65 | Start: 2026-03-13 06:54:18.190000 | Status: suspended | Cmd: UPDATE
(@P1 binary(8000))UPDATE SACONF SET Adicional=@P1 , DESCRIP='Farmacia Americana C.A.', NROSERIAL='ADME393713724599196', KEYSERIAL='1966618' WHERE CODSUCU='00000'
GO

-- Session: 54 | Start: 2026-03-13 07:00:00.847000 | Status: runnable | Cmd: EXECUTE
xp_instance_regread
GO

-- Session: 58 | Start: 2026-03-13 07:00:00.847000 | Status: runnable | Cmd: EXECUTE
xp_instance_regread
GO

-- Session: 60 | Start: 2026-03-13 07:00:00.760000 | Status: runnable | Cmd: SELECT
declare 
@Invdia as decimal = (SELECT total_inv FROM CUSTOM_INVENTARIO_DIVISAS), 
@pro as real = (SELECT COSTO_PROMEDIO FROM CUSTOM_INVENTARIO_DIVISAS),
@uni as decimal = (SELECT TOTAL_UNIDADES FROM CUSTOM_INVENTARIO_DIVISAS)
insert costo_inventario_divisas values (@Invdia,@pro,@uni,GETDATE())
GO

-- Session: 61 | Start: 2026-03-13 07:04:00.410000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MA%') OR (Descrip LIKE 'MA%') OR (ID3 LIKE 'MA%') OR (Clase LIKE 'MA%') OR (Saldo LIKE 'MA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 07:04:05.900000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='COMPL' OR P.CodProd='COMPL')
GO

-- Session: 61 | Start: 2026-03-13 07:04:24.520000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '7598455000186%') OR (SP.DESCRIPALL LIKE '7598455000186%') OR (SP.REFERE LIKE '7598455000186%') OR (SP.EXISTEN LIKE '7598455000186%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 07:04:36.557000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7598455000186' OR P.CodProd='7598455000186')
GO

-- Session: 61 | Start: 2026-03-13 07:06:29.130000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7595059001304' OR P.CodProd='7595059001304')
GO

-- Session: 61 | Start: 2026-03-13 07:07:08.300000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'JER%') OR (SP.DescripAll LIKE 'JER%') OR (SP.Refere LIKE 'JER%') OR (SP.Existen LIKE 'JER%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 07:08:48.720000 | Status: runnable | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V6291532'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TGravable],[TExento],[MtoTax],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 07:08:47.550','2026-03-13 07:08:47.769','2026-03-13 07:08:47.550',1,1,'V6291532','CAJA004','V12400678','12400678','AMR001','MABEL D OSUNA PALACIOS','LOS RUICES','V6291532',12914.69,13023.26,443.25,29.38,13023.26,12914.69,678.70,12235.98,108.59,13023.26);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
INSERT INTO SATAXVTA ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[MtoTax],[TGravable],[Monto])
       VALUES ('00000','A',@NUMEROFAC,'IVA',16.00,678.70,108.59);
SET @NROUNICOLOT=1056522;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:47.831'
 WHERE (CodProd='7597533000070');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7597533000070') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597533000070','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7597533000070') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056522
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 07:08:47.863','7597533000070','5.6829','AMR001','HIERRO 100      MG / 5 ML I.V',1.00,1.00,2370.60,1.00,3704.332,3704.332,3,3704.332,'12400678','V12400678',1,1,'368',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-28 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1045292;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:47.878'
 WHERE (CodProd='AMP_COMPLE_B');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='AMP_COMPLE_B') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','AMP_COMPLE_B','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='AMP_COMPLE_B') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1045292
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,2,1,'2026-03-13 07:08:47.909','AMP_COMPLE_B','1.4464','AMR001','COMPLEJO B (DETALLADO) AMP I.V/I.M',1.00,1.00,170.82,1.00,1105.374,1105.374,3,1105.374,'12400678','V12400678',1,1,'25',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2025-09-30 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1055824;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:47.925'
 WHERE (CodProd='7592253003066');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7592253003066') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592253003066','AMR001',-3.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7592253003066') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1055824
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-3.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,3,1,'2026-03-13 07:08:47.956','7592253003066','1.4942','AMR001','CLORURO DE SODIO 500ML 0.9',3.00,1.00,592.41,1.00,5981.073,1993.691,3,1993.691,'12400678','V12400678',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-03 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056464;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:47.972'
 WHERE (CodProd='813333014541');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='813333014541') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','813333014541','AMR001',-2.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='813333014541') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056464
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-2.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,4,1,'2026-03-13 07:08:47.988','813333014541','0.3428','AMR001','MACROGOTERO KX MEDICAL',2.00,1.00,142.48,1.00,799.716,399.858,3,399.858,'12400678','V12400678',1,1,'1',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-26 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056134;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:48.003'
 WHERE (CodProd='7595059001304');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7595059001304') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7595059001304','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7595059001304') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056134
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,5,1,'2026-03-13 07:08:48.019','7595059001304','0.8094','AMR001','CATETER VENTRON N 22 VEINCARE',1.00,1.00,331.75,1.00,640.655,640.655,3,640.655,'12400678','V12400678',1,1,'58',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-12 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=344910;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:48.034'
 WHERE (CodProd='100012');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='100012') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','100012','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='100012') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=344910
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,6,1,'2026-03-13 07:08:48.066','100012','0.0024','AMR001','PERICRANEAL Nº 25',1.00,1.00,0.28,1.00,4.835,4.835,3,4.835,'12400678','V12400678',1,1,'9',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2023-03-27 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1055791;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 07:08:48.081'
 WHERE (CodProd='36596');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='36596') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','36596','AMR001',-2.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='36596') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1055791
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-2.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[MtoTax],[MtoTaxO],[CodVend],[CodUsua],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,7,1,'2026-03-13 07:08:48.113','36596','0.1914','AMR001','JER  10CC 21 X 1 CC X 100  GAESCA',2.00,1.00,93.03,1.00,678.704,339.352,3,339.352,108.59264,54.29632,'12400678','V12400678',1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-03 00:00:00.000','1899-12-29 00:00:00.000');
INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','36596',678.704,16.00,108.59,7);
UPDATE SAFACT SET 
   CostoPrd=5121.70   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,13023.26,1.00,'2026-03-13 07:08:44.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 61 | Start: 2026-03-13 07:08:49.067000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 61 | Start: 2026-03-13 07:08:52.293000 | Status: runnable | Cmd: SELECT
SELECT SAFACT.NumeroD NumeroD_2, 
       SAFACT.TipoFac TipoFac_2, 
       SAITEMFAC.Cantidad, SAITEMFAC.CantidadU, 
       SAITEMFAC.CantMayor, SAITEMFAC.CodItem, 
       SAITEMFAC.CodMeca, SAITEMFAC.CodSucu, 
       SAITEMFAC.CodUbic, SAITEMFAC.CodUsua, 
       SAITEMFAC.CodVend, SAITEMFAC.Costo, 
       SAITEMFAC.Descrip1, SAITEMFAC.Descrip10, 
       SAITEMFAC.Descrip2, SAITEMFAC.Descrip3, 
       SAITEMFAC.Descrip4, SAITEMFAC.Descrip5, 
       SAITEMFAC.Descrip6, SAITEMFAC.Descrip7, 
       SAITEMFAC.Descrip8, SAITEMFAC.Descrip9, 
       SAITEMFAC.Descto, SAITEMFAC.DEsLote, 
       SAITEMFAC.DEsSeri, SAITEMFAC.EsExento, 
       SAITEMFAC.EsPesa, SAITEMFAC.EsServ, 
       SAITEMFAC.EsUnid, SAITEMFAC.ExistAnt, 
       SAITEMFAC.ExistAntU, SAITEMFAC.FechaE, 
       SAITEMFAC.Factor, SAITEMFAC.FechaL, 
       SAITEMFAC.FechaV, SAITEMFAC.MtoTax, 
       SAITEMFAC.NroLinea, SAITEMFAC.NroLineaC, 
       SAITEMFAC.MtoTaxO, SAITEMFAC.NroLote, 
       SAITEMFAC.NroUnicoL, SAITEMFAC.NumeroD, 
       SAITEMFAC.NumeroE, SAITEMFAC.Precio, 
       SAITEMFAC.PriceO, SAITEMFAC.Refere, 
       SAITEMFAC.Signo, SAITEMFAC.PrecioI, 
       SAITEMFAC.Tara, SAITEMFAC.TipoFac, 
       SAITEMFAC.TotalItem, SAITEMFAC.UsaServ, 
       SAITEMFAC.TipoData, SAITEMFAC.TipoPVP
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
      INNER JOIN SAITEMFAC SAITEMFAC ON 
     (SAITEMFAC.NumeroD = SAFACT.NumeroD)
      AND (SAITEMFAC.TipoFac = SAFACT.TipoFac)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44365' )
ORDER BY SAITEMFAC.NumeroD, SAITEMFAC.TipoFac
GO

-- Session: 61 | Start: 2026-03-13 07:08:59.163000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 07:12:36.497000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'NA%') OR (Descrip LIKE 'NA%') OR (ID3 LIKE 'NA%') OR (Clase LIKE 'NA%') OR (Saldo LIKE 'NA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 07:12:41.480000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='039800014023' OR P.CodProd='039800014023')
GO

-- Session: 64 | Start: 2026-03-13 07:13:31.420000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 61 | Start: 2026-03-13 07:13:51.833000 | Status: running | Cmd: SELECT
SELECT SAFACT.NumeroD NumeroD_2, 
       SAFACT.TipoFac TipoFac_2, 
       SAITEMFAC.Cantidad, SAITEMFAC.CantidadU, 
       SAITEMFAC.CantMayor, SAITEMFAC.CodItem, 
       SAITEMFAC.CodMeca, SAITEMFAC.CodSucu, 
       SAITEMFAC.CodUbic, SAITEMFAC.CodUsua, 
       SAITEMFAC.CodVend, SAITEMFAC.Costo, 
       SAITEMFAC.Descrip1, SAITEMFAC.Descrip10, 
       SAITEMFAC.Descrip2, SAITEMFAC.Descrip3, 
       SAITEMFAC.Descrip4, SAITEMFAC.Descrip5, 
       SAITEMFAC.Descrip6, SAITEMFAC.Descrip7, 
       SAITEMFAC.Descrip8, SAITEMFAC.Descrip9, 
       SAITEMFAC.Descto, SAITEMFAC.DEsLote, 
       SAITEMFAC.DEsSeri, SAITEMFAC.EsExento, 
       SAITEMFAC.EsPesa, SAITEMFAC.EsServ, 
       SAITEMFAC.EsUnid, SAITEMFAC.ExistAnt, 
       SAITEMFAC.ExistAntU, SAITEMFAC.FechaE, 
       SAITEMFAC.Factor, SAITEMFAC.FechaL, 
       SAITEMFAC.FechaV, SAITEMFAC.MtoTax, 
       SAITEMFAC.NroLinea, SAITEMFAC.NroLineaC, 
       SAITEMFAC.MtoTaxO, SAITEMFAC.NroLote, 
       SAITEMFAC.NroUnicoL, SAITEMFAC.NumeroD, 
       SAITEMFAC.NumeroE, SAITEMFAC.Precio, 
       SAITEMFAC.PriceO, SAITEMFAC.Refere, 
       SAITEMFAC.Signo, SAITEMFAC.PrecioI, 
       SAITEMFAC.Tara, SAITEMFAC.TipoFac, 
       SAITEMFAC.TotalItem, SAITEMFAC.UsaServ, 
       SAITEMFAC.TipoData, SAITEMFAC.TipoPVP
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
      INNER JOIN SAITEMFAC SAITEMFAC ON 
     (SAITEMFAC.NumeroD = SAFACT.NumeroD)
      AND (SAITEMFAC.TipoFac = SAFACT.TipoFac)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44367' )
ORDER BY SAITEMFAC.NumeroD, SAITEMFAC.TipoFac
GO

-- Session: 51 | Start: 2026-03-13 07:15:33.387000 | Status: runnable | Cmd: SELECT
DECLARE @msticks bigint, @mstickstime datetime, @LastHour datetime
                SELECT @mstickstime = GETDATE(), @msticks = ms_ticks from sys.dm_os_sys_info
                SELECT @LastHour = DATEADD(HOUR, -1, @mstickstime);
                
                WITH Quartiles AS (
                SELECT DISTINCT       
                    CONVERT(VARCHAR(10), CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE), 112) EventDate,
                       CONVERT(VARCHAR(30), TIMEFROMPARTS(DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)), 00,00,00,00), 114) AS [EventTime],         
                       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
                           )
                           OVER (PARTITION BY CONVERT(VARCHAR(10), CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE), 112),
                                  CONVERT(VARCHAR(30), TIMEFROMPARTS(DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)), 00,00,00,00), 114)
                           ) AS MedianSQLCPU
                           ,           
                       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
                           )
                           OVER (PARTITION BY CONVERT(VARCHAR(10), CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE), 112),
                                  CONVERT(VARCHAR(30), TIMEFROMPARTS(DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)), 00,00,00,00), 114)
                           ) AS Q3SQLCPU
                     ,           
                       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
                           )
                           OVER (PARTITION BY CONVERT(VARCHAR(10), CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE), 112),
                                  CONVERT(VARCHAR(30), TIMEFROMPARTS(DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)), 00,00,00,00), 114)
                           ) AS Q1SQLCPU
                  FROM (
                    SELECT timestamp, CONVERT (xml, record) AS 'record' 
                    FROM sys.dm_os_ring_buffers 
                    WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
                      AND record LIKE '%<SystemHealth>%'
                            ) AS t
                     WHERE DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)) = DATEPART(HOUR, @LastHour)
                     AND CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE) = CAST(@LastHour AS DATE)
              ),
              SimpleStats AS (
                SELECT         
                    CONVERT(VARCHAR(10), CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE), 112) EventDate,
                       CONVERT(VARCHAR(30), TIMEFROMPARTS(DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)), 00,00,00,00), 114) AS [EventTime],  
                    MAX(record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')) AS [MaxSQLCPU], 
                       MIN(record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')) AS [MinSQLCPU], 
                       AVG(record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')) AS [AvgSQLCPU]          
                  FROM (
                    SELECT timestamp, CONVERT (xml, record) AS 'record' 
                    FROM sys.dm_os_ring_buffers 
                    WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
                      AND record LIKE '%<SystemHealth>%'
                            ) AS t
              WHERE DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)) = DATEPART(HOUR, @LastHour)
                     AND CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE) = CAST(@LastHour AS DATE)
              GROUP BY 
                     CONVERT(VARCHAR(10), CAST(DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime) AS DATE), 112) ,
                     CONVERT(VARCHAR(30), TIMEFROMPARTS(DATEPART(HOUR, DATEADD (ms, -1 * (@msticks - [timestamp]),@mstickstime)), 00,00,00,00), 114) 
              )
              SELECT 
                     ss.EventDate AS EventDate,
                     ss.EventTime AS EventTime,
                     ss.MaxSQLCPU,
                     ss.MinSQLCPU,
                     ss.AvgSQLCPU,
                     q.MedianSQLCPU,
                     q.Q1SQLCPU,
                     q.Q3SQLCPU
              FROM SimpleStats ss
                     INNER JOIN Quartiles q
                           ON q.EventDate = ss.EventDate
                           AND q.EventTime = ss.EventTime
GO

-- Session: 59 | Start: 2026-03-13 07:30:00.740000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 51 | Start: 2026-03-13 07:30:30.823000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 61 | Start: 2026-03-13 07:35:28.647000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7593255000176' OR P.CodProd='7593255000176')
GO

-- Session: 61 | Start: 2026-03-13 07:37:48.427000 | Status: running | Cmd: EXECUTE
SET DATEFORMAT YMD;
SELECT P.*, C.Saldo AS SALDOP,
       DBO.FN_ADM_DESCTOCONVENIO('V13615765',3638.94,2.00,'2026-03-13 07:13:48.604') AS DESCTOCV 
  FROM SACLIE P 
  LEFT JOIN (SELECT CODCLIE, SUM(SALDO) AS SALDO 
               FROM SAACXC
              WHERE (SALDO>0) AND ((TIPOCXC IN ('10','60','70')) or (substring(tipocxC,1,1)='2'))
              GROUP BY CODCLIE) C ON
       P.CODCLIE=C.CODCLIE
 WHERE P.CODCLIE='V13615765'
GO

-- Session: 58 | Start: 2026-03-13 08:03:46.547000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 13
GO

-- Session: 58 | Start: 2026-03-13 08:03:47.730000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'BA%') OR (Descrip LIKE 'BA%') OR (ID3 LIKE 'BA%') OR (Clase LIKE 'BA%') OR (Saldo LIKE 'BA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 13
GO

-- Session: 58 | Start: 2026-03-13 08:03:56.730000 | Status: suspended | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7593567000697') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 58 | Start: 2026-03-13 08:04:05.720000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 66 | Start: 2026-03-13 08:13:31.570000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 58 | Start: 2026-03-13 08:25:06.633000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'NA%') OR (Descrip LIKE 'NA%') OR (ID3 LIKE 'NA%') OR (Clase LIKE 'NA%') OR (Saldo LIKE 'NA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 13
GO

-- Session: 58 | Start: 2026-03-13 08:25:12.787000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='CANDESART' OR P.CodProd='CANDESART')
GO

-- Session: 51 | Start: 2026-03-13 08:25:31.637000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 58 | Start: 2026-03-13 08:25:32.763000 | Status: runnable | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7590027002857') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 51 | Start: 2026-03-13 08:25:38.437000 | Status: runnable | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 58 | Start: 2026-03-13 08:27:50.103000 | Status: runnable | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V18675677'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 08:27:49.609','2026-03-13 08:27:49.781','2026-03-13 08:27:49.609',1,1,'V18675677','BK03','V12400678','12400678','AMR001','NAANYELI EDITH BENITEZ TERAN','CARICUAO','V18675677',3759.76,3759.76,443.25,8.48,3759.76,3759.76,3759.76,3759.76);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1056797;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 08:27:49.843'
 WHERE (CodProd='7590027002857');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7590027002857') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7590027002857','AMR001',-2.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7590027002857') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056797
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-2.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 08:27:49.874','7590027002857','2.6295','AMR001','CANDESARTAN CILEXETICO 8      MG CJX30',2.00,1.00,1135.77,1.00,3759.76,1879.88,3,1879.88,'12400678','V12400678',1,1,'06987',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-09 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=2271.54   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,3759.76,1.00,'2026-03-13 08:27:47.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 60 | Start: 2026-03-13 08:30:01.030000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 66 | Start: 2026-03-13 08:45:00.733000 | Status: running | Cmd: EXECUTE
xp_instance_regread
GO

-- Session: 67 | Start: 2026-03-13 08:45:00.647000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 62 | Start: 2026-03-13 08:49:25.770000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 64 | Start: 2026-03-13 08:49:42.863000 | Status: suspended | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 64 | Start: 2026-03-13 08:50:00.110000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 62 | Start: 2026-03-13 08:50:07.950000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'FLUCONA%') OR (SP.DescripAll LIKE 'FLUCONA%') OR (SP.Refere LIKE 'FLUCONA%') OR (SP.Existen LIKE 'FLUCONA%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 61 | Start: 2026-03-13 08:50:11.077000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'KEOP%') OR (SP.DESCRIPALL LIKE 'KEOP%') OR (SP.REFERE LIKE 'KEOP%') OR (SP.EXISTEN LIKE 'KEOP%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 62 | Start: 2026-03-13 08:50:11.760000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, lo.cantidad, lo.cantidadu, lo.fechav,       lo.precio3 preciov,       lo.precio3 +(lo.precio3*tx.mtotax+tx.mtofijo) preciotx,       lo.precioi3 precioI,       lo.preciou3 preciou,       lo.preciou3+(lo.preciou3*tx.mtotax+                          iif(pr.cantempaq>1,1/pr.cantempaq,1)*tx.mtofijo) precioutx,       lo.precioui3 precioui,       lo.costo, pr.cantempaq   FROM salote lo       LEFT JOIN (                  SELECT codprod, 0 mtotax, 0 mtofijo
                    FROM SAPROD
                 ) tx       ON (tx.codprod=lo.codprod)       INNER JOIN saprod pr       ON (pr.codprod=lo.codprod)       INNER JOIN sadepo dp       ON (dp.codubic=lo.codubic) WHERE (lo.CodProd='7592616200026')       And (lo.CodUbic='AMR001')  ORDER BY lo.codubic, lo.fechav
GO

-- Session: 62 | Start: 2026-03-13 08:50:24.607000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'RECOL%') OR (SP.DescripAll LIKE 'RECOL%') OR (SP.Refere LIKE 'RECOL%') OR (SP.Existen LIKE 'RECOL%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 62 | Start: 2026-03-13 08:53:12.643000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 62 | Start: 2026-03-13 08:53:13.943000 | Status: runnable | Cmd: SELECT
(@P1 varchar(60))SELECT A.*
FROM SFTITM A
WHERE (UPPER(A.ItemName) = UPPER(@P1))
ORDER BY A.itemid ASC

OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY
GO

-- Session: 62 | Start: 2026-03-13 08:53:14.430000 | Status: suspended | Cmd: SELECT
create procedure sys.sp_tableswc
(
    @table_name         nvarchar(384)   = null,
    @table_owner        nvarchar(384)   = null,
    @table_qualifier    sysname = null,
    @table_type         varchar(100) = null,
    @fUsePattern        bit = 1, -- To allow users to explicitly disable all pattern matching.
    @fTableCreated      bit = 0  -- whether our caller created the table #sptableswc for us to insert into or we should create/drop it ourselves
)
as
    declare @databasename   sysname
    declare @qualprocname   nvarchar(142) -- 128 + '.sys.sp_tables'

    if (@fUsePattern = 1) -- Does the user want it?
    begin
        if ((@table_name is not null) and
            (@table_owner is not null) and
            (isnull(charindex('%', @table_name),0) = 0) and
            (isnull(charindex('_', @table_name),0) = 0) and
            (isnull(charindex('%', @table_owner),0) = 0) and
            (isnull(charindex('_', @table_owner),0) = 0))
        begin
             select @fUsePattern = 0 -- not a single wild char, so go the fast way.
        end
    end

    if @fTableCreated = 0
    begin
        create table #sptableswc
        (
            TABLE_QUALIFIER sysname collate catalog_default null,
            TABLE_OWNER sysname collate catalog_default null,
            TABLE_NAME sysname collate catalog_default null,
            TABLE_TYPE  varchar(32) collate catalog_default null,
            REMARKS varchar(254) collate catalog_default null
        )
    end

    if @fUsePattern = 0
    begin
        select @qualprocname = quotename(@table_qualifier) + '.sys.sp_tables'

        if object_id(@qualprocname) is null
        begin
            -- DB doesn't exist - request an empty resultset from current DB.
            select @qualprocname = 'sys.sp_tables'
            select @table_name = ' ' -- no tables with that name could possibly exist
        end

        /* -- Debug output, do not remove it.
        print '*************'
        print 'No pattern matching.'
        print @fUsePattern
        print isnull(@qualprocname, '@qualprocname = null')
        print isnull(@table_name, '@table_name = null')
        print isnull(@table_owner, '@table_owner = null')
        print isnull(@table_qualifier, '@table_qualifier = null')
        print isnull(@table_type, '@table_type = null')
        print '*************'
        */
        insert into #sptableswc exec @qualprocname @table_name, @table_owner, @table_qualifier, @table_type, @fUsePattern
    end
    else
    begin

        declare cursDB cursor local for
            select
                name
            from
                sys.databases d
            where
                d.name like @table_qualifier and
                d.name <> 'model' and
                has_dbaccess(d.name)=1
            for read only

        open cursDB

        fetch next from cursDB into @databasename
        while (@@FETCH_STATUS <> -1)
        begin
            if (charindex('%', @databasename) = 0)
            begin   -- Skip dbnames w/wildcard characters to prevent loop.
                select @qualprocname = quotename(@databasename) + '.sys.sp_tables'

                /* -- Debug output, do not remove it.
                print '*************'
                print 'THERE IS pattern matching!'
                print @fUsePattern
                print isnull(@qualprocname, '@qualprocname = null')
                print isnull(@table_name, '@table_name = null')
                print isnull(@table_owner, '@table_owner = null')
                print isnull(@databasename, '@databasename = null')
                print isnull(@table_type, '@table_type = null')
                print '*************'
                */
                insert into #sptableswc
                exec @qualprocname @table_name, @table_owner, @databasename, @table_type, @fUsePattern
            end
            fetch next from cursDB into @databasename
        end

        deallocate cursDB


    end

    if @fTableCreated = 0
    begin
        select
            *
        from
            #sptableswc
        order by 4, 1, 2, 3

        drop table #sptableswc
    end
GO

-- Session: 65 | Start: 2026-03-13 09:00:00.967000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 60 | Start: 2026-03-13 09:00:31.300000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 59 | Start: 2026-03-13 09:01:00.490000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 67 | Start: 2026-03-13 09:03:00.443000 | Status: running | Cmd: UPDATE
UPDATE SAPROD 
SET PrecioI1=b.precio$1,PrecioI2=b.precio$2,PrecioI3=b.precio$3
from SAPROD as a
inner join CUSTOM_PRECIO_EN_DOLAR as b on (a.CodProd=b.codprod)
GO

-- Session: 61 | Start: 2026-03-13 09:04:51.697000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.EXISTEN DESC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'SAITO%') OR (SP.DESCRIPALL LIKE 'SAITO%') OR (SP.REFERE LIKE 'SAITO%') OR (SP.EXISTEN LIKE 'SAITO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 09:05:00.010000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ROSA%') OR (Descrip LIKE 'ROSA%') OR (ID3 LIKE 'ROSA%') OR (Clase LIKE 'ROSA%') OR (Saldo LIKE 'ROSA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 58 | Start: 2026-03-13 09:06:09.710000 | Status: suspended | Cmd: UPDATE
IF COL_LENGTH('SACORRELSIS', 'ValueDec') IS NULL
	            ALTER TABLE dbo.SACORRELSIS ADD [ValueDec] Decimal(18,2)  NOT NULL DEFAULT(0);
            IF COL_LENGTH('SACORRELSIS', 'ValueStr') IS NULL
	            ALTER TABLE dbo.SACORRELSIS ADD [ValueStr] VARCHAR(40)  NULL ;
            IF COL_LENGTH('SACORRELSIS', 'Prefijo') IS NULL
	            ALTER TABLE dbo.SACORRELSIS ADD [Prefijo] VARCHAR(15)  NULL ;
            IF COL_LENGTH('SACORRELSIS', 'Desde') IS NULL
	            ALTER TABLE dbo.SACORRELSIS ADD [Desde] int  NOT NULL DEFAULT(0);
            IF COL_LENGTH('SACORRELSIS', 'Hasta') IS NULL
	            ALTER TABLE dbo.SACORRELSIS ADD [Hasta] int NOT NULL DEFAULT(0);

            IF COL_LENGTH('SACONF', 'AutSRIReten') IS NULL
                ALTER TABLE dbo.SACONF ADD AutSRIReten VARCHAR(10) NULL;
            IF COL_LENGTH('SACONF', 'FillCorrel') IS NULL
                ALTER TABLE dbo.SACONF ADD [FillCorrel] [smallint] NOT NULL DEFAULT ((0.00));
            IF COL_LENGTH('SACONF', 'FacWSrvURL') IS NULL
	            ALTER TABLE dbo.SACONF ADD FacWSrvURL VARCHAR(100) NULL;
            IF COL_LENGTH('SACONF', 'MontoMin') IS NULL
	            ALTER TABLE dbo.SACONF ADD MontoMin decimal(28,4) NOT NULL DEFAULT ((0));
            IF COL_LENGTH('SACONF', 'ImpT') IS NULL
	            ALTER TABLE dbo.SACONF ADD ImpT int NOT NULL DEFAULT ((0));
            IF COL_LENGTH('SACONF', 'TipoAtr') IS NULL
	            ALTER TABLE dbo.SACONF ADD TipoAtr smallint NOT NULL DEFAULT ((0));
            IF COL_LENGTH('SACONF', 'TokenEmpresa') IS NULL
	            ALTER TABLE dbo.SACONF ADD TokenEmpresa VARCHAR(50) NULL;
            IF COL_LENGTH('SACONF', 'TokenSecuencial') IS NULL
	            ALTER TABLE dbo.SACONF ADD TokenSecuencial VARCHAR(50) NULL;
            IF COL_LENGTH('SACONF', 'FechaUV') IS NULL
	            ALTER TABLE dbo.SACONF ADD FechaUV datetime NULL;

            IF COL_LENGTH('SAMUNICIPIO', 'Pais') IS NULL
	            ALTER TABLE dbo.SAMUNICIPIO ADD [Pais] int  NOT NULL DEFAULT(0);
            IF COL_LENGTH('SAMUNICIPIO', 'Estado') IS NULL
	            ALTER TABLE dbo.SAMUNICIPIO ADD [Estado] int  NOT NULL DEFAULT(0);
            IF COL_LENGTH('SACIUDAD', 'Pais') IS NULL
	            ALTER TABLE dbo.SACIUDAD ADD [Pais] int  NOT NULL DEFAULT(0);

            IF COL_LENGTH('SAPAIS', 'PhoneCode') IS NULL
	            ALTER TABLE dbo.SAPAIS ADD PhoneCode int NULL;
            IF COL_LENGTH('SAPAIS', 'SPais') IS NULL
                ALTER TABLE dbo.SAPAIS ADD SPais VARCHAR(30) NULL;
            IF COL_LENGTH('SAPAIS', 'SEstado') IS NULL
                ALTER TABLE dbo.SAPAIS ADD SEstado VARCHAR(30) NULL;
            IF COL_LENGTH('SAPAIS', 'SCiudad') IS NULL
                ALTER TABLE dbo.SAPAIS ADD SCiudad VARCHAR(30) NULL;
            IF COL_LENGTH('SAPAIS', 'SMunicipio') IS NULL
                ALTER TABLE dbo.SAPAIS ADD SMunicipio VARCHAR(30) NULL;
            IF COL_LENGTH('SAPAIS', 'SortName') IS NULL
                ALTER TABLE dbo.SAPAIS ADD SortName VARCHAR(6) NULL;

            IF COL_LENGTH('SATAXES', 'CodFacE') IS NULL
	            ALTER TABLE dbo.SATAXES ADD CodFacE VARCHAR(10) NULL

            IF COL_LENGTH('SATAXVTA', 'EsReten') IS NULL
              ALTER TABLE dbo.SATAXVTA ADD [EsReten] [smallint] NOT NULL DEFAULT ((0.00));

            if COL_LENGTH('SAFACT', 'NumeroF') < 20
                alter table SAFACT alter column NumeroF varchar(20) null;
            if COL_LENGTH('SAFACT', 'NumeroP') < 15
                alter table SAFACT alter column NumeroP varchar(15) null;
            if COL_LENGTH('SAFACT', 'ONumero') < 20
                alter table SAFACT alter column ONumero varchar(20) null;
            IF COL_LENGTH('SAFACT', 'HaciendaRespuesta') IS NULL
	            ALTER TABLE dbo.SAFACT ADD [HaciendaRespuesta] [varchar](2000) NULL;
            IF COL_LENGTH('SAFACT', 'ProveedorRespuesta') IS NULL
	            ALTER TABLE dbo.SAFACT ADD [ProveedorRespuesta] [varchar](2000) NULL;

            IF COL_LENGTH('SAFACT', 'ProveedorRespuesta') IS NULL
	            ALTER TABLE dbo.SAFACT ADD [ProveedorRespuesta] [varchar](2000) NULL;

            IF COL_LENGTH('SAFACT', 'RespuestaError') IS NULL
	            ALTER TABLE dbo.SAFACT ADD [RespuestaError] [varchar](4000) NULL;

            if COL_LENGTH('SAFACT', 'HaciendaRespuesta') < 2000
                alter table SAFACT alter column HaciendaRespuesta varchar(2000) null;
            if COL_LENGTH('SAFACT', 'ProveedorRespuesta') < 2000
                alter table SAFACT alter column ProveedorRespuesta varchar(2000) null;

            if (select count(*) from SAFIEL where tablename= 'SAFACT' and fieldname = 'HaciendaRespuesta') = 0
            begin
            insert into SAFIEL
	            (tablename,fieldname,fieldalias,datatype,selectable,searchable,sortable,autosearch,mandatory)
	            select 'SAFACT','HaciendaRespuesta','Hacienda_Respuesta','dtString','T','T','T','F','F'
            end;

            if (select count(*) from SAFIEL where tablename= 'SAFACT' and fieldname = 'ProveedorRespuesta') = 0
            begin
            insert into SAFIEL
	            (tablename,fieldname,fieldalias,datatype,selectable,searchable,sortable,autosearch,mandatory)
	            select 'SAFACT','ProveedorRespuesta','Proveedor_Respuesta','dtString','T','T','T','F','F'
            end;

            IF COL_LENGTH('SAFACT', 'HaciendaFecha1') IS NULL
	            ALTER TABLE dbo.SAFACT ADD [HaciendaFecha1] [date] NULL;
            if (select count(*) from SAFIEL where tablename= 'SAFACT' and fieldname = 'HaciendaFecha1') = 0
            begin
            insert into SAFIEL
	            (tablename,fieldname,fieldalias,datatype,selectable,searchable,sortable,autosearch,mandatory)
	            select 'SAFACT','HaciendaFecha1','Hacienda_Fecha1','dtString','T','T','T','F','F'
            end;

            IF COL_LENGTH('SAFACT', 'EsMonedaTran') IS NULL
	            ALTER TABLE dbo.SAFACT ADD [EsMonedaTran] [smallint] NOT NULL DEFAULT ((0.00));
            if (select count(*) from SAFIEL where tablename= 'SAFACT' and fieldname = 'EsMonedaTran') = 0
            begin
            insert into SAFIEL
	            (tablename,fieldname,fieldalias,datatype,selectable,searchable,sortable,autosearch,mandatory)
	            select 'SAFACT','EsMonedaTran','EsMonedaTran','dtInteger','T','T','T','F','F'
            end;


            IF COL_LENGTH('SAITEMFAC', 'TipoPVP') IS NULL
	            ALTER TABLE dbo.SAITEMFAC ADD [TipoPVP] smallint NOT NULL DEFAULT(0);
            IF COL_LENGTH('SAITEMFAC', 'MtoTaxO') IS NULL
	            ALTER TABLE dbo.SAITEMFAC ADD [MtoTaxO] Decimal(28,4) NOT NULL DEFAULT(0);

            IF COL_LENGTH('SACLIE', 'CodSucu') IS NULL
	            ALTER TABLE SACLIE ADD CodSucu varchar(5) NULL DEFAULT('00000')
            IF COL_LENGTH('SACLIE', 'EsReten') IS NULL
	            ALTER TABLE dbo.SACLIE ADD [EsReten] smallint NOT NULL DEFAULT(0);


            IF COL_LENGTH('SAIPAVTA', 'Factor') IS NULL
	            ALTER TABLE dbo.SAIPAVTA ADD [Factor] Decimal(28,4) NOT NULL DEFAULT(0);

            IF COL_LENGTH('SAIPAVTA', 'MontoMEx') IS NULL
	            ALTER TABLE dbo.SAIPAVTA ADD [MontoMEx] Decimal(28,4) NOT NULL DEFAULT(0);

            update SAFACT set 
                NumeroP = 'NOENVIADA'
            where 
                NumeroP = '**Error IF**'

            if (select count(*) from SAFIEL where tablename= 'SAFACT' and fieldname = 'ONumero') = 0
            begin
            insert into SAFIEL
	            (tablename,fieldname,fieldalias,datatype,selectable,searchable,sortable,autosearch,mandatory)
	            select 'SAFACT','ONumero','ONumero','dtString','T','T','T','F','F'
            end;
GO

-- Session: 62 | Start: 2026-03-13 09:06:12.477000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ROSA%') OR (Descrip LIKE 'ROSA%') OR (ID3 LIKE 'ROSA%') OR (Clase LIKE 'ROSA%') OR (Saldo LIKE 'ROSA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 64 | Start: 2026-03-13 09:06:20.653000 | Status: runnable | Cmd: CONDITIONAL
USE [ENTERPRISEADMIN_AMC]
                                 SET ANSI_NULLS ON
                                 SET QUOTED_IDENTIFIER ON
                                 BEGIN TRY
                                     BEGIN
                                         SET NOCOUNT ON
		                                 SET DATEFORMAT YMD
		
		                                 BEGIN TRAN "215C950595824BB279914959"

                                         BEGIN
                                             IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'TotalApp_App' AND column_name = 'CodSucu') 
BEGIN 
    ALTER TABLE TotalApp_App ADD CodSucu NVARCHAR(10) 
END 
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'TotalApp_App' AND column_name = 'Station')
BEGIN 
    ALTER TABLE TotalApp_App ADD Station NVARCHAR(4000) 
END 
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'TotalApp_App' AND column_name = 'Addon')
BEGIN 
    ALTER TABLE TotalApp_App ADD Addon NVARCHAR(4000) 
END 
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'TotalApp_App' AND column_name = 'DateRegLic')
BEGIN 
    ALTER TABLE TotalApp_App ADD DateRegLic DATETIME 
END 
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'TotalApp_App' AND column_name = 'DateUpdLic')
BEGIN 
    ALTER TABLE TotalApp_App ADD DateUpdLic DATETIME 
END 
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'TotalApp_App' AND column_name = 'LicCountry')
BEGIN 
    ALTER TABLE TotalApp_App ADD LicCountry VARCHAR(3) 
END 


                                         END
                                         COMMIT TRAN "215C950595824BB279914959"

                                     END
                                 END TRY
                                 BEGIN CATCH
                                      DECLARE @ErrorMessage NVARCHAR(4000);
								      DECLARE @ErrorSeverity INT;
								      DECLARE @ErrorState INT;

								      SELECT @ErrorMessage = ERROR_MESSAGE(),
									         @ErrorSeverity = ERROR_SEVERITY(),
									         @ErrorState = ERROR_STATE();

									 IF @@TRANCOUNT > 0

                                     BEGIN
                                         ROLLBACK TRAN "215C950595824BB279914959"
                                     END

                                   
                                    RAISERROR(@ErrorMessage,
                                               @ErrorSeverity,
                                               @ErrorState-- State.

                                               );
                                 END CATCH
                                 SET NOCOUNT ON
                                 SET ANSI_NULLS OFF
                                 SET QUOTED_IDENTIFIER OFF
GO

-- Session: 62 | Start: 2026-03-13 09:06:34.920000 | Status: running | Cmd: EXECUTE
SELECT SAFACT.AutSRI, SAFACT.Cambio, 
       SAFACT.CancelA, SAFACT.CancelC, 
       SAFACT.CancelE, SAFACT.CancelG, 
       SAFACT.CancelI, SAFACT.CancelP, 
       SAFACT.CancelT, SAFACT.CancelTips, 
       SAFACT.CodClie, SAFACT.CodAlte, 
       SAFACT.CodConv, SAFACT.CodEsta, 
       SAFACT.CodOper, SAFACT.CodSucu, 
       SAFACT.CodUbic, SAFACT.CodUsua, 
       SAFACT.CodTarj, SAFACT.CodVend, 
       SAFACT.CodTran, SAFACT.Contado, 
       SAFACT.CostoPrd, SAFACT.CostoSrv, 
       SAFACT.Credito, SAFACT.Descrip, 
       SAFACT.Descto1, SAFACT.Descto2, 
       SAFACT.DesctoP, SAFACT.DetalChq, 
       SAFACT.Direc1, SAFACT.Direc2, 
       SAFACT.Direc3, SAFACT.EsCorrel, 
       SAFACT.Factor, SAFACT.FechaE, 
       SAFACT.FechaI, SAFACT.FechaR, 
       SAFACT.FechaV, SAFACT.Fletes, SAFACT.ID3, 
       SAFACT.Monto, SAFACT.MontoMEx, 
       SAFACT.MtoComiCob, SAFACT.MtoComiCobD, 
       SAFACT.MtoComiVta, SAFACT.MtoComiVtaD, 
       SAFACT.MtoExtra, SAFACT.MtoFinanc, 
       SAFACT.MtoInt1, SAFACT.MtoInt2, 
       SAFACT.MtoNCredito, SAFACT.MtoNDebito, 
       SAFACT.MtoPagos, SAFACT.MtoTax, 
       SAFACT.MtoTotal, SAFACT.NGiros, 
       SAFACT.NMeses, SAFACT.Notas1, 
       SAFACT.Notas10, SAFACT.Notas2, 
       SAFACT.Notas3, SAFACT.Notas4, 
       SAFACT.Notas5, SAFACT.Notas6, 
       SAFACT.Notas7, SAFACT.Notas8, 
       SAFACT.Notas9, SAFACT.NroCtrol, 
       SAFACT.NroEstable, SAFACT.NroUnico, 
       SAFACT.NumeroD, SAFACT.NumeroE, 
       SAFACT.NumeroF, SAFACT.NroTurno, 
       SAFACT.NumeroNCF, SAFACT.OrdenC, 
       SAFACT.NumeroP, SAFACT.NroUnicoL, 
       SAFACT.NumeroR, SAFACT.NumeroT, 
       SAFACT.NumeroZ, SAFACT.RetenIVA, 
       SAFACT.PctAnual, SAFACT.PctManejo, 
       SAFACT.PtoEmision, SAFACT.NumeroU, 
       SAFACT.SaldoAct, SAFACT.Signo, 
       SAFACT.Telef, SAFACT.Parcial, 
       SAFACT.TExento, SAFACT.TGravable, 
       SAFACT.TipoFac, SAFACT.TipoTraE, 
       SAFACT.TotalPrd, SAFACT.TotalSrv, 
       SAFACT.ValorPtos, SAFACT.ZipCode, 
       SAVEND.Activo, SAVEND.Clase, 
       SAVEND.Descrip Descrip_2, 
       SAFACT.TGravable0, 
       SAVEND.CodVend CodVend_2, SAFACT.TipoDev, 
       SAVEND.Direc1 Direc1_2, 
       SACONV.Descrip Descrip_3, 
       SAVEND.Direc2 Direc2_2, SAVEND.Email, 
       SAVEND.FechaUC, SAVEND.FechaUV, 
       SAVEND.ID3 ID3_2, SAVEND.Movil, 
       SAVEND.Telef Telef_2, SAVEND.TipoID, 
       SAVEND.TipoID3, SACLIE.Activo Activo_2, 
       SACLIE.Ciudad, SACLIE.Clase Clase_2, 
       SACLIE.CodAlte CodAlte_2, 
       SACLIE.CodClie CodClie_2, 
       SACLIE.CodConv CodConv_2, 
       SACLIE.CodVend CodVend_3, SACLIE.CodZona, 
       SACLIE.Descrip Descrip_4, 
       SACLIE.DescripExt, SACLIE.Descto, 
       SACLIE.DiasCred, SACLIE.DiasTole, 
       SACLIE.Direc1 Direc1_3, 
       SACLIE.Direc2 Direc2_3, 
       SACLIE.Email Email_2, SACLIE.EsCredito, 
       SACLIE.EsMoneda, SACLIE.Estado, 
       SACLIE.EsToleran, SACLIE.Fax, 
       SACLIE.FechaE FechaE_2, SACLIE.FechaUP, 
       SACLIE.FechaUV FechaUV_2, 
       SACLIE.ID3 ID3_3, SACLIE.IntMora, 
       SACLIE.LimiteCred, SACLIE.MontoMax, 
       SACLIE.EsReten, SACLIE.MontoUP, 
       SACLIE.MontoUV, SACLIE.Movil Movil_2, 
       SACLIE.MtoMaxCred, SACLIE.Municipio, 
       SACLIE.NumeroUP, SACLIE.NumeroUV, 
       SACLIE.Observa, SACLIE.PagosA, 
       SACLIE.Pais, SACLIE.PromPago, 
       SACLIE.Represent, 
       SACLIE.RetenIVA RetenIVA_2, SACLIE.Saldo, 
       SACLIE.SaldoPtos, SACLIE.Telef Telef_3, 
       SACLIE.TipoCli, SACLIE.TipoID TipoID_2, 
       SACLIE.TipoID3 TipoID3_2, SACLIE.TipoPVP, 
       SACLIE.ZipCode ZipCode_2, 
       SACONV.Activo Activo_3, SACONV.Autori, 
       SACONV.CodConv CodConv_3, SACONV.EsFijo, 
       SACONV.FechaE FechaE_3, 
       SACONV.FechaV FechaV_2, SACONV.Respon, 
       SACONV.TipoCnv, SACLIE.TipoReg
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44373' )
GO

-- Session: 58 | Start: 2026-03-13 09:06:36.437000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD
    Declare @FactorMul as decimal(28,3) = (select FactorM from SACONF where CodSucu='00000'  )
    Declare @PreFacPV varchar(10)= '*'

    

    SELECT F.TipoFac
        ,F.NumeroD
        ,F.FechaE
        ,isnull(F.ID3,'') ID3
        ,isnull(F.Descrip,'') Descrip
        ,isnull(C.Direc1,'') Direc1
        ,isnull(C.Direc2,'') Direc2
        ,isnull(C.Telef,'') Telef
        ,isnull(F.NumeroR,'') NumeroR
        ,F.MtoTotal
        ,'' V
        ,isnull(F.NroCtrol,'') NroCtrol
        ,isnull(F.CodUsua,'') CodUsua
        ,isnull(F.CodVend,'') CodVend
  	    ,F.CancelE 
        ,F.CancelT 
        ,F.CancelC 
        ,F.CancelI 
        ,F.CancelA 
        ,F.Contado 
        ,F.Credito+F.MtoFinanc Credito 
        ,F.FechaV
        ,isnull(C.DescripExt,'') DescripExt
        ,F.Descto1+F.Descto2 Descuentos
        ,F.Descto1+F.Descto2 DescuentosOri
        ,F.DesctoP DescuentosParcial
		,(case when isnull(sum(itf.Cantidad*itf.Precio),0) > 0 then ((F.Descto1+F.Descto2)*100)/sum(itf.Cantidad*itf.Precio) else 0 end) DescuentosPorc
        ,F.Fletes Fletes
        ,CAST(ROUND(F.Monto,3,1) as DECIMAL(18,3)) Monto 
        ,isnull(sum(CAST(ROUND(itf.Cantidad*itf.Precio,3,1) as DECIMAL(18,3))),0) MontoItems
        ,CAST(ROUND(F.Monto,4,1) as DECIMAL(18,4)) MontoOri 
        ,isnull(sum(CAST(ROUND(itf.Cantidad*itf.Precio,4,1) as DECIMAL(18,4))),0) MontoItemsOri
        ,CAST(ROUND(F.TGravable,2,1) as DECIMAL(18,4)) TGravable
        ,F.TExento
        ,CAST(ROUND(F.MtoTax,2,1) as DECIMAL(18,2)) as MontoImp
        ,F.RetenIVA 
        ,isnull(F.ONumero,'') ONumero
        ,isnull(F.Notas1,'') Notas1
        ,isnull(F.Notas2,'') Notas2
        ,isnull(F.Notas3,'') Notas3
        ,isnull(F.Notas4,'') Notas4
        ,isnull(F.Notas5,'') Notas5
        ,isnull(F.Notas6,'') Notas6
        ,isnull(F.Notas7,'') Notas7
        ,isnull(F.Notas8,'') Notas8
        ,isnull(F.Notas9,'') Notas9
        ,isnull(F.Notas10,'') Notas10
        ,isnull(C.ID3,'')  SaClieID3
        ,isnull(C.TipoCli,1) TipoCli
        ,isnull(C.TipoID3,0) TipoID3
        ,isnull(C.TipoID,0) TipoID
        ,isnull(C.Email,'') Email
        ,isnull(C.Estado,2) EstadoCod
        ,isnull(C.Ciudad,2001) CiudadCod
	    ,isnull(C.Municipio,2001) MunicipioCod
        ,isnull(Vend.Descrip,'') DescVend
        ,F.CodClie
        ,F.NROUNICO NroUnico
        ,F.CodSucu
        ,isnull(F.OrdenC,'') OrdenC
        ,isnull((case when F.Factor =1 then @FactorMul else F.Factor end),1) Factor
        ,isnull(C.EsMoneda,0) EsMoneda
        ,(case @PreFacPV when  left(F.NumeroD,len(@PreFacPV)) then 1  else 0 end) EsPuntoVentas
        ,isnull(F.ProveedorRespuesta,'') ProveedorRespuesta
        ,isnull(cast(ITF.Numerod as varchar(100)),F.NumeroD+' IF: La transacción no tiene detalles o ítems.')+isnull(F.RespuestaError,'') RespuestaError
        ,'VEN' Pais
        ,isnull(F.HaciendaRespuesta,'') HaciendaRespuesta
    FROM dbo.SAFACT F  with (nolock)
    inner join SAITEMFAC ITF with (nolock) on
        F.CodSucu = ITF.CodSucu and
        F.TipoFac = ITF.TipoFac and
        F.NumeroD = ITF.NumeroD 
    left join dbo.SACLIE C on  
        F.CodCLie = C.CodClie  
    Left join dbo.SAVEND Vend on  
        F.CodVend = Vend.CodVend  
    where 
        F.CodSucu='00000' 
        AND isnull(ITF.NroLineaC,0) = 0

        AND F.CodEsta in ('CAJA001', 'CAJA01', 'CAJA02', 'CAJA03', 'CAJA10') 

    
        AND ISNULL(NULLIF(F.NumeroP, 'PRINTER-TESTER'),'') = '' 
        AND F.TipoFac in ('A','B') 


    group by 
        F.NROUNICO,F.Tipofac,F.NumeroD,F.FechaE,F.ID3,F.Descrip,C.Direc1,C.Direc2,C.Telef,F.NumeroR,F.MtoTotal
        ,F.NroCtrol,F.CodUsua,F.CodVend,F.CancelE ,F.CancelT ,F.CancelC ,F.CancelI ,F.CancelA ,F.Contado ,(F.Credito+F.MtoFinanc)
        ,F.FechaV,C.DescripExt,F.Descto1,F.Descto2,F.DesctoP,F.Fletes,F.Monto,F.TGravable,F.TExento,F.MtoTax,F.RetenIVA
        ,F.ONumero,F.Notas1,F.Notas2,F.Notas3,F.Notas4,F.Notas5,F.Notas6,F.Notas7,F.Notas8,F.Notas9,F.Notas10
        ,C.ID3,C.TipoCli,C.TipoID3,C.TipoID,C.Email,C.Estado,C.Ciudad,C.Municipio,Vend.Descrip,F.CodClie,F.CodSucu,F.OrdenC,F.Factor
        ,C.EsMoneda,F.ProveedorRespuesta,F.RespuestaError,ITF.Numerod,F.HaciendaRespuesta
    Having Count(itf.CodItem) > 0
Order by F.NROUNICO
GO

-- Session: 58 | Start: 2026-03-13 09:06:40.490000 | Status: suspended | Cmd: SELECT
select 
	count(NumeroD) Conteo
from SAFACT F with (nolock)
	where 
        CodSucu = '00000'
		and NumeroP in ('**Error IF**','NOENVIADA')
        
AND F.CodEsta in ('CAJA001', 'CAJA01', 'CAJA02', 'CAJA03', 'CAJA10')
GO

-- Session: 61 | Start: 2026-03-13 09:09:15.097000 | Status: running | Cmd: SELECT
create procedure sys.sp_pkeys
(
    @table_name      sysname,
    @table_owner     sysname = null,
    @table_qualifier sysname = null
)
as
    declare @table_id           int
    -- quotename() returns up to 258 chars
    declare @full_table_name    nvarchar(517) -- 258 + 1 + 258

    if @table_qualifier is not null
    begin
        if db_name() <> @table_qualifier
        begin   -- If qualifier doesn't match current database
            raiserror (15250, -1,-1)
            return
        end
    end

    if @table_owner is null
    begin   -- If unqualified table name
        select @full_table_name = quotename(@table_name)
    end
    else
    begin   -- Qualified table name
        if @table_owner = ''
        begin   -- If empty owner name
            select @full_table_name = quotename(@table_owner)
        end
        else
        begin
            select @full_table_name = quotename(@table_owner) + '.' + quotename(@table_name)
        end
    end

    select @table_id = object_id(@full_table_name)

    select
        TABLE_QUALIFIER = convert(sysname,db_name()),
        TABLE_OWNER = convert(sysname,schema_name(o.schema_id)),
        TABLE_NAME = convert(sysname,o.name),
        COLUMN_NAME = convert(sysname,c.name),
        KEY_SEQ = convert (smallint,
            case
                when c.name = index_col(@full_table_name, i.index_id,  1) then 1
                when c.name = index_col(@full_table_name, i.index_id,  2) then 2
                when c.name = index_col(@full_table_name, i.index_id,  3) then 3
                when c.name = index_col(@full_table_name, i.index_id,  4) then 4
                when c.name = index_col(@full_table_name, i.index_id,  5) then 5
                when c.name = index_col(@full_table_name, i.index_id,  6) then 6
                when c.name = index_col(@full_table_name, i.index_id,  7) then 7
                when c.name = index_col(@full_table_name, i.index_id,  8) then 8
                when c.name = index_col(@full_table_name, i.index_id,  9) then 9
                when c.name = index_col(@full_table_name, i.index_id, 10) then 10
                when c.name = index_col(@full_table_name, i.index_id, 11) then 11
                when c.name = index_col(@full_table_name, i.index_id, 12) then 12
                when c.name = index_col(@full_table_name, i.index_id, 13) then 13
                when c.name = index_col(@full_table_name, i.index_id, 14) then 14
                when c.name = index_col(@full_table_name, i.index_id, 15) then 15
                when c.name = index_col(@full_table_name, i.index_id, 16) then 16
            end),
        PK_NAME = convert(sysname,k.name)
    from
        sys.indexes i,
        sys.all_columns c,
        sys.all_objects o,
        sys.key_constraints k
    where
        o.object_id = @table_id and
        o.object_id = c.object_id and
        o.object_id = i.object_id and
        k.parent_object_id = o.object_id and 
        k.unique_index_id = i.index_id and 
        i.is_primary_key = 1 and
        (c.name = index_col (@full_table_name, i.index_id,  1) or
         c.name = index_col (@full_table_name, i.index_id,  2) or
         c.name = index_col (@full_table_name, i.index_id,  3) or
         c.name = index_col (@full_table_name, i.index_id,  4) or
         c.name = index_col (@full_table_name, i.index_id,  5) or
         c.name = index_col (@full_table_name, i.index_id,  6) or
         c.name = index_col (@full_table_name, i.index_id,  7) or
         c.name = index_col (@full_table_name, i.index_id,  8) or
         c.name = index_col (@full_table_name, i.index_id,  9) or
         c.name = index_col (@full_table_name, i.index_id, 10) or
         c.name = index_col (@full_table_name, i.index_id, 11) or
         c.name = index_col (@full_table_name, i.index_id, 12) or
         c.name = index_col (@full_table_name, i.index_id, 13) or
         c.name = index_col (@full_table_name, i.index_id, 14) or
         c.name = index_col (@full_table_name, i.index_id, 15) or
         c.name = index_col (@full_table_name, i.index_id, 16))
         
    order by 1, 2, 3, 5
GO

-- Session: 61 | Start: 2026-03-13 09:09:42.840000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'EQUIPO%') OR (SP.DESCRIPALL LIKE 'EQUIPO%') OR (SP.REFERE LIKE 'EQUIPO%') OR (SP.EXISTEN LIKE 'EQUIPO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 09:12:26.500000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '%MACRO%') OR (SP.DESCRIPALL LIKE '%MACRO%') OR (SP.REFERE LIKE '%MACRO%') OR (SP.EXISTEN LIKE '%MACRO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 54 | Start: 2026-03-13 09:16:00.100000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 65 | Start: 2026-03-13 09:17:31.540000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 61 | Start: 2026-03-13 09:21:31.903000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'BLI_SILDE%') OR (SP.DESCRIPALL LIKE 'BLI_SILDE%') OR (SP.REFERE LIKE 'BLI_SILDE%') OR (SP.EXISTEN LIKE 'BLI_SILDE%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 09:21:44.513000 | Status: running | Cmd: SELECT
(@P1 varchar(15))SELECT *
  FROM SAIPRD IG WITH (NOLOCK)
 WHERE IG.CODPROD=@P1
GO

-- Session: 62 | Start: 2026-03-13 09:22:05.140000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY CodServ ASC) AS ROWNUM   FROM VW_ADM_SERVICIOS WITH (NOLOCK) 
  WHERE ((CodServ LIKE 'TUBO%') OR (DescripAll LIKE 'TUBO%') OR (Clase LIKE 'TUBO%')) AND (ACTIVO=1) AND (EsVenta=1))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 51 | Start: 2026-03-13 09:46:00.363000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 62 | Start: 2026-03-13 09:52:24.663000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT * FROM VW_ADM_TAXINVENT WITH (NOLOCK) WHERE  (ESTAXVENTA>0) AND CodProd='7591196004208'
GO

-- Session: 61 | Start: 2026-03-13 09:54:18.210000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'TOMMY%') OR (SP.DESCRIPALL LIKE 'TOMMY%') OR (SP.REFERE LIKE 'TOMMY%') OR (SP.EXISTEN LIKE 'TOMMY%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 09:55:51.163000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 09:55:56.217000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CODPROD LIKE 'FITEX%') OR (SP.DESCRIPALL LIKE 'FITEX%') OR (SP.REFERE LIKE 'FITEX%') OR (SP.EXISTEN LIKE 'FITEX%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 09:57:29.980000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 09:57:30.910000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'NA%') OR (Descrip LIKE 'NA%') OR (ID3 LIKE 'NA%') OR (Clase LIKE 'NA%') OR (Saldo LIKE 'NA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 65 | Start: 2026-03-13 09:57:39.240000 | Status: runnable | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 66 | Start: 2026-03-13 10:00:00.640000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 69 | Start: 2026-03-13 10:03:00.103000 | Status: runnable | Cmd: UPDATE
UPDATE SAPROD 
SET PrecioI1=b.precio$1,PrecioI2=b.precio$2,PrecioI3=b.precio$3
from SAPROD as a
inner join CUSTOM_PRECIO_EN_DOLAR as b on (a.CodProd=b.codprod)
GO

-- Session: 69 | Start: 2026-03-13 10:09:37.477000 | Status: runnable | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 69 | Start: 2026-03-13 10:10:00.530000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 61 | Start: 2026-03-13 10:10:10.997000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7597758000145') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 51 | Start: 2026-03-13 10:10:58.533000 | Status: suspended | Cmd: SELECT
SELECT asf.assembly_id, asi.name, asf.content FROM [sys].[assembly_files] asf INNER JOIN [sys].[assemblies] asi ON asi.assembly_id = asf.assembly_id
GO

-- Session: 61 | Start: 2026-03-13 10:11:11.687000 | Status: running | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V10915197'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 10:11:10.747','2026-03-13 10:11:10.934','2026-03-13 10:11:10.747',1,1,'V10915197','CAJA004','V12400678','12400678','AMR001','ROSA','CARACAS','V10915197',1607.96,1607.96,443.25,3.63,1607.96,1607.96,1607.96,1607.96);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1055564;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 10:11:11.012'
 WHERE (CodProd='7597758000145');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7597758000145') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597758000145','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7597758000145') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1055564
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 10:11:11.028','7597758000145','2.15985','AMR001','AZITROMICINA 500      MG X 5',1.00,1.00,812.68,1.00,1607.963,1607.963,3,1607.963,'12400678','V12400678',1,1,'6987',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-01-27 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=812.68   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1607.96,1.00,'2026-03-13 10:11:08.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 67 | Start: 2026-03-13 10:15:00.267000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_jobstep_completion_state]
    @job_id                UNIQUEIDENTIFIER,
    @step_id               INT,
    @last_run_outcome      INT,
    @last_run_duration     INT,
    @last_run_retries      INT,
    @last_run_date         INT,
    @last_run_time         INT,
    @session_id            INT
AS
BEGIN
    -- Update job step completion state in sysjobsteps as well as sysjobactivity
    UPDATE [msdb].[dbo].[sysjobsteps]
    SET last_run_outcome      = @last_run_outcome,
        last_run_duration     = @last_run_duration,
        last_run_retries      = @last_run_retries,
        last_run_date         = @last_run_date,
        last_run_time         = @last_run_time
    WHERE job_id   = @job_id
    AND   step_id  = @step_id

    DECLARE @last_executed_step_date DATETIME
    SET @last_executed_step_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET last_executed_step_date = @last_executed_step_date,
        last_executed_step_id   = @step_id
    WHERE job_id     = @job_id
    AND   session_id = @session_id
END
GO

-- Session: 65 | Start: 2026-03-13 10:30:00.527000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 65 | Start: 2026-03-13 10:30:31.627000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 61 | Start: 2026-03-13 10:33:31.743000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='AZITROMI' OR P.CodProd='AZITROMI')
GO

-- Session: 59 | Start: 2026-03-13 10:39:37.920000 | Status: running | Cmd: SELECT
(@P1 nvarchar(4),@P2 nvarchar(4),@P3 nvarchar(4),@P4 nvarchar(4))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 61 | Start: 2026-03-13 10:43:59.960000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.EXISTEN DESC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'BLI_AMPI%') OR (SP.DESCRIPALL LIKE 'BLI_AMPI%') OR (SP.REFERE LIKE 'BLI_AMPI%') OR (SP.EXISTEN LIKE 'BLI_AMPI%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 10:44:51.933000 | Status: suspended | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='BLI_AMPICI_500M') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 64 | Start: 2026-03-13 10:48:11.927000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CODPROD LIKE 'GINKG%') OR (SP.DESCRIPALL LIKE 'GINKG%') OR (SP.REFERE LIKE 'GINKG%') OR (SP.EXISTEN LIKE 'GINKG%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 10:53:27.467000 | Status: runnable | Cmd: SELECT
SELECT SAFACT.AutSRI, SAFACT.Cambio, 
       SAFACT.CancelA, SAFACT.CancelC, 
       SAFACT.CancelE, SAFACT.CancelG, 
       SAFACT.CancelI, SAFACT.CancelP, 
       SAFACT.CancelT, SAFACT.CancelTips, 
       SAFACT.CodClie, SAFACT.CodAlte, 
       SAFACT.CodConv, SAFACT.CodEsta, 
       SAFACT.CodOper, SAFACT.CodSucu, 
       SAFACT.CodUbic, SAFACT.CodUsua, 
       SAFACT.CodTarj, SAFACT.CodVend, 
       SAFACT.CodTran, SAFACT.Contado, 
       SAFACT.CostoPrd, SAFACT.CostoSrv, 
       SAFACT.Credito, SAFACT.Descrip, 
       SAFACT.Descto1, SAFACT.Descto2, 
       SAFACT.DesctoP, SAFACT.DetalChq, 
       SAFACT.Direc1, SAFACT.Direc2, 
       SAFACT.Direc3, SAFACT.EsCorrel, 
       SAFACT.Factor, SAFACT.FechaE, 
       SAFACT.FechaI, SAFACT.FechaR, 
       SAFACT.FechaV, SAFACT.Fletes, SAFACT.ID3, 
       SAFACT.Monto, SAFACT.MontoMEx, 
       SAFACT.MtoComiCob, SAFACT.MtoComiCobD, 
       SAFACT.MtoComiVta, SAFACT.MtoComiVtaD, 
       SAFACT.MtoExtra, SAFACT.MtoFinanc, 
       SAFACT.MtoInt1, SAFACT.MtoInt2, 
       SAFACT.MtoNCredito, SAFACT.MtoNDebito, 
       SAFACT.MtoPagos, SAFACT.MtoTax, 
       SAFACT.MtoTotal, SAFACT.NGiros, 
       SAFACT.NMeses, SAFACT.Notas1, 
       SAFACT.Notas10, SAFACT.Notas2, 
       SAFACT.Notas3, SAFACT.Notas4, 
       SAFACT.Notas5, SAFACT.Notas6, 
       SAFACT.Notas7, SAFACT.Notas8, 
       SAFACT.Notas9, SAFACT.NroCtrol, 
       SAFACT.NroEstable, SAFACT.NroUnico, 
       SAFACT.NumeroD, SAFACT.NumeroE, 
       SAFACT.NumeroF, SAFACT.NroTurno, 
       SAFACT.NumeroNCF, SAFACT.OrdenC, 
       SAFACT.NumeroP, SAFACT.NroUnicoL, 
       SAFACT.NumeroR, SAFACT.NumeroT, 
       SAFACT.NumeroZ, SAFACT.RetenIVA, 
       SAFACT.PctAnual, SAFACT.PctManejo, 
       SAFACT.PtoEmision, SAFACT.NumeroU, 
       SAFACT.SaldoAct, SAFACT.Signo, 
       SAFACT.Telef, SAFACT.Parcial, 
       SAFACT.TExento, SAFACT.TGravable, 
       SAFACT.TipoFac, SAFACT.TipoTraE, 
       SAFACT.TotalPrd, SAFACT.TotalSrv, 
       SAFACT.ValorPtos, SAFACT.ZipCode, 
       SAVEND.Activo, SAVEND.Clase, 
       SAVEND.Descrip Descrip_2, 
       SAFACT.TGravable0, 
       SAVEND.CodVend CodVend_2, SAFACT.TipoDev, 
       SAVEND.Direc1 Direc1_2, 
       SACONV.Descrip Descrip_3, 
       SAVEND.Direc2 Direc2_2, SAVEND.Email, 
       SAVEND.FechaUC, SAVEND.FechaUV, 
       SAVEND.ID3 ID3_2, SAVEND.Movil, 
       SAVEND.Telef Telef_2, SAVEND.TipoID, 
       SAVEND.TipoID3, SACLIE.Activo Activo_2, 
       SACLIE.Ciudad, SACLIE.Clase Clase_2, 
       SACLIE.CodAlte CodAlte_2, 
       SACLIE.CodClie CodClie_2, 
       SACLIE.CodConv CodConv_2, 
       SACLIE.CodVend CodVend_3, SACLIE.CodZona, 
       SACLIE.Descrip Descrip_4, 
       SACLIE.DescripExt, SACLIE.Descto, 
       SACLIE.DiasCred, SACLIE.DiasTole, 
       SACLIE.Direc1 Direc1_3, 
       SACLIE.Direc2 Direc2_3, 
       SACLIE.Email Email_2, SACLIE.EsCredito, 
       SACLIE.EsMoneda, SACLIE.Estado, 
       SACLIE.EsToleran, SACLIE.Fax, 
       SACLIE.FechaE FechaE_2, SACLIE.FechaUP, 
       SACLIE.FechaUV FechaUV_2, 
       SACLIE.ID3 ID3_3, SACLIE.IntMora, 
       SACLIE.LimiteCred, SACLIE.MontoMax, 
       SACLIE.EsReten, SACLIE.MontoUP, 
       SACLIE.MontoUV, SACLIE.Movil Movil_2, 
       SACLIE.MtoMaxCred, SACLIE.Municipio, 
       SACLIE.NumeroUP, SACLIE.NumeroUV, 
       SACLIE.Observa, SACLIE.PagosA, 
       SACLIE.Pais, SACLIE.PromPago, 
       SACLIE.Represent, 
       SACLIE.RetenIVA RetenIVA_2, SACLIE.Saldo, 
       SACLIE.SaldoPtos, SACLIE.Telef Telef_3, 
       SACLIE.TipoCli, SACLIE.TipoID TipoID_2, 
       SACLIE.TipoID3 TipoID3_2, SACLIE.TipoPVP, 
       SACLIE.ZipCode ZipCode_2, 
       SACONV.Activo Activo_3, SACONV.Autori, 
       SACONV.CodConv CodConv_3, SACONV.EsFijo, 
       SACONV.FechaE FechaE_3, 
       SACONV.FechaV FechaV_2, SACONV.Respon, 
       SACONV.TipoCnv, SACLIE.TipoReg
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44377' )
GO

-- Session: 62 | Start: 2026-03-13 10:59:12.597000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JOSE%') OR (Descrip LIKE 'JOSE%') OR (ID3 LIKE 'JOSE%') OR (Clase LIKE 'JOSE%') OR (Saldo LIKE 'JOSE%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 61 | Start: 2026-03-13 10:59:39.533000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591619000992') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 62 | Start: 2026-03-13 10:59:54.900000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'PEDRO%') OR (Descrip LIKE 'PEDRO%') OR (ID3 LIKE 'PEDRO%') OR (Clase LIKE 'PEDRO%') OR (Saldo LIKE 'PEDRO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 62 | Start: 2026-03-13 10:59:59.183000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'JER%') OR (SP.DescripAll LIKE 'JER%') OR (SP.Refere LIKE 'JER%') OR (SP.Existen LIKE 'JER%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 62 | Start: 2026-03-13 11:00:14.310000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT LO.CodProd, LO.CODUBIC, DP.DESCRIP,
       LO.Cantidad As Existen, LO.CantidadU As ExUnidad,
       LO.PUESTOI, EX.CANTCOM, EX.UNIDCOM, EX.CANTPED, EX.UNIDPED 
  FROM SALOTE LO WITH (NOLOCK) 
       INNER JOIN SAEXIS EX
          ON (LO.CODUBIC=EX.CODUBIC) 
       INNER JOIN SADEPO DP
          ON (DP.CODUBIC=EX.CODUBIC) 
 WHERE (LO.CODUBIC='AMR001') AND 
       (LO.CODSUCU='00000') AND 
       (LO.CODPROD='407') AND 
       (LO.NroUnico=1030741)
GO

-- Session: 51 | Start: 2026-03-13 11:10:00.713000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 51 | Start: 2026-03-13 11:10:20.580000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_next_scheduled_date]
    @session_id            INT,
    @job_id                UNIQUEIDENTIFIER,
	@is_system             TINYINT = 0,
    @last_run_date         INT,
    @last_run_time         INT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

   DECLARE @next_scheduled_run_date DATETIME
   SET @next_scheduled_run_date = NULL

   -- If last rundate and last runtime is not null then convert date, time to datetime
   IF (@last_run_date IS NOT NULL AND @last_run_time IS NOT NULL)
   BEGIN
        SET @next_scheduled_run_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)
   END

   UPDATE [msdb].[dbo].[sysjobactivity]
   SET next_scheduled_run_date = @next_scheduled_run_date
   WHERE session_id = @session_id
   AND job_id = @job_id
END
GO

-- Session: 61 | Start: 2026-03-13 11:18:54.327000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'CIE%') OR (SP.DescripAll LIKE 'CIE%') OR (SP.Refere LIKE 'CIE%') OR (SP.Existen LIKE 'CIE%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 11:19:20.990000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 11:21:51.590000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7703038040477' OR P.CodProd='7703038040477')
GO

-- Session: 61 | Start: 2026-03-13 11:22:05.190000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591821102071') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 62 | Start: 2026-03-13 11:26:45.573000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='DEPO' OR P.CodProd='DEPO')
GO

-- Session: 62 | Start: 2026-03-13 11:29:07.537000 | Status: runnable | Cmd: INSERT
SET DATEFORMAT YMD;
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE
   @ErrMsg        NVARCHAR(4000)
  ,@ErrorSeverity INT
  ,@ErrorState    INT
  ,@ErrorNumber   INT
  ,@ErrorLine     INT
  ,@OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V10915197'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
;
BEGIN TRANSACTION;
BEGIN TRY
  EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
  INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TGravable],[TExento],[MtoTax],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 11:19:43.274','2026-03-13 11:19:43.337','2026-03-13 11:19:43.274',1,1,'V10915197','BK-01','12394915','12394915','AMR001','ROSA','CARACAS','V10915197',7724.92,7749.85,443.25,17.48,7749.85,7724.92,155.84,7569.08,24.93,7749.85);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT');
  
INSERT INTO SATAXVTA ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[MtoTax],[TGravable],[Monto])
       VALUES ('00000','A',@NUMEROFAC,'IVA',16.00,155.84,24.93);
  SET @NROUNICOLOT=1055122
  UPDATE SAPROD SET FechaUV='2026-03-13 11:19:43.431'
 WHERE (CodProd='196852644438');
  SELECT @EXISTANT=0, @EXISTANTUND=0;
  SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='196852644438') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
  EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','196852644438','AMR001',-1.00,0,'2026-03-13';
  SELECT TOP 1 @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='196852644438') And (E.CodUbic='AMR001')
  IF @EXISTPRD<0 BEGIN
       SET @ErrMsg = 'Existencia cero o negativa!';
       RAISERROR(@ErrMsg, 16, 0);
     END;
  SET @NROUNICOLOT=1055122
  UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
  INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 11:19:43.446','196852644438','11.6119','AMR001','DEPOFEM MEDROXIPROGERSTERONA SOL IM 1 ML',1.00,1.00,4103.99,1.00,7569.08,7569.08,7569.08,'12394915','12394915',1,1,'34',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-01-14 00:00:00.000','1899-12-29 00:00:00.000');
  SET @NROUNICOLOT=1056412
  UPDATE SAPROD SET FechaUV='2026-03-13 11:19:43.462'
 WHERE (CodProd='JER_3CC');
  SELECT @EXISTANT=0, @EXISTANTUND=0;
  SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='JER_3CC') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
  EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','JER_3CC','AMR001',-1.00,0,'2026-03-13';
  SELECT TOP 1 @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='JER_3CC') And (E.CodUbic='AMR001')
  IF @EXISTPRD<0 BEGIN
       SET @ErrMsg = 'Existencia cero o negativa!';
       RAISERROR(@ErrMsg, 16, 0);
     END;
  SET @NROUNICOLOT=1056412
  UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
  INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[PriceO],[MtoTax],[MtoTaxO],[CodVend],[CodUsua],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,2,1,'2026-03-13 11:19:43.478','JER_3CC','0.166953','AMR001','JERINGA 3 ML 23GR X 1 1/4 HB',1.00,1.00,69.23,1.00,155.837,155.837,155.837,24.93392,24.93392,'12394915','12394915',1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-23 00:00:00.000','1899-12-29 00:00:00.000');
  INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','JER_3CC',155.837,16.00,24.93,2);
  UPDATE SAFACT SET 
   CostoPrd=4173.22   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
  INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,7749.85,1.00,'2026-03-13 00:00:00.000');
  UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  COMMIT TRANSACTION;
  SELECT 0 error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  SELECT
     @ErrMsg = ERROR_MESSAGE(),
     @ErrorSeverity = ERROR_SEVERITY(),
     @ErrorState = ERROR_STATE(),
     @ErrorNumber = ERROR_NUMBER(),
     @ErrorLine = ERROR_LINE();
  SET @ErrMsg = @ErrMsg+Char(13)+
      'Line: '+Cast(@ErrorLine As Varchar(10));
  SELECT -1 error, @ErrMsg errmsg, @ErrorSeverity errseverity;
  RAISERROR(@ErrMsg, @ErrorSeverity, @ErrorState);
END CATCH;
GO

-- Session: 65 | Start: 2026-03-13 11:30:05.850000 | Status: suspended | Cmd: INSERT
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END
GO

-- Session: 66 | Start: 2026-03-13 11:30:31.233000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 54 | Start: 2026-03-13 11:31:01.290000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_jobstep_completion_state]
    @job_id                UNIQUEIDENTIFIER,
    @step_id               INT,
    @last_run_outcome      INT,
    @last_run_duration     INT,
    @last_run_retries      INT,
    @last_run_date         INT,
    @last_run_time         INT,
    @session_id            INT
AS
BEGIN
    -- Update job step completion state in sysjobsteps as well as sysjobactivity
    UPDATE [msdb].[dbo].[sysjobsteps]
    SET last_run_outcome      = @last_run_outcome,
        last_run_duration     = @last_run_duration,
        last_run_retries      = @last_run_retries,
        last_run_date         = @last_run_date,
        last_run_time         = @last_run_time
    WHERE job_id   = @job_id
    AND   step_id  = @step_id

    DECLARE @last_executed_step_date DATETIME
    SET @last_executed_step_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET last_executed_step_date = @last_executed_step_date,
        last_executed_step_id   = @step_id
    WHERE job_id     = @job_id
    AND   session_id = @session_id
END
GO

-- Session: 61 | Start: 2026-03-13 11:32:11.220000 | Status: running | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='8908020242542' OR P.CodProd='8908020242542')
GO

-- Session: 62 | Start: 2026-03-13 11:33:32.653000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'FLOR%') OR (Descrip LIKE 'FLOR%') OR (ID3 LIKE 'FLOR%') OR (Clase LIKE 'FLOR%') OR (Saldo LIKE 'FLOR%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 70 | Start: 2026-03-13 11:45:00.550000 | Status: suspended | Cmd: INSERT
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END
GO

-- Session: 61 | Start: 2026-03-13 11:46:01.727000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='8906009231020') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 11:49:17.913000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'BISOPR%') OR (SP.DESCRIPALL LIKE 'BISOPR%') OR (SP.REFERE LIKE 'BISOPR%') OR (SP.EXISTEN LIKE 'BISOPR%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 11:49:51.603000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '7592349001570%') OR (SP.DESCRIPALL LIKE '7592349001570%') OR (SP.REFERE LIKE '7592349001570%') OR (SP.EXISTEN LIKE '7592349001570%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 54 | Start: 2026-03-13 11:51:03.533000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select Fecha
     , Sum(VNeta) VNetas
     , sum(VImpuesto) VImpuestos
     , sum (VCredito) VCredito
     , sum(VContado) VContado
     , sum(VAdelanto) VAdelantos
     , sum(VCobros) VCobros
     , sum(VAdelanto)+sum(VCobros) VTotalIngreso
     , sum(VCosto) VCostos
     ,(Sum(VNeta)-sum(VCosto)) VUtilidad
     , Sum(NFact) NFact
     , Sum(NDev) NDev
  from
      (select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
            , sum(F.Monto_Neto) VNeta 
            , sum(F.MtoTax) VImpuesto
            , Sum(F.Credito) VCredito 
            , sum(F.Contado) VContado
            , sum(F.CancelA)VAdelanto
            , 0 VCobros
            , sum((F.CostoPrd+F.CostoSrv)) VCosto
            , sum(IIF(F.TipoFac = 'A',1,0)) NFact
            , sum(IIF(F.TipoFac = 'B',1,0)) NDev
          from vw_adm_facturas F 
               left join SACLIE C 
                      on F.CodClie = C.CodClie
          where (F.FechaE >= (CONVERT(DATETIME,'2026-03-13',120)+' 00:00:00') and F.FechaE<= (CONVERT(DATETIME,'2026-03-13',120)+ ' 23:59:59')) 
            and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),F.FechaE,112))
       union all
       select convert(datetime,convert(varchar(8),CXC.FechaE,112)) Fecha
            , 0,0,0,0,0,sum(Monto),0,0,0
         from SAACXC CXC 
              left join SACLIE C 
                     on CXC.CodClie = C.CodClie
         where (CXC.TipoCxc in (41))  And (CXC.EsUnPago=1)  
           and (CXC.FechaE>=(CONVERT(DATETIME,'2026-03-13',120)+' 00:00:00') and CXC.FechaE<=(CONVERT(DATETIME,'2026-03-13',120)+' 23:59:59')) 
           and (SUBSTRING(ISNULL(CXC.CODOPER,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodClie,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CODVEND,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodUsua,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),CXC.FechaE,112))) as Ventas
  group by Fecha
  order by Fecha
GO

-- Session: 54 | Start: 2026-03-13 11:51:04.067000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
     , (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) Tipo
     , Numerod Numero
     , F.CodClie Codigo
     , C.Descrip Cliente
     ,(F.Monto_Neto) VNeta
     , F.MtoTax VImpuesto
     , F.Credito VCredito 
     , F.Contado VContado
     , F.CancelA VAdelanto
     , 0 VCobros
     , (F.CostoPrd+F.CostoSrv) VCosto
     , (F.MontoTotal) VMtoTotal
  from VW_ADM_FACTURAS F 
       left join SACLIE C 
              on F.CodClie = C.CodClie
  where (F.FechaE >= CONVERT(DATETIME,'2026-03-13',120) and F.FechaE<= CONVERT(DATETIME,'2026-03-13',120)+ ' 23:59:59' ) 
    and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'')
	  and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
  order by convert(datetime,convert(varchar(8),F.FechaE,112)),
          (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) desc
GO

-- Session: 61 | Start: 2026-03-13 12:00:23.350000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'RAFAEL%') OR (Descrip LIKE 'RAFAEL%') OR (ID3 LIKE 'RAFAEL%') OR (Clase LIKE 'RAFAEL%') OR (Saldo LIKE 'RAFAEL%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 12:00:32.970000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='55555' OR P.CodProd='55555')
GO

-- Session: 64 | Start: 2026-03-13 12:00:52.183000 | Status: running | Cmd: AWAITING COMMAND
SELECT TOP 1 CodProd   FROM VW_ADM_PRODUCTOS WITH (NOLOCK)
GO

-- Session: 64 | Start: 2026-03-13 12:00:56.700000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CODPROD LIKE 'LEPTA%') OR (SP.DESCRIPALL LIKE 'LEPTA%') OR (SP.REFERE LIKE 'LEPTA%') OR (SP.EXISTEN LIKE 'LEPTA%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 12:01:39.013000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='ACEITE' OR P.CodProd='ACEITE')
GO

-- Session: 62 | Start: 2026-03-13 12:03:39.170000 | Status: running | Cmd: SET COMMAND
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, lo.cantidad, lo.cantidadu, lo.fechav,       lo.precio3 preciov,       lo.precio3 +(lo.precio3*tx.mtotax+tx.mtofijo) preciotx,       lo.precioi3 precioI,       lo.preciou3 preciou,       lo.preciou3+(lo.preciou3*tx.mtotax+                          iif(pr.cantempaq>1,1/pr.cantempaq,1)*tx.mtofijo) precioutx,       lo.precioui3 precioui,       lo.costo, pr.cantempaq   FROM salote lo       LEFT JOIN (                  SELECT codprod, 0 mtotax, 0 mtofijo
                    FROM SAPROD
                 ) tx       ON (tx.codprod=lo.codprod)       INNER JOIN saprod pr       ON (pr.codprod=lo.codprod)       INNER JOIN sadepo dp       ON (dp.codubic=lo.codubic) WHERE (lo.CodProd='55555')       And (lo.CodUbic='AMR001')  ORDER BY lo.codubic, lo.fechav
GO

-- Session: 62 | Start: 2026-03-13 12:04:22.893000 | Status: running | Cmd: INSERT
SET DATEFORMAT YMD;
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE
   @ErrMsg        NVARCHAR(4000)
  ,@ErrorSeverity INT
  ,@ErrorState    INT
  ,@ErrorNumber   INT
  ,@ErrorLine     INT
  ,@OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V2764432'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
;
BEGIN TRANSACTION;
BEGIN TRY
  EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
  INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[ImpuestoD],[CancelE],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 11:54:58.667','2026-03-13 11:54:58.714','2026-03-13 11:54:58.667',1,1,'V2764432','BK-01','12394915','12394915','AMR001','FLOR','CARACAS','V2764432',791.12,814.85,443.25,1.84,814.85,791.12,791.12,23.73,791.12,23.73);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT');
  SET @NROUNICOLOT=1056118
  UPDATE SAPROD SET FechaUV='2026-03-13 11:54:58.808'
 WHERE (CodProd='55555');
  SELECT @EXISTANT=0, @EXISTANTUND=0;
  SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='55555') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
  EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','55555','AMR001',-1.00,0,'2026-03-13';
  SELECT TOP 1 @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='55555') And (E.CodUbic='AMR001')
  IF @EXISTPRD<0 BEGIN
       SET @ErrMsg = 'Existencia cero o negativa!';
       RAISERROR(@ErrMsg, 16, 0);
     END;
  SET @NROUNICOLOT=1056118
  UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
  INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 11:54:58.839','55555','1.03516','AMR001','ADHESIVO MICROPORE 2"X10YD COLOR BLANCO',1.00,1.00,424.30,1.00,791.125,791.125,791.125,'12394915','12394915',1,1,'9',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-12 00:00:00.000','1899-12-29 00:00:00.000');
  INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','55555',791.125,16.00,126.58,1);
  UPDATE SAFACT SET 
   CostoPrd=424.30   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
  INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[Monto],[MontoMEx],[Factor],[ImpuestoD],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','021','1,78x443,25',791.12,1.78,443.25,23.7336,'2026-03-13 00:00:00.000');
  INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','011','DESC I.G.T.F',2,23.73,1.00,'2026-03-13 00:00:00.000');
  UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  COMMIT TRANSACTION;
  SELECT 0 error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  SELECT
     @ErrMsg = ERROR_MESSAGE(),
     @ErrorSeverity = ERROR_SEVERITY(),
     @ErrorState = ERROR_STATE(),
     @ErrorNumber = ERROR_NUMBER(),
     @ErrorLine = ERROR_LINE();
  SET @ErrMsg = @ErrMsg+Char(13)+
      'Line: '+Cast(@ErrorLine As Varchar(10));
  SELECT -1 error, @ErrMsg errmsg, @ErrorSeverity errseverity;
  RAISERROR(@ErrMsg, @ErrorSeverity, @ErrorState);
END CATCH;
GO

-- Session: 69 | Start: 2026-03-13 12:05:38.237000 | Status: suspended | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 70 | Start: 2026-03-13 12:15:00.780000 | Status: running | Cmd: SELECT
select @@microsoftversion
GO

-- Session: 70 | Start: 2026-03-13 12:25:32.463000 | Status: running | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 70 | Start: 2026-03-13 12:25:38.927000 | Status: suspended | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 61 | Start: 2026-03-13 12:33:20.030000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'VITAMINA%') OR (SP.DescripAll LIKE 'VITAMINA%') OR (SP.Refere LIKE 'VITAMINA%') OR (SP.Existen LIKE 'VITAMINA%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 12:34:00.843000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='AMP_FOLICO_10') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 12:34:40.147000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'MACRO%') OR (SP.DESCRIPALL LIKE 'MACRO%') OR (SP.REFERE LIKE 'MACRO%') OR (SP.EXISTEN LIKE 'MACRO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 12:35:04.240000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='CLORURO' OR P.CodProd='CLORURO')
GO

-- Session: 61 | Start: 2026-03-13 12:36:54.573000 | Status: running | Cmd: SELECT
(@P1 varchar(15))SET DATEFORMAT YMD;
SELECT SP.CODPROD, SP.DESCRIP, SP.DESCRIP2, SP.DESCRIP3
      ,SP.REFERE, SP.EXISTEN, SP.EXUNIDAD, SP.ESEXENTO
      ,SP.ESENSER, SP.ACTIVO, SP.MARCA, SP.DESSERI
      ,SP.DESCRIPALL, SP.DESLOTE, SP.DESCOMP, SP.DESVENCE
      ,SP.COSTPRO, SP.COSTACT, SP.COSTANT
      ,SP.CANTPED, SP.CANTCOM, SP.UNIDPED, SP.UNIDCOM
      ,SP.MINIMO, SP.MAXIMO
      ,SP.UNIDAD, SP.CANTEMPAQ, SP.UNDEMPAQ
      ,SP.PRECIO1, SP.PRECIO2, SP.PRECIO3
      ,SP.PRECIOU AS PRECIOU1, SP.PRECIOU2, SP.PRECIOU3
      ,SP.PRECIOI1, SP.PRECIOI2, SP.PRECIOI3
      ,SP.PRECIOIU1, SP.PRECIOIU2, SP.PRECIOIU3
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.Precio1, 1, 0, 0)+SP.Precio1 AS PTX1 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.Precio2, 1, 0, 0)+SP.Precio2 AS PTX2 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.Precio3, 1, 0, 0)+SP.Precio3 AS PTX3 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.PrecioU, 1, 1, 0)+SP.PrecioU AS PTXU1 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.PrecioU2,1, 1, 0)+SP.PrecioU2 AS PTXU2 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.PrecioU3,1, 1, 0)+SP.PrecioU3 AS PTXU3 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.CostPro, 1, 0, 1)+SP.CostPro AS COSTOPROTX 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.CostAct, 1, 0, 1)+SP.CostAct AS COSTOACTTX 
  FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 
 WHERE SP.CODPROD=@P1
GO

-- Session: 54 | Start: 2026-03-13 12:41:38.900000 | Status: running | Cmd: SELECT
SELECT target_data
									FROM sys.dm_xe_session_targets xet WITH(nolock)
									JOIN sys.dm_xe_sessions xes WITH(nolock)
									ON xes.address = xet.event_session_address
									WHERE xes.name = 'telemetry_xevents'
									AND xet.target_name = 'ring_buffer'
GO

-- Session: 60 | Start: 2026-03-13 12:45:01.163000 | Status: running | Cmd: EXECUTE
xp_instance_regread
GO

-- Session: 66 | Start: 2026-03-13 12:50:00.643000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 62 | Start: 2026-03-13 12:51:14.943000 | Status: runnable | Cmd: SELECT
SELECT TOP 1 CodProd   FROM VW_ADM_PRODUCTOS WITH (NOLOCK)
GO

-- Session: 62 | Start: 2026-03-13 12:51:32.520000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='89044179733887' OR P.CodProd='89044179733887')
GO

-- Session: 62 | Start: 2026-03-13 12:51:49.147000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'OMEPRAZOL%') OR (SP.DescripAll LIKE 'OMEPRAZOL%') OR (SP.Refere LIKE 'OMEPRAZOL%') OR (SP.Existen LIKE 'OMEPRAZOL%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 62 | Start: 2026-03-13 12:56:51.293000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JULIO%') OR (Descrip LIKE 'JULIO%') OR (ID3 LIKE 'JULIO%') OR (Clase LIKE 'JULIO%') OR (Saldo LIKE 'JULIO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 65 | Start: 2026-03-13 13:01:00.157000 | Status: runnable | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 64 | Start: 2026-03-13 13:02:30.250000 | Status: runnable | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591821101692') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 71 | Start: 2026-03-13 13:03:00.143000 | Status: runnable | Cmd: UPDATE
UPDATE SAPROD 
SET PrecioI1=b.precio$1,PrecioI2=b.precio$2,PrecioI3=b.precio$3
from SAPROD as a
inner join CUSTOM_PRECIO_EN_DOLAR as b on (a.CodProd=b.codprod)
GO

-- Session: 64 | Start: 2026-03-13 13:03:26.140000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SAEXIS EX     ON (EX.CODSUCU='00000') AND        (EX.CODPROD=P.CODPROD) AND        (EX.CODUBIC='AMR001') INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='BLI_ALKASE' OR P.CodProd='BLI_ALKASE')
GO

-- Session: 71 | Start: 2026-03-13 13:05:31.717000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 61 | Start: 2026-03-13 13:13:32.400000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='736372722492') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 62 | Start: 2026-03-13 13:16:29.393000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE '694289304330%') OR (SP.DescripAll LIKE '694289304330%') OR (SP.Refere LIKE '694289304330%') OR (SP.Existen LIKE '694289304330%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 62 | Start: 2026-03-13 13:26:20.563000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'TORS%') OR (SP.DescripAll LIKE 'TORS%') OR (SP.Refere LIKE 'TORS%') OR (SP.Existen LIKE 'TORS%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 62 | Start: 2026-03-13 13:27:44.017000 | Status: running | Cmd: ASSIGN
SET DATEFORMAT YMD;
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE
   @ErrMsg        NVARCHAR(4000)
  ,@ErrorSeverity INT
  ,@ErrorState    INT
  ,@ErrorNumber   INT
  ,@ErrorLine     INT
  ,@OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V10915197'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
;
BEGIN TRANSACTION;
BEGIN TRY
  EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
  INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 13:18:19.832','2026-03-13 13:18:19.879','2026-03-13 13:18:19.832',1,1,'V10915197','BK-01','12394915','12394915','AMR001','ROSA','CARACAS','V10915197',1400.67,1400.67,443.25,3.16,1400.67,1400.67,1400.67,1400.67);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT');
  SET @NROUNICOLOT=1056755
  UPDATE SAPROD SET FechaUV='2026-03-13 13:18:19.957'
 WHERE (CodProd='BLI_TORSIL');
  SELECT @EXISTANT=0, @EXISTANTUND=0;
  SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='BLI_TORSIL') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
  EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','BLI_TORSIL','AMR001',-1.00,0,'2026-03-13';
  SELECT TOP 1 @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='BLI_TORSIL') And (E.CodUbic='AMR001')
  IF @EXISTPRD<0 BEGIN
       SET @ErrMsg = 'Existencia cero o negativa!';
       RAISERROR(@ErrMsg, 16, 0);
     END;
  SET @NROUNICOLOT=1056755
  UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
  INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 13:18:19.988','BLI_TORSIL','1.89601','AMR001','TORSILAX BLISTER X 10 COMP',1.00,1.00,816.64,1.00,1400.67,1400.67,1400.67,'12394915','12394915',1,1,'261',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-06 00:00:00.000','1899-12-29 00:00:00.000');
  UPDATE SAFACT SET 
   CostoPrd=816.64   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
  INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1400.67,1.00,'2026-03-13 00:00:00.000');
  UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  COMMIT TRANSACTION;
  SELECT 0 error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  SELECT
     @ErrMsg = ERROR_MESSAGE(),
     @ErrorSeverity = ERROR_SEVERITY(),
     @ErrorState = ERROR_STATE(),
     @ErrorNumber = ERROR_NUMBER(),
     @ErrorLine = ERROR_LINE();
  SET @ErrMsg = @ErrMsg+Char(13)+
      'Line: '+Cast(@ErrorLine As Varchar(10));
  SELECT -1 error, @ErrMsg errmsg, @ErrorSeverity errseverity;
  RAISERROR(@ErrMsg, @ErrorSeverity, @ErrorState);
END CATCH;
GO

-- Session: 66 | Start: 2026-03-13 13:30:32.020000 | Status: running | Cmd: SELECT
create procedure sys.sp_datatype_info_100
(
    @data_type int = 0,
    @ODBCVer tinyint = 2
)
as
    declare @mintype int
    declare @maxtype int

    set @ODBCVer = isnull(@ODBCVer, 2)
    if @ODBCVer < 3 -- includes ODBC 1.0 as well
        set @ODBCVer = 2
    else
        set @ODBCVer = 3

    if @data_type = 0
    begin
        select @mintype = -32768
        select @maxtype = 32767
    end
    else
    begin
        select @mintype = @data_type
        select @maxtype = @data_type
    end

    select
        TYPE_NAME           = v.TYPE_NAME,
        DATA_TYPE           = v.DATA_TYPE,
        PRECISION           = v.PRECISION,
        LITERAL_PREFIX      = v.LITERAL_PREFIX,
        LITERAL_SUFFIX      = v.LITERAL_SUFFIX,
        CREATE_PARAMS       = v.CREATE_PARAMS,
        NULLABLE            = v.NULLABLE,
        CASE_SENSITIVE      = v.CASE_SENSITIVE,
        SEARCHABLE          = v.SEARCHABLE,
        UNSIGNED_ATTRIBUTE  = v.UNSIGNED_ATTRIBUTE,
        MONEY               = v.MONEY,
        AUTO_INCREMENT      = v.AUTO_INCREMENT,
        LOCAL_TYPE_NAME     = v.LOCAL_TYPE_NAME,
        MINIMUM_SCALE       = v.MINIMUM_SCALE,
        MAXIMUM_SCALE       = v.MAXIMUM_SCALE,
        SQL_DATA_TYPE       = v.SQL_DATA_TYPE,
        SQL_DATETIME_SUB    = v.SQL_DATETIME_SUB,
        NUM_PREC_RADIX      = v.NUM_PREC_RADIX,
        INTERVAL_PRECISION  = v.INTERVAL_PRECISION,
        USERTYPE            = v.USERTYPE

    from
        sys.spt_datatype_info_view v

    where
        v.DATA_TYPE between @mintype and @maxtype and
        v.ODBCVer = @ODBCVer

    order by 2, 12, 11, 20
GO

-- Session: 60 | Start: 2026-03-13 13:31:00.337000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 59 | Start: 2026-03-13 13:34:45.883000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TP.CODPROD, TP.Monto, TP.EsPorct, TX.CODTAXS, TX.DESCRIP,        TX.ESLIBROI, TX.ESRETEN, TX.CODOPER, TX.SUSTRAENDO   FROM SATAXPRD TP WITH (NOLOCK)        LEFT JOIN SATAXES TX ON        TX.CODTAXS=TP.CODTAXS  WHERE (TX.EsTaxCompra>0) AND (TP.CODPROD='7591196000514')
GO

-- Session: 59 | Start: 2026-03-13 13:35:51.093000 | Status: running | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='B0311832'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='8906082150973') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 680.79 
ELSE ((CostPro*Existen)+1361.58)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=680.79,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:35:50.750'
 WHERE (CodProd='8906082150973')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='8906082150973')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='8906082150973' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8906082150973','AMR001',2.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','8906082150973','AMR001','25')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=680.79,Precio2=680.79,Precio3=680.79,Costo=680.79,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='8906082150973') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=680.79,Precio2=680.79,Precio3=680.79
 WHERE (CodSucu='00000') And (CodProd='8906082150973') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='8906082150973') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'8906082150973','J-412413740');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=680.79,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='1.80411'
 WHERE (TipoCom='H') And 
       (CodItem='8906082150973') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,1,'2026-03-12 13:35:50.750','8906082150973','1.80411','AMR001','CLOPIDROGREL 75MG X 20 TAB FARMAMED',2.00,680.79,680.79,680.79,680.79,1361.58,1,1,ISNULL(@NROUNICOLOT,0),'25','2026-03-12 13:35:50.750',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7591062010753') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1834.55 
ELSE ((CostPro*Existen)+3669.10)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=1834.55,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:35:50.750'
 WHERE (CodProd='7591062010753')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591062010753')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591062010753' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591062010753','AMR001',2.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591062010753','AMR001','368')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1834.55,Precio2=1834.55,Precio3=1834.55,Costo=1834.55,FechaE='2026-03-12',FechaV='2027-05-23'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591062010753') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1834.55,Precio2=1834.55,Precio3=1834.55
 WHERE (CodSucu='00000') And (CodProd='7591062010753') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591062010753') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591062010753','J-412413740');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=1834.55,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='3.86491'
 WHERE (TipoCom='H') And 
       (CodItem='7591062010753') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[FechaV],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,2,'2026-03-12 13:35:50.750','7591062010753','3.86491','AMR001','COLFENE COM 400      MG /4      MG X 1',2.00,1834.55,1834.55,1834.55,1834.55,3669.10,1,1,ISNULL(@NROUNICOLOT,0),'368','2026-03-12 13:35:50.750','2027-05-23 00:00:00.000',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592806132038') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2612.09 
ELSE ((CostPro*Existen)+2612.09)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=2612.09,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:35:50.750'
 WHERE (CodProd='7592806132038')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592806132038')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592806132038' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592806132038','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592806132038','AMR001','8888')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=4366.58,Precio2=4642.07,Precio3=5187.86,Costo=2612.09,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592806132038') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=4366.58,Precio2=4642.07,Precio3=5187.86
 WHERE (CodSucu='00000') And (CodProd='7592806132038') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592806132038') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592806132038','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=2612.09,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='7.95962'
 WHERE (TipoCom='H') And 
       (CodItem='7592806132038') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,3,'2026-03-12 13:35:50.750','7592806132038','7.95962','AMR001','MILAX PVO SOL ORL X 120GR',1.00,2612.09,4366.58,4642.07,5187.86,2612.09,1,1,ISNULL(@NROUNICOLOT,0),'8888','2026-03-12 13:35:50.750',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7590027002673') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1419.93 
ELSE ((CostPro*Existen)+1419.93)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=1419.93,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:35:50.750'
 WHERE (CodProd='7590027002673')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7590027002673')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7590027002673' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7590027002673','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7590027002673','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1419.93,Precio2=1419.93,Precio3=1419.93,Costo=1419.93,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7590027002673') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1419.93,Precio2=1419.93,Precio3=1419.93
 WHERE (CodSucu='00000') And (CodProd='7590027002673') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7590027002673') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7590027002673','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=1419.93,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='2.68043'
 WHERE (TipoCom='H') And 
       (CodItem='7590027002673') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,4,'2026-03-12 13:35:50.750','7590027002673','2.68043','AMR001','QUEATIPINA 25      MG X 30TAB SPEFAR',1.00,1419.93,1419.93,1419.93,1419.93,1419.93,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:35:50.750',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7591062017295') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 292.91 
ELSE ((CostPro*Existen)+292.91)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=292.91,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:35:50.750'
 WHERE (CodProd='7591062017295')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591062017295')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591062017295' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591062017295','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591062017295','AMR001','101010')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=292.91,Precio2=292.91,Precio3=292.91,Costo=292.91,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591062017295') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=292.91,Precio2=292.91,Precio3=292.91
 WHERE (CodSucu='00000') And (CodProd='7591062017295') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591062017295') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591062017295','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=292.91,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='0.869999'
 WHERE (TipoCom='H') And 
       (CodItem='7591062017295') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,5,'2026-03-12 13:35:50.750','7591062017295','0.869999','AMR001','TACHIFORTE TAB 650      MG X 10',1.00,292.91,292.91,292.91,292.91,292.91,1,1,ISNULL(@NROUNICOLOT,0),'101010','2026-03-12 13:35:50.750',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-3.00
 WHERE (CodSucu='00000') And (CodProd='7591196000514') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2022.70 
ELSE ((CostPro*Existen)+6068.10)/NULLIF(Existen+3.00,0) END),0), 
COSTACT=2022.70,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:35:50.750'
 WHERE (CodProd='7591196000514')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591196000514')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591196000514' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591196000514','AMR001',3.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591196000514','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+3.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2644.40,Precio2=2840.07,Precio3=3239.43,Costo=2022.70,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591196000514') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2644.40,Precio2=2840.07,Precio3=3239.43
 WHERE (CodSucu='00000') And (CodProd='7591196000514') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591196000514') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591196000514','J-412413740');
UPDATE SAPVPR SET Cantidad=3.00,
       Costo=2022.70,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='4.67767'
 WHERE (TipoCom='H') And 
       (CodItem='7591196000514') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,6,'2026-03-12 13:35:50.750','7591196000514','4.67767','AMR001','TODEX SUSP OFT X 5 ML',3.00,2022.70,2644.40,2840.07,3239.43,6068.10,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:35:50.750',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Monto],[TExento],[TotalPrd],[OrdenC],[CodOper],[Credito])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 13:35:50.750','2026-03-12 13:35:50.750','2026-04-02 13:35:50.750',@NUMEROCOM,'J-412413740','AMR001','INSUAMINCA C.A.',443.25,34.796864,'00-1138010','J-412413740',15423.71,15423.71,15423.71,15423.71,'B0311832','CXP',15423.71)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=15423.71, NumeroUC='B0311832', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J-412413740')
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-412413740','B0311832','00-1138010','V12400678','ADM-3','10','INSUAMINCA C.A.','J-412413740',GETDATE(),'B0311832 B0311832','2026-03-13 13:35:50.750','2026-03-12 13:35:50.750','2026-04-02 13:35:50.750',443.25,34.796864,34.796864,15423.71,15423.71,15423.71,15423.71,15423.71,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 59 | Start: 2026-03-13 13:36:53.330000 | Status: running | Cmd: AWAITING COMMAND
SELECT EsPorct,Monto FROM VW_ADM_TAXINVENT WITH (NOLOCK) WHERE (CodProd='6972718560074') And (EsReten=0)
GO

-- Session: 62 | Start: 2026-03-13 13:39:13.743000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='OLMESAR' OR P.CodProd='OLMESAR')
GO

-- Session: 65 | Start: 2026-03-13 13:41:22.210000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='8904278589569') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 59 | Start: 2026-03-13 13:42:00.927000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='SONDA') OR         (C.CodAlte='SONDA') OR 
        (P.Refere ='SONDA'))
GO

-- Session: 58 | Start: 2026-03-13 13:43:31.190000 | Status: running | Cmd: SELECT
SELECT convert(bit,(case when OBJECT_ID(N'dbo.TaVPOSAdmin') is null then 0 else 1 end)) AS 'tbExiste';
GO

-- Session: 59 | Start: 2026-03-13 13:44:09.343000 | Status: runnable | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='B0311835'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='6972718560074') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1273.88 
ELSE ((CostPro*Existen)+1273.88)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=1273.88,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='6972718560074')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='6972718560074')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='6972718560074' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','6972718560074','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','6972718560074','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1273.88,Precio2=1273.88,Precio3=1273.88,Costo=1273.88,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='6972718560074') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1273.88,Precio2=1273.88,Precio3=1273.88
 WHERE (CodSucu='00000') And (CodProd='6972718560074') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='6972718560074') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'6972718560074','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=1273.88,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='2.76347'
 WHERE (TipoCom='H') And 
       (CodItem='6972718560074') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,1,'2026-03-12 13:44:08.807','6972718560074','2.76347','AMR001','CLOPIDROGREL 75MG X30 TABL BLE MEDICAL',1.00,1273.88,1273.88,1273.88,1273.88,1273.88,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='7598008000472') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 580.14 
ELSE ((CostPro*Existen)+5801.40)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=580.14,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='7598008000472')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7598008000472')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7598008000472' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7598008000472','AMR001',10.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7598008000472','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=580.14,Precio2=580.14,Precio3=580.14,Costo=580.14,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7598008000472') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=580.14,Precio2=580.14,Precio3=580.14
 WHERE (CodSucu='00000') And (CodProd='7598008000472') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7598008000472') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7598008000472','J-412413740');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=580.14,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='0.719515'
 WHERE (TipoCom='H') And 
       (CodItem='7598008000472') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Descrip2],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,2,'2026-03-12 13:44:08.807','7598008000472','0.719515','AMR001','LEVPNOGESTREL 1.5      MG X 1','LEVPNOGESTREL 1.5 MG X 1',10.00,580.14,580.14,580.14,580.14,5801.40,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='8906142160898') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 343.01 
ELSE ((CostPro*Existen)+3430.10)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=343.01,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='8906142160898')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='8906142160898')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='8906142160898' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8906142160898','AMR001',10.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','8906142160898','AMR001','000368')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=343.01,Precio2=343.01,Precio3=343.01,Costo=343.01,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='8906142160898') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=343.01,Precio2=343.01,Precio3=343.01
 WHERE (CodSucu='00000') And (CodProd='8906142160898') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='8906142160898') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'8906142160898','J-412413740');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=343.01,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='0.796724'
 WHERE (TipoCom='H') And 
       (CodItem='8906142160898') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,3,'2026-03-12 13:44:08.807','8906142160898','0.796724','AMR001','LORATADINA 10      MG X 10 TAB ADN MED',10.00,343.01,343.01,343.01,343.01,3430.10,1,1,ISNULL(@NROUNICOLOT,0),'000368','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='196852522460') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 4312.71 
ELSE ((CostPro*Existen)+8625.42)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=4312.71,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='196852522460')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='196852522460')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='196852522460' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','196852522460','AMR001',2.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','196852522460','AMR001','841')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=6033.45,Precio2=6413.91,Precio3=7168.73,Costo=4312.71,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='196852522460') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=6033.45,Precio2=6413.91,Precio3=7168.73
 WHERE (CodSucu='00000') And (CodProd='196852522460') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='196852522460') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'196852522460','J-412413740');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=4312.71,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='10.9978'
 WHERE (TipoCom='H') And 
       (CodItem='196852522460') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,4,'2026-03-12 13:44:08.807','196852522460','10.9978','AMR001','MAITE ANANTO NOREST50ML+VALER ESTRAD 5',2.00,4312.71,6033.45,6413.91,7168.73,8625.42,1,1,ISNULL(@NROUNICOLOT,0),'841','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='669238000499') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 3869.09 
ELSE ((CostPro*Existen)+3869.09)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=3869.09,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='669238000499')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='669238000499')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='669238000499' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','669238000499','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','669238000499','AMR001','654')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=3869.09,Precio2=3869.09,Precio3=3869.09,Costo=3869.09,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='669238000499') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=3869.09,Precio2=3869.09,Precio3=3869.09
 WHERE (CodSucu='00000') And (CodProd='669238000499') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='669238000499') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'669238000499','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=3869.09,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='8.49402'
 WHERE (TipoCom='H') And 
       (CodItem='669238000499') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,5,'2026-03-12 13:44:08.807','669238000499','8.49402','AMR001','OMEGA 3 CAPB 1000       MG X30 VAL NAT',1.00,3869.09,3869.09,3869.09,3869.09,3869.09,1,1,ISNULL(@NROUNICOLOT,0),'654','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7592946001768') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 3943.33 
ELSE ((CostPro*Existen)+7886.66)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=3943.33,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='7592946001768')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592946001768')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592946001768' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592946001768','AMR001',2.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592946001768','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=3943.33,Precio2=3943.33,Precio3=3943.33,Costo=3943.33,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592946001768') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=3943.33,Precio2=3943.33,Precio3=3943.33
 WHERE (CodSucu='00000') And (CodProd='7592946001768') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592946001768') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592946001768','J-412413740');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=3943.33,
       FechaE='2026-03-12',
       EsServ=0,
       Refere=''
 WHERE (TipoCom='H') And 
       (CodItem='7592946001768') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,6,'2026-03-12 13:44:08.807','7592946001768','AMR001','PENTAMAG/CITRATO DE MAGNESIO X60 CAP ARC',2.00,3943.33,3943.33,3943.33,3943.33,7886.66,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7591821802322') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1959.50 
ELSE ((CostPro*Existen)+3919.00)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=1959.50,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='7591821802322')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591821802322')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591821802322' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591821802322','AMR001',2.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591821802322','AMR001','3333')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1959.50,Precio2=1959.50,Precio3=1959.50,Costo=1959.50,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591821802322') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1959.50,Precio2=1959.50,Precio3=1959.50
 WHERE (CodSucu='00000') And (CodProd='7591821802322') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591821802322') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591821802322','J-412413740');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=1959.50,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='4.34844'
 WHERE (TipoCom='H') And 
       (CodItem='7591821802322') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,7,'2026-03-12 13:44:08.807','7591821802322','4.34844','AMR001','RINARIS TABR 5      MG -60      MG X 1',2.00,1959.50,1959.50,1959.50,1959.50,3919.00,1,1,ISNULL(@NROUNICOLOT,0),'3333','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7597830005167') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 304.27 
ELSE ((CostPro*Existen)+304.27)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=304.27,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='7597830005167')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7597830005167')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7597830005167' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597830005167','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7597830005167','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=304.27,Precio2=304.27,Precio3=304.27,Costo=304.27,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7597830005167') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=304.27,Precio2=304.27,Precio3=304.27
 WHERE (CodSucu='00000') And (CodProd='7597830005167') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7597830005167') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7597830005167','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=304.27,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='0.696444'
 WHERE (TipoCom='H') And 
       (CodItem='7597830005167') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,8,'2026-03-12 13:44:08.807','7597830005167','0.696444','AMR001','SONDA FOLEY NRO 16 GROSSMED',1.00,304.27,304.27,304.27,304.27,304.27,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592946001164') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 3452.44 
ELSE ((CostPro*Existen)+3452.44)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=3452.44,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 13:44:08.807'
 WHERE (CodProd='7592946001164')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592946001164')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592946001164' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592946001164','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592946001164','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=3452.44,Precio2=3452.44,Precio3=3452.44,Costo=3452.44,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592946001164') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=3452.44,Precio2=3452.44,Precio3=3452.44
 WHERE (CodSucu='00000') And (CodProd='7592946001164') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592946001164') And 
                     (CodProv='J-412413740'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592946001164','J-412413740');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=3452.44,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='7.98445'
 WHERE (TipoCom='H') And 
       (CodItem='7592946001164') And 
       (CodProv='J-412413740')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-412413740','H',@NUMEROCOM,9,'2026-03-12 13:44:08.807','7592946001164','7.98445','AMR001','ZABILA TAB 430      MG X 30',1.00,3452.44,3452.44,3452.44,3452.44,3452.44,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 13:44:08.807',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Monto],[TExento],[TotalPrd],[OrdenC],[CodOper],[Credito])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 13:44:08.807','2026-03-12 13:44:08.807','2026-03-14 13:44:08.807',@NUMEROCOM,'J-412413740','AMR001','INSUAMINCA C.A.',443.25,86.998895,'00-1138013','J-412413740',38562.26,38562.26,38562.26,38562.26,'B0311835','CXP',38562.26)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=38562.26, NumeroUC='B0311835', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J-412413740')
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-412413740','B0311835','00-1138013','V12400678','ADM-3','10','INSUAMINCA C.A.','J-412413740',GETDATE(),'B0311835 B0311835','2026-03-13 13:44:08.807','2026-03-12 13:44:08.807','2026-03-14 13:44:08.807',443.25,86.998895,86.998895,38562.26,38562.26,38562.26,38562.26,38562.26,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 71 | Start: 2026-03-13 13:45:00.080000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 62 | Start: 2026-03-13 13:45:30.543000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7703712032538' OR P.CodProd='7703712032538')
GO

-- Session: 58 | Start: 2026-03-13 13:47:07.227000 | Status: running | Cmd: SELECT
select 
	C.CodClie
    ,C.Descrip
	,isnull(C.ID3,'') ID3
	,isnull(C.TipoID,0) TipoID
	,isnull(C.TipoID3,0) TipoID3
    ,isnull(C.TipoCli,0) TipoCli
    ,isnull(C.DescripExt,'') DescripExt
    ,isnull(C.Clase,'') Clase
    ,isnull(C.Direc1,'') Direc1
    ,isnull(C.Direc2,'') Direc2
    ,'' Direc3
    ,isnull(C.Email,'') Email
    ,isnull(C.ZipCode,'') ZipCode
    ,isnull(C.Telef,'') Telef
    ,isnull(C.Fax,'') Fax
    ,isnull(C.EsMoneda,0) EsMoneda
    ,isnull(C.Estado,0) EstadoCod
    ,isnull(Estado.Descrip,'') EstadoDescrip
    ,isnull(C.Ciudad,0) CiudadCod
    ,isnull(Ciudad.Descrip,'') CiudadDescrip
    ,isnull(C.Municipio,0) MunicipioCod
    ,isnull(Mun.Descrip,'') MunicipioDescrip
    ,0 DigitoVerificador
    ,isnull(C.Observa,'') Observa
from SACLIE  C with (nolock)
left join SAMUNICIPIO Mun with (nolock) on
    C.Pais = Mun.Pais
	and C.Estado = Mun.Estado 
    and C.Ciudad = Mun.Ciudad
    and C.Municipio = Mun.Municipio
left join SACIUDAD Ciudad with (nolock)  on
	C.Pais = Ciudad.Pais
	and C.Estado = Ciudad.Estado 
    and C.Ciudad = Ciudad.Ciudad
left join SAESTADO Estado with (nolock)  on
	Ciudad.Pais = Estado.Pais 
    and Ciudad.Estado = Estado.Estado
where 
    C.CodClie = '9231879'
GO

-- Session: 59 | Start: 2026-03-13 13:47:57.023000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='7594005620088') OR         (C.CodAlte='7594005620088') OR 
        (P.Refere ='7594005620088'))
GO

-- Session: 62 | Start: 2026-03-13 13:48:09.153000 | Status: runnable | Cmd: SELECT
SELECT SAFACT.NumeroD NumeroD_2, 
       SAFACT.TipoFac TipoFac_2, 
       SAITEMFAC.Cantidad, SAITEMFAC.CantidadU, 
       SAITEMFAC.CantMayor, SAITEMFAC.CodItem, 
       SAITEMFAC.CodMeca, SAITEMFAC.CodSucu, 
       SAITEMFAC.CodUbic, SAITEMFAC.CodUsua, 
       SAITEMFAC.CodVend, SAITEMFAC.Costo, 
       SAITEMFAC.Descrip1, SAITEMFAC.Descrip10, 
       SAITEMFAC.Descrip2, SAITEMFAC.Descrip3, 
       SAITEMFAC.Descrip4, SAITEMFAC.Descrip5, 
       SAITEMFAC.Descrip6, SAITEMFAC.Descrip7, 
       SAITEMFAC.Descrip8, SAITEMFAC.Descrip9, 
       SAITEMFAC.Descto, SAITEMFAC.DEsLote, 
       SAITEMFAC.DEsSeri, SAITEMFAC.EsExento, 
       SAITEMFAC.EsPesa, SAITEMFAC.EsServ, 
       SAITEMFAC.EsUnid, SAITEMFAC.ExistAnt, 
       SAITEMFAC.ExistAntU, SAITEMFAC.FechaE, 
       SAITEMFAC.Factor, SAITEMFAC.FechaL, 
       SAITEMFAC.FechaV, SAITEMFAC.MtoTax, 
       SAITEMFAC.NroLinea, SAITEMFAC.NroLineaC, 
       SAITEMFAC.MtoTaxO, SAITEMFAC.NroLote, 
       SAITEMFAC.NroUnicoL, SAITEMFAC.NumeroD, 
       SAITEMFAC.NumeroE, SAITEMFAC.Precio, 
       SAITEMFAC.PriceO, SAITEMFAC.Refere, 
       SAITEMFAC.Signo, SAITEMFAC.PrecioI, 
       SAITEMFAC.Tara, SAITEMFAC.TipoFac, 
       SAITEMFAC.TotalItem, SAITEMFAC.UsaServ, 
       SAITEMFAC.TipoData, SAITEMFAC.TipoPVP
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
      INNER JOIN SAITEMFAC SAITEMFAC ON 
     (SAITEMFAC.NumeroD = SAFACT.NumeroD)
      AND (SAITEMFAC.TipoFac = SAFACT.TipoFac)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44389' )
ORDER BY SAITEMFAC.NumeroD, SAITEMFAC.TipoFac
GO

-- Session: 59 | Start: 2026-03-13 13:48:58.507000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='7594005620989') OR         (C.CodAlte='7594005620989') OR 
        (P.Refere ='7594005620989'))
GO

-- Session: 61 | Start: 2026-03-13 13:50:15.827000 | Status: suspended | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V10915197'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TGravable],[MtoTax],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 13:50:14.873','2026-03-13 13:50:15.029','2026-03-13 13:50:14.873',1,1,'V10915197','CAJA004','V12400678','12400678','AMR001','ROSA','CARACAS','V10915197',985.39,1143.05,443.25,2.58,1143.05,985.39,985.39,157.66,1143.05);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
INSERT INTO SATAXVTA ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[MtoTax],[TGravable],[Monto])
       VALUES ('00000','A',@NUMEROFAC,'IVA',16.00,985.39,157.66);
SET @NROUNICOLOT=1055497;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 13:50:15.107'
 WHERE (CodProd='7702010972287');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7702010972287') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7702010972287','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7702010972287') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1055497
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[MtoTax],[MtoTaxO],[CodVend],[CodUsua],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 13:50:15.138','7702010972287','1.08852','AMR001','LADY SPEED STICK TALC CREMA 30GR',1.00,1.00,459.77,1.00,985.391,985.391,3,985.391,157.66256,157.66256,'12400678','V12400678',1,'9',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-01-26 00:00:00.000','1899-12-29 00:00:00.000');
INSERT INTO SATAXITF ([CodSucu],[TipoFac],[NumeroD],[CodTaxs],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','A',@NUMEROFAC,'IVA','7702010972287',985.391,16.00,157.66,1);
UPDATE SAFACT SET 
   CostoPrd=459.77   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1143.05,1.00,'2026-03-13 00:00:00.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 59 | Start: 2026-03-13 13:50:30.693000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='7594005620538') OR         (C.CodAlte='7594005620538') OR 
        (P.Refere ='7594005620538'))
GO

-- Session: 59 | Start: 2026-03-13 13:52:52.870000 | Status: runnable | Cmd: INSERT
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='102380'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005622389') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1546.98 
ELSE ((CostPro*Existen)+9281.88)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=1546.98,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005622389')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005622389')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005622389' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005622389','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005622389','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1546.98,Precio2=1546.98,Precio3=1546.98,Costo=1546.98,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005622389') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1546.98,Precio2=1546.98,Precio3=1546.98
 WHERE (CodSucu='00000') And (CodProd='7594005622389') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005622389') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005622389','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=1546.98,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='3.32908'
 WHERE (TipoCom='H') And 
       (CodItem='7594005622389') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,1,'2026-03-13 13:52:52.327','7594005622389','3.32908','AMR001','PASTA AL AGUA 240G',6.00,1546.98,1546.98,1546.98,1546.98,9281.88,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005620088') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 793.44 
ELSE ((CostPro*Existen)+4760.64)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=793.44,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620088')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620088')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620088' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620088','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620088','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=793.44,Precio2=793.44,Precio3=793.44,Costo=793.44,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620088') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=793.44,Precio2=793.44,Precio3=793.44
 WHERE (CodSucu='00000') And (CodProd='7594005620088') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620088') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620088','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=793.44,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.90192'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620088') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,2,'2026-03-13 13:52:52.327','7594005620088','1.90192','AMR001','ACEITE DE COCO 60 CC ALVA LOF',6.00,793.44,793.44,793.44,793.44,4760.64,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005620101') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1103.72 
ELSE ((CostPro*Existen)+6622.32)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=1103.72,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620101')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620101')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620101' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620101','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620101','AMR001','0687')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1465.76,Precio2=1582.62,Precio3=1825.24,Costo=1103.72,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620101') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1465.76,Precio2=1582.62,Precio3=1825.24
 WHERE (CodSucu='00000') And (CodProd='7594005620101') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620101') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620101','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=1103.72,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='2.21266'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620101') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,3,'2026-03-13 13:52:52.327','7594005620101','2.21266','AMR001','ACEITE DE RICINO ALVA-LOF',6.00,1103.72,1465.76,1582.62,1825.24,6622.32,1,1,ISNULL(@NROUNICOLOT,0),'0687','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005620989') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 713.65 
ELSE ((CostPro*Existen)+4281.90)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=713.65,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620989')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620989')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620989' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620989','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620989','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=911.08,Precio2=989.26,Precio3=1154.03,Costo=713.65,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620989') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=911.08,Precio2=989.26,Precio3=1154.03
 WHERE (CodSucu='00000') And (CodProd='7594005620989') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620989') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620989','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=713.65,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.53575'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620989') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,4,'2026-03-13 13:52:52.327','7594005620989','1.53575','AMR001','CLORURO DE MAGNESIO 33GR',6.00,713.65,911.08,989.26,1154.03,4281.90,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005622259') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 664.89 
ELSE ((CostPro*Existen)+3989.34)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=664.89,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005622259')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005622259')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005622259' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005622259','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005622259','AMR001','111')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=664.89,Precio2=664.89,Precio3=664.89,Costo=664.89,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005622259') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=664.89,Precio2=664.89,Precio3=664.89
 WHERE (CodSucu='00000') And (CodProd='7594005622259') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005622259') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005622259','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=664.89,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.05831'
 WHERE (TipoCom='H') And 
       (CodItem='7594005622259') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,5,'2026-03-13 13:52:52.327','7594005622259','1.05831','AMR001','ALCOHOL ABSOLUTO 60CC',6.00,664.89,664.89,664.89,664.89,3989.34,1,1,ISNULL(@NROUNICOLOT,0),'111','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-12.00
 WHERE (CodSucu='00000') And (CodProd='7594005620538') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 438.83 
ELSE ((CostPro*Existen)+5265.96)/NULLIF(Existen+12.00,0) END),0), 
COSTACT=438.83,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620538')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620538')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620538' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620538','AMR001',12.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620538','AMR001','654')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+12.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=743.78,Precio2=812.20,Precio3=959.19,Costo=438.83,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620538') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=743.78,Precio2=812.20,Precio3=959.19
 WHERE (CodSucu='00000') And (CodProd='7594005620538') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620538') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620538','J001966650');
UPDATE SAPVPR SET Cantidad=12.00,
       Costo=438.83,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.2551'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620538') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,6,'2026-03-13 13:52:52.327','7594005620538','1.2551','AMR001','ALUMBRE EN POLVO 20 GRS ALVA LOF',12.00,438.83,743.78,812.20,959.19,5265.96,1,1,ISNULL(@NROUNICOLOT,0),'654','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005620491') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 571.81 
ELSE ((CostPro*Existen)+3430.86)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=571.81,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620491')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620491')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620491' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620491','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620491','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=729.16,Precio2=796.28,Precio3=940.32,Costo=571.81,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620491') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=729.16,Precio2=796.28,Precio3=940.32
 WHERE (CodSucu='00000') And (CodProd='7594005620491') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620491') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620491','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=571.81,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.2305'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620491') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,7,'2026-03-13 13:52:52.327','7594005620491','1.2305','AMR001','VASELINA 30GR',6.00,571.81,729.16,796.28,940.32,3430.86,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005620361') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 616.13 
ELSE ((CostPro*Existen)+3696.78)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=616.13,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620361')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620361')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620361' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620361','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620361','AMR001','6666')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=823.81,Precio2=899.59,Precio3=1062.48,Costo=616.13,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620361') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=823.81,Precio2=899.59,Precio3=1062.48
 WHERE (CodSucu='00000') And (CodProd='7594005620361') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620361') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620361','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=616.13,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.3903'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620361') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,8,'2026-03-13 13:52:52.327','7594005620361','1.3903','AMR001','VIOLETA DE GENCIANA 30ML',6.00,616.13,823.81,899.59,1062.48,3696.78,1,1,ISNULL(@NROUNICOLOT,0),'6666','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7594005620323') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 531.91 
ELSE ((CostPro*Existen)+3191.46)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=531.91,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 13:52:52.327'
 WHERE (CodProd='7594005620323')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594005620323')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594005620323' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594005620323','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594005620323','AMR001','3214')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=697.68,Precio2=761.83,Precio3=899.71,Costo=531.91,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594005620323') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=697.68,Precio2=761.83,Precio3=899.71
 WHERE (CodSucu='00000') And (CodProd='7594005620323') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594005620323') And 
                     (CodProv='J001966650'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594005620323','J001966650');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=531.91,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.1773'
 WHERE (TipoCom='H') And 
       (CodItem='7594005620323') And 
       (CodProv='J001966650')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J001966650','H',@NUMEROCOM,9,'2026-03-13 13:52:52.327','7594005620323','1.1773','AMR001','TINTURA DE VALERIANA 30 ML',6.00,531.91,697.68,761.83,899.71,3191.46,1,1,ISNULL(@NROUNICOLOT,0),'3214','2026-03-13 13:52:52.327',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Monto],[TExento],[TotalPrd],[OrdenC],[CodOper],[Credito])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 13:52:52.327','2026-03-13 13:52:52.327','2026-03-28 13:52:52.327',@NUMEROCOM,'J001966650','AMR001','QUIMICA FARMACEUTICA ALVA-LOF S.A.',443.25,100.442504,'00-040610','J001966650',44521.14,44521.14,44521.14,44521.14,'102380','CXP',44521.14)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=44521.14, NumeroUC='102380', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J001966650')
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J001966650','102380','00-040610','V12400678','ADM-3','10','QUIMICA FARMACEUTICA ALVA-LOF S.A.','J001966650',GETDATE(),'102380 102380','2026-03-13 13:52:52.327','2026-03-13 13:52:52.327','2026-03-28 13:52:52.327',443.25,100.442504,100.442504,44521.14,44521.14,44521.14,44521.14,44521.14,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 59 | Start: 2026-03-13 13:55:03.670000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT * FROM SALOTE WITH (NOLOCK) WHERE (CodSucu='00000') And (CodProd='7597830005037') And (CodUbic='AMR001') ORDER BY CodUbic
GO

-- Session: 59 | Start: 2026-03-13 13:59:01.710000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='606110873017') OR         (C.CodAlte='606110873017') OR 
        (P.Refere ='606110873017'))
GO

-- Session: 64 | Start: 2026-03-13 13:59:47.460000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CODPROD LIKE '%TORSI%') OR (SP.DESCRIPALL LIKE '%TORSI%') OR (SP.REFERE LIKE '%TORSI%') OR (SP.EXISTEN LIKE '%TORSI%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 70 | Start: 2026-03-13 14:00:01.077000 | Status: runnable | Cmd: EXECUTE
xp_instance_regread
GO

-- Session: 70 | Start: 2026-03-13 14:00:01.077000 | Status: suspended | Cmd: COMMIT TRANSACTION
CREATE PROCEDURE sp_jobhistory_row_limiter
  @job_id UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @max_total_rows         INT -- This value comes from the registry (MaxJobHistoryTableRows)
  DECLARE @max_rows_per_job       INT -- This value comes from the registry (MaxJobHistoryRows)
  DECLARE @rows_to_delete         INT
  DECLARE @current_rows           INT
  DECLARE @current_rows_per_job   INT

  SET NOCOUNT ON

  -- Get max-job-history-rows from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @max_total_rows OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysjobhistory rows
  IF (ISNULL(@max_total_rows, -1) = -1)
    RETURN(0)

  -- Check that max_total_rows is more than 1
  IF (ISNULL(@max_total_rows, 0) < 2)
  BEGIN
    -- It isn't, so set the default to 1000 rows
    SELECT @max_total_rows = 1000
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @max_total_rows
  END

  -- Get the per-job maximum number of rows to keep
  SELECT @max_rows_per_job = 0
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @max_rows_per_job OUTPUT,
                                         N'no_output'

  -- Check that max_rows_per_job is <= max_total_rows
  IF ((@max_rows_per_job > @max_total_rows) OR (@max_rows_per_job < 1))
  BEGIN
    -- It isn't, so default the rows_per_job to max_total_rows
    SELECT @max_rows_per_job = @max_total_rows
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @max_rows_per_job
  END

  BEGIN TRANSACTION

  SELECT @current_rows_per_job = COUNT(*)
  FROM msdb.dbo.sysjobhistory with (TABLOCKX)
  WHERE (job_id = @job_id)

  -- Delete the oldest history row(s) for the job being inserted if the new row has
  -- pushed us over the per-job row limit (MaxJobHistoryRows)
  SELECT @rows_to_delete = @current_rows_per_job - @max_rows_per_job

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      WHERE (job_id = @job_id)
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  -- Delete the oldest history row(s) if inserting the new row has pushed us over the
  -- global MaxJobHistoryTableRows limit.
  SELECT @current_rows = COUNT(*)
  FROM msdb.dbo.sysjobhistory

  SELECT @rows_to_delete = @current_rows - @max_total_rows

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  IF (@@trancount > 0)
    COMMIT TRANSACTION

  RETURN(0) -- Success
END
GO

-- Session: 64 | Start: 2026-03-13 14:00:30.427000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ANA%') OR (Descrip LIKE 'ANA%') OR (ID3 LIKE 'ANA%') OR (Clase LIKE 'ANA%') OR (Saldo LIKE 'ANA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 14:02:43.817000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ISABEL%') OR (Descrip LIKE 'ISABEL%') OR (ID3 LIKE 'ISABEL%') OR (Clase LIKE 'ISABEL%') OR (Saldo LIKE 'ISABEL%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 72 | Start: 2026-03-13 14:05:40.303000 | Status: suspended | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 65 | Start: 2026-03-13 14:13:24.147000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT *, ROW_NUMBER() OVER (ORDER BY CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS WITH (NOLOCK) 
  WHERE ((CodProd LIKE '10017%') OR (DescripAll LIKE '10017%') OR (Refere LIKE '10017%')))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 23
GO

-- Session: 65 | Start: 2026-03-13 14:13:59.910000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT *, ROW_NUMBER() OVER (ORDER BY CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS WITH (NOLOCK) 
 )
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 23
GO

-- Session: 72 | Start: 2026-03-13 14:15:00.660000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 61 | Start: 2026-03-13 14:15:09.950000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'FLOR%') OR (Descrip LIKE 'FLOR%') OR (ID3 LIKE 'FLOR%') OR (Clase LIKE 'FLOR%') OR (Saldo LIKE 'FLOR%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 14:15:40.160000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT * FROM SALOTE WITH (NOLOCK) WHERE (NroUnico=1056899)
GO

-- Session: 71 | Start: 2026-03-13 14:15:47.630000 | Status: running | Cmd: SELECT
(@P1 nvarchar(4),@P2 nvarchar(4),@P3 nvarchar(4),@P4 nvarchar(4))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 72 | Start: 2026-03-13 14:16:00.230000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 65 | Start: 2026-03-13 14:16:09.827000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT *, ROW_NUMBER() OVER (ORDER BY Refere DESC) AS ROWNUM   FROM VW_ADM_PRODUCTOS WITH (NOLOCK) 
  WHERE ((CodProd LIKE 'JER%') OR (DescripAll LIKE 'JER%') OR (Refere LIKE 'JER%')))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 23
GO

-- Session: 59 | Start: 2026-03-13 14:16:26.907000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'JER%') OR (SP.DescripAll LIKE 'JER%') OR (SP.Refere LIKE 'JER%') OR (SP.Existen LIKE 'JER%')) AND  (SP.Activo=1))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 51 | Start: 2026-03-13 14:21:40.920000 | Status: running | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 71 | Start: 2026-03-13 14:24:20.263000 | Status: suspended | Cmd: SELECT
SELECT asf.assembly_id, asi.name, asf.content FROM [sys].[assembly_files] asf INNER JOIN [sys].[assemblies] asi ON asi.assembly_id = asf.assembly_id
GO

-- Session: 65 | Start: 2026-03-13 14:28:07.083000 | Status: running | Cmd: SELECT
(@1 varchar(8000),@2 smallint,@3 tinyint)SELECT * FROM [SSPARM] WHERE [CodParm]=@1 AND [Modulo]=@2 AND [Parametro]=@3
GO

-- Session: 70 | Start: 2026-03-13 14:30:00.427000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 61 | Start: 2026-03-13 14:30:14.083000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591818026366') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 14:30:43.940000 | Status: running | Cmd: EXECUTE
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7751940001307') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 67 | Start: 2026-03-13 14:31:00.903000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 59 | Start: 2026-03-13 14:32:05.670000 | Status: runnable | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='00002183'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='7597830005037') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 376.77 
ELSE ((CostPro*Existen)+3767.70)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=376.77,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='7597830005037')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7597830005037')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7597830005037' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597830005037','AMR001',10.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7597830005037','AMR001','687')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=487.48,Precio2=535.49,Precio3=640.66,Costo=376.77,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7597830005037') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=487.48,Precio2=535.49,Precio3=640.66
 WHERE (CodSucu='00000') And (CodProd='7597830005037') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7597830005037') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7597830005037','J-500921918');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=376.77,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='0.8094'
 WHERE (TipoCom='H') And 
       (CodItem='7597830005037') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,1,'2026-03-13 14:32:05.105','7597830005037','0.8094','AMR001','CATETER VENTRON N 16 VEINCARE',10.00,376.77,487.48,535.49,640.66,3767.70,1,1,ISNULL(@NROUNICOLOT,0),'687','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='6971077612493') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 376.77 
ELSE ((CostPro*Existen)+3767.70)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=376.77,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='6971077612493')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='6971077612493')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='6971077612493' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','6971077612493','AMR001',10.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','6971077612493','AMR001','311')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=376.77,Precio2=376.77,Precio3=376.77,Costo=376.77,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='6971077612493') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=376.77,Precio2=376.77,Precio3=376.77
 WHERE (CodSucu='00000') And (CodProd='6971077612493') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='6971077612493') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'6971077612493','J-500921918');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=376.77,
       FechaE='2026-03-13',
       EsServ=0,
       Refere=''
 WHERE (TipoCom='H') And 
       (CodItem='6971077612493') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,2,'2026-03-13 14:32:05.105','6971077612493','AMR001','CATETER VALEMEDIC N 22 X1',10.00,376.77,376.77,376.77,376.77,3767.70,1,1,ISNULL(@NROUNICOLOT,0),'311','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='6971077612509') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 376.77 
ELSE ((CostPro*Existen)+3767.70)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=376.77,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='6971077612509')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='6971077612509')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='6971077612509' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','6971077612509','AMR001',10.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','6971077612509','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=376.77,Precio2=376.77,Precio3=376.77,Costo=376.77,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='6971077612509') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=376.77,Precio2=376.77,Precio3=376.77
 WHERE (CodSucu='00000') And (CodProd='6971077612509') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='6971077612509') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'6971077612509','J-500921918');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=376.77,
       FechaE='2026-03-13',
       EsServ=0,
       Refere=''
 WHERE (TipoCom='H') And 
       (CodItem='6971077612509') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,3,'2026-03-13 14:32:05.105','6971077612509','AMR001','CATETER N 24 VALEMEDIC X1',10.00,376.77,376.77,376.77,376.77,3767.70,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-3.00
 WHERE (CodSucu='00000') And (CodProd='606110873017') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1861.69 
ELSE ((CostPro*Existen)+5585.07)/NULLIF(Existen+3.00,0) END),0), 
COSTACT=1861.69,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='606110873017')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='606110873017')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='606110873017' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','606110873017','AMR001',3.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','606110873017','AMR001','654')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+3.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1894.4569,Precio2=2034.63,Precio3=2320.73,Costo=1861.69,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='606110873017') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1894.4569,Precio2=2034.63,Precio3=2320.73
 WHERE (CodSucu='00000') And (CodProd='606110873017') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='606110873017') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'606110873017','J-500921918');
UPDATE SAPVPR SET Cantidad=3.00,
       Costo=1861.69,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='3.35086'
 WHERE (TipoCom='H') And 
       (CodItem='606110873017') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[MtoTax],[Precio1],[Precio2],[Precio3],[TotalItem],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,4,'2026-03-13 14:32:05.105','606110873017','3.35086','AMR001','COMPRESAS DE LAPATOMIA 18X18 PQT 5 UNID',3.00,1861.69,893.609763,1894.4569,2034.63,2320.73,5585.07,1,ISNULL(@NROUNICOLOT,0),'654','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
INSERT INTO SATAXITC ([CodSucu],[TipoCom],[NumeroD],[CodTaxs],[CodProv],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','H',@NUMEROCOM,'IVA','J-500921918','606110873017',5585.07,16.00,893.61,4)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='100117') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 376.77 
ELSE ((CostPro*Existen)+3767.70)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=376.77,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='100117')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='100117')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='100117' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','100117','AMR001',10.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','100117','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=530.59,Precio2=582.87,Precio3=697.33,Costo=376.77,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='100117') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=530.59,Precio2=582.87,Precio3=697.33
 WHERE (CodSucu='00000') And (CodProd='100117') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='100117') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'100117','J-500921918');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=376.77,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='0.995626'
 WHERE (TipoCom='H') And 
       (CodItem='100117') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[MtoTax],[Precio1],[Precio2],[Precio3],[TotalItem],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,5,'2026-03-13 14:32:05.105','100117','0.995626','AMR001','GUANTE ESTERIL X TIPO PAR',10.00,376.77,602.831031,530.59,582.87,697.33,3767.70,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
INSERT INTO SATAXITC ([CodSucu],[TipoCom],[NumeroD],[CodTaxs],[CodProv],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','H',@NUMEROCOM,'IVA','J-500921918','100117',3767.70,16.00,602.83,5)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='100117') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 376.77 
ELSE ((CostPro*Existen)+3767.70)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=376.77,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='100117')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='100117')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='100117' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','100117','AMR001',10.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','100117','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=530.58621,Precio2=582.87,Precio3=697.33,Costo=376.77,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='100117') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=530.58621,Precio2=582.87,Precio3=697.33
 WHERE (CodSucu='00000') And (CodProd='100117') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='100117') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'100117','J-500921918');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=376.77,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='0.995626'
 WHERE (TipoCom='H') And 
       (CodItem='100117') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[MtoTax],[Precio1],[Precio2],[Precio3],[TotalItem],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,6,'2026-03-13 14:32:05.105','100117','0.995626','AMR001','GUANTE ESTERIL X TIPO PAR',10.00,376.77,602.831031,530.58621,582.87,697.33,3767.70,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
INSERT INTO SATAXITC ([CodSucu],[TipoCom],[NumeroD],[CodTaxs],[CodProv],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','H',@NUMEROCOM,'IVA','J-500921918','100117',3767.70,16.00,602.83,6)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-100.00
 WHERE (CodSucu='00000') And (CodProd='7597478000166') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 70.92 
ELSE ((CostPro*Existen)+7092.00)/NULLIF(Existen+100.00,0) END),0), 
COSTACT=70.92,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='7597478000166')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7597478000166')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7597478000166' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597478000166','AMR001',100.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7597478000166','AMR001','698')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+100.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=70.92241,Precio2=70.92,Precio3=70.92,Costo=70.92,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7597478000166') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=70.92241,Precio2=70.92,Precio3=70.92
 WHERE (CodSucu='00000') And (CodProd='7597478000166') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7597478000166') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7597478000166','J-500921918');
UPDATE SAPVPR SET Cantidad=100.00,
       Costo=70.92,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='0.207501'
 WHERE (TipoCom='H') And 
       (CodItem='7597478000166') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[MtoTax],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,7,'2026-03-13 14:32:05.105','7597478000166','0.207501','AMR001','JERINGA 1CC 30GX1/2 TAPA NARANJA GDG',100.00,70.92,1134.718175,70.92241,70.92,70.92,7092.00,1,1,ISNULL(@NROUNICOLOT,0),'698','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
INSERT INTO SATAXITC ([CodSucu],[TipoCom],[NumeroD],[CodTaxs],[CodProv],[CodItem],[TGravable],[MtoTax],[Monto],[NroLinea])
       VALUES ('00000','H',@NUMEROCOM,'IVA','J-500921918','7597478000166',7092.00,16.00,1134.72,7)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-100.00
 WHERE (CodSucu='00000') And (CodProd='JER_3CC') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 53.19 
ELSE ((CostPro*Existen)+5319.00)/NULLIF(Existen+100.00,0) END),0), 
COSTACT=53.19,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='JER_3CC')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='JER_3CC')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='JER_3CC' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','JER_3CC','AMR001',100.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','JER_3CC','AMR001','2')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+100.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=108.06,Precio2=122.10,Precio3=155.84,Costo=53.19,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='JER_3CC') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=108.06,Precio2=122.10,Precio3=155.84
 WHERE (CodSucu='00000') And (CodProd='JER_3CC') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='JER_3CC') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'JER_3CC','J-500921918');
UPDATE SAPVPR SET Cantidad=100.00,
       Costo=53.19,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='0.167'
 WHERE (TipoCom='H') And 
       (CodItem='JER_3CC') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,8,'2026-03-13 14:32:05.105','JER_3CC','0.167','AMR001','JERINGA 3 ML 23GR X 1 1/4 HB',100.00,53.19,108.06,122.10,155.84,5319.00,1,1,ISNULL(@NROUNICOLOT,0),'2','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-100.00
 WHERE (CodSucu='00000') And (CodProd='JER_5CC') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 62.06 
ELSE ((CostPro*Existen)+6206.00)/NULLIF(Existen+100.00,0) END),0), 
COSTACT=62.06,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 14:32:05.105'
 WHERE (CodProd='JER_5CC')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='JER_5CC')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='JER_5CC' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','JER_5CC','AMR001',100.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','JER_5CC','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+100.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=92.19,Precio2=107.28,Precio3=147.48,Costo=62.06,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='JER_5CC') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=92.19,Precio2=107.28,Precio3=147.48
 WHERE (CodSucu='00000') And (CodProd='JER_5CC') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='JER_5CC') And 
                     (CodProv='J-500921918'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'JER_5CC','J-500921918');
UPDATE SAPVPR SET Cantidad=100.00,
       Costo=62.06,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='0.1331'
 WHERE (TipoCom='H') And 
       (CodItem='JER_5CC') And 
       (CodProv='J-500921918')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-500921918','H',@NUMEROCOM,9,'2026-03-13 14:32:05.105','JER_5CC','0.1331','AMR001','JERINGA 5 CC',100.00,62.06,92.19,107.28,147.48,6206.00,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-13 14:32:05.105',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Contado],[Monto],[MtoTax],[RetenIVA],[TGravable],[TExento],[TotalPrd],[OrdenC],[CodOper],[CancelE])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 14:32:05.105','2026-03-13 14:32:05.105','2026-03-28 14:32:05.105',@NUMEROCOM,'J-500921918','AMR001','MEDICAL JR 23 C.A',443.25,97.102245,'00-00002335','J-500921918',46274.56,46274.56,43040.57,3233.99,1574.46,13120.47,29920.10,43040.57,'00002183','CXP',44700.10)
INSERT INTO SATAXCOM ([CodSucu],[TipoCom],[NumeroD],[CodProv],[CodTaxs],[MtoTax],[Monto],[TGravable])
       VALUES ('00000','H',@NUMEROCOM,'J-500921918','IVA',16.00,3233.99,20212.47)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=43040.57, NumeroUC='00002183', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J-500921918')
INSERT INTO SAIPACOM ([CodSucu],[TipoCom],[CodProv],[NumeroD],[CodTarj],[Descrip],[TipoPag],[Monto],[FechaE],[Factor],[Refere],[RetencT])
       VALUES ('00000','H','J-500921918',@NUMEROCOM,'008','Retencion de IVA',7,1574.46,'2026-03-13 14:32:05.826',1.00,'IVA',13120.47)
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[Monto],[MontoNeto],[MtoTax],[OrgTax],[RetenIVA],[BaseImpo],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-500921918','00002183','00-00002335','V12400678','ADM-3','10','MEDICAL JR 23 C.A','J-500921918',GETDATE(),'00002183 00002183','2026-03-13 14:32:05.105','2026-03-13 14:32:05.105','2026-03-28 14:32:05.105',443.25,97.102245,46274.56,43040.57,3233.99,3233.99,1574.46,13120.47,29920.10,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
INSERT INTO SAACXP ([CodSucu],[NroRegi],[TipoCxP],[CodProv],[NumeroD],[NumeroN],[NroCtrol],[CodUsua],[CodEsta],[Document],[FechaT],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[Monto],[Descrip],[ID3],[CodOper],[CodTarj],[MtoTax],[BaseImpo],[TExento],[CancelE])
       VALUES ('00000',@NroUnicoCxp,'41','J-500921918','00002183','00002183','00-00002335','V12400678','ADM-3','EFECTIVO',GETDATE(),'2026-03-13 14:32:05.105','2026-03-13 14:32:05.105','2026-03-28 14:32:05.105',443.25,100.846249,44700.10,'MEDICAL JR 23 C.A','J-500921918','CXP','-EFE-',3233.99,13120.47,29920.10,44700.10)
SET @NROUNICO=IDENT_CURRENT('SAACXP')
INSERT INTO SAPAGCXP ([CodSucu],[NroPpal],[NroRegi],[TipoCxP],[MontoDocA],[Monto],[NumeroD],[Descrip],[FechaE],[FechaO],[CodOper])
       VALUES ('00000',@NroUnico,@NroUnicoCXP,'10',43040.57,44700.10,'00002183','EFECTIVO','2026-03-13 14:32:05.105','2026-03-13 14:32:05.105','CXP')
EXEC SP_ADM_PROXCORREL '00000','','PrxRetenIVA',@NUMERORETIVA OUTPUT;
SET @NUMERORETIVA=REPLICATE('0',8-LEN(RIGHT(@NUMERORETIVA,8)))+RIGHT(@NUMERORETIVA,8);
SET @NUMERORETIVA='202603'+@NUMERORETIVA
INSERT INTO SAACXP ([CodSucu],[NroRegi],[TipoCxP],[CodProv],[NumeroD],[NumeroN],[NroCtrol],[CodUsua],[CodEsta],[Document],[FechaT],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[Monto],[Descrip],[ID3],[CodTarj],[RetenIVA],[BaseImpo],[TExento],[MtoTax],[MontoNeto],[EsReten])
       VALUES ('00000',@NroUnicoCxp,'81','J-500921918',@NUMERORETIVA,'00002183','00-00002335','V12400678','ADM-3','RET. IVA DOC.: 00002183',GETDATE(),'2026-03-13 14:32:05.105','2026-03-13 14:32:05.105','2026-03-28 14:32:05.105',443.25,3.552081,1574.46,'MEDICAL JR 23 C.A','J-500921918','008',1574.46,13120.47,29920.10,3233.99,43040.57,1)
SET @NROUNICORETIVA=IDENT_CURRENT('SAACXP')
INSERT INTO SAPAGCXP ([CodSucu],[NroPpal],[NroRegi],[CodProv],[FechaE],[FechaO],[Monto],[Descrip],[TipoCxP],[NumeroD],[MontoDocA],[BaseReten],[CodRete],[EsReten])
       VALUES ('00000',@NROUNICORETIVA,@NroUnicoCxp,'J-500921918','2026-03-13 14:32:05.826','2026-03-13 14:32:05.105',1574.46,'Retencion de IVA','81',@NUMERORETIVA,43040.57,13120.47,'IVA',1)
UPDATE SACOMP SET 
       NumeroR=@NUMERORETIVA
 WHERE (CodSucu='00000') And (CodProv='J-500921918') And (TipoCom='H') And (NumeroD='00002183')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 61 | Start: 2026-03-13 14:32:13.977000 | Status: running | Cmd: SELECT (STATMAN)
SET DATEFORMAT YMD;
SELECT P.*, I.DEsComi AS ITIENECOMI FROM SAPROD P, SAINSTA I WITH (NOLOCK) WHERE P.CodInst=I.CodInst AND (CodProd='7751940001307')
GO

-- Session: 61 | Start: 2026-03-13 14:32:16.520000 | Status: running | Cmd: SELECT
SELECT SAFACT.NumeroD NumeroD_2, 
       SAFACT.TipoFac TipoFac_2, 
       SAITEMFAC.Cantidad, SAITEMFAC.CantidadU, 
       SAITEMFAC.CantMayor, SAITEMFAC.CodItem, 
       SAITEMFAC.CodMeca, SAITEMFAC.CodSucu, 
       SAITEMFAC.CodUbic, SAITEMFAC.CodUsua, 
       SAITEMFAC.CodVend, SAITEMFAC.Costo, 
       SAITEMFAC.Descrip1, SAITEMFAC.Descrip10, 
       SAITEMFAC.Descrip2, SAITEMFAC.Descrip3, 
       SAITEMFAC.Descrip4, SAITEMFAC.Descrip5, 
       SAITEMFAC.Descrip6, SAITEMFAC.Descrip7, 
       SAITEMFAC.Descrip8, SAITEMFAC.Descrip9, 
       SAITEMFAC.Descto, SAITEMFAC.DEsLote, 
       SAITEMFAC.DEsSeri, SAITEMFAC.EsExento, 
       SAITEMFAC.EsPesa, SAITEMFAC.EsServ, 
       SAITEMFAC.EsUnid, SAITEMFAC.ExistAnt, 
       SAITEMFAC.ExistAntU, SAITEMFAC.FechaE, 
       SAITEMFAC.Factor, SAITEMFAC.FechaL, 
       SAITEMFAC.FechaV, SAITEMFAC.MtoTax, 
       SAITEMFAC.NroLinea, SAITEMFAC.NroLineaC, 
       SAITEMFAC.MtoTaxO, SAITEMFAC.NroLote, 
       SAITEMFAC.NroUnicoL, SAITEMFAC.NumeroD, 
       SAITEMFAC.NumeroE, SAITEMFAC.Precio, 
       SAITEMFAC.PriceO, SAITEMFAC.Refere, 
       SAITEMFAC.Signo, SAITEMFAC.PrecioI, 
       SAITEMFAC.Tara, SAITEMFAC.TipoFac, 
       SAITEMFAC.TotalItem, SAITEMFAC.UsaServ, 
       SAITEMFAC.TipoData, SAITEMFAC.TipoPVP
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
      INNER JOIN SAITEMFAC SAITEMFAC ON 
     (SAITEMFAC.NumeroD = SAFACT.NumeroD)
      AND (SAITEMFAC.TipoFac = SAFACT.TipoFac)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44392' )
ORDER BY SAITEMFAC.NumeroD, SAITEMFAC.TipoFac
GO

-- Session: 59 | Start: 2026-03-13 14:34:16.017000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='196852644438') OR         (C.CodAlte='196852644438') OR 
        (P.Refere ='196852644438'))
GO

-- Session: 59 | Start: 2026-03-13 14:35:26.013000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT P.*, C.Saldo AS SALDOP 
  FROM SAPROV P 
       LEFT JOIN (SELECT CODPROV, SUM(SALDO) AS SALDO 
                    FROM SAACXP
                   WHERE (SALDO>0) and ((TIPOCXP IN ('10','60','70')) or (substring(tipocxp,1,1)='3'))
                   GROUP BY CodProv) C
        ON (P.CODPROV=C.CODPROV)
 WHERE P.CODPROV='RIJ-41298028-9'
GO

-- Session: 61 | Start: 2026-03-13 14:37:07.187000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '196852522460%') OR (SP.DESCRIPALL LIKE '196852522460%') OR (SP.REFERE LIKE '196852522460%') OR (SP.EXISTEN LIKE '196852522460%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 14:37:34.480000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '669238000499%') OR (SP.DESCRIPALL LIKE '669238000499%') OR (SP.REFERE LIKE '669238000499%') OR (SP.EXISTEN LIKE '669238000499%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 59 | Start: 2026-03-13 14:40:24.703000 | Status: running | Cmd: EXECUTE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='105805'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-3.00
 WHERE (CodSucu='00000') And (CodProd='7594001102359') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2037.25 
ELSE ((CostPro*Existen)+6111.75)/NULLIF(Existen+3.00,0) END),0), 
COSTACT=2037.25,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 14:40:24.426'
 WHERE (CodProd='7594001102359')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594001102359')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594001102359' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594001102359','AMR001',3.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594001102359','AMR001','987')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+3.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2037.25,Precio2=2037.25,Precio3=2037.25,Costo=2037.25,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594001102359') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2037.25,Precio2=2037.25,Precio3=2037.25
 WHERE (CodSucu='00000') And (CodProd='7594001102359') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594001102359') And 
                     (CodProv='J-04310975'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594001102359','J-04310975');
UPDATE SAPVPR SET Cantidad=3.00,
       Costo=2037.25,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='5.12737'
 WHERE (TipoCom='H') And 
       (CodItem='7594001102359') And 
       (CodProv='J-04310975')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-04310975','H',@NUMEROCOM,1,'2026-03-12 14:40:24.426','7594001102359','5.12737','AMR001','TANSUDEX/TAMSULOSINA 0.4 X30 PLUS ANDEX',3.00,2037.25,2037.25,2037.25,2037.25,6111.75,1,1,ISNULL(@NROUNICOLOT,0),'987','2026-03-12 14:40:24.426',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7460536574377') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1300.85 
ELSE ((CostPro*Existen)+1300.85)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=1300.85,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 14:40:24.426'
 WHERE (CodProd='7460536574377')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7460536574377')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7460536574377' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7460536574377','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7460536574377','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1815.56,Precio2=1950.01,Precio3=2224.06,Costo=1300.85,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7460536574377') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1815.56,Precio2=1950.01,Precio3=2224.06
 WHERE (CodSucu='00000') And (CodProd='7460536574377') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7460536574377') And 
                     (CodProv='J-04310975'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7460536574377','J-04310975');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=1300.85,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='3.21136'
 WHERE (TipoCom='H') And 
       (CodItem='7460536574377') And 
       (CodProv='J-04310975')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-04310975','H',@NUMEROCOM,2,'2026-03-12 14:40:24.426','7460536574377','3.21136','AMR001','NEFROTAL 50MGX30 COMP ROWE',1.00,1300.85,1815.56,1950.01,2224.06,1300.85,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-12 14:40:24.426',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592349722932') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 5004.96 
ELSE ((CostPro*Existen)+5004.96)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=5004.96,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 14:40:24.426'
 WHERE (CodProd='7592349722932')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592349722932')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592349722932' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592349722932','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592349722932','AMR001','32')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=5178.44,Precio2=5505.40,Precio3=6153.13,Costo=5004.96,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592349722932') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=5178.44,Precio2=5505.40,Precio3=6153.13
 WHERE (CodSucu='00000') And (CodProd='7592349722932') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592349722932') And 
                     (CodProv='J-04310975'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592349722932','J-04310975');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=5004.96,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='10.8535'
 WHERE (TipoCom='H') And 
       (CodItem='7592349722932') And 
       (CodProv='J-04310975')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-04310975','H',@NUMEROCOM,3,'2026-03-12 14:40:24.426','7592349722932','10.8535','AMR001','REFLUXYL SUSP ORAL X 120 ML VARGAS',1.00,5004.96,5178.44,5505.40,6153.13,5004.96,1,1,ISNULL(@NROUNICOLOT,0),'32','2026-03-12 14:40:24.426',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='8906009239903') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 6222.03 
ELSE ((CostPro*Existen)+6222.03)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=6222.03,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 14:40:24.426'
 WHERE (CodProd='8906009239903')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='8906009239903')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='8906009239903' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8906009239903','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','8906009239903','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=6222.03,Precio2=6238.87,Precio3=6973.02,Costo=6222.03,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='8906009239903') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=6222.03,Precio2=6238.87,Precio3=6973.02
 WHERE (CodSucu='00000') And (CodProd='8906009239903') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='8906009239903') And 
                     (CodProv='J-04310975'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'8906009239903','J-04310975');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=6222.03,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='10.6971'
 WHERE (TipoCom='H') And 
       (CodItem='8906009239903') And 
       (CodProv='J-04310975')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-04310975','H',@NUMEROCOM,4,'2026-03-12 14:40:24.426','8906009239903','10.6971','AMR001','GESTASYN 200 MG X 10 CAP TIARES',1.00,6222.03,6222.03,6238.87,6973.02,6222.03,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-12 14:40:24.426',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='8904187866065') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 4784.48 
ELSE ((CostPro*Existen)+4784.48)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=4784.48,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-12 14:40:24.426'
 WHERE (CodProd='8904187866065')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='8904187866065')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='8904187866065' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8904187866065','AMR001',1.00,0,'2026-03-12'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','8904187866065','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=4784.48,Precio2=4784.48,Precio3=4784.48,Costo=4784.48,FechaE='2026-03-12',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='8904187866065') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=4784.48,Precio2=4784.48,Precio3=4784.48
 WHERE (CodSucu='00000') And (CodProd='8904187866065') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='8904187866065') And 
                     (CodProv='J-04310975'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'8904187866065','J-04310975');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=4784.48,
       FechaE='2026-03-12',
       EsServ=0,
       Refere='7.7086'
 WHERE (TipoCom='H') And 
       (CodItem='8904187866065') And 
       (CodProv='J-04310975')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-04310975','H',@NUMEROCOM,5,'2026-03-12 14:40:24.426','8904187866065','7.7086','AMR001','METRONIDAZOL-MICONAZOL 750      MG -25',1.00,4784.48,4784.48,4784.48,4784.48,4784.48,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-12 14:40:24.426',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Monto],[TExento],[TotalPrd],[OrdenC],[CodOper],[Credito])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 14:40:24.426','2026-03-12 14:40:24.426','2026-03-28 14:40:24.426',@NUMEROCOM,'J-04310975','AMR001','El Mastranto M & M c.a.',443.25,52.846182,'00-146433','404310975',23424.07,23424.07,23424.07,23424.07,'105805','CXP',23424.07)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=23424.07, NumeroUC='105805', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J-04310975')
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-04310975','105805','00-146433','V12400678','ADM-3','10','El Mastranto M & M c.a.','404310975',GETDATE(),'105805 105805','2026-03-13 14:40:24.426','2026-03-12 14:40:24.426','2026-03-28 14:40:24.426',443.25,52.846182,52.846182,23424.07,23424.07,23424.07,23424.07,23424.07,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 59 | Start: 2026-03-13 14:42:55.887000 | Status: running | Cmd: SELECT
SELECT EsPorct,Monto FROM VW_ADM_TAXINVENT WITH (NOLOCK) WHERE (CodProd='7591062902539') And (EsReten=0)
GO

-- Session: 71 | Start: 2026-03-13 14:45:05.837000 | Status: runnable | Cmd: INSERT
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END
GO

-- Session: 71 | Start: 2026-03-13 14:46:00.807000 | Status: runnable | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 61 | Start: 2026-03-13 14:49:00.660000 | Status: runnable | Cmd: SELECT (STATMAN)
SELECT TOP 1 CodProd   FROM VW_ADM_PRODUCTOS WITH (NOLOCK)
GO

-- Session: 61 | Start: 2026-03-13 14:49:04.683000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'VAPO%') OR (SP.DESCRIPALL LIKE 'VAPO%') OR (SP.REFERE LIKE 'VAPO%') OR (SP.EXISTEN LIKE 'VAPO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 59 | Start: 2026-03-13 14:53:08.533000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='7894164009671') OR         (C.CodAlte='7894164009671') OR 
        (P.Refere ='7894164009671'))
GO

-- Session: 61 | Start: 2026-03-13 14:59:39.913000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='BLI_TORSIL' OR P.CodProd='BLI_TORSIL')
GO

-- Session: 59 | Start: 2026-03-13 15:00:53.437000 | Status: running | Cmd: AWAITING COMMAND
(@P1 varchar(5),@P2 varchar(15))SET DATEFORMAT YMD;
SELECT DP.CODUBIC, DP.DESCRIP, EX.PUESTOI, EX.EXISTEN, EX.EXUNIDAD,
       EX.CANTCOM, EX.CANTPED, EX.UNIDCOM, EX.UNIDPED
  FROM SAEXIS EX WITH (NOLOCK)
       INNER JOIN SADEPO DP
       ON DP.CODUBIC=EX.CODUBIC
 WHERE EX.CODSUCU=@P1 AND EX.CODPROD=@P2
GO

-- Session: 66 | Start: 2026-03-13 15:01:00.137000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 61 | Start: 2026-03-13 15:01:02.497000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='6972718560074') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 54 | Start: 2026-03-13 15:03:00.100000 | Status: running | Cmd: UPDATE
UPDATE SAPROD 
SET PrecioI1=b.precio$1,PrecioI2=b.precio$2,PrecioI3=b.precio$3
from SAPROD as a
inner join CUSTOM_PRECIO_EN_DOLAR as b on (a.CodProd=b.codprod)
GO

-- Session: 61 | Start: 2026-03-13 15:03:18.497000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7594001101956') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 59 | Start: 2026-03-13 15:04:22.507000 | Status: running | Cmd: EXECUTE
SELECT TOP 1 CodSucu FROM SALOTE WITH (NOLOCK)  WHERE (CodSucu='00000') And (CodProd='7594001455806') And (CodUbic='AMR001') And (NroLote='654')
GO

-- Session: 61 | Start: 2026-03-13 15:04:49.670000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7594001101406') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 59 | Start: 2026-03-13 15:05:14.320000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 *, ISNULL((SELECT COUNT(CODALTE) FROM SAEQUI WITH (NOLOCK)  WHERE CODPROD='7598677000452'),0) AS CANTEQUIV,  0 AS ISADIC FROM VW_ADM_PRODUCTOS with (nolock) WHERE (CodProd='7598677000452') And (Activo=1)
GO

-- Session: 61 | Start: 2026-03-13 15:05:20.897000 | Status: running | Cmd: AWAITING COMMAND
(@P1 varchar(5),@P2 varchar(15))SET DATEFORMAT YMD;
SELECT DP.CODUBIC, DP.DESCRIP, EX.PUESTOI, EX.EXISTEN, EX.EXUNIDAD,
       EX.CANTCOM, EX.CANTPED, EX.UNIDCOM, EX.UNIDPED
  FROM SAEXIS EX WITH (NOLOCK)
       INNER JOIN SADEPO DP
       ON DP.CODUBIC=EX.CODUBIC
 WHERE EX.CODSUCU=@P1 AND EX.CODPROD=@P2
GO

-- Session: 59 | Start: 2026-03-13 15:06:35.027000 | Status: running | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='00145092'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-3.00
 WHERE (CodSucu='00000') And (CodProd='8906005118370') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 914.98 
ELSE ((CostPro*Existen)+2744.94)/NULLIF(Existen+3.00,0) END),0), 
COSTACT=914.98,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='8906005118370')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='8906005118370')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='8906005118370' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8906005118370','AMR001',3.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','8906005118370','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+3.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=914.98,Precio2=914.98,Precio3=914.98,Costo=914.98,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='8906005118370') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=914.98,Precio2=914.98,Precio3=914.98
 WHERE (CodSucu='00000') And (CodProd='8906005118370') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='8906005118370') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'8906005118370','J-50159019-2');
UPDATE SAPVPR SET Cantidad=3.00,
       Costo=914.98,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='0'
 WHERE (TipoCom='H') And 
       (CodItem='8906005118370') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,1,'2026-03-11 15:06:34.211','8906005118370','0','AMR001','ACIDO MEFENAMICO 500      MG X 10 TAB',3.00,914.98,914.98,914.98,914.98,2744.94,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592349001822') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2058.71 
ELSE ((CostPro*Existen)+2058.71)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=2058.71,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7592349001822')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592349001822')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592349001822' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592349001822','AMR001',1.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592349001822','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2058.71,Precio2=2058.71,Precio3=2058.71,Costo=2058.71,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592349001822') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2058.71,Precio2=2058.71,Precio3=2058.71
 WHERE (CodSucu='00000') And (CodProd='7592349001822') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592349001822') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592349001822','J-50159019-2');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=2058.71,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='0'
 WHERE (TipoCom='H') And 
       (CodItem='7592349001822') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,2,'2026-03-11 15:06:34.211','7592349001822','0','AMR001','ANTIFON 125MG X10TABL/MASTICABLE VARGAS',1.00,2058.71,2058.71,2058.71,2058.71,2058.71,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592349722925') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2040.97 
ELSE ((CostPro*Existen)+2040.97)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=2040.97,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7592349722925')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592349722925')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592349722925' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592349722925','AMR001',1.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592349722925','AMR001','368')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2040.97,Precio2=2040.97,Precio3=2040.97,Costo=2040.97,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592349722925') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2040.97,Precio2=2040.97,Precio3=2040.97
 WHERE (CodSucu='00000') And (CodProd='7592349722925') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592349722925') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592349722925','J-50159019-2');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=2040.97,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='0'
 WHERE (TipoCom='H') And 
       (CodItem='7592349722925') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,3,'2026-03-11 15:06:34.211','7592349722925','0','AMR001','ANTIFOM COMR 40      MG X 10',1.00,2040.97,2040.97,2040.97,2040.97,2040.97,1,1,ISNULL(@NROUNICOLOT,0),'368','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592349001563') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2082.37 
ELSE ((CostPro*Existen)+2082.37)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=2082.37,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7592349001563')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592349001563')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592349001563' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592349001563','AMR001',1.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592349001563','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2600.36,Precio2=2764.33,Precio3=3089.57,Costo=2082.37,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592349001563') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2600.36,Precio2=2764.33,Precio3=3089.57
 WHERE (CodSucu='00000') And (CodProd='7592349001563') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592349001563') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592349001563','J-50159019-2');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=2082.37,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='4.74'
 WHERE (TipoCom='H') And 
       (CodItem='7592349001563') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,4,'2026-03-11 15:06:34.211','7592349001563','4.74','AMR001','FUMARATO DE BISOPROLOL 2.5      MG X 3',1.00,2082.37,2600.36,2764.33,3089.57,2082.37,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7592349723618') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1277.82 
ELSE ((CostPro*Existen)+1277.82)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=1277.82,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7592349723618')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7592349723618')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7592349723618' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592349723618','AMR001',1.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7592349723618','AMR001','32')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1319.24,Precio2=1424.39,Precio3=1642.65,Costo=1277.82,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7592349723618') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1319.24,Precio2=1424.39,Precio3=1642.65
 WHERE (CodSucu='00000') And (CodProd='7592349723618') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7592349723618') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7592349723618','J-50159019-2');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=1277.82,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='2.2976'
 WHERE (TipoCom='H') And 
       (CodItem='7592349723618') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,5,'2026-03-11 15:06:34.211','7592349723618','2.2976','AMR001','BIPROLIL 2,5 X 15 COMP',1.00,1277.82,1319.24,1424.39,1642.65,1277.82,1,1,ISNULL(@NROUNICOLOT,0),'32','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7591818000182') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 2846.70 
ELSE ((CostPro*Existen)+2846.70)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=2846.70,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7591818000182')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591818000182')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591818000182' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591818000182','AMR001',1.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591818000182','AMR001','32')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2846.70,Precio2=2846.70,Precio3=2846.70,Costo=2846.70,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591818000182') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2846.70,Precio2=2846.70,Precio3=2846.70
 WHERE (CodSucu='00000') And (CodProd='7591818000182') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591818000182') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591818000182','J-50159019-2');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=2846.70,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='0'
 WHERE (TipoCom='H') And 
       (CodItem='7591818000182') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,6,'2026-03-11 15:06:34.211','7591818000182','0','AMR001','CLORACI PLUS 1000MG/10MG TAB COFASA',1.00,2846.70,2846.70,2846.70,2846.70,2846.70,1,1,ISNULL(@NROUNICOLOT,0),'32','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-10.00
 WHERE (CodSucu='00000') And (CodProd='AMP_DEXAME_4MG') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 299.74 
ELSE ((CostPro*Existen)+2997.40)/NULLIF(Existen+10.00,0) END),0), 
COSTACT=299.74,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='AMP_DEXAME_4MG')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='AMP_DEXAME_4MG')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='AMP_DEXAME_4MG' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','AMP_DEXAME_4MG','AMR001',10.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','AMP_DEXAME_4MG','AMR001','325')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+10.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=299.74,Precio2=299.74,Precio3=299.74,Costo=299.74,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='AMP_DEXAME_4MG') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=299.74,Precio2=299.74,Precio3=299.74
 WHERE (CodSucu='00000') And (CodProd='AMP_DEXAME_4MG') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='AMP_DEXAME_4MG') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'AMP_DEXAME_4MG','J-50159019-2');
UPDATE SAPVPR SET Cantidad=10.00,
       Costo=299.74,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='0.1527'
 WHERE (TipoCom='H') And 
       (CodItem='AMP_DEXAME_4MG') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,7,'2026-03-11 15:06:34.211','AMP_DEXAME_4MG','0.1527','AMR001','DEXAMETAXONA 4      MG /1ML AMP I.V/I.',10.00,299.74,299.74,299.74,299.74,2997.40,1,1,ISNULL(@NROUNICOLOT,0),'325','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7591818116005') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 855.43 
ELSE ((CostPro*Existen)+1710.86)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=855.43,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7591818116005')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591818116005')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591818116005' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591818116005','AMR001',2.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591818116005','AMR001','368')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=855.43,Precio2=855.43,Precio3=855.43,Costo=855.43,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591818116005') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=855.43,Precio2=855.43,Precio3=855.43
 WHERE (CodSucu='00000') And (CodProd='7591818116005') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591818116005') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591818116005','J-50159019-2');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=855.43,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='2.02573'
 WHERE (TipoCom='H') And 
       (CodItem='7591818116005') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,8,'2026-03-11 15:06:34.211','7591818116005','2.02573','AMR001','EUSILEN COMPDO 4      MG X 8',2.00,855.43,855.43,855.43,855.43,1710.86,1,1,ISNULL(@NROUNICOLOT,0),'368','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7594001451051') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1703.76 
ELSE ((CostPro*Existen)+3407.52)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=1703.76,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7594001451051')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594001451051')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594001451051' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594001451051','AMR001',2.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594001451051','AMR001','14')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1703.76,Precio2=1703.76,Precio3=1703.76,Costo=1703.76,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594001451051') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1703.76,Precio2=1703.76,Precio3=1703.76
 WHERE (CodSucu='00000') And (CodProd='7594001451051') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594001451051') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594001451051','J-50159019-2');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=1703.76,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='3.00138'
 WHERE (TipoCom='H') And 
       (CodItem='7594001451051') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,9,'2026-03-11 15:06:34.211','7594001451051','3.00138','AMR001','JARABE LAMEDOR ADULTO 120 ML RECETEMA',2.00,1703.76,1703.76,1703.76,1703.76,3407.52,1,1,ISNULL(@NROUNICOLOT,0),'14','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-1.00
 WHERE (CodSucu='00000') And (CodProd='7596139000026') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1806.30 
ELSE ((CostPro*Existen)+1806.30)/NULLIF(Existen+1.00,0) END),0), 
COSTACT=1806.30,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7596139000026')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7596139000026')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7596139000026' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7596139000026','AMR001',1.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7596139000026','AMR001','1414444')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+1.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1806.30,Precio2=1806.30,Precio3=1806.30,Costo=1806.30,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7596139000026') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1806.30,Precio2=1806.30,Precio3=1806.30
 WHERE (CodSucu='00000') And (CodProd='7596139000026') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7596139000026') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7596139000026','J-50159019-2');
UPDATE SAPVPR SET Cantidad=1.00,
       Costo=1806.30,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='4.54664'
 WHERE (TipoCom='H') And 
       (CodItem='7596139000026') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,10,'2026-03-11 15:06:34.211','7596139000026','4.54664','AMR001','JARABE LAMEDOR SOMA 120ML',1.00,1806.30,1806.30,1806.30,1806.30,1806.30,1,1,ISNULL(@NROUNICOLOT,0),'1414444','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7594001455806') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1234.44 
ELSE ((CostPro*Existen)+2468.88)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=1234.44,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7594001455806')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7594001455806')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7594001455806' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7594001455806','AMR001',2.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7594001455806','AMR001','654')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1234.44,Precio2=1234.44,Precio3=1234.44,Costo=1234.44,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7594001455806') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1234.44,Precio2=1234.44,Precio3=1234.44
 WHERE (CodSucu='00000') And (CodProd='7594001455806') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7594001455806') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7594001455806','J-50159019-2');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=1234.44,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='2.33336'
 WHERE (TipoCom='H') And 
       (CodItem='7594001455806') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,11,'2026-03-11 15:06:34.211','7594001455806','2.33336','AMR001','LAMEDOR C/ZABILA PED X120ML RECCETE MARK',2.00,1234.44,1234.44,1234.44,1234.44,2468.88,1,1,ISNULL(@NROUNICOLOT,0),'654','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-3.00
 WHERE (CodSucu='00000') And (CodProd='7597767000334') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1557.84 
ELSE ((CostPro*Existen)+4673.52)/NULLIF(Existen+3.00,0) END),0), 
COSTACT=1557.84,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7597767000334')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7597767000334')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7597767000334' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7597767000334','AMR001',3.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7597767000334','AMR001','321')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+3.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1557.84,Precio2=1557.84,Precio3=1557.84,Costo=1557.84,FechaE='2026-03-11',FechaV='2026-05-22'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7597767000334') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1557.84,Precio2=1557.84,Precio3=1557.84
 WHERE (CodSucu='00000') And (CodProd='7597767000334') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7597767000334') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7597767000334','J-50159019-2');
UPDATE SAPVPR SET Cantidad=3.00,
       Costo=1557.84,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='3.24473'
 WHERE (TipoCom='H') And 
       (CodItem='7597767000334') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[FechaV],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,12,'2026-03-11 15:06:34.211','7597767000334','3.24473','AMR001','SUEROLITO CHICLE 400 ML',3.00,1557.84,1557.84,1557.84,1557.84,4673.52,1,1,ISNULL(@NROUNICOLOT,0),'321','2026-03-11 15:06:34.211','2026-05-22 00:00:00.000',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7598677000452') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 3817.68 
ELSE ((CostPro*Existen)+7635.36)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=3817.68,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-11 15:06:34.211'
 WHERE (CodProd='7598677000452')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7598677000452')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7598677000452' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7598677000452','AMR001',2.00,0,'2026-03-11'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7598677000452','AMR001','654')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=5306.02,Precio2=5641.61,Precio3=6305.00,Costo=3817.68,FechaE='2026-03-11',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7598677000452') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=5306.02,Precio2=5641.61,Precio3=6305.00
 WHERE (CodSucu='00000') And (CodProd='7598677000452') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7598677000452') And 
                     (CodProv='J-50159019-2'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7598677000452','J-50159019-2');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=3817.68,
       FechaE='2026-03-11',
       EsServ=0,
       Refere='9.67294'
 WHERE (TipoCom='H') And 
       (CodItem='7598677000452') And 
       (CodProv='J-50159019-2')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-50159019-2','H',@NUMEROCOM,13,'2026-03-11 15:06:34.211','7598677000452','9.67294','AMR001','VASTRON/ACIDO VALPROICO 250MG 180ML CLEO',2.00,3817.68,5306.02,5641.61,6305.00,7635.36,1,1,ISNULL(@NROUNICOLOT,0),'654','2026-03-11 15:06:34.211',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Monto],[TExento],[TotalPrd],[OrdenC],[CodOper],[Credito])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 15:06:34.211','2026-03-11 15:06:34.211','2026-03-27 15:06:34.211',@NUMEROCOM,'J-50159019-2','AMR001','DROGUERIA INTERCONTINENTAL C.A.',443.25,85.16943,'00-149647','J-50159019-2',37751.35,37751.35,37751.35,37751.35,'00145092','CXP',37751.35)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=37751.35, NumeroUC='00145092', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J-50159019-2')
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-50159019-2','00145092','00-149647','V12400678','ADM-3','10','DROGUERIA INTERCONTINENTAL C.A.','J-50159019-2',GETDATE(),'00145092 00145092','2026-03-13 15:06:34.211','2026-03-11 15:06:34.211','2026-03-27 15:06:34.211',443.25,85.16943,85.16943,37751.35,37751.35,37751.35,37751.35,37751.35,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 59 | Start: 2026-03-13 15:07:35.857000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='7591585116000') OR         (C.CodAlte='7591585116000') OR 
        (P.Refere ='7591585116000'))
GO

-- Session: 64 | Start: 2026-03-13 15:10:32.157000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MA%') OR (Descrip LIKE 'MA%') OR (ID3 LIKE 'MA%') OR (Clase LIKE 'MA%') OR (Saldo LIKE 'MA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 15:13:26.790000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT P.*, C.Saldo AS SALDOP,
       DBO.FN_ADM_DESCTOCONVENIO('V6291532',3075.37,1.00,'2026-03-13 14:23:44.626') AS DESCTOCV 
  FROM SACLIE P 
  LEFT JOIN (SELECT CODCLIE, SUM(SALDO) AS SALDO 
               FROM SAACXC
              WHERE (SALDO>0) AND ((TIPOCXC IN ('10','60','70')) or (substring(tipocxC,1,1)='2'))
              GROUP BY CODCLIE) C ON
       P.CODCLIE=C.CODCLIE
 WHERE P.CODCLIE='V6291532'
GO

-- Session: 69 | Start: 2026-03-13 15:15:27.753000 | Status: running | Cmd: EXECUTE
-- Check all SAACXP records for 64057256 (principal + retention)
SELECT NroUnico, NroRegi, NumeroD, CodProv, TipoCxP, Monto, MontoNeto, Saldo, SaldoAct, 
       RetenIVA, EsReten, EsUnPago, CancelT
FROM SAACXP
WHERE NumeroD = '64057256'
ORDER BY TipoCxP
GO

-- Session: 61 | Start: 2026-03-13 15:17:37.500000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'BLI_SIL%') OR (SP.DescripAll LIKE 'BLI_SIL%') OR (SP.Refere LIKE 'BLI_SIL%') OR (SP.Existen LIKE 'BLI_SIL%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 15:18:11.160000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='8906130231' OR P.CodProd='8906130231')
GO

-- Session: 61 | Start: 2026-03-13 15:19:02.440000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7894164009671') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 15:22:19.570000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7592430000185' OR P.CodProd='7592430000185')
GO

-- Session: 59 | Start: 2026-03-13 15:24:45.400000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.DEsVence,P.Descto,
     P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.CantEmpaq,P.CostPro,P.Descrip,P.Descrip2,
     P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,P.Precio3,P.PrecioIU1,
     P.PrecioIU2,P.PrecioIU3,P.PrecioI1,P.PrecioI2,P.PrecioI3
  FROM VW_ADM_PRODUCTOS P WITH (NOLOCK) 
       INNER JOIN SACODBAR C ON 
       P.CODPROD=C.CODPROD 
 WHERE (P.Activo=1) AND
       ((P.CodProd='7591585616685') OR         (C.CodAlte='7591585616685') OR 
        (P.Refere ='7591585616685'))
GO

-- Session: 70 | Start: 2026-03-13 15:24:48.950000 | Status: running | Cmd: AWAITING COMMAND
SET DATEFORMAT YMD;
Select * from SSPARM WITH (NOLOCK) Where (CodParm='_N_04') And (Modulo=101) And (Parametro=2)
GO

-- Session: 70 | Start: 2026-03-13 15:24:49.160000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 70 | Start: 2026-03-13 15:24:51.287000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JUÑIO%') OR (Descrip LIKE 'JUÑIO%') OR (ID3 LIKE 'JUÑIO%') OR (Clase LIKE 'JUÑIO%') OR (Saldo LIKE 'JUÑIO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 70 | Start: 2026-03-13 15:25:00.067000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JULIO%') OR (Descrip LIKE 'JULIO%') OR (ID3 LIKE 'JULIO%') OR (Clase LIKE 'JULIO%') OR (Saldo LIKE 'JULIO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 59 | Start: 2026-03-13 15:28:30.763000 | Status: running | Cmd: INSERT
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
  @MONTO DECIMAL(28,2)
 ,@MONTOTAX DECIMAL(28,2)
 ,@EXISTANT DECIMAL(28,3)=0
 ,@EXISTANTUND DECIMAL(28,3)=0
 ,@NUMEROCOM VARCHAR(20)
 ,@NUMERODEB VARCHAR(20)
 ,@NUMERORET VARCHAR(20)
 ,@NUMERORETIVA VARCHAR(20)
 ,@NROUNICO INT
 ,@NROUNICOCXP INT
 ,@NROUNICOLOT INT
 ,@NROUNICORET INT
 ,@NROUNICORETREV INT
 ,@NROUNICONDB INT
 ,@NROUNICORETIVA INT
 ,@PORCT DECIMAL(28,3)
 ,@UCOSTOACT DECIMAL(28,3)
 ,@UCOSTOPRO DECIMAL(28,3)
 ,@UCOSTOANT DECIMAL(28,3)
 ,@NCOSTOACT DECIMAL(28,3)
 ,@NCOSTOPRO DECIMAL(28,3)
 ,@NCOSTOANT DECIMAL(28,3)
 ,@NROREGISERI INT
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
SET @NUMEROCOM='0000165339'
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-2.00
 WHERE (CodSucu='00000') And (CodProd='7591585116000') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 1874.98 
ELSE ((CostPro*Existen)+3749.96)/NULLIF(Existen+2.00,0) END),0), 
COSTACT=1874.98,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 15:28:30.534'
 WHERE (CodProd='7591585116000')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591585116000')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591585116000' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591585116000','AMR001',2.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591585116000','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+2.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=2283.50,Precio2=2452.56,Precio3=2797.23,Costo=1874.98,FechaE='2026-03-13',FechaV='1899-12-30'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591585116000') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=2283.50,Precio2=2452.56,Precio3=2797.23
 WHERE (CodSucu='00000') And (CodProd='7591585116000') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591585116000') And 
                     (CodProv='J-40663222-8'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591585116000','J-40663222-8');
UPDATE SAPVPR SET Cantidad=2.00,
       Costo=1874.98,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='4.039'
 WHERE (TipoCom='H') And 
       (CodItem='7591585116000') And 
       (CodProv='J-40663222-8')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-40663222-8','H',@NUMEROCOM,1,'2026-03-13 15:28:30.534','7591585116000','4.039','AMR001','ALIVET COM D?A/NOCHE X 8/4',2.00,1874.98,2283.50,2452.56,2797.23,3749.96,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-13 15:28:30.534',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-12.00
 WHERE (CodSucu='00000') And (CodProd='7591585616685') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 577.71 
ELSE ((CostPro*Existen)+6932.52)/NULLIF(Existen+12.00,0) END),0), 
COSTACT=577.71,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 15:28:30.534'
 WHERE (CodProd='7591585616685')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591585616685')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591585616685' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591585616685','AMR001',12.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591585616685','AMR001','24')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+12.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1033.29,Precio2=1121.77,Precio3=1308.81,Costo=577.71,FechaE='2026-03-13',FechaV='2030-01-19'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591585616685') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1033.29,Precio2=1121.77,Precio3=1308.81
 WHERE (CodSucu='00000') And (CodProd='7591585616685') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591585616685') And 
                     (CodProv='J-40663222-8'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591585616685','J-40663222-8');
UPDATE SAPVPR SET Cantidad=12.00,
       Costo=577.71,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.77163'
 WHERE (TipoCom='H') And 
       (CodItem='7591585616685') And 
       (CodProv='J-40663222-8')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[FechaV],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-40663222-8','H',@NUMEROCOM,2,'2026-03-13 15:28:30.534','7591585616685','1.77163','AMR001','ALIVETFORTE NOCHE SOBRE 10 GR',12.00,577.71,1033.29,1121.77,1308.81,6932.52,1,1,ISNULL(@NROUNICOLOT,0),'24','2026-03-13 15:28:30.534','2030-01-19 00:00:00.000',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7591585616685') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 577.71 
ELSE ((CostPro*Existen)+3466.26)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=577.71,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 15:28:30.534'
 WHERE (CodProd='7591585616685')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591585616685')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591585616685' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591585616685','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591585616685','AMR001','32')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=1033.29,Precio2=1121.77,Precio3=1308.81,Costo=577.71,FechaE='2026-03-13',FechaV='2032-01-25'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591585616685') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=1033.29,Precio2=1121.77,Precio3=1308.81
 WHERE (CodSucu='00000') And (CodProd='7591585616685') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591585616685') And 
                     (CodProv='J-40663222-8'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591585616685','J-40663222-8');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=577.71,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.77163'
 WHERE (TipoCom='H') And 
       (CodItem='7591585616685') And 
       (CodProv='J-40663222-8')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[FechaV],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-40663222-8','H',@NUMEROCOM,3,'2026-03-13 15:28:30.534','7591585616685','1.77163','AMR001','ALIVETFORTE NOCHE SOBRE 10 GR',6.00,577.71,1033.29,1121.77,1308.81,3466.26,1,1,ISNULL(@NROUNICOLOT,0),'32','2026-03-13 15:28:30.534','2032-01-25 00:00:00.000',@EXISTANTUND,@EXISTANT)
UPDATE SAEXIS SET 
       [UnidPed]=[UnidPed]+-6.00
 WHERE (CodSucu='00000') And (CodProd='7591585216175') And (CodUbic='AMR001')
SET @NUMERRORS=@NUMERRORS+@@ERROR;
UPDATE SAPROD SET 
       @UCOSTOACT=COSTACT, @UCOSTOANT=COSTANT, @UCOSTOPRO=COSTPRO, CostAnt=CostAct,
CostPro=ISNULL((CASE WHEN COSTPRO=0 THEN 542.99 
ELSE ((CostPro*Existen)+3257.94)/NULLIF(Existen+6.00,0) END),0), 
COSTACT=542.99,@NCOSTOACT=CostAct,@NCOSTOANT=CostAnt,@NCOSTOPRO=CostPro,FechaUC='2026-03-13 15:28:30.534'
 WHERE (CodProd='7591585216175')
UPDATE SAPROD
   SET COSTACT=COSTACT-@UCOSTOACT+@NCOSTOACT 
      ,COSTANT=COSTANT-@UCOSTOANT+@NCOSTOANT 
      ,COSTPRO=COSTPRO-@UCOSTOPRO+@NCOSTOPRO 
      ,@PORCT=IIF(@NCOSTOPRO>0,(@NCOSTOPRO-@UCOSTOPRO)/@NCOSTOPRO,0) 
      ,PRECIO1=PRECIO1+PRECIO1*@PORCT 
      ,PRECIO2=PRECIO2+PRECIO2*@PORCT 
      ,PRECIO3=PRECIO3+PRECIO3*@PORCT 
  FROM SAPART 
 WHERE (SAPART.CODPROD=SAPROD.CODPROD) AND (SAPART.CODALTE='7591585216175')
SELECT @EXISTANT=EXISTEN, @EXISTANTUND=EXUNIDAD   FROM SAEXIS WITH (NOLOCK)   WHERE CODPROD='7591585216175' AND   CODSUCU='00000' AND   CODUBIC='AMR001';
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591585216175','AMR001',6.00,0,'2026-03-13'
INSERT INTO SALOTE ([CodSucu],[CodProd],[CodUbic],[NroLote])
       VALUES ('00000','7591585216175','AMR001','258')
SET @NROUNICOLOT=IDENT_CURRENT('SALOTE')
UPDATE SALOTE SET 
       [Cantidad]=[Cantidad]+6.00, PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00,Precio1=650.60,Precio2=710.44,Precio3=838.98,Costo=542.99,FechaE='2026-03-13',FechaV='2026-03-29'
 WHERE NroUnico=@NROUNICOLOT
UPDATE SALOTE SET 
       PrecioU1=0.00,PrecioU2=0.00,PrecioU3=0.00
 WHERE (CodSucu='00000') And (CodProd='7591585216175') And (CodUbic='AMR001')
UPDATE SALOTE SET 
       Precio1=650.60,Precio2=710.44,Precio3=838.98
 WHERE (CodSucu='00000') And (CodProd='7591585216175') And (CodUbic='AMR001')
IF NOT EXISTS(SELECT * FROM SAPVPR WITH (NOLOCK)
               WHERE (TipoCom='H') And 
                     (CodItem='7591585216175') And 
                     (CodProv='J-40663222-8'))
   INSERT INTO SAPVPR (TipoCom,NumeroD,CodItem,CodProv)
          VALUES ('H',@NUMEROCOM,'7591585216175','J-40663222-8');
UPDATE SAPVPR SET Cantidad=6.00,
       Costo=542.99,
       FechaE='2026-03-13',
       EsServ=0,
       Refere='1.09787'
 WHERE (TipoCom='H') And 
       (CodItem='7591585216175') And 
       (CodProv='J-40663222-8')
INSERT INTO SAITEMCOM ([Signo],[CodSucu],[CodProv],[TipoCom],[NumeroD],[NroLinea],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[Costo],[Precio1],[Precio2],[Precio3],[TotalItem],[EsExento],[DEsLote],[NroUnicoL],[NroLote],[FechaL],[FechaV],[ExistAntU],[ExistAnt])
       VALUES (1,'00000','J-40663222-8','H',@NUMEROCOM,4,'2026-03-13 15:28:30.534','7591585216175','1.09787','AMR001','ALIVET GRANULADO LIMON X1 SOBRE',6.00,542.99,650.60,710.44,838.98,3257.94,1,1,ISNULL(@NROUNICOLOT,0),'258','2026-03-13 15:28:30.534','2026-03-29 00:00:00.000',@EXISTANTUND,@EXISTANT)
INSERT INTO SACOMP ([Signo],[TipoCom],[CodSucu],[CodUsua],[CodEsta],[FechaT],[FechaI],[FechaE],[FechaV],[NumeroD],[CodProv],[CodUbic],[Descrip],[Factor],[MontoMEx],[NroCtrol],[ID3],[MtoTotal],[Monto],[TExento],[TotalPrd],[OrdenC],[CodOper],[Credito])
       VALUES (1,'H','00000','V12400678','ADM-3',GETDATE(),'2026-03-13 15:28:30.534','2026-03-13 15:28:30.534','2026-03-22 15:28:30.534',@NUMEROCOM,'J-40663222-8','AMR001','INVERSIONES TOTAL SERVIS 2015, C.A.',443.25,39.27057,'00-186391','J-40663222-8',17406.68,17406.68,17406.68,17406.68,'0000165339','CXP',17406.68)
UPDATE SAPROV SET 
       FechaUC='2026-03-13', MontoUC=17406.68, NumeroUC='0000165339', [RetenIVA]=[RetenIVA]+0.00
 WHERE (CodProv='J-40663222-8')
INSERT INTO SAACXP ([CodSucu],[CodProv],[NumeroD],[NroCtrol],[CodUsua],[CodEsta],[TipoCxP],[Descrip],[ID3],[FechaT],[Document],[FechaI],[FechaE],[FechaV],[Factor],[MontoMEx],[SaldoMEx],[Monto],[MontoNeto],[Saldo],[SaldoOrg],[TExento],[EsLibroI],[CodOper])
       VALUES ('00000','J-40663222-8','0000165339','00-186391','V12400678','ADM-3','10','INVERSIONES TOTAL SERVIS 2015, C.A.','J-40663222-8',GETDATE(),'0000165339 0000165339','2026-03-13 15:28:30.534','2026-03-13 15:28:30.534','2026-03-22 15:28:30.534',443.25,39.27057,39.27057,17406.68,17406.68,17406.68,17406.68,17406.68,1,'CXP')
SET @NROUNICOCXP=IDENT_CURRENT('SAACXP')
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROCOM,'') AS numerod, ISNULL(@NROUNICORET,0) AS nrounicoret, ISNULL(@NROUNICONDB,0) AS nrounicondb, ISNULL(@NROUNICORETIVA,0) AS nrounicoretiva;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 71 | Start: 2026-03-13 15:30:00.927000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 71 | Start: 2026-03-13 15:30:31.997000 | Status: runnable | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 64 | Start: 2026-03-13 15:38:00.123000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CODPROD LIKE '7591020005012%') OR (SP.DESCRIPALL LIKE '7591020005012%') OR (SP.REFERE LIKE '7591020005012%') OR (SP.EXISTEN LIKE '7591020005012%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 15:39:55.420000 | Status: runnable | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V2996490'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 15:39:54.430','2026-03-13 15:39:54.602','2026-03-13 15:39:54.430',1,1,'V2996490','CAJA004','V12400678','12400678','AMR001','RAFAEL','CARACAS','V2996490',1658.18,1658.18,443.25,3.74,1658.18,1658.18,1658.18,1658.18);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1056727;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 15:39:54.680'
 WHERE (CodProd='7592616200026');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7592616200026') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7592616200026','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7592616200026') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056727
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 15:39:54.712','7592616200026','2.31943','AMR001','FLUCONAZOL TAB 150      MG X 2 KIMICEG',1.00,1.00,999.01,1.00,1658.184,1658.184,3,1658.184,'12400678','V12400678',1,1,'25',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-06 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=999.01   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,1658.18,1.00,'2026-03-13 00:00:00.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 64 | Start: 2026-03-13 15:40:28.353000 | Status: runnable | Cmd: INSERT
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V11662388'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFactPV',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 15:40:28.735','2026-03-13 15:40:28.907','2026-03-13 15:40:28.735',1,1,'V11662388','CAJA10','V12400678','12400678','AMR001','NABIL ELNESER IMPORT ELNESER NABIL','LOS RUICES','V11662388',1709.26,1709.27,443.25,3.86,1709.27,1709.26,1709.26,1709.27);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1056016;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 15:40:28.985'
 WHERE (CodProd='7591821904293');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7591821904293') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591821904293','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7591821904293') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056016
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 15:40:29.000','7591821904293','1.03756','AMR001','FITEX 20      MG',1.00,1.00,505.27,1.00,821.388,821.388,3,821.388,'12400678','V12400678',1,1,'258',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-09 00:00:00.000','1899-12-29 00:00:00.000');
SET @NROUNICOLOT=1056773;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 15:40:29.000'
 WHERE (CodProd='7591020005012');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='7591020005012') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','7591020005012','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='7591020005012') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1056773
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,2,1,'2026-03-13 15:40:29.032','7591020005012','1.16179','AMR001','DUROVAL X 1',1.00,1.00,500.40,1.00,887.876,887.876,3,887.876,'12400678','V12400678',1,1,'671',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-03-07 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=1005.67   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','006','EFECTIVO',2,1709.27,1.00,'2026-03-13 15:40:21.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 61 | Start: 2026-03-13 15:42:21.697000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'REYNA%') OR (Descrip LIKE 'REYNA%') OR (ID3 LIKE 'REYNA%') OR (Clase LIKE 'REYNA%') OR (Saldo LIKE 'REYNA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 71 | Start: 2026-03-13 15:45:05.577000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_jobstep_completion_state]
    @job_id                UNIQUEIDENTIFIER,
    @step_id               INT,
    @last_run_outcome      INT,
    @last_run_duration     INT,
    @last_run_retries      INT,
    @last_run_date         INT,
    @last_run_time         INT,
    @session_id            INT
AS
BEGIN
    -- Update job step completion state in sysjobsteps as well as sysjobactivity
    UPDATE [msdb].[dbo].[sysjobsteps]
    SET last_run_outcome      = @last_run_outcome,
        last_run_duration     = @last_run_duration,
        last_run_retries      = @last_run_retries,
        last_run_date         = @last_run_date,
        last_run_time         = @last_run_time
    WHERE job_id   = @job_id
    AND   step_id  = @step_id

    DECLARE @last_executed_step_date DATETIME
    SET @last_executed_step_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET last_executed_step_date = @last_executed_step_date,
        last_executed_step_id   = @step_id
    WHERE job_id     = @job_id
    AND   session_id = @session_id
END
GO

-- Session: 61 | Start: 2026-03-13 15:45:25.713000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591585116000') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 15:47:08.397000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='ALIVE' OR P.CodProd='ALIVE')
GO

-- Session: 64 | Start: 2026-03-13 15:49:40.670000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CODPROD LIKE 'TOBRAS%') OR (SP.DESCRIPALL LIKE 'TOBRAS%') OR (SP.REFERE LIKE 'TOBRAS%') OR (SP.EXISTEN LIKE 'TOBRAS%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 15:50:06.990000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7591818000182') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 65 | Start: 2026-03-13 15:50:09.607000 | Status: suspended | Cmd: UPDATE
(@1 int,@2 int,@3 varbinary(8000),@4 smallint)UPDATE [msdb].[dbo].[sysjobschedules] set [next_run_date] = @1,[next_run_time] = @2  WHERE [job_id]=@3 AND [schedule_id]=@4
GO

-- Session: 61 | Start: 2026-03-13 15:50:48.487000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7592349722925' OR P.CodProd='7592349722925')
GO

-- Session: 61 | Start: 2026-03-13 15:53:26.267000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'ALIVE%') OR (SP.DESCRIPALL LIKE 'ALIVE%') OR (SP.REFERE LIKE 'ALIVE%') OR (SP.EXISTEN LIKE 'ALIVE%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 15:53:42.440000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT P.*, I.DEsComi AS ITIENECOMI FROM SAPROD P, SAINSTA I WITH (NOLOCK) WHERE P.CodInst=I.CodInst AND (CodProd='7591196000873')
GO

-- Session: 61 | Start: 2026-03-13 15:56:07.527000 | Status: running | Cmd: SELECT
(@P1 varchar(15))SET DATEFORMAT YMD;
SELECT PA.CODALTE, ISNULL(PR.DESCRIP,SR.DESCRIP) AS DESCRIP,
       PA.CANTIDAD, PA.ESUNID, PA.ESSERV 
  FROM SAPART PA  WITH (NOLOCK)
       LEFT JOIN SAPROD PR 
       ON PR.CODPROD=PA.CODALTE
       LEFT JOIN SASERV SR 
       ON SR.CODSERV=PA.CODALTE
 WHERE PA.CODPROD=@P1
GO

-- Session: 70 | Start: 2026-03-13 15:56:19.537000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'KETOCONAZOL%') OR (SP.DescripAll LIKE 'KETOCONAZOL%') OR (SP.Refere LIKE 'KETOCONAZOL%') OR (SP.Existen LIKE 'KETOCONAZOL%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 61 | Start: 2026-03-13 15:56:20.067000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7591020009379' OR P.CodProd='7591020009379')
GO

-- Session: 70 | Start: 2026-03-13 15:57:47.213000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SFTITM A
ORDER BY A.itemid ASC
GO

-- Session: 63 | Start: 2026-03-13 16:00:00.543000 | Status: running | Cmd: EXECUTE
(@P1 int,@P2 uniqueidentifier,@P3 int,@P4 int)EXECUTE [msdb].[dbo].[sp_sqlagent_update_jobactivity_requested_date] @session_id = @P1, @job_id = @P2, @is_system = @P3, @run_requested_source_id  = @P4
GO

-- Session: 65 | Start: 2026-03-13 16:00:00.810000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_next_scheduled_date]
    @session_id            INT,
    @job_id                UNIQUEIDENTIFIER,
	@is_system             TINYINT = 0,
    @last_run_date         INT,
    @last_run_time         INT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

   DECLARE @next_scheduled_run_date DATETIME
   SET @next_scheduled_run_date = NULL

   -- If last rundate and last runtime is not null then convert date, time to datetime
   IF (@last_run_date IS NOT NULL AND @last_run_time IS NOT NULL)
   BEGIN
        SET @next_scheduled_run_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)
   END

   UPDATE [msdb].[dbo].[sysjobactivity]
   SET next_scheduled_run_date = @next_scheduled_run_date
   WHERE session_id = @session_id
   AND job_id = @job_id
END
GO

-- Session: 65 | Start: 2026-03-13 16:00:01.927000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_set_job_completion_state]
    @job_id               UNIQUEIDENTIFIER,
    @last_run_outcome     TINYINT,
    @last_outcome_message NVARCHAR(4000),
    @last_run_date        INT,
    @last_run_time        INT,
    @last_run_duration    INT
AS
BEGIN
    -- Update last run date, time for specific job_id in local server
    UPDATE msdb.dbo.sysjobservers
    SET last_run_outcome =  @last_run_outcome,
        last_outcome_message = @last_outcome_message,
        last_run_date = @last_run_date,
        last_run_time = @last_run_time,
        last_run_duration = @last_run_duration
    WHERE job_id  = @job_id
    AND server_id = 0
END
GO

-- Session: 60 | Start: 2026-03-13 16:01:00.547000 | Status: running | Cmd: CONDITIONAL
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(4000) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               sysname = NULL,
  @session_id           INT = 0
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server collate SQL_Latin1_General_CP1_CS_AS) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to stay around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    DECLARE @job_id_as_char      VARCHAR(36)
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      DECLARE @step_id_as_char     VARCHAR(10)
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Update sysjobactivity table
  IF (@step_id = 0) --only update for job, not for each step
  BEGIN
    UPDATE msdb.dbo.sysjobactivity
    SET stop_execution_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()),
        job_history_id = SCOPE_IDENTITY()
    WHERE
        session_id = @session_id AND job_id = @job_id
  END
  -- Special handling of replication jobs
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs
   WHERE job_id = @job_id

  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and
   object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and
   lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
      N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
   DECLARE @proc nvarchar(500)
   SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
   EXEC @proc @job_id = @job_id, @category_id = @category_id,
      @message = @message
    END
  END

  -- Delete any history rows that are over the registry-defined limits
  IF (@step_id = 0) --only check once per job execution.
  BEGIN
    EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id
  END

  RETURN(@@error) -- 0 means success
END
GO

-- Session: 66 | Start: 2026-03-13 16:04:01.143000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(4),@P2 nvarchar(4),@P3 nvarchar(4),@P4 nvarchar(4))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 60 | Start: 2026-03-13 16:07:24.717000 | Status: running | Cmd: SELECT
SELECT target_data
									FROM sys.dm_xe_session_targets xet WITH(nolock)
									JOIN sys.dm_xe_sessions xes WITH(nolock)
									ON xes.address = xet.event_session_address
									WHERE xes.name = 'telemetry_xevents'
									AND xet.target_name = 'ring_buffer'
GO

-- Session: 61 | Start: 2026-03-13 16:09:32.523000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JOSE%') OR (Descrip LIKE 'JOSE%') OR (ID3 LIKE 'JOSE%') OR (Clase LIKE 'JOSE%') OR (Saldo LIKE 'JOSE%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 66 | Start: 2026-03-13 16:09:38.973000 | Status: suspended | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 61 | Start: 2026-03-13 16:10:50.953000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'MIOVIT%') OR (SP.DESCRIPALL LIKE 'MIOVIT%') OR (SP.REFERE LIKE 'MIOVIT%') OR (SP.EXISTEN LIKE 'MIOVIT%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 69 | Start: 2026-03-13 16:15:44.483000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(4),@P2 nvarchar(4),@P3 nvarchar(4),@P4 nvarchar(4))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 67 | Start: 2026-03-13 16:15:49.720000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select Fecha
     , Sum(VNeta) VNetas
     , sum(VImpuesto) VImpuestos
     , sum (VCredito) VCredito
     , sum(VContado) VContado
     , sum(VAdelanto) VAdelantos
     , sum(VCobros) VCobros
     , sum(VAdelanto)+sum(VCobros) VTotalIngreso
     , sum(VCosto) VCostos
     ,(Sum(VNeta)-sum(VCosto)) VUtilidad
     , Sum(NFact) NFact
     , Sum(NDev) NDev
  from
      (select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
            , sum(F.Monto_Neto) VNeta 
            , sum(F.MtoTax) VImpuesto
            , Sum(F.Credito) VCredito 
            , sum(F.Contado) VContado
            , sum(F.CancelA)VAdelanto
            , 0 VCobros
            , sum((F.CostoPrd+F.CostoSrv)) VCosto
            , sum(IIF(F.TipoFac = 'A',1,0)) NFact
            , sum(IIF(F.TipoFac = 'B',1,0)) NDev
          from vw_adm_facturas F 
               left join SACLIE C 
                      on F.CodClie = C.CodClie
          where (F.FechaE >= (CONVERT(DATETIME,'2026-03-13',120)+' 00:00:00') and F.FechaE<= (CONVERT(DATETIME,'2026-03-13',120)+ ' 23:59:59')) 
            and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),F.FechaE,112))
       union all
       select convert(datetime,convert(varchar(8),CXC.FechaE,112)) Fecha
            , 0,0,0,0,0,sum(Monto),0,0,0
         from SAACXC CXC 
              left join SACLIE C 
                     on CXC.CodClie = C.CodClie
         where (CXC.TipoCxc in (41))  And (CXC.EsUnPago=1)  
           and (CXC.FechaE>=(CONVERT(DATETIME,'2026-03-13',120)+' 00:00:00') and CXC.FechaE<=(CONVERT(DATETIME,'2026-03-13',120)+' 23:59:59')) 
           and (SUBSTRING(ISNULL(CXC.CODOPER,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodClie,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CODVEND,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodUsua,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),CXC.FechaE,112))) as Ventas
  group by Fecha
  order by Fecha
GO

-- Session: 67 | Start: 2026-03-13 16:15:50.173000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
     , (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) Tipo
     , Numerod Numero
     , F.CodClie Codigo
     , C.Descrip Cliente
     ,(F.Monto_Neto) VNeta
     , F.MtoTax VImpuesto
     , F.Credito VCredito 
     , F.Contado VContado
     , F.CancelA VAdelanto
     , 0 VCobros
     , (F.CostoPrd+F.CostoSrv) VCosto
     , (F.MontoTotal) VMtoTotal
  from VW_ADM_FACTURAS F 
       left join SACLIE C 
              on F.CodClie = C.CodClie
  where (F.FechaE >= CONVERT(DATETIME,'2026-03-13',120) and F.FechaE<= CONVERT(DATETIME,'2026-03-13',120)+ ' 23:59:59' ) 
    and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'')
	  and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
  order by convert(datetime,convert(varchar(8),F.FechaE,112)),
          (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) desc
GO

-- Session: 59 | Start: 2026-03-13 16:17:38.077000 | Status: runnable | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 69 | Start: 2026-03-13 16:17:39.583000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(16),@P2 nvarchar(16),@P3 nvarchar(16),@P4 nvarchar(16))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 58 | Start: 2026-03-13 16:18:10.283000 | Status: running | Cmd: SELECT
Set dateformat YMD
Declare @CodSucu as varchar(10) = '00000'
Declare @TipoFac as Varchar(1)  = 'A'
Declare @NumeroD as VArchar(20) = '*41197'  
;WITH ItTax AS 
(
select 
	 itf.CodSucu
	,itf.TipoFac
	,itf.NumeroD
	,itf.CodItem
	,itf.NroLinea
	,itf.MtoTax
	,itf.TGravable
	,itf.Monto
	,TAX.CodTaxs
	,Tax.TipoIVA
from dbo.SATAXITF itf with (nolock)
inner JOIN (select CodTaxs,TipoIVA from dbo.SATAXES with (nolock)  where TipoIVA in (1,2,3)) TAX ON
	itf.CodTaxs = TAX.CodTaxs
WHERE
        itf.CodSucu = @CodSucu
	    AND itf.TipoFac = @TipoFac
        AND itf.NumeroD = @NumeroD
)
		 SELECT 
            F.TipoFac
		    ,F.Numerod 
		    ,ITF.CodItem 
		    ,isnull(ITF.Descrip1,'') Descrip1
		    ,isnull(ITF.Descrip2,'') Descrip2
		    ,isnull(ITF.Descrip3,'') Descrip3
		    ,isnull(ITF.Descrip4,'') Descrip4
		    ,isnull(ITF.Descrip5,'') Descrip5
		    ,isnull(ITF.Descrip6,'') Descrip6
		    ,isnull(ITF.Descrip7,'') Descrip7
		    ,isnull(ITF.Descrip8,'') Descrip8
		    ,isnull(ITF.Descrip9,'') Descrip9
            ,isnull(ITF.Descrip10,'') Descrip10
		    ,isnull(ITF.Refere,'') Refere
		    ,isnull(ITF.NroLote,'') NroLote
		    ,isnull(EX.PuestoI,'') PuestoI
            ,isnull(EX.Existen,0) Existen
		    ,ITF.Cantidad 
		    ,ITF.Precio 
		    ,(case when ITF.PriceO > 0 then (ITF.Descto*100)/ITF.PriceO else 0 end) DescuentoPorc
            ,ITF.Descto Descuento 
		    ,ITF.PriceO 
		    ,ITF.TotalItem 
            ,(case when F.MtoTax = 0 then '' else isnull(ItTax.CodTaxs,'') end) CodTaxs 
		    ,(case when F.MtoTax = 0 then 0 else isnull(ItTax.MtoTax,0) end) MtoTax 
		    ,(case when F.MtoTax = 0 then 0 else CAST(ROUND (isnull(ItTax.TGravable,0),2,1) as DECIMAL(18,4)) end) TGravable
		    ,(case when F.MtoTax = 0 then 0 else CAST(ROUND (isnull(ItTax.Monto,0),2,1) as DECIMAL(18,2)) end)  MontoImp
            ,isnull(ITF.FechaV,'19891029')  FechaV
		    ,(case when F.MtoTax = 0 then 0 else isnull(ItTax.TipoIVA,0) end)   TipoIVA
		    ,ITF.EsServ 
		    ,ITF.EsExento 
            ,ITF.DEsSeri
            ,ITF.NroLinea 
            ,isnull(ITF.CodMeca,'') MecaCod
            ,isnull(Meca.Descrip,'') MecaDescrip
            ,isnull((case ITF.EsUnid when 0 then isnull(P.Unidad,'')+isnull(S.Unidad,'') when 1 then P.UndEmpaq else '' end),'') Unidad
		FROM dbo.SAFACT F with (nolock)
		INNER JOIN  dbo.SAITEMFAC ITF with (nolock) ON  
			F.CodSucu = ITF.CodSucu 
    		AND F.TipoFac = ITF.TipoFac 
    		AND F.NumeroD = ITF.NumeroD
		LEFT join ItTax with (nolock) on
		    ITF.CodSucu = ItTax.CodSucu 
		    AND ITF.TipoFac = ItTax.TipoFac 
		    AND ITF.NumeroD = ItTax.NumeroD 
		    AND ITF.CodItem = ItTax.CodItem 
		    AND ITF.NroLinea = ItTax.NroLinea
		LEFT JOIN SAEXIS EX  with (nolock) ON
			ITF.CodUbic = EX.CodUbic 
    		AND ITF.CodItem = EX.CodProd 
		LEFT JOIN SAMECA Meca with (nolock) ON
            ITF.CodMeca = Meca.CodMeca
        LEFT join SAPROD P with (nolock) ON
            ITF.CodItem = P.CodProd
        LEFT join SASERV S with (nolock) ON
            ITF.CodItem = S.CodServ
		WHERE   
                F.CodSucu = @CodSucu
	    		AND F.TipoFac = @TipoFac
                AND F.NumeroD = @NumeroD
				AND ITF.NroLineaC = 0
GO

-- Session: 61 | Start: 2026-03-13 16:19:38.177000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='EVIGAX' OR P.CodProd='EVIGAX')
GO

-- Session: 64 | Start: 2026-03-13 16:19:44.170000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'KA%') OR (Descrip LIKE 'KA%') OR (ID3 LIKE 'KA%') OR (Clase LIKE 'KA%') OR (Saldo LIKE 'KA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 16:19:52.743000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY DescripAll ASC) AS ROWNUM   FROM VW_ADM_SERVICIOS WITH (NOLOCK) 
  WHERE ((CodServ LIKE 'DEXAM%') OR (DescripAll LIKE 'DEXAM%') OR (Clase LIKE 'DEXAM%')) AND (ACTIVO=1) AND (EsVenta=1))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 15
GO

-- Session: 64 | Start: 2026-03-13 16:20:01.240000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 INNER JOIN SAEXIS EX ON (EX.CodSucu='00000') And (EX.CodProd=SP.CodProd) And (EX.CodUbic='AMR001')
  WHERE ((SP.CodProd LIKE 'MELOXI%') OR (SP.DescripAll LIKE 'MELOXI%') OR (SP.Refere LIKE 'MELOXI%') OR (SP.Existen LIKE 'MELOXI%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 64 | Start: 2026-03-13 16:20:09.323000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='AMP_MELOXI') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 60 | Start: 2026-03-13 16:27:32.343000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(4),@P2 nvarchar(4),@P3 nvarchar(4),@P4 nvarchar(4))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 60 | Start: 2026-03-13 16:28:06.540000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(16),@P2 nvarchar(16),@P3 nvarchar(16),@P4 nvarchar(16))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 61 | Start: 2026-03-13 16:32:48.627000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='RANIIDI' OR P.CodProd='RANIIDI')
GO

-- Session: 61 | Start: 2026-03-13 16:37:50.450000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '7597758000626%') OR (SP.DESCRIPALL LIKE '7597758000626%') OR (SP.REFERE LIKE '7597758000626%') OR (SP.EXISTEN LIKE '7597758000626%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 70 | Start: 2026-03-13 16:38:38.720000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'FLOR%') OR (Descrip LIKE 'FLOR%') OR (ID3 LIKE 'FLOR%') OR (Clase LIKE 'FLOR%') OR (Saldo LIKE 'FLOR%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 61 | Start: 2026-03-13 16:38:58.480000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'CAROLINA%') OR (Descrip LIKE 'CAROLINA%') OR (ID3 LIKE 'CAROLINA%') OR (Clase LIKE 'CAROLINA%') OR (Saldo LIKE 'CAROLINA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 16:45:31 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MARIA%') OR (Descrip LIKE 'MARIA%') OR (ID3 LIKE 'MARIA%') OR (Clase LIKE 'MARIA%') OR (Saldo LIKE 'MARIA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 16:45:57.027000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7898563802468' OR P.CodProd='7898563802468')
GO

-- Session: 69 | Start: 2026-03-13 16:46:00.217000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 54 | Start: 2026-03-13 16:48:05.923000 | Status: running | Cmd: SELECT
(@P1 nvarchar(6),@P2 nvarchar(6),@P3 nvarchar(6),@P4 nvarchar(6))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 54 | Start: 2026-03-13 16:50:33.707000 | Status: runnable | Cmd: UPDATE
(@P1 nvarchar(20),@P2 nvarchar(20),@P3 nvarchar(20),@P4 float,@P5 float,@P6 nvarchar(16))UPDATE EnterpriseAdmin_AMC.dbo.SACOMP SET FechaE = @P1, FechaI = @P2, FechaV = @P3, Credito = @P4, MtoTotal = @P5 WHERE NumeroD = @P6
GO

-- Session: 54 | Start: 2026-03-13 16:53:13.800000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(4),@P2 nvarchar(4),@P3 nvarchar(4),@P4 nvarchar(4))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 54 | Start: 2026-03-13 16:53:20.877000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(14),@P2 nvarchar(14),@P3 nvarchar(14),@P4 nvarchar(14))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 53 | Start: 2026-03-13 16:58:02.493000 | Status: runnable | Cmd: SELECT
USE EnterpriseAdmin_AMC;
SELECT
  result_objects.object_id
, result_objects.table_name 
, s.name AS schema_name
, result_objects.create_date
, result_objects.modify_date
, 0 AS is_system_table
, t.is_memory_optimized
, t.temporal_type
, history_tables.history_schema history_table_schema
, history_tables.history_name history_table_name
FROM (
  SELECT 
    o.object_id
  , table_name = o.name 
  , o.[schema_id]
  , o.create_date
  , o.modify_date
  FROM
    sys.objects o WITH(NOLOCK)
  WHERE
    ('' = '' OR o.object_id IN (''))
    AND ('' = '' OR o.name IN (''))
    AND o.type = 'U'
    AND o.is_ms_shipped = 0
) result_objects
JOIN sys.schemas s WITH(NOLOCK) ON result_objects.[schema_id] = s.[schema_id]
JOIN sys.tables t WITH(NOLOCK) ON result_objects.[object_id] = t.[object_id]
LEFT JOIN
  (SELECT
    ht.object_id
  , ht.name history_name
  , sc.name history_schema
  FROM
    sys.tables ht WITH(NOLOCK), sys.schemas sc WITH(NOLOCK)
  WHERE
    ht.type = 'U'
    AND ht.is_ms_shipped = 0
    AND ht.[schema_id] = sc.[schema_id]
  ) history_tables ON t.[history_table_id] = history_tables.object_id
WHERE
  is_external = 0 AND
  ('' = '' OR s.name IN (''))
ORDER BY 
  s.name
, result_objects.table_name
GO

-- Session: 53 | Start: 2026-03-13 16:58:19.093000 | Status: running | Cmd: SELECT
SELECT
    s.object_id
  , s.name
  , s.schema_id
  , s.base_object_name
  , OBJECTPROPERTYEX(s.object_id, N'BaseType') AS base_object_type
  , ep.value AS description
FROM sys.synonyms AS s WITH (NOLOCK)
LEFT JOIN (
    SELECT value, major_id, minor_id 
    FROM sys.extended_properties WITH(NOLOCK) 
    WHERE class = 1 AND name = 'MS_Description'
) ep ON s.[object_id] = ep.major_id AND ep.minor_id = 0
;
GO

-- Session: 59 | Start: 2026-03-13 16:58:19 | Status: runnable | Cmd: SELECT
SELECT * FROM EnterpriseAdmin_AMC.dbo.dolartoday
GO

-- Session: 59 | Start: 2026-03-13 16:58:34.150000 | Status: runnable | Cmd: SELECT
SELECT * FROM (SELECT * FROM EnterpriseAdmin_AMC.dbo.dolartoday
) subquery ORDER BY fecha
GO

-- Session: 59 | Start: 2026-03-13 16:58:46.413000 | Status: suspended | Cmd: SELECT
FETCH API_CURSOR0000000000000063 
GO

-- Session: 59 | Start: 2026-03-13 16:58:49.753000 | Status: runnable | Cmd: SELECT
FETCH API_CURSOR0000000000000064 
GO

-- Session: 61 | Start: 2026-03-13 17:01:24.513000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7730969306907' OR P.CodProd='7730969306907')
GO

-- Session: 61 | Start: 2026-03-13 17:04:53.883000 | Status: running | Cmd: SELECT
SELECT SAFACT.NumeroD NumeroD_2, 
       SAFACT.TipoFac TipoFac_2, 
       SAITEMFAC.Cantidad, SAITEMFAC.CantidadU, 
       SAITEMFAC.CantMayor, SAITEMFAC.CodItem, 
       SAITEMFAC.CodMeca, SAITEMFAC.CodSucu, 
       SAITEMFAC.CodUbic, SAITEMFAC.CodUsua, 
       SAITEMFAC.CodVend, SAITEMFAC.Costo, 
       SAITEMFAC.Descrip1, SAITEMFAC.Descrip10, 
       SAITEMFAC.Descrip2, SAITEMFAC.Descrip3, 
       SAITEMFAC.Descrip4, SAITEMFAC.Descrip5, 
       SAITEMFAC.Descrip6, SAITEMFAC.Descrip7, 
       SAITEMFAC.Descrip8, SAITEMFAC.Descrip9, 
       SAITEMFAC.Descto, SAITEMFAC.DEsLote, 
       SAITEMFAC.DEsSeri, SAITEMFAC.EsExento, 
       SAITEMFAC.EsPesa, SAITEMFAC.EsServ, 
       SAITEMFAC.EsUnid, SAITEMFAC.ExistAnt, 
       SAITEMFAC.ExistAntU, SAITEMFAC.FechaE, 
       SAITEMFAC.Factor, SAITEMFAC.FechaL, 
       SAITEMFAC.FechaV, SAITEMFAC.MtoTax, 
       SAITEMFAC.NroLinea, SAITEMFAC.NroLineaC, 
       SAITEMFAC.MtoTaxO, SAITEMFAC.NroLote, 
       SAITEMFAC.NroUnicoL, SAITEMFAC.NumeroD, 
       SAITEMFAC.NumeroE, SAITEMFAC.Precio, 
       SAITEMFAC.PriceO, SAITEMFAC.Refere, 
       SAITEMFAC.Signo, SAITEMFAC.PrecioI, 
       SAITEMFAC.Tara, SAITEMFAC.TipoFac, 
       SAITEMFAC.TotalItem, SAITEMFAC.UsaServ, 
       SAITEMFAC.TipoData, SAITEMFAC.TipoPVP
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
      INNER JOIN SAITEMFAC SAITEMFAC ON 
     (SAITEMFAC.NumeroD = SAFACT.NumeroD)
      AND (SAITEMFAC.TipoFac = SAFACT.TipoFac)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44403' )
ORDER BY SAITEMFAC.NumeroD, SAITEMFAC.TipoFac
GO

-- Session: 58 | Start: 2026-03-13 17:05:03.457000 | Status: suspended | Cmd: UPDATE
(@P1 binary(8000))UPDATE SACONF SET Adicional=@P1 , DESCRIP='Farmacia Americana C.A.', NROSERIAL='ADME393713724599196', KEYSERIAL='1966618' WHERE CODSUCU='00000'
GO

-- Session: 71 | Start: 2026-03-13 17:06:53.953000 | Status: suspended | Cmd: SELECT
FETCH API_CURSOR0000000000000060 
GO

-- Session: 61 | Start: 2026-03-13 17:08:40.480000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'NUE%') OR (Descrip LIKE 'NUE%') OR (ID3 LIKE 'NUE%') OR (Clase LIKE 'NUE%') OR (Saldo LIKE 'NUE%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 61 | Start: 2026-03-13 17:08:47.357000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'NI%') OR (Descrip LIKE 'NI%') OR (ID3 LIKE 'NI%') OR (Clase LIKE 'NI%') OR (Saldo LIKE 'NI%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 74 | Start: 2026-03-13 17:15:00.880000 | Status: runnable | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 74 | Start: 2026-03-13 17:16:00.360000 | Status: suspended | Cmd: UPDATE
UPDATE SAPROD
SET Refere=b.precio$
from SAPROD as a
inner join CUSTOM_COSTO_COMPRAS as b on (a.CodProd=b.codprod)
GO

-- Session: 54 | Start: 2026-03-13 17:18:27.710000 | Status: runnable | Cmd: SELECT
SELECT
      db_id() AS database_id,
      c.system_type_id,
      c.user_type_id,
      c.is_sparse,
      c.is_column_set,
      c.is_filestream,
      c.encryption_type,
      CASE WHEN o.object_id IS NOT NULL THEN 1 ELSE 0 END AS is_user,
      COUNT_BIG(*) AS [ColCount],
      CASE WHEN c.collation_name IS NULL THEN CONVERT(VARCHAR(128), SERVERPROPERTY('Collation')) ELSE c.collation_name END AS collation_name,
      AVG(c.max_length) AS avg_max_length
      FROM sys.columns c WITH (NOLOCK)
      LEFT OUTER JOIN sys.objects o WITH (NOLOCK)
      ON o.object_id = c.object_id
      AND o.type = 'U'
      GROUP BY
      c.system_type_id,
      c.user_type_id,
      c.is_sparse,
      c.is_column_set,
      c.encryption_type,
      c.is_filestream,
      CASE WHEN o.object_id IS NOT NULL THEN 1 ELSE 0 END,
      CASE WHEN c.collation_name IS NULL THEN CONVERT(VARCHAR(128), SERVERPROPERTY('Collation')) ELSE c.collation_name END
GO

-- Session: 54 | Start: 2026-03-13 17:18:31.860000 | Status: runnable | Cmd: SELECT
select count_big(*) AS [XTPAlwaysOnAG],
      isnull(sum(ar.availability_mode),0) AS [XTPAlwaysOnAGSync], db_id() AS database_id
      from sys.databases d WITH (NOLOCK)
      join sys.availability_databases_cluster adb WITH (NOLOCK)
      on d.group_database_id=adb.group_database_id
      join sys.availability_replicas ar  WITH (NOLOCK)
      on d.replica_id=ar.replica_id
      where database_id=db_id() and exists (select * from sys.data_spaces  WITH (NOLOCK) where type='FX')
GO

-- Session: 54 | Start: 2026-03-13 17:18:32.383000 | Status: runnable | Cmd: SELECT
SELECT db_id() AS database_id, o.[type] as ModuleType, COUNT_BIG(*) as ModuleCount
      FROM sys.objects AS o WITH(nolock)
      WHERE o.type in ('AF', 'F', 'FN', 'FS', 'FT', 'IF', 'P', 'PC', 'TA', 'TF', 'TR', 'X', 'C', 'D', 'PG', 'SN', 'SO', 'SQ', 'TT', 'UQ', 'V')
      GROUP BY o.[type]
GO

-- Session: 54 | Start: 2026-03-13 17:18:32.907000 | Status: runnable | Cmd: SELECT
SELECT db_id() AS database_id,
      COUNT_BIG(*) AS [NumExternalStats]
      FROM sys.tables t WITH(nolock) INNER JOIN sys.stats s WITH(nolock) ON t.object_id = s.object_id
      WHERE t.is_external=1
GO

-- Session: 54 | Start: 2026-03-13 17:18:33.920000 | Status: runnable | Cmd: SELECT
SELECT
      db_id() as database_id,
      sm.[is_inlineable] AS InlineableScalarCount,
      sm.[inline_type] AS InlineType,
      COUNT_BIG(*) AS ScalarCount, 
      COUNT_BIG(CASE WHEN sm.[definition] LIKE '%getdate%' OR 
      sm.[definition] LIKE '%getutcdate%' OR 
      sm.[definition] LIKE '%sysdatetime%' OR
      sm.[definition] LIKE '%sysutcdatetime%' OR
      sm.[definition] LIKE '%sysdatetimeoffset%' OR
      sm.[definition] LIKE '%CURRENT_TIMESTAMP%'
      THEN 1 
      END) AS ScalarCountWithDate          
      FROM    [sys].[objects] o
      INNER JOIN    [sys].[sql_modules] sm 
      ON o.[object_id] = sm.[object_id]
      WHERE   o.[type] = 'FN'
      GROUP BY 
      sm.[is_inlineable],
      sm.[inline_type]
GO

-- Session: 61 | Start: 2026-03-13 17:21:22.773000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT * FROM VW_ADM_TAXINVENT WITH (NOLOCK)  WHERE (CodProd='7593255000145') AND ESTAXVENTA=1
GO

-- Session: 66 | Start: 2026-03-13 17:21:37.367000 | Status: runnable | Cmd: SELECT
-- Query for 'Lotes' worksheet: filters lots based on entry date, rotation and quantity.
SELECT
    SALOTE.CodProd AS Cod,
    SALOTE.NroLote,
    SALOTE.Cantidad,

    -- Si la FechaE es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaE) <= 1900 THEN NULL
        ELSE SALOTE.FechaE
    END AS FechaE,

    -- Si la FechaV es 1900 o anterior, la muestra como NULL (vacía)
    CASE
        WHEN DATEPART(year, SALOTE.FechaV) <= 1900 THEN NULL
        ELSE SALOTE.FechaV
    END AS FechaV,

    Rotacion.RotacionMensual,
    SAPROD.Descrip
FROM dbo.SALOTE
LEFT OUTER JOIN Procurement.Rotacion
    ON SALOTE.CodProd = Rotacion.CodItem
INNER JOIN dbo.SAPROD
    ON SALOTE.CodProd = SAPROD.CodProd
WHERE
-- Se mantiene la lógica de FILTRADO DE FILAS original
(
    (
        SALOTE.FechaE > GETDATE() - 120
        AND Rotacion.RotacionMensual < 0.3
        AND SALOTE.Cantidad > 0
    )
    OR (
        SALOTE.FechaE > GETDATE() - 720
        AND Rotacion.RotacionMensual IS NULL
        AND SALOTE.Cantidad > 0
    )
);
GO

-- Session: 70 | Start: 2026-03-13 17:22:03.397000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ROBERTO%') OR (Descrip LIKE 'ROBERTO%') OR (ID3 LIKE 'ROBERTO%') OR (Clase LIKE 'ROBERTO%') OR (Saldo LIKE 'ROBERTO%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 70 | Start: 2026-03-13 17:22:16.543000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='AMP_DICLOF_POTA' OR P.CodProd='AMP_DICLOF_POTA')
GO

-- Session: 62 | Start: 2026-03-13 17:22:37.070000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MARCOS%') OR (Descrip LIKE 'MARCOS%') OR (ID3 LIKE 'MARCOS%') OR (Clase LIKE 'MARCOS%') OR (Saldo LIKE 'MARCOS%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 62 | Start: 2026-03-13 17:22:41.200000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'FURO%') OR (SP.DescripAll LIKE 'FURO%') OR (SP.Refere LIKE 'FURO%') OR (SP.Existen LIKE 'FURO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 58 | Start: 2026-03-13 17:24:07.140000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7592467001056') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 17:24:50.847000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='8906005119292' OR P.CodProd='8906005119292')
GO

-- Session: 70 | Start: 2026-03-13 17:25:25.057000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'DAVID%') OR (Descrip LIKE 'DAVID%') OR (ID3 LIKE 'DAVID%') OR (Clase LIKE 'DAVID%') OR (Saldo LIKE 'DAVID%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 70 | Start: 2026-03-13 17:25:31.087000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7590027002901' OR P.CodProd='7590027002901')
GO

-- Session: 73 | Start: 2026-03-13 17:25:32.427000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 58 | Start: 2026-03-13 17:26:03.753000 | Status: runnable | Cmd: SELECT
SELECT SAFACT.NumeroD NumeroD_2, 
       SAFACT.TipoFac TipoFac_2, 
       SAITEMFAC.Cantidad, SAITEMFAC.CantidadU, 
       SAITEMFAC.CantMayor, SAITEMFAC.CodItem, 
       SAITEMFAC.CodMeca, SAITEMFAC.CodSucu, 
       SAITEMFAC.CodUbic, SAITEMFAC.CodUsua, 
       SAITEMFAC.CodVend, SAITEMFAC.Costo, 
       SAITEMFAC.Descrip1, SAITEMFAC.Descrip10, 
       SAITEMFAC.Descrip2, SAITEMFAC.Descrip3, 
       SAITEMFAC.Descrip4, SAITEMFAC.Descrip5, 
       SAITEMFAC.Descrip6, SAITEMFAC.Descrip7, 
       SAITEMFAC.Descrip8, SAITEMFAC.Descrip9, 
       SAITEMFAC.Descto, SAITEMFAC.DEsLote, 
       SAITEMFAC.DEsSeri, SAITEMFAC.EsExento, 
       SAITEMFAC.EsPesa, SAITEMFAC.EsServ, 
       SAITEMFAC.EsUnid, SAITEMFAC.ExistAnt, 
       SAITEMFAC.ExistAntU, SAITEMFAC.FechaE, 
       SAITEMFAC.Factor, SAITEMFAC.FechaL, 
       SAITEMFAC.FechaV, SAITEMFAC.MtoTax, 
       SAITEMFAC.NroLinea, SAITEMFAC.NroLineaC, 
       SAITEMFAC.MtoTaxO, SAITEMFAC.NroLote, 
       SAITEMFAC.NroUnicoL, SAITEMFAC.NumeroD, 
       SAITEMFAC.NumeroE, SAITEMFAC.Precio, 
       SAITEMFAC.PriceO, SAITEMFAC.Refere, 
       SAITEMFAC.Signo, SAITEMFAC.PrecioI, 
       SAITEMFAC.Tara, SAITEMFAC.TipoFac, 
       SAITEMFAC.TotalItem, SAITEMFAC.UsaServ, 
       SAITEMFAC.TipoData, SAITEMFAC.TipoPVP
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
      INNER JOIN SAITEMFAC SAITEMFAC ON 
     (SAITEMFAC.NumeroD = SAFACT.NumeroD)
      AND (SAITEMFAC.TipoFac = SAFACT.TipoFac)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44408' )
ORDER BY SAITEMFAC.NumeroD, SAITEMFAC.TipoFac
GO

-- Session: 58 | Start: 2026-03-13 17:26:09.917000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'MA%') OR (Descrip LIKE 'MA%') OR (ID3 LIKE 'MA%') OR (Clase LIKE 'MA%') OR (Saldo LIKE 'MA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 13
GO

-- Session: 70 | Start: 2026-03-13 17:26:14.827000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'PREGAB%') OR (SP.DescripAll LIKE 'PREGAB%') OR (SP.Refere LIKE 'PREGAB%') OR (SP.Existen LIKE 'PREGAB%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 54 | Start: 2026-03-13 17:27:13.117000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(16),@P2 nvarchar(16),@P3 nvarchar(16),@P4 nvarchar(16))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 70 | Start: 2026-03-13 17:29:15.673000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='PRUEB' OR P.CodProd='PRUEB')
GO

-- Session: 64 | Start: 2026-03-13 17:30:00.553000 | Status: suspended | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO

-- Session: 69 | Start: 2026-03-13 17:30:00.557000 | Status: suspended | Cmd: BACKUP DATABASE
BACKUP DATABASE EnterpriseAdmin_AMC TO DISK = '\\10.200.8.5\sql\EnterpriseAdmin_AMCbackup2026-03-13.bak' WITH COMPRESSION;
GO

-- Session: 73 | Start: 2026-03-13 17:30:00.560000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[UpdatePricesDay]
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Inicio del procedimiento UpdatePrices (versión simplificada)';

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Ya no se necesita obtener valores de [%descuento]

        PRINT 'Aplicando precios y costo desde Custom_Lotes a SALOTE y SAPROD';

        -- Actualizar SALOTE directamente con los precios de Custom_Lotes
        UPDATE SALOTE
        SET PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SALOTE
        INNER JOIN Custom_Lotes ON SALOTE.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SALOTE completada con valores de Custom_Lotes';

        -- Actualizar SAPROD directamente con los precios y CostPror de Custom_Lotes
        UPDATE SAPROD
        SET Refere = ISNULL(Custom_Lotes.CostPror, 0), -- Actualiza el costo de referencia
            PRECIO1 = ISNULL(Custom_Lotes.precio1, 0),
            PRECIO2 = ISNULL(Custom_Lotes.precio2, 0),
            PRECIO3 = ISNULL(Custom_Lotes.precio3, 0),
            PrecioI1 = ISNULL(Custom_Lotes.PrecioI1, 0),
            PrecioI2 = ISNULL(Custom_Lotes.PrecioI2, 0),
            PrecioI3 = ISNULL(Custom_Lotes.PrecioI3, 0)
        FROM SAPROD
        INNER JOIN Custom_Lotes ON SAPROD.CodProd = Custom_Lotes.CodProd;

        PRINT 'Actualización de SAPROD completada con valores de Custom_Lotes';

        COMMIT TRANSACTION;
        PRINT 'Transacción confirmada exitosamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado: ' + ERROR_MESSAGE();
        -- Relanzar el error para que el llamador sepa que algo falló
        THROW;
    END CATCH;
END;
GO

-- Session: 64 | Start: 2026-03-13 17:30:25.413000 | Status: suspended | Cmd: COMMIT TRANSACTION
CREATE PROCEDURE sp_jobhistory_row_limiter
  @job_id UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @max_total_rows         INT -- This value comes from the registry (MaxJobHistoryTableRows)
  DECLARE @max_rows_per_job       INT -- This value comes from the registry (MaxJobHistoryRows)
  DECLARE @rows_to_delete         INT
  DECLARE @current_rows           INT
  DECLARE @current_rows_per_job   INT

  SET NOCOUNT ON

  -- Get max-job-history-rows from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @max_total_rows OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysjobhistory rows
  IF (ISNULL(@max_total_rows, -1) = -1)
    RETURN(0)

  -- Check that max_total_rows is more than 1
  IF (ISNULL(@max_total_rows, 0) < 2)
  BEGIN
    -- It isn't, so set the default to 1000 rows
    SELECT @max_total_rows = 1000
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @max_total_rows
  END

  -- Get the per-job maximum number of rows to keep
  SELECT @max_rows_per_job = 0
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @max_rows_per_job OUTPUT,
                                         N'no_output'

  -- Check that max_rows_per_job is <= max_total_rows
  IF ((@max_rows_per_job > @max_total_rows) OR (@max_rows_per_job < 1))
  BEGIN
    -- It isn't, so default the rows_per_job to max_total_rows
    SELECT @max_rows_per_job = @max_total_rows
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @max_rows_per_job
  END

  BEGIN TRANSACTION

  SELECT @current_rows_per_job = COUNT(*)
  FROM msdb.dbo.sysjobhistory with (TABLOCKX)
  WHERE (job_id = @job_id)

  -- Delete the oldest history row(s) for the job being inserted if the new row has
  -- pushed us over the per-job row limit (MaxJobHistoryRows)
  SELECT @rows_to_delete = @current_rows_per_job - @max_rows_per_job

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      WHERE (job_id = @job_id)
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  -- Delete the oldest history row(s) if inserting the new row has pushed us over the
  -- global MaxJobHistoryTableRows limit.
  SELECT @current_rows = COUNT(*)
  FROM msdb.dbo.sysjobhistory

  SELECT @rows_to_delete = @current_rows - @max_total_rows

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  IF (@@trancount > 0)
    COMMIT TRANSACTION

  RETURN(0) -- Success
END
GO

-- Session: 73 | Start: 2026-03-13 17:30:31.717000 | Status: running | Cmd: SELECT
SELECT * FROM Custom_Inventario_i360;
GO

-- Session: 60 | Start: 2026-03-13 17:31:23.960000 | Status: running | Cmd: SELECT
(@P1 nvarchar(14),@P2 nvarchar(14),@P3 nvarchar(14),@P4 nvarchar(14))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 51 | Start: 2026-03-13 17:33:26.007000 | Status: runnable | Cmd: SELECT
(@P1 nvarchar(12),@P2 nvarchar(12),@P3 nvarchar(12),@P4 nvarchar(12))
            SELECT
              SACOMP.FechaI,
              SACOMP.FechaE,
              SACOMP.FechaV,
              SAPROV.Descrip,
              SAACXP.RetenIVA,
              SAACXP.SaldoAct,
              SAACXP.Monto,
              SAACXP.CodOper,
              SAACXP.MontoNeto,
              SAACXP.Saldo,
              SAACXP.MtoTax,
              SACOMP.MtoPagos,
              SACOMP.SaldoAct AS SaldoAct_SACOMP,
              SACOMP.MtoNCredito,
              SACOMP.MtoNDebito,
              SACOMP.Signo,
              SACOMP.NumeroD AS NumeroD_SACOMP,
              SAACXP.NroCtrol,
              SACOMP.MtoTotal,
              SACOMP.Contado,
              SACOMP.Credito,
              SAACXP.NroUnico,
              SAACXP.CodSucu,
              SAACXP.CodProv,
              SAACXP.NumeroD,
              SACOMP.CodSucu AS CodSucu_SACOMP,
              SACOMP.TipoCom,
              SACOMP.Notas10,
              SAPAGCXP.NumeroD AS NumeroD_SAPAGCXP,
              dt_emision.dolarbcv AS TasaEmision,
              dt_actual.dolarbcv AS TasaActual,
              PP.ID AS Plan_ID,
              PP.Banco AS Plan_Banco,
              PP.FechaPlanificada AS Plan_Fecha,
              CAST(CASE WHEN SAACXP.RetenIVA > 0 THEN 1 ELSE 0 END AS BIT) AS Has_Retencion,
              CAST(CASE WHEN abonos.TotalBs IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS Has_Abonos,
              ISNULL(abonos.TotalBs, 0) AS TotalBsAbonado
            FROM dbo.SAACXP
            OUTER APPLY (
                SELECT SUM(MontoBsAbonado) AS TotalBs
                FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos A 
                WHERE A.CodProv = SAACXP.CodProv AND A.NumeroD = SAACXP.NumeroD
            ) abonos
            OUTER APPLY (
                SELECT TOP 1 NumeroD
                FROM dbo.SAPAGCXP
                WHERE SAPAGCXP.NroUnico = SAACXP.NroUnico
            ) SAPAGCXP
            LEFT OUTER JOIN dbo.SAPROV ON SAACXP.CodProv = SAPROV.CodProv
            LEFT OUTER JOIN dbo.SAIPACXP ON SAACXP.NroUnico = SAIPACXP.NroUnico
            LEFT OUTER JOIN dbo.SACOMP ON SAACXP.NumeroD = SACOMP.NumeroD AND SAACXP.CodProv = SACOMP.CodProv
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE CAST(fecha AS DATE) <= CAST(SAACXP.FechaE AS DATE)
                ORDER BY fecha DESC
            ) dt_emision
            OUTER APPLY (
                SELECT TOP 1 dolarbcv 
                FROM EnterpriseAdmin_AMC.dbo.dolartoday 
                WHERE dolarbcv IS NOT NULL
                ORDER BY id DESC
            ) dt_actual
            LEFT OUTER JOIN EnterpriseAdmin_AMC.Procurement.PagosPlanificados PP
                ON SAACXP.NroUnico = PP.NroUnico
            WHERE SAACXP.TipoCxP = '10' 
               AND (SAACXP.NumeroD LIKE @P1
               OR SACOMP.NumeroD LIKE @P2
               OR SAPAGCXP.NumeroD LIKE @P3
               OR SAPROV.Descrip LIKE @P4)
                AND SAACXP.FechaE >= DATEADD(month, -4, GETDATE())
            ORDER BY SAACXP.FechaE DESC
GO

-- Session: 58 | Start: 2026-03-13 17:38:32.297000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'CILOS%') OR (SP.DESCRIPALL LIKE 'CILOS%') OR (SP.REFERE LIKE 'CILOS%') OR (SP.EXISTEN LIKE 'CILOS%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 36
GO

-- Session: 61 | Start: 2026-03-13 17:42:01.130000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 74 | Start: 2026-03-13 17:45:32.573000 | Status: runnable | Cmd: SELECT
-- This script extracts inventory, costs, rotation, and expiration classification,
-- ensuring that the next expiration date (ProximaFechaV) is only taken from lots with active stock (Cantidad > 0).

-- CTE 1: ProductData - Gets base product data and the next expiration date (FEFO)
WITH ProductData AS (
    SELECT
        p.CodProd,
        p.Descrip,
        p.CodInst,
        p.Existen,
        p.FechaUV, -- Last Sale Date
        p.FechaUC, -- Last Purchase Date
        p.EsEnser, -- Flag indicating if it is an asset/tool
        i.Descrip AS InstanciaDescrip,
        i.InsPadre, -- Captured from SAINSTA (i)
        r.RotacionMensual,
        cl.CostPror$,
        
        -- CORRECTED subquery (FEFO): Gets the oldest expiration date (MIN)
        -- ONLY from lots that have Quantity > 0 (active available inventory).
        -- Excludes placeholder dates far in the future (> '2050-01-01')
        (SELECT MIN(l.FechaV)
         FROM dbo.SALOTE AS l
         WHERE l.CodProd = p.CodProd
           AND l.FechaV IS NOT NULL
           AND l.Cantidad > 0
           -- Filter to ignore arbitrarily far placeholder dates.
           AND l.FechaV < '2050-01-01') AS ProximaFechaV,
           
        -- Assigns a unique row number for each product, ordered by highest cost
        ROW_NUMBER() OVER(PARTITION BY p.CodProd ORDER BY cl.CostPror$ DESC) AS rn
    FROM
        dbo.SAPROD AS p
    INNER JOIN
        dbo.SAINSTA AS i ON p.CodInst = i.CodInst
    INNER JOIN
        dbo.CUSTOM_LOTES AS cl ON p.CodProd = cl.CodProd
    LEFT OUTER JOIN
        Procurement.Rotacion AS r ON p.CodProd = r.CodItem
    WHERE
        p.Activo = 1
        AND p.Existen >= 0
        -- Ensure the product has records in the lots table (SALOTE)
        AND EXISTS (
            SELECT 1
            FROM dbo.SALOTE AS l
            WHERE l.CodProd = p.CodProd AND l.Cantidad >= 0
        )
),
-- CTE 2: RankedData - Applies date cleaning logic and computes ExpirationRange
RankedData AS (
    SELECT
        pd.CodProd AS Cod,
        -- Cleans the code to create an alternate code (Cod_Alt)
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pd.CodProd, ' ', ''), '/', ''), '.', ''), '_', ''), '-', '') AS Cod_Alt,
        pd.Descrip AS Descripcion,
        pd.CodInst AS CodInsta,
        pd.Existen AS Existencia,
        pd.InstanciaDescrip AS Instancia,
        pd.InsPadre,
        
        -- Use cleaned dates defined in CROSS APPLY
        calc.FechaUV_Limpia AS FechaUV,
        calc.FechaUC_Limpia AS FechaUC,
        calc.ProximaFechaV_Limpia AS ProximaFechaV,
        
        pd.RotacionMensual,
        pd.CostPror$ AS Costo,
        CONVERT(VARCHAR, GETDATE(), 120) AS TiempoRefresData,
        
        -- Subquery to get the current Inventory Cycle ID
        (SELECT TOP 1 CicloID
         FROM EnterpriseAdmin_AMC.Procurement.InventarioCiclo
         WHERE GETDATE() >= InicioCiclo AND (FinCiclo IS NULL OR GETDATE() <= FinCiclo)
         ORDER BY InicioCiclo DESC) AS CicloID,
        
        pd.EsEnser,
        
        -- Classify the product based on the range of days to the next expiration date.
        -- LOGIC: Apply the range ONLY if (CodInst=2 OR InsPadre=2).
        CASE
            -- Inclusion criteria: If it meets the instance/parent condition (uses OR)
            WHEN pd.CodInst = 2 OR pd.InsPadre = 2 THEN 
                -- Apply day-range classification (nested CASE):
                CASE
                    WHEN calc.ProximaFechaV_Limpia IS NULL THEN NULL -- If there is no date, the range is NULL
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 30   THEN '0-30 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 60   THEN '31-60 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 90   THEN '61-90 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 120  THEN '91-120 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 150  THEN '121-150 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 180  THEN '151-180 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 210  THEN '181-210 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 240  THEN '211-240 días'
                    WHEN DATEDIFF(day, GETDATE(), calc.ProximaFechaV_Limpia) <= 270  THEN '241-270 días'
                    ELSE NULL -- Set to NULL to remove classification for >270 days
                END
            
            -- Exclusion criteria: If it does not meet the OR condition, classify as empty string.
            ELSE '' -- CHANGE REQUESTED
        END AS RangoVencimiento
    FROM
        ProductData AS pd
    -- Use CROSS APPLY to define cleaned dates (NULLIF + CAST) once
    CROSS APPLY (
        SELECT
            CAST(NULLIF(pd.FechaUV, '1899-12-30') AS DATE) AS FechaUV_Limpia,
            CAST(NULLIF(pd.FechaUC, '1899-12-30') AS DATE) AS FechaUC_Limpia,
            CAST(NULLIF(pd.ProximaFechaV, '1899-12-30') AS DATE) AS ProximaFechaV_Limpia
    ) AS calc
    WHERE
        pd.rn = 1 -- Filter to get only the row with the highest cost per product
)
-- Final selection including ALL rows
SELECT
    Cod,
    Cod_Alt,
    Descripcion,
    CodInsta,
    Existencia,
    Instancia,
    InsPadre,
    FechaUV,
    FechaUC,
    ProximaFechaV,
    RotacionMensual,
    Costo,
    TiempoRefresData,
    CicloID,
    EsEnser,
    RangoVencimiento
FROM
    RankedData
ORDER BY
    Descripcion ASC;
GO

-- Session: 74 | Start: 2026-03-13 17:45:38.730000 | Status: runnable | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 60 | Start: 2026-03-13 17:46:01.327000 | Status: runnable | Cmd: COMMIT TRANSACTION
CREATE PROCEDURE sp_jobhistory_row_limiter
  @job_id UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @max_total_rows         INT -- This value comes from the registry (MaxJobHistoryTableRows)
  DECLARE @max_rows_per_job       INT -- This value comes from the registry (MaxJobHistoryRows)
  DECLARE @rows_to_delete         INT
  DECLARE @current_rows           INT
  DECLARE @current_rows_per_job   INT

  SET NOCOUNT ON

  -- Get max-job-history-rows from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @max_total_rows OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysjobhistory rows
  IF (ISNULL(@max_total_rows, -1) = -1)
    RETURN(0)

  -- Check that max_total_rows is more than 1
  IF (ISNULL(@max_total_rows, 0) < 2)
  BEGIN
    -- It isn't, so set the default to 1000 rows
    SELECT @max_total_rows = 1000
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @max_total_rows
  END

  -- Get the per-job maximum number of rows to keep
  SELECT @max_rows_per_job = 0
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @max_rows_per_job OUTPUT,
                                         N'no_output'

  -- Check that max_rows_per_job is <= max_total_rows
  IF ((@max_rows_per_job > @max_total_rows) OR (@max_rows_per_job < 1))
  BEGIN
    -- It isn't, so default the rows_per_job to max_total_rows
    SELECT @max_rows_per_job = @max_total_rows
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @max_rows_per_job
  END

  BEGIN TRANSACTION

  SELECT @current_rows_per_job = COUNT(*)
  FROM msdb.dbo.sysjobhistory with (TABLOCKX)
  WHERE (job_id = @job_id)

  -- Delete the oldest history row(s) for the job being inserted if the new row has
  -- pushed us over the per-job row limit (MaxJobHistoryRows)
  SELECT @rows_to_delete = @current_rows_per_job - @max_rows_per_job

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      WHERE (job_id = @job_id)
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  -- Delete the oldest history row(s) if inserting the new row has pushed us over the
  -- global MaxJobHistoryTableRows limit.
  SELECT @current_rows = COUNT(*)
  FROM msdb.dbo.sysjobhistory

  SELECT @rows_to_delete = @current_rows - @max_total_rows

  IF (@rows_to_delete > 0)
  BEGIN
    WITH RowsToDelete AS (
      SELECT TOP (@rows_to_delete) *
      FROM msdb.dbo.sysjobhistory
      ORDER BY instance_id
    )
    DELETE FROM RowsToDelete;
  END

  IF (@@trancount > 0)
    COMMIT TRANSACTION

  RETURN(0) -- Success
END
GO

-- Session: 62 | Start: 2026-03-13 17:47:42.700000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 62 | Start: 2026-03-13 17:47:44.943000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JOSEFIN%') OR (Descrip LIKE 'JOSEFIN%') OR (ID3 LIKE 'JOSEFIN%') OR (Clase LIKE 'JOSEFIN%') OR (Saldo LIKE 'JOSEFIN%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 35
GO

-- Session: 62 | Start: 2026-03-13 17:47:57.840000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='BLI_TORSIL') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 69 | Start: 2026-03-13 17:50:12.630000 | Status: suspended | Cmd: UPDATE
(@1 int,@2 int,@3 varbinary(8000),@4 smallint)UPDATE [msdb].[dbo].[sysjobschedules] set [next_run_date] = @1,[next_run_time] = @2  WHERE [job_id]=@3 AND [schedule_id]=@4
GO

-- Session: 58 | Start: 2026-03-13 17:50:21.390000 | Status: suspended | Cmd: UPDATE
SET DATEFORMAT YMD;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE @ErrMsg nvarchar(4000);
DECLARE 
   @OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V11601398'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
  ,@NUMERRORS INT=0;
BEGIN TRANSACTION;
BEGIN TRY
EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 17:50:22.085','2026-03-13 17:50:22.241','2026-03-13 17:50:22.085',1,1,'V11601398','BK03','V12400678','12400678','AMR001','MABEL AYARI BURGOS DE RIVAS','LOS RUICES','V11601398',3321.64,3321.64,443.25,7.49,3321.64,3321.64,3321.64,3321.64);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT')
SET @NROUNICOLOT=1055611;
UPDATE SAPROD SET 
       FechaUV='2026-03-13 17:50:22.304'
 WHERE (CodProd='736372692283');
SELECT @EXISTANT=0, @EXISTANTUND=0;
SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='736372692283') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','736372692283','AMR001',-1.00,0,'2026-03-13';
SELECT  @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='736372692283') And (E.CodUbic='AMR001')
IF @EXISTPRD<0 SET @NUMERRORS=1000;
SET @NROUNICOLOT=1055611
UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[TipoPVP],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 17:50:22.335','736372692283','5.08695','AMR001','LIDOCAINA 5% GEL X30G H',1.00,1.00,1837.69,1.00,3321.637,3321.637,3,3321.637,'12400678','V12400678',1,1,'35',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-01-28 00:00:00.000','1899-12-29 00:00:00.000');
UPDATE SAFACT SET 
   CostoPrd=1837.69   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,3321.64,1.00,'2026-03-13 17:50:19.000');
UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  IF @NUMERRORS>0
  BEGIN
    ROLLBACK;
    SELECT @ErrMsg='ERROR ['+CAST(@NUMERRORS as varchar(10))+'] IN TRASACTION';
    SELECT @NUMERRORS error, @ErrMsg errmsg;
    RAISERROR(@ErrMsg,  @NUMERRORS,1);
  END;
  COMMIT TRANSACTION;
  SELECT @NUMERRORS error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  DECLARE @ErrSeverity int;
  SELECT @ErrMsg = '['+CAST(@NUMERRORS as varchar(10))+'] '+ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
  SELECT -1 error, @ErrMsg errmsg, @errseverity errseverity;
  RAISERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH;
GO

-- Session: 58 | Start: 2026-03-13 17:50:41.313000 | Status: running | Cmd: SELECT
SELECT SAFACT.AutSRI, SAFACT.Cambio, 
       SAFACT.CancelA, SAFACT.CancelC, 
       SAFACT.CancelE, SAFACT.CancelG, 
       SAFACT.CancelI, SAFACT.CancelP, 
       SAFACT.CancelT, SAFACT.CancelTips, 
       SAFACT.CodClie, SAFACT.CodAlte, 
       SAFACT.CodConv, SAFACT.CodEsta, 
       SAFACT.CodOper, SAFACT.CodSucu, 
       SAFACT.CodUbic, SAFACT.CodUsua, 
       SAFACT.CodTarj, SAFACT.CodVend, 
       SAFACT.CodTran, SAFACT.Contado, 
       SAFACT.CostoPrd, SAFACT.CostoSrv, 
       SAFACT.Credito, SAFACT.Descrip, 
       SAFACT.Descto1, SAFACT.Descto2, 
       SAFACT.DesctoP, SAFACT.DetalChq, 
       SAFACT.Direc1, SAFACT.Direc2, 
       SAFACT.Direc3, SAFACT.EsCorrel, 
       SAFACT.Factor, SAFACT.FechaE, 
       SAFACT.FechaI, SAFACT.FechaR, 
       SAFACT.FechaV, SAFACT.Fletes, SAFACT.ID3, 
       SAFACT.Monto, SAFACT.MontoMEx, 
       SAFACT.MtoComiCob, SAFACT.MtoComiCobD, 
       SAFACT.MtoComiVta, SAFACT.MtoComiVtaD, 
       SAFACT.MtoExtra, SAFACT.MtoFinanc, 
       SAFACT.MtoInt1, SAFACT.MtoInt2, 
       SAFACT.MtoNCredito, SAFACT.MtoNDebito, 
       SAFACT.MtoPagos, SAFACT.MtoTax, 
       SAFACT.MtoTotal, SAFACT.NGiros, 
       SAFACT.NMeses, SAFACT.Notas1, 
       SAFACT.Notas10, SAFACT.Notas2, 
       SAFACT.Notas3, SAFACT.Notas4, 
       SAFACT.Notas5, SAFACT.Notas6, 
       SAFACT.Notas7, SAFACT.Notas8, 
       SAFACT.Notas9, SAFACT.NroCtrol, 
       SAFACT.NroEstable, SAFACT.NroUnico, 
       SAFACT.NumeroD, SAFACT.NumeroE, 
       SAFACT.NumeroF, SAFACT.NroTurno, 
       SAFACT.NumeroNCF, SAFACT.OrdenC, 
       SAFACT.NumeroP, SAFACT.NroUnicoL, 
       SAFACT.NumeroR, SAFACT.NumeroT, 
       SAFACT.NumeroZ, SAFACT.RetenIVA, 
       SAFACT.PctAnual, SAFACT.PctManejo, 
       SAFACT.PtoEmision, SAFACT.NumeroU, 
       SAFACT.SaldoAct, SAFACT.Signo, 
       SAFACT.Telef, SAFACT.Parcial, 
       SAFACT.TExento, SAFACT.TGravable, 
       SAFACT.TipoFac, SAFACT.TipoTraE, 
       SAFACT.TotalPrd, SAFACT.TotalSrv, 
       SAFACT.ValorPtos, SAFACT.ZipCode, 
       SAVEND.Activo, SAVEND.Clase, 
       SAVEND.Descrip Descrip_2, 
       SAFACT.TGravable0, 
       SAVEND.CodVend CodVend_2, SAFACT.TipoDev, 
       SAVEND.Direc1 Direc1_2, 
       SACONV.Descrip Descrip_3, 
       SAVEND.Direc2 Direc2_2, SAVEND.Email, 
       SAVEND.FechaUC, SAVEND.FechaUV, 
       SAVEND.ID3 ID3_2, SAVEND.Movil, 
       SAVEND.Telef Telef_2, SAVEND.TipoID, 
       SAVEND.TipoID3, SACLIE.Activo Activo_2, 
       SACLIE.Ciudad, SACLIE.Clase Clase_2, 
       SACLIE.CodAlte CodAlte_2, 
       SACLIE.CodClie CodClie_2, 
       SACLIE.CodConv CodConv_2, 
       SACLIE.CodVend CodVend_3, SACLIE.CodZona, 
       SACLIE.Descrip Descrip_4, 
       SACLIE.DescripExt, SACLIE.Descto, 
       SACLIE.DiasCred, SACLIE.DiasTole, 
       SACLIE.Direc1 Direc1_3, 
       SACLIE.Direc2 Direc2_3, 
       SACLIE.Email Email_2, SACLIE.EsCredito, 
       SACLIE.EsMoneda, SACLIE.Estado, 
       SACLIE.EsToleran, SACLIE.Fax, 
       SACLIE.FechaE FechaE_2, SACLIE.FechaUP, 
       SACLIE.FechaUV FechaUV_2, 
       SACLIE.ID3 ID3_3, SACLIE.IntMora, 
       SACLIE.LimiteCred, SACLIE.MontoMax, 
       SACLIE.EsReten, SACLIE.MontoUP, 
       SACLIE.MontoUV, SACLIE.Movil Movil_2, 
       SACLIE.MtoMaxCred, SACLIE.Municipio, 
       SACLIE.NumeroUP, SACLIE.NumeroUV, 
       SACLIE.Observa, SACLIE.PagosA, 
       SACLIE.Pais, SACLIE.PromPago, 
       SACLIE.Represent, 
       SACLIE.RetenIVA RetenIVA_2, SACLIE.Saldo, 
       SACLIE.SaldoPtos, SACLIE.Telef Telef_3, 
       SACLIE.TipoCli, SACLIE.TipoID TipoID_2, 
       SACLIE.TipoID3 TipoID3_2, SACLIE.TipoPVP, 
       SACLIE.ZipCode ZipCode_2, 
       SACONV.Activo Activo_3, SACONV.Autori, 
       SACONV.CodConv CodConv_3, SACONV.EsFijo, 
       SACONV.FechaE FechaE_3, 
       SACONV.FechaV FechaV_2, SACONV.Respon, 
       SACONV.TipoCnv, SACLIE.TipoReg
FROM SAFACT SAFACT INNER JOIN SAVEND SAVEND ON 
     (SAVEND.CodVend = SAFACT.CodVend)
      LEFT OUTER JOIN SACLIE SACLIE ON 
     (SACLIE.CodClie = SAFACT.CodClie)
      LEFT OUTER JOIN SACONV SACONV ON 
     (SACONV.CodConv = SACLIE.CodConv)
WHERE ( SAFACT.CodSucu = '00000' )
       AND ( SAFACT.TipoFac = 'A' )
       AND ( SAFACT.NumeroD = '44412' )
GO

-- Session: 61 | Start: 2026-03-13 17:50:43.357000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT lo.nrounico, lo.nrolote, lo.codubic, dp.descrip, lo.costo, Precio3 AS PRECIO, dbo.FN_ADM_TAXPRODUCT(CodProd,Precio3,1,0,0)+Precio3 As PrecioTx,PrecioU3 AS PRECIOU, dbo.FN_ADM_TAXPRODUCT(CodProd,PrecioU3,1,1,0)+PrecioU3 As PrecioUTx,lo.cantidad, lo.cantidadu, lo.fechae, lo.fechav from SALOTE lo Inner Join sadepo dp on lo.codubic=dp.codubic where (lo.codprod='7590027002864') And (lo.CodUbic='AMR001')  And ((lo.Cantidad>0) Or (lo.CantidadU>0)) Order By lo.codubic, lo.fechav
GO

-- Session: 61 | Start: 2026-03-13 17:51:41.163000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='PREGA' OR P.CodProd='PREGA')
GO

-- Session: 60 | Start: 2026-03-13 17:53:40.800000 | Status: runnable | Cmd: SELECT
SELECT 
    SAPROD.Descrip, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio1 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio1 
    END AS Precio1, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio2 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio2 
    END AS Precio2, 
    CASE 
        WHEN SATAXPRD.Monto IS NOT NULL THEN SAPROD.Precio3 * (1 + SATAXPRD.Monto / 100) 
        ELSE SAPROD.Precio3 
    END AS Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere AS CosPror$, -- Aquí está la columna que pediste agregar
    SATAXPRD.Monto, 
    SAPROD.CodProd AS Cod, 
    GETDATE() AS LastUpdated
FROM 
    dbo.SAPROD 
LEFT OUTER JOIN 
    dbo.SATAXPRD 
ON 
    SAPROD.CodProd = SATAXPRD.CodProd
WHERE 
    SAPROD.Existen > 0 
    AND SAPROD.Activo = 1 
GROUP BY 
    SAPROD.Descrip, 
    SAPROD.Precio1, 
    SAPROD.Precio2, 
    SAPROD.Precio3, 
    SAPROD.PrecioI1, 
    SAPROD.PrecioI2, 
    SAPROD.PrecioI3, 
    SAPROD.Existen, 
    SAPROD.Descrip3, 
    SAPROD.Refere, -- Añadido al GROUP BY para que la consulta sea válida
    SATAXPRD.Monto, 
    SAPROD.CodProd;
GO

-- Session: 60 | Start: 2026-03-13 17:54:37.790000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select Fecha
     , Sum(VNeta) VNetas
     , sum(VImpuesto) VImpuestos
     , sum (VCredito) VCredito
     , sum(VContado) VContado
     , sum(VAdelanto) VAdelantos
     , sum(VCobros) VCobros
     , sum(VAdelanto)+sum(VCobros) VTotalIngreso
     , sum(VCosto) VCostos
     ,(Sum(VNeta)-sum(VCosto)) VUtilidad
     , Sum(NFact) NFact
     , Sum(NDev) NDev
  from
      (select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
            , sum(F.Monto_Neto) VNeta 
            , sum(F.MtoTax) VImpuesto
            , Sum(F.Credito) VCredito 
            , sum(F.Contado) VContado
            , sum(F.CancelA)VAdelanto
            , 0 VCobros
            , sum((F.CostoPrd+F.CostoSrv)) VCosto
            , sum(IIF(F.TipoFac = 'A',1,0)) NFact
            , sum(IIF(F.TipoFac = 'B',1,0)) NDev
          from vw_adm_facturas F 
               left join SACLIE C 
                      on F.CodClie = C.CodClie
          where (F.FechaE >= (CONVERT(DATETIME,'2026-03-13',120)+' 00:00:00') and F.FechaE<= (CONVERT(DATETIME,'2026-03-13',120)+ ' 23:59:59')) 
            and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),F.FechaE,112))
       union all
       select convert(datetime,convert(varchar(8),CXC.FechaE,112)) Fecha
            , 0,0,0,0,0,sum(Monto),0,0,0
         from SAACXC CXC 
              left join SACLIE C 
                     on CXC.CodClie = C.CodClie
         where (CXC.TipoCxc in (41))  And (CXC.EsUnPago=1)  
           and (CXC.FechaE>=(CONVERT(DATETIME,'2026-03-13',120)+' 00:00:00') and CXC.FechaE<=(CONVERT(DATETIME,'2026-03-13',120)+' 23:59:59')) 
           and (SUBSTRING(ISNULL(CXC.CODOPER,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodClie,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CODVEND,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodUsua,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),CXC.FechaE,112))) as Ventas
  group by Fecha
  order by Fecha
GO

-- Session: 60 | Start: 2026-03-13 17:54:38.300000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
     , (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) Tipo
     , Numerod Numero
     , F.CodClie Codigo
     , C.Descrip Cliente
     ,(F.Monto_Neto) VNeta
     , F.MtoTax VImpuesto
     , F.Credito VCredito 
     , F.Contado VContado
     , F.CancelA VAdelanto
     , 0 VCobros
     , (F.CostoPrd+F.CostoSrv) VCosto
     , (F.MontoTotal) VMtoTotal
  from VW_ADM_FACTURAS F 
       left join SACLIE C 
              on F.CodClie = C.CodClie
  where (F.FechaE >= CONVERT(DATETIME,'2026-03-13',120) and F.FechaE<= CONVERT(DATETIME,'2026-03-13',120)+ ' 23:59:59' ) 
    and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'')
	  and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
  order by convert(datetime,convert(varchar(8),F.FechaE,112)),
          (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) desc
GO

-- Session: 60 | Start: 2026-03-13 17:56:16.337000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select Fecha
     , Sum(VNeta) VNetas
     , sum(VImpuesto) VImpuestos
     , sum (VCredito) VCredito
     , sum(VContado) VContado
     , sum(VAdelanto) VAdelantos
     , sum(VCobros) VCobros
     , sum(VAdelanto)+sum(VCobros) VTotalIngreso
     , sum(VCosto) VCostos
     ,(Sum(VNeta)-sum(VCosto)) VUtilidad
     , Sum(NFact) NFact
     , Sum(NDev) NDev
  from
      (select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
            , sum(F.Monto_Neto) VNeta 
            , sum(F.MtoTax) VImpuesto
            , Sum(F.Credito) VCredito 
            , sum(F.Contado) VContado
            , sum(F.CancelA)VAdelanto
            , 0 VCobros
            , sum((F.CostoPrd+F.CostoSrv)) VCosto
            , sum(IIF(F.TipoFac = 'A',1,0)) NFact
            , sum(IIF(F.TipoFac = 'B',1,0)) NDev
          from vw_adm_facturas F 
               left join SACLIE C 
                      on F.CodClie = C.CodClie
          where (F.FechaE >= (CONVERT(DATETIME,'2026-03-12',120)+' 00:00:00') and F.FechaE<= (CONVERT(DATETIME,'2026-03-12',120)+ ' 23:59:59')) 
            and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
            and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),F.FechaE,112))
       union all
       select convert(datetime,convert(varchar(8),CXC.FechaE,112)) Fecha
            , 0,0,0,0,0,sum(Monto),0,0,0
         from SAACXC CXC 
              left join SACLIE C 
                     on CXC.CodClie = C.CodClie
         where (CXC.TipoCxc in (41))  And (CXC.EsUnPago=1)  
           and (CXC.FechaE>=(CONVERT(DATETIME,'2026-03-12',120)+' 00:00:00') and CXC.FechaE<=(CONVERT(DATETIME,'2026-03-12',120)+' 23:59:59')) 
           and (SUBSTRING(ISNULL(CXC.CODOPER,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodClie,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CODVEND,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodUsua,''),1,LEN(+''))=+'') 
           and (SUBSTRING(ISNULL(CXC.CodEsta,''),1,LEN(+''))=+'') 
         group by convert(datetime,convert(varchar(8),CXC.FechaE,112))) as Ventas
  group by Fecha
  order by Fecha
GO

-- Session: 60 | Start: 2026-03-13 17:56:16.840000 | Status: suspended | Cmd: SELECT
/*    
 ****************************************************************************** 
 
 RELACION DE VENTAS Y COBROS                                       
 
 Copyright (c) 2017 Guillermo J. Rivero and SAINT DE VENEZUELA Team        
 ****************************************************************************** 
 Licensed under the Apache License, Version 2.0 (the "License");             
 you may not use this file except in compliance with the License.            

 You may obtain a copy of the License at www.apache.org/licenses/LICENSE-2.0                                    
                                                                              
 Unless required by applicable law or agreed to in writing, software         
 distributed under the License is distributed on an "AS IS" BASIS,           
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    
 See the License for the specific language governing permissions and         
 limitations under the License.                                              
 ******************************************************************************
 POR ERNESTO ARENAS N - CANAL ASYS, C.A. - VALENCIA
 ESQUEMATIZADO 23-04-2019
 MEJORADO 23-04-2019
 ******************************************************************************   
*/
select convert(datetime,convert(varchar(8),F.FechaE,112)) Fecha
     , (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) Tipo
     , Numerod Numero
     , F.CodClie Codigo
     , C.Descrip Cliente
     ,(F.Monto_Neto) VNeta
     , F.MtoTax VImpuesto
     , F.Credito VCredito 
     , F.Contado VContado
     , F.CancelA VAdelanto
     , 0 VCobros
     , (F.CostoPrd+F.CostoSrv) VCosto
     , (F.MontoTotal) VMtoTotal
  from VW_ADM_FACTURAS F 
       left join SACLIE C 
              on F.CodClie = C.CodClie
  where (F.FechaE >= CONVERT(DATETIME,'2026-03-12',120) and F.FechaE<= CONVERT(DATETIME,'2026-03-12',120)+ ' 23:59:59' ) 
    and (SUBSTRING(ISNULL(F.CODOPER,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodClie,''),1,LEN(+''))=+'')
	  and (SUBSTRING(ISNULL(F.CODVEND,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(C.CodZona,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUbic,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodUsua,''),1,LEN(+''))=+'') 
	  and (SUBSTRING(ISNULL(F.CodEsta,''),1,LEN(+''))=+'') 
  order by convert(datetime,convert(varchar(8),F.FechaE,112)),
          (case F.Tipofac when 'A' then 'Fac' else 'Dev' end) desc
GO

-- Session: 60 | Start: 2026-03-13 17:56:30.103000 | Status: runnable | Cmd: SELECT
SELECT A.*
FROM SAITRE A
ORDER BY A.itemid ASC
GO

-- Session: 61 | Start: 2026-03-13 17:58:28.987000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '796029455258%') OR (SP.DESCRIPALL LIKE '796029455258%') OR (SP.REFERE LIKE '796029455258%') OR (SP.EXISTEN LIKE '796029455258%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 58 | Start: 2026-03-13 17:58:50.157000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'VA%') OR (Descrip LIKE 'VA%') OR (ID3 LIKE 'VA%') OR (Clase LIKE 'VA%') OR (Saldo LIKE 'VA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 13
GO

-- Session: 58 | Start: 2026-03-13 17:59:13.640000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='ACEITE' OR P.CodProd='ACEITE')
GO

-- Session: 61 | Start: 2026-03-13 17:59:26.247000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JUAN%') OR (Descrip LIKE 'JUAN%') OR (ID3 LIKE 'JUAN%') OR (Clase LIKE 'JUAN%') OR (Saldo LIKE 'JUAN%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 58 | Start: 2026-03-13 17:59:48.347000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '7595481000234%') OR (SP.DESCRIPALL LIKE '7595481000234%') OR (SP.REFERE LIKE '7595481000234%') OR (SP.EXISTEN LIKE '7595481000234%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 36
GO

-- Session: 58 | Start: 2026-03-13 18:00:29.573000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE '7592349003000%') OR (SP.DESCRIPALL LIKE '7592349003000%') OR (SP.REFERE LIKE '7592349003000%') OR (SP.EXISTEN LIKE '7592349003000%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 36
GO

-- Session: 60 | Start: 2026-03-13 18:03:00.997000 | Status: runnable | Cmd: UPDATE
UPDATE SAPROD 
SET PrecioI1=b.precio$1,PrecioI2=b.precio$2,PrecioI3=b.precio$3
from SAPROD as a
inner join CUSTOM_PRECIO_EN_DOLAR as b on (a.CodProd=b.codprod)
GO

-- Session: 61 | Start: 2026-03-13 18:06:06.770000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.DescripAll ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CODPROD LIKE 'AIRO%') OR (SP.DESCRIPALL LIKE 'AIRO%') OR (SP.REFERE LIKE 'AIRO%') OR (SP.EXISTEN LIKE 'AIRO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 61 | Start: 2026-03-13 18:06:57.923000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'JOSEFINA%') OR (Descrip LIKE 'JOSEFINA%') OR (ID3 LIKE 'JOSEFINA%') OR (Clase LIKE 'JOSEFINA%') OR (Saldo LIKE 'JOSEFINA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 27
GO

-- Session: 70 | Start: 2026-03-13 18:07:12.853000 | Status: suspended | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT  * , ROW_NUMBER() OVER (ORDER BY Descrip ASC) AS ROWNUM   FROM SACLIE WITH (NOLOCK) 
  WHERE ((CodClie LIKE 'ROSA%') OR (Descrip LIKE 'ROSA%') OR (ID3 LIKE 'ROSA%') OR (Clase LIKE 'ROSA%') OR (Saldo LIKE 'ROSA%')) AND (ACTIVO>0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 30
GO

-- Session: 61 | Start: 2026-03-13 18:07:27.247000 | Status: running | Cmd: SELECT
SET DATEFORMAT YMD;
Set DateFormat YMD
;WITH MyCTE AS (SELECT '00000' CODSUCU,SP.CODPROD, SP.DESCRIP, SP.DESCRIPALL, SP.REFERE, SP.EXISTEN, SP.EXUNIDAD,SP.DESCOMP, SP.DESSERI, SP.DESLOTE, SP.ESEXENTO, ROW_NUMBER() OVER (ORDER BY SP.CodProd ASC) AS ROWNUM   FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 

  WHERE ((SP.CodProd LIKE 'CETIRO%') OR (SP.DescripAll LIKE 'CETIRO%') OR (SP.Refere LIKE 'CETIRO%') OR (SP.Existen LIKE 'CETIRO%')) AND  (SP.Activo=1) AND (SP.EsEnser=0))
 SELECT *, (SELECT MAX(ROWNUM) FROM myCTE WITH (NOLOCK)) AS TOTALROWS
   FROM myCTE WITH (NOLOCK) 
  WHERE RowNum BETWEEN 1 AND 24
GO

-- Session: 58 | Start: 2026-03-13 18:07:31.770000 | Status: runnable | Cmd: SELECT
SET DATEFORMAT YMD;
SELECT TOP 1 P.CodProd,P.CodInst,P.DEsCorrel,P.DigitosC,P.Refere,P.DEsSeri,P.DEsComp,P.EsExento,
     P.ExDecimal,P.Unidad,P.UndEmpaq,P.DEsLote,P.EsPesa,P.Tara,P.Factor,P.DEsVence,
     P.Descto,P.CantEmpaq,P.Peso,P.Volumen,P.UndVol,P.EsEmpaque,P.CostPro,P.DescripAll,
     P.Descrip,P.Descrip2,P.Descrip3,P.PrecioU,P.PrecioU2,P.PrecioU3,P.Precio1,P.Precio2,
     P.Precio3, 0 AS ISADIC , P.COSTPRO AS COSTO   FROM VW_ADM_PRODUCTOS P WITH (NOLOCK)  INNER JOIN SACODBAR C ON        P.CODPROD=C.CODPROD  WHERE (P.EsEnser=0) AND (P.Activo>0)  AND (P.CODPROD=C.CODPROD) AND (C.CodAlte='7593255000114' OR P.CodProd='7593255000114')
GO

-- Session: 70 | Start: 2026-03-13 18:09:10.820000 | Status: running | Cmd: AWAITING COMMAND
(@P1 varchar(15))SET DATEFORMAT YMD;
SELECT SP.CODPROD, SP.DESCRIP, SP.DESCRIP2, SP.DESCRIP3
      ,SP.REFERE, SP.EXISTEN, SP.EXUNIDAD, SP.ESEXENTO
      ,SP.ESENSER, SP.ACTIVO, SP.MARCA, SP.DESSERI
      ,SP.DESCRIPALL, SP.DESLOTE, SP.DESCOMP, SP.DESVENCE
      ,SP.COSTPRO, SP.COSTACT, SP.COSTANT
      ,SP.CANTPED, SP.CANTCOM, SP.UNIDPED, SP.UNIDCOM
      ,SP.MINIMO, SP.MAXIMO
      ,SP.UNIDAD, SP.CANTEMPAQ, SP.UNDEMPAQ
      ,SP.PRECIO1, SP.PRECIO2, SP.PRECIO3
      ,SP.PRECIOU AS PRECIOU1, SP.PRECIOU2, SP.PRECIOU3
      ,SP.PRECIOI1, SP.PRECIOI2, SP.PRECIOI3
      ,SP.PRECIOIU1, SP.PRECIOIU2, SP.PRECIOIU3
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.Precio1, 1, 0, 0)+SP.Precio1 AS PTX1 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.Precio2, 1, 0, 0)+SP.Precio2 AS PTX2 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.Precio3, 1, 0, 0)+SP.Precio3 AS PTX3 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.PrecioU, 1, 1, 0)+SP.PrecioU AS PTXU1 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.PrecioU2,1, 1, 0)+SP.PrecioU2 AS PTXU2 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.PrecioU3,1, 1, 0)+SP.PrecioU3 AS PTXU3 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.CostPro, 1, 0, 1)+SP.CostPro AS COSTOPROTX 
      ,dbo.FN_ADM_TAXPRODUCT(SP.CodProd, SP.CostAct, 1, 0, 1)+SP.CostAct AS COSTOACTTX 
  FROM VW_ADM_PRODUCTOS SP WITH (NOLOCK) 
 
 WHERE SP.CODPROD=@P1
GO

-- Session: 64 | Start: 2026-03-13 18:10:00.590000 | Status: suspended | Cmd: UPDATE
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_start_execution_date]
    @session_id               INT,
    @job_id                   UNIQUEIDENTIFIER,
    @is_system                TINYINT = 0,
    @begin_execution_date     INT,
    @begin_execution_time     INT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

   DECLARE @start_execution_date DATETIME
   SET @start_execution_date = [msdb].[dbo].[agent_datetime](@begin_execution_date, @begin_execution_time)

   UPDATE [msdb].[dbo].[sysjobactivity]
   SET start_execution_date = @start_execution_date
   WHERE session_id = @session_id
   AND job_id = @job_id
END
GO

-- Session: 70 | Start: 2026-03-13 18:10:11.820000 | Status: suspended | Cmd: UPDATE
SET DATEFORMAT YMD;
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DECLARE
   @ErrMsg        NVARCHAR(4000)
  ,@ErrorSeverity INT
  ,@ErrorState    INT
  ,@ErrorNumber   INT
  ,@ErrorLine     INT
  ,@OCANT        decimal(28,4)=0
  ,@CANT         decimal(28,4)=0
  ,@PORCT        DECIMAL(28,4)=0
  ,@MONTO        DECIMAL(28,4)=0
  ,@MONTOTAX     DECIMAL(28,4)=0
  ,@EXISTPRD     DECIMAL(28,4)=0
  ,@EXISTANT     DECIMAL(28,4)=0
  ,@EXISTANTUND  DECIMAL(28,4)=0
  ,@NUMEROFAC    VARCHAR(20)
  ,@NUMERODES    VARCHAR(20)
  ,@NUMERONCR    VARCHAR(20)
  ,@NUMEROREC    VARCHAR(20)
  ,@NUMERODOC    VARCHAR(20)
  ,@NUMEROAUD    VARCHAR(20)
  ,@IMPUESTOTJT  DECIMAL(28,3)=0
  ,@COMISIONTJT  DECIMAL(28,3)=0
  ,@RETENCIVATJT DECIMAL(28,3)=0
  ,@RETENCIONTJT DECIMAL(28,3)=0
  ,@LENCORREL    INT=8
  ,@SALDO        decimal(28,4)=0
  ,@SaldoAnt     DECIMAL(28,4)=0
  ,@FECHAE       datetime
  ,@TipoCxC      VARCHAR(2)
  ,@CancelA      DECIMAL(28,4)=0.00
  ,@CODCLIE      VARCHAR(15) ='V10915197'
  ,@FACTORM      DECIMAL(28,4)=443.25
  ,@CORRELATIVO  INT=1
  ,@PROXNUMBER   INT=0
  ,@NROUNICO     INT=0
  ,@NROUNICOIPA  INT=0
  ,@NROUNICOFAC  INT=0
  ,@NROUNICOAUD  INT=0
  ,@NROREGISERI  INT=0
  ,@NROUNICOCXC  INT=0
  ,@NROUNICORETI INT=0
  ,@NROUNICOREC  INT=0
  ,@NROUNICOLOT  INT=0
  ,@NROUNICONCR  INT=0
;
BEGIN TRANSACTION;
BEGIN TRY
  EXEC SP_ADM_PROXCORREL '00000','','PrxFact',@NUMEROFAC OUTPUT;
  INSERT INTO SAFACT ([CodSucu],[TipoFac],[NumeroD],[EsCorrel],[FechaT],[FechaI],[FechaE],[FechaV],[FromTran],[Signo],[CodClie],[CodEsta],[CodUsua],[CodVend],[CodUbic],[Descrip],[Direc1],[ID3],[Monto],[MtoTotal],[Factor],[MontoMEx],[Contado],[TotalPrd],[TExento],[CancelT])
       VALUES ('00000','A',@NUMEROFAC,@CORRELATIVO,GETDATE(),'2026-03-13 18:00:46.862','2026-03-13 18:00:46.909','2026-03-13 18:00:46.862',1,1,'V10915197','BK-01','12394915','12394915','AMR001','ROSA','CARACAS','V10915197',971.56,971.56,443.25,2.19,971.56,971.56,971.56,971.56);
SET @NROUNICOFAC=IDENT_CURRENT('SAFACT');
  SET @NROUNICOLOT=1056321
  UPDATE SAPROD SET FechaUV='2026-03-13 18:00:47.003'
 WHERE (CodProd='8906005116987');
  SELECT @EXISTANT=0, @EXISTANTUND=0;
  SELECT @EXISTANT=ISNULL(EXISTEN,0), @EXISTANTUND=ISNULL(EXUNIDAD,0)
  FROM SAEXIS WITH (NOLOCK) 
 WHERE (CODPROD='8906005116987') AND 
       (CODSUCU='00000') AND 
       (CODUBIC='AMR001');
  EXEC TR_ADM_UPDATE_EXISTENCIAS '00000','8906005116987','AMR001',-1.00,0,'2026-03-13';
  SELECT TOP 1 @EXISTPRD=ISNULL(E.EXISTEN,0) FROM SAEXIS E WITH (NOLOCK)  WHERE (E.CodSucu='00000') And (E.CodProd='8906005116987') And (E.CodUbic='AMR001')
  IF @EXISTPRD<0 BEGIN
       SET @ErrMsg = 'Existencia cero o negativa!';
       RAISERROR(@ErrMsg, 16, 0);
     END;
  SET @NROUNICOLOT=1056321
  UPDATE SALOTE SET [Cantidad]=[Cantidad]+-1.00 WHERE NroUnico=@NROUNICOLOT
  INSERT INTO SAITEMFAC ([CodSucu],[TipoFac],[NumeroD],[NroLinea],[Signo],[FechaE],[CodItem],[Refere],[CodUbic],[Descrip1],[Cantidad],[CantMayor],[Costo],[Factor],[TotalItem],[Precio],[PriceO],[CodVend],[CodUsua],[EsExento],[DEsLote],[NroLote],[NroUnicoL],[ExistAntU],[ExistAnt],[FechaL],[FechaV])
       VALUES ('00000','A',@NUMEROFAC,1,1,'2026-03-13 18:00:47.034','8906005116987','1.29366','AMR001','SILDENAFIL 50      MG X 4 TAB DROTACA',1.00,1.00,511.31,1.00,971.558,971.558,971.558,'12394915','12394915',1,1,'0357',ISNULL(@NROUNICOLOT,0),ISNULL(@EXISTANTUND,0),ISNULL(@EXISTANT,0),'2026-02-20 00:00:00.000','1899-12-29 00:00:00.000');
  UPDATE SAFACT SET 
   CostoPrd=511.31   ,CostoSrv=0.00   ,MtoComiVta=0.00   ,MtoComiVtaD=0.00   ,MtoComiCob=0.00   ,MtoComiCobD=0.00  WHERE (CODSUCU='00000') AND (TIPOFAC='A') AND (NUMEROD=@NUMEROFAC);
  INSERT INTO SAIPAVTA ([NumeroD],[TipoFac],[CodSucu],[CodTarj],[Descrip],[TipoPag],[Monto],[Factor],[FechaE])
       VALUES (@NUMEROFAC,'A','00000','001','TDD',2,971.56,1.00,'2026-03-13 00:00:00.000');
  UPDATE SACONF SET FECHAUP=GETDATE()  WHERE CODSUCU='00000'
  COMMIT TRANSACTION;
  SELECT 0 error, ISNULL(@NUMEROFAC,'') AS numerod, ISNULL(@NUMERODES,'') AS numerodes, ISNULL(@NROUNICOFAC, 0) AS nrounicofac, ISNULL(@NROUNICOREC, 0) AS nrounicorec, ISNULL(@NROUNICONCR, 0) AS nrouniconcr;
END TRY
BEGIN CATCH
  IF (@@TRANCOUNT>0)
     ROLLBACK;
  SELECT
     @ErrMsg = ERROR_MESSAGE(),
     @ErrorSeverity = ERROR_SEVERITY(),
     @ErrorState = ERROR_STATE(),
     @ErrorNumber = ERROR_NUMBER(),
     @ErrorLine = ERROR_LINE();
  SET @ErrMsg = @ErrMsg+Char(13)+
      'Line: '+Cast(@ErrorLine As Varchar(10));
  SELECT -1 error, @ErrMsg errmsg, @ErrorSeverity errseverity;
  RAISERROR(@ErrMsg, @ErrorSeverity, @ErrorState);
END CATCH;
GO

-- Session: 73 | Start: 2026-03-13 18:15:01.050000 | Status: runnable | Cmd: BACKUP DATABASE
CREATE PROCEDURE [dbo].[BackupEnterpriseAdmin_AMC]
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @DatabaseName NVARCHAR(50) = 'EnterpriseAdmin_AMC'
    	DECLARE @BackupPath NVARCHAR(200) = '\\10.200.8.5\sql\' + @DatabaseName + 'backup' + CONVERT(NVARCHAR(10), @@datefirst) + '.bak'''
    -- Variables
   
    DECLARE @FullBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Full.bak'
    DECLARE @DiffBackupFile NVARCHAR(200) = @BackupPath + @DatabaseName + '_Diff.dif'
    DECLARE @LastFullBackup DATETIME
    DECLARE @BackupName NVARCHAR(200)

    -- Check the last full backup date
    SELECT @LastFullBackup = MAX(backup_finish_date)
    FROM msdb.dbo.backupset
    WHERE database_name = @DatabaseName
    AND type = 'D'

    -- If no full backup exists or the last full backup is older than 24 hours, create a new full backup
    IF @LastFullBackup IS NULL OR DATEDIFF(HOUR, @LastFullBackup, GETDATE()) > 24
    BEGIN
        SET @BackupName = N'Full Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @FullBackupFile
        WITH INIT, NAME = @BackupName
    END
    ELSE
    BEGIN
        -- Create a differential backup
        SET @BackupName = N'Differential Backup of ' + @DatabaseName
        BACKUP DATABASE @DatabaseName
        TO DISK = @DiffBackupFile
        WITH DIFFERENTIAL, INIT, NAME = @BackupName
    END
END
GO
