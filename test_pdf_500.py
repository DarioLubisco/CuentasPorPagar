import database
from fastapi import HTTPException
from main import generar_pdf_retencion
import traceback

try:
    conn = database.get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT CodProv FROM EnterpriseAdmin_AMC.Procurement.Retenciones_IVA WHERE NumeroD = '00152218'")
    row = cursor.fetchone()
    print('CodProv found:', row[0] if row else 'None')
    cod_prov = row[0] if row else 'J-31121175-9'

    cursor.execute("SELECT NumeroComprobante FROM EnterpriseAdmin_AMC.Procurement.Retenciones_IVA WHERE NumeroD = ? AND CodProv = ? AND Estado <> 'ANULADO'", ('00152218', cod_prov))
    row = cursor.fetchone()
    if not row:
        print("No comprobante found!")
    else:
        nro_comp = row[0]
        cursor.execute("""
            SELECT r.*, p.Descrip as ProveedorNombre
            FROM EnterpriseAdmin_AMC.Procurement.Retenciones_IVA r
            LEFT JOIN EnterpriseAdmin_AMC.dbo.SAPROV p ON r.CodProv = p.CodProv
            WHERE r.NumeroComprobante = ? AND r.Estado <> 'ANULADO'
        """, (nro_comp,))
        rows = cursor.fetchall()
        cols = [column[0] for column in cursor.description]
        ret_list = [dict(zip(cols, row)) for row in rows]
        
        cursor.execute("SELECT RIF_Agente, RazonSocial_Agente, DireccionFiscal_Agente, ValorUT, UltimoSecuencial FROM EnterpriseAdmin_AMC.Procurement.Retenciones_Config WHERE Id = 1")
        cfg_row = cursor.fetchone()
        config = dict(zip([c[0] for c in cursor.description], cfg_row)) if cfg_row else {}
        
        pdf = generar_pdf_retencion(config, ret_list)
        print('PDF Length:', len(pdf))
except Exception as e:
    traceback.print_exc()
