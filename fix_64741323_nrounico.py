import database

conn = database.get_db_connection()
cursor = conn.cursor()

try:
    print("Fijando NroUnico manualmente...")
    cursor.execute("""
        DECLARE @MaxNro INT;
        SELECT @MaxNro = ISNULL(MAX(NroUnico), 0) + 1 FROM EnterpriseAdmin_AMC.dbo.SAACXP;
        
        UPDATE EnterpriseAdmin_AMC.dbo.SAACXP 
        SET NroUnico = @MaxNro
        WHERE NumeroD = '64741323' AND NroUnico = 0 AND TipoCxP = '10';
        
        SELECT NroUnico FROM EnterpriseAdmin_AMC.dbo.SAACXP WHERE NumeroD = '64741323';
    """)
    row = cursor.fetchone()
    print(f"Nuevo NroUnico asignado: {row[0] if row else 'Ninguno'}")
    conn.commit()
except Exception as e:
    print("Error:", e)
    conn.rollback()
finally:
    conn.close()
