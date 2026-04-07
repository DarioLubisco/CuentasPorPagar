IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'Procurement' AND table_name = 'InvoiceSettings')
BEGIN
    CREATE TABLE EnterpriseAdmin_AMC.Procurement.InvoiceSettings (
        NumeroD varchar(20) NOT NULL,
        CodProv varchar(20) NOT NULL,
        AplicaIndexacion bit NOT NULL DEFAULT 1,
        IndexaIVA bit NOT NULL DEFAULT 1,
        UpdatedAt datetime DEFAULT GETDATE(),
        PRIMARY KEY (NumeroD, CodProv)
    );
    PRINT 'Tabla Procurement.InvoiceSettings creada.';
END
ELSE
    PRINT 'La tabla ya existe.';
