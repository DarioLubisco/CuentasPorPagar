import os
import pyodbc
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

DB_SERVER = os.getenv("DB_SERVER")
DB_DATABASE = "EnterpriseAdmin_AMC"
DB_USERNAME = "sa"
DB_PASSWORD = os.getenv("SA_PASSWORD", "Twinc3pt.")
DRIVER = os.getenv("DRIVER", "{ODBC Driver 17 for SQL Server}")

def get_db_connection():
    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_DATABASE};"
        f"UID={DB_USERNAME};"
        f"PWD={DB_PASSWORD}"
    )
    return pyodbc.connect(conn_str)

def process_mass_payments(target_date="2026-01-31", dry_run=True):
    print(f"Starting Mass Payment Process for records on or before {target_date}")
    print(f"DRY RUN: {'YES (No changes will be saved)' if dry_run else 'NO (Executing changes)'}")
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Step 1: Find all pending accounts payable (Facturas: TipoCxP = '10') before the target date
        query_invoices = """
            SELECT NroUnico, CodProv, NumeroD, Saldo, FechaE, MtoTax
            FROM SAACXP
            WHERE Saldo > 0 
              AND FechaE <= ?
              AND TipoCxP = '10' -- Facturas
            ORDER BY CodProv, FechaE
        """
        cursor.execute(query_invoices, (target_date,))
        invoices = cursor.fetchall()
        
        if not invoices:
            print("No pending invoices found before that date.")
            return

        # Group invoices by Provider
        providers = {}
        for inv in invoices:
            if inv.CodProv not in providers:
                providers[inv.CodProv] = []
            providers[inv.CodProv].append(inv)
            
        print(f"Found {len(invoices)} pending invoices across {len(providers)} providers.")
        
        # Step 2: Iterate through each provider and build the mass transaction
        total_processed_amount = 0
        
        for cod_prov, prov_invoices in providers.items():
            total_saldo = sum([inv.Saldo for inv in prov_invoices])
            total_tax = sum([inv.MtoTax for inv in prov_invoices]) # Simplified tax sum, adjust if needed
            total_processed_amount += total_saldo
            
            print(f"Processing Provider: {cod_prov} | Invoices: {len(prov_invoices)} | Total: {total_saldo:,.2f}")
            
            if not dry_run:
                # Build the dynamic SQL batch for this provider
                batch_sql = f"""
                SET NOCOUNT ON;
                DECLARE @ErrMsg nvarchar(4000);
                DECLARE @NROUNICODOC INT = 0;
                DECLARE @AFECTED INT = 0;
                DECLARE @NUMERRORS INT = 0;
                
                BEGIN TRY
                    -- Insert Parent Payment Record
                    INSERT INTO SAACXP (
                        [TipoCxP], [CodProv], [FromTran], [CodUsua], [CodEsta], [CodSucu], 
                        [NumeroD], [CodOper], [Document], [FechaT], [FechaI], [FechaE], 
                        [FechaV], [Monto], [MontoNeto], [EsReten], [MtoTax], [CancelT], 
                        [EsUnPago], [Descrip], [ID3]
                    ) VALUES (
                        '41', '{cod_prov}', 1, 'PYTHON', 'AUTOMATION', '00000', 
                        'MASIVO', 'CXP', 'masivo', GETDATE(), GETDATE(), GETDATE(), 
                        GETDATE(), {total_saldo}, {total_saldo}, 1, {total_tax}, {total_saldo}, 
                        1, 'PAGO MASIVO AUTOMATIZADO', '{cod_prov}'
                    );
                    
                    SET @NROUNICODOC = IDENT_CURRENT('SAACXP');
                """
                
                # Add the chunks for each individual invoice
                for i, inv in enumerate(prov_invoices):
                    descrip = f"PAGO FACTURA NRO. {inv.NumeroD}"
                    # Format date safely for SQL
                    safe_date = inv.FechaE.strftime('%Y-%m-%d %H:%M:%S') if hasattr(inv.FechaE, 'strftime') else inv.FechaE
                    
                    batch_sql += f"""
                    IF ISNULL((SELECT Saldo FROM SAACXP WITH (NOLOCK) WHERE NroUnico={inv.NroUnico}),0) - {inv.Saldo} <= 0.009
                    BEGIN
                        UPDATE SAACXP SET [Saldo] = [Saldo] - {inv.Saldo} WHERE (NroUnico={inv.NroUnico});
                        
                        IF @AFECTED = 0 BEGIN
                            UPDATE SAACXP SET NumeroN = ISNULL((SELECT NumeroD FROM SAACXP WITH (NOLOCK) WHERE NroUnico={inv.NroUnico}),'')
                            WHERE NroUnico = @NROUNICODOC;
                            SET @AFECTED = 1;
                        END;
                    END
                    ELSE BEGIN
                        SET @NUMERRORS = @NUMERRORS + 2000;
                    END;
                    
                    INSERT INTO SAPAGCXP (
                        [CodSucu], [NroPpal], [NroRegi], [CodProv], [TipoCxP], 
                        [MontoDocA], [Monto], [NumeroD], [CodOper], [Descrip], [FechaE], [FechaO]
                    ) VALUES (
                        '00000', @NROUNICODOC, {inv.NroUnico}, '{cod_prov}', '10', 
                        {inv.Saldo}, {inv.Saldo}, '{inv.NumeroD}', 'CXP', '{descrip}', GETDATE(), '{safe_date}'
                    );
                    """
                
                batch_sql += """
                    IF @NUMERRORS > 0 BEGIN
                        RAISERROR('Saldo checking failed for one or more invoices.', 16, 1);
                    END;
                END TRY
                BEGIN CATCH
                    SELECT ERROR_MESSAGE() AS ErrorMsg;
                    THROW;
                END CATCH;
                """
                
                # Execute the big batch for this specific provider (no parameterized tuples to avoid pyodbc driver limits)
                cursor.execute(batch_sql)
        
        print("-" * 50)
        print(f"Total Amount Processed: {total_processed_amount:,.2f}")
                
        if not dry_run:
            print("Committing transaction...")
            conn.commit()
            print("SUCCESS! Changes saved to the database.")
        else:
            print("Transaction rolled back (Dry Run active). Set dry_run=False to save.")
            
    except Exception as e:
        print("\nERROR occurred!")
        print(str(e))
        if not dry_run:
            print("Rolling back transaction to protect data integrity.")
            conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    # CAUTION: Set dry_run to False to actually execute the payments!
    process_mass_payments(target_date="2026-01-31", dry_run=False)
