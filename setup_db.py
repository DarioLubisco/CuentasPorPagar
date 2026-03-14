import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

def get_sa_connection():
    DB_SERVER = os.getenv("DB_SERVER")
    DB_DATABASE = "EnterpriseAdmin_AMC"
    DB_USERNAME = "sa"
    DB_PASSWORD = os.getenv("SA_PASSWORD", "Twinc3pt.")
    DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    return pyodbc.connect(conn_str)

def setup_db():
    conn = get_sa_connection()
    cursor = conn.cursor()
    
    try:
        print("Creating table EnterpriseAdmin_AMC.Procurement.PagosPlanificados...")
        
        # We assume the Procurement schema already exists based on earlier queries (Procurement.Rotacion).
        # We create the table to store planned payments linked to SAACXP.NroUnico
        ddl = """
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Procurement].[PagosPlanificados]') AND type in (N'U'))
        BEGIN
            CREATE TABLE [Procurement].[PagosPlanificados](
                [ID] [int] IDENTITY(1,1) NOT NULL,
                [NroUnico] [int] NOT NULL,
                [FechaPlanificada] [datetime] NOT NULL,
                [Banco] [varchar](100) NOT NULL,
                [CodUsua] [varchar](50) NULL,
                [FechaRegistro] [datetime] NOT NULL DEFAULT (GETDATE()),
                CONSTRAINT [PK_PagosPlanificados] PRIMARY KEY CLUSTERED 
                (
                    [ID] ASC
                )
            )
            
            -- Add an index on NroUnico for fast joins with SAACXP
            CREATE NONCLUSTERED INDEX [IX_PagosPlanificados_NroUnico] ON [Procurement].[PagosPlanificados]
            (
                [NroUnico] ASC
            )
            
            print 'Table created successfully'
        END
        ELSE
        BEGIN
            print 'Table already exists'
        END
        """
        
        cursor.execute(ddl)
        conn.commit()
        print("Setup complete.")
        
    except Exception as e:
        print(f"Error creating table: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    setup_db()
