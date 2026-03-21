import os
import pyodbc
from dotenv import load_dotenv
import sys

def create_tables():
    load_dotenv()
    
    DB_SERVER = os.getenv("DB_SERVER")
    DB_DATABASE = os.getenv("DB_DATABASE")
    DB_USERNAME = os.getenv("DB_USERNAME")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    
    print(f"Connecting to {DB_DATABASE} on {DB_SERVER}...")
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        
        # 1. ProveedorCondiciones
        print("Creating table ProveedorCondiciones...")
        cursor.execute("""
        IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Procurement')
        BEGIN
            EXEC('CREATE SCHEMA [Procurement]');
        END
        
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Procurement].[ProveedorCondiciones]') AND type in (N'U'))
        BEGIN
            CREATE TABLE [Procurement].[ProveedorCondiciones] (
                [CodProv] VARCHAR(50) PRIMARY KEY,
                [DiasNoIndexacion] INT,
                [BaseDiasCredito] VARCHAR(20) DEFAULT 'EMISION',
                [DiasVencimiento] INT,
                [ProntoPago1_Dias] INT,
                [ProntoPago1_Pct] DECIMAL(5,2),
                [ProntoPago2_Dias] INT,
                [ProntoPago2_Pct] DECIMAL(5,2),
                [Email] VARCHAR(100)
            );
        END
        """)
        
        # 2. CxP_Abonos
        print("Creating table CxP_Abonos...")
        cursor.execute("""
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CxP_Abonos]') AND type in (N'U'))
        BEGIN
            CREATE TABLE [dbo].[CxP_Abonos] (
                [AbonoID] INT IDENTITY(1,1) PRIMARY KEY,
                [NumeroD] VARCHAR(50) NOT NULL,
                [CodProv] VARCHAR(50) NOT NULL,
                [FechaAbono] DATE NOT NULL,
                [MontoBsAbonado] DECIMAL(18,2) NOT NULL,
                [TasaCambioDiaAbono] DECIMAL(18,4),
                [MontoUsdAbonado] DECIMAL(18,2) NOT NULL,
                [AplicaIndexacion] BIT NOT NULL,
                [Referencia] VARCHAR(100),
                [FechaRegistro] DATETIME DEFAULT GETDATE()
            );
            
            -- Add an index for faster lookups by invoice
            CREATE INDEX IX_CxP_Abonos_Factura ON [dbo].[CxP_Abonos]([CodProv], [NumeroD]);
        END
        """)
        
        # 3. DebitNotesTracking
        print("Creating table DebitNotesTracking...")
        cursor.execute("""
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Procurement].[DebitNotesTracking]') AND type in (N'U'))
        BEGIN
            CREATE TABLE [Procurement].[DebitNotesTracking] (
                [CodProv] VARCHAR(50) NOT NULL,
                [NumeroD] VARCHAR(50) NOT NULL,
                [Estatus] VARCHAR(30) DEFAULT 'PENDIENTE',
                [NotaDebitoID] VARCHAR(50),
                [FechaSolicitud] DATETIME,
                [FechaEmision] DATETIME,
                [MontoRetencionBs] DECIMAL(18,2),
                PRIMARY KEY ([CodProv], [NumeroD])
            );
        END
        """)
        
        # 4. Migrations (idempotent)
        print("Running migrations...")
        
        # 4a. Add new columns to Retenciones_IVA
        cursor.execute("""
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='Procurement' AND TABLE_NAME='Retenciones_IVA' AND COLUMN_NAME='NroNotaDebito')
            ALTER TABLE [Procurement].[Retenciones_IVA] ADD [NroNotaDebito] VARCHAR(20) NULL;
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='Procurement' AND TABLE_NAME='Retenciones_IVA' AND COLUMN_NAME='NroNotaCredito')
            ALTER TABLE [Procurement].[Retenciones_IVA] ADD [NroNotaCredito] VARCHAR(20) NULL;
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='Procurement' AND TABLE_NAME='Retenciones_IVA' AND COLUMN_NAME='FacturaAfectada')
            ALTER TABLE [Procurement].[Retenciones_IVA] ADD [FacturaAfectada] VARCHAR(50) NULL;
        """)
        
        # 4b. Add TipoAbono column to CxP_Abonos
        cursor.execute("""
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='CxP_Abonos' AND COLUMN_NAME='TipoAbono')
            ALTER TABLE [dbo].[CxP_Abonos] ADD [TipoAbono] VARCHAR(20) NOT NULL CONSTRAINT DF_CxP_TipoAbono DEFAULT 'PAGO';
        """)
        
        # 5. CreditNotesTracking
        print("Creating table CreditNotesTracking...")
        cursor.execute("""
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Procurement].[CreditNotesTracking]') AND type in (N'U'))
        BEGIN
            CREATE TABLE [Procurement].[CreditNotesTracking] (
                [Id] INT IDENTITY(1,1) PRIMARY KEY,
                [CodProv] VARCHAR(50) NOT NULL,
                [NumeroD] VARCHAR(50) NOT NULL,
                [NotaCreditoID] VARCHAR(50),
                [Motivo] VARCHAR(20) NOT NULL,
                [MontoBs] DECIMAL(18,2) NOT NULL,
                [TasaCambio] DECIMAL(18,4),
                [MontoUsd] DECIMAL(18,2),
                [Estatus] VARCHAR(30) DEFAULT 'PENDIENTE',
                [FechaSolicitud] DATETIME DEFAULT GETDATE(),
                [FechaEmision] DATETIME,
                [Observacion] VARCHAR(200)
            );
        END
        """)
        
        conn.commit()
        print("Tables created and migrations applied successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    create_tables()
