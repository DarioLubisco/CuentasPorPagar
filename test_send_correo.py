"""Test: enviar correo de prueba para la factura 0170733 de Zakipharma"""
import sys
sys.path.insert(0, '.')

from main import enviar_correo_pago

pago_data = {
    "NumeroD": "0170733",
    "CodProv": "J-500976160",
    "FechaAbono": "2026-03-12",
    "MontoBsAbonado": 54282.18,
    "MontoUsdAbonado": 123.10,
    "TasaCambioDiaAbono": 440.96,
    "AplicaIndexacion": "Sí",
    "Referencia": "Venezuela 00854512"
}

print("Enviando correo de prueba a CreditoZakipharma08@gmail.com ...")
result = enviar_correo_pago(
    destinatario="CreditoZakipharma08@gmail.com",
    proveedor_nombre="DROGUERIA ZAKIPHARMA C.A.",
    nro_factura="0170733",
    pago_data=pago_data,
    filepath="static/uploads/caf6c8c4-81a4-4f18-8fb1-790d929c0ff9.pdf"
)

if result:
    print("✅ Correo enviado exitosamente!")
else:
    print("❌ Error al enviar correo. Revisa los logs arriba.")
