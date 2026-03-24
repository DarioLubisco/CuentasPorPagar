USE EnterpriseAdmin_AMC;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Procurement].[Settings]') AND type in (N'U'))
BEGIN
    CREATE TABLE Procurement.Settings (
        SettingKey VARCHAR(50) PRIMARY KEY,
        SettingValue VARCHAR(100) NOT NULL,
        Description VARCHAR(200),
        UpdatedAt DATETIME DEFAULT GETDATE()
    );

    -- Seed defaults
    INSERT INTO Procurement.Settings (SettingKey, SettingValue, Description)
    VALUES 
    ('TasaEmisionSource', 'DOLARTODAY', 'Origen de la tasa de cambio de emision: DOLARTODAY o SACOMP_FACTOR'),
    ('MontoUSDSource', 'CALCULATED', 'Origen del monto en USD: CALCULATED (Bs/Tasa) o SACOMP_Monomex');
    
    PRINT 'Table Procurement.Settings created and seeded successfully.';
END
ELSE
BEGIN
    PRINT 'Table Procurement.Settings already exists.';
END
GO
