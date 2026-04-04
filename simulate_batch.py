import traceback
import sys

def simulate_batch():
    try:
        import main
        from fastapi.testclient import TestClient
        client = TestClient(main.app)
        
        payload = {
            "NotificarCorreo": False,
            "MontoTotalPagado": 1000,
            "force_send": False,
            "pagos": [
                {
                    "NumeroD": "64700083",
                    "CodProv": "J- 08518977-7",
                    "FechaAbono": "2026-03-30",
                    "MontoBsAbonado": 100,
                    "TasaCambioDiaAbono": 471.0,
                    "MontoUsdAbonado": 0.2,
                    "AplicaIndexacion": False,
                    "Referencia": "test"
                },
                {
                    "NumeroD": "00002183",
                    "CodProv": "J-500921918",
                    "FechaAbono": "2026-03-30",
                    "MontoBsAbonado": 100,
                    "TasaCambioDiaAbono": 471.0,
                    "MontoUsdAbonado": 0.2,
                    "AplicaIndexacion": False,
                    "Referencia": "test"
                }
            ]
        }
        
        # We need to send it as form-data since the endpoint is Form or File!
        # Wait, registrar_abonos_batch is defined as Form and File!
        # Let's check main.py definition!
        
    except Exception as e:
        traceback.print_exc()

simulate_batch()
