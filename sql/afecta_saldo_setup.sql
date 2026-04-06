-- ================================================================
-- Add AfectaSaldo column to CxP_Abonos
-- Registros con AfectaSaldo=0 son informativos (descuentos, etc.)
-- y NO se deben sumar en los cálculos de saldo adeudado
-- ================================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('EnterpriseAdmin_AMC.dbo.CxP_Abonos')
      AND name = 'AfectaSaldo'
)
BEGIN
    ALTER TABLE EnterpriseAdmin_AMC.dbo.CxP_Abonos
        ADD AfectaSaldo BIT NOT NULL DEFAULT 1;
    
    -- Los AJUSTE existentes ya afectaron saldo al registrarse, mantenemos AfectaSaldo=1
    -- Los DESCUENTO (nuevos) se insertarán con AfectaSaldo=0
    PRINT 'Columna AfectaSaldo agregada a CxP_Abonos.';
END
ELSE
    PRINT 'Columna AfectaSaldo ya existe.';
