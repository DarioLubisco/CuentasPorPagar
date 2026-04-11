import database
import pandas as pd

def run_query(query, params=None):
    conn = database.get_db_connection()
    try:
        df = pd.read_sql(query, conn, params=params)
        return df
    finally:
        conn.close()

invoice = '00092540'
print(f"--- Deep Investigation for Invoice: {invoice} ---")

print("\n[TARGET RECORDS]")
query = "SELECT NroUnico, TipoCxP, Monto, Saldo, CancelC, NroRegi FROM dbo.SAACXP WHERE NroUnico IN (62815, 62816)"
df_cxp = run_query(query)
print(df_cxp)

print("\n[SACOMP]")
df_comp = run_query("SELECT NumeroD, CodProv, MtoTotal, SaldoAct, MtoPagos, FechaI, FechaE FROM dbo.SACOMP WHERE NumeroD = ?", [invoice])
print(df_comp)

print("\n[CxP_Abonos]")
df_abonos = run_query("SELECT AbonoID, TipoAbono, MontoBsAbonado, TasaCambioDiaAbono, MontoUsdAbonado, AplicaIndexacion FROM EnterpriseAdmin_AMC.dbo.CxP_Abonos WHERE NumeroD = ?", [invoice])
print(df_abonos)
