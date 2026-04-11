import database

def check():
    c = database.get_db_connection().cursor()
    c.execute("SELECT CodProv, DiasDesde, DiasHasta, Porcentaje, DeduceIVA FROM EnterpriseAdmin_AMC.Procurement.ProveedorDescuentosProntoPago WHERE CodProv='V023190479'")
    print("ProntoPago: ", c.fetchall())
    c.execute("SELECT DescuentoBase_DeduceIVA FROM EnterpriseAdmin_AMC.Procurement.ProveedorCondiciones WHERE CodProv='V023190479'")
    print("Base: ", c.fetchall())

if __name__ == '__main__':
    check()
