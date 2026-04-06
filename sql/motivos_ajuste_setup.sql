-- ============================================================
-- Tabla: MotivosAjuste
-- Centraliza los conceptos contables para los ajustes internos.
-- AnulaNotaDebito: Si 1, la factura se excluye del módulo de ND.
-- AnulaNotaCredito: Si 1, la factura se excluye del módulo de NC.
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Procurement'
      AND TABLE_NAME   = 'MotivosAjuste'
      AND TABLE_CATALOG = 'EnterpriseAdmin_AMC'
)
BEGIN
    CREATE TABLE EnterpriseAdmin_AMC.Procurement.MotivosAjuste (
        MotivoID         INT IDENTITY(1,1) PRIMARY KEY,
        Codigo           VARCHAR(20)  NOT NULL,
        Descripcion      VARCHAR(150) NOT NULL,
        AnulaNotaDebito  BIT NOT NULL DEFAULT 1,  -- Excluye del módulo de ND
        AnulaNotaCredito BIT NOT NULL DEFAULT 0,  -- Excluye del módulo de NC
        Activo           BIT NOT NULL DEFAULT 1,
        FechaCreacion    DATETIME NOT NULL DEFAULT GETDATE()
    );
END;

-- Datos iniciales
IF NOT EXISTS (SELECT 1 FROM EnterpriseAdmin_AMC.Procurement.MotivosAjuste)
BEGIN
    INSERT INTO EnterpriseAdmin_AMC.Procurement.MotivosAjuste
        (Codigo, Descripcion, AnulaNotaDebito, AnulaNotaCredito, Activo)
    VALUES
        ('100', 'Descuento Pronto Pago',         0, 1, 1),  -- El proveedor rebajó, no es nota de crédito pendiente
        ('101', 'Diferencial Cambiario / Ajuste de Tasa', 1, 0, 1),  -- Ya ajustado internamente, no genera ND
        ('102', 'Redondeo Contable (Céntimos)',  1, 0, 1),  -- Diferencia ínfima, sin impacto en notas
        ('103', 'Acuerdo Comercial Específico',  0, 0, 1);  -- Caso a caso, no anula ninguna
END;

-- ============================================================
-- Columna en CxP_Abonos para trazar el motivo de cada ajuste
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME   = 'CxP_Abonos'
      AND COLUMN_NAME  = 'MotivoAjusteID'
      AND TABLE_CATALOG = 'EnterpriseAdmin_AMC'
)
BEGIN
    ALTER TABLE EnterpriseAdmin_AMC.dbo.CxP_Abonos
        ADD MotivoAjusteID INT NULL
            CONSTRAINT FK_CxP_Abonos_MotivoAjuste
            FOREIGN KEY REFERENCES EnterpriseAdmin_AMC.Procurement.MotivosAjuste(MotivoID);
END;
