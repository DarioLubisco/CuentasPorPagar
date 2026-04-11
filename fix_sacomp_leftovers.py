import database

def fix_contado_leftovers():
    conn = database.get_db_connection()
    cursor = conn.cursor()
    
    invoices = [
        ('DROGUERIA NENA C.A.', '64741324'),
        ('DROGUERIA NENA C.A.', '64741325'),
        ('DROGUERIA VITALCLINIC', '0574050'),
        ('DROGUERIA VITALCLINIC', '0574051'),
        ('DROGUERIA NENA C.A.', '64778016'),
        ('CRIST MEDICALS C.A.', '00095592'),
        ('INVERSIONES TOTAL SERVIS 2015, C.A.', '00001664498'),
        ('CRIST MEDICALS C.A.', '00344967'),
        ('El Mastranto M & M c.a.', '00097428'),
        ('CRIST MEDICALS C.A.', '000974280'),
        ('CRIST MEDICALS C.A.', '0097428'),
        ('INSUAMINCA C.A.', 'B0337124'),
        ('DROGUERIA ZAKIPHARMA C.A.', '0193777'),
        ('DROGUERIA NENA C.A.', '64741326')
    ]
    
    total_repaired = 0
    for prov_fuzzy, num in invoices:
        cursor.execute("SELECT CodProv FROM EnterpriseAdmin_AMC.dbo.SAPROV WHERE Descrip LIKE ?", (f"%{prov_fuzzy[:15]}%",))
        row = cursor.fetchone()
        if row:
            cod_prov = row.CodProv
            # Only update SACOMP
            cursor.execute("""
                UPDATE EnterpriseAdmin_AMC.dbo.SACOMP 
                SET Contado = 0, Credito = MtoTotal, MtoPagos = 0
                WHERE NumeroD = ? AND CodProv = ? AND TipoCom = 'H'
            """, (num, cod_prov))
            
            total_repaired += 1
            print(f"Reparada data en SACOMP (Contado/Credito) para {num}")

    conn.commit()
    conn.close()
    print(f"Reparadas {total_repaired} facturas.")

if __name__ == '__main__':
    fix_contado_leftovers()
