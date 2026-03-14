import urllib.request
import json

try:
    req = urllib.request.Request('http://localhost:8000/api/cuentas-por-pagar?cod_prov=15064619&status_base=todos_activos')
    response = urllib.request.urlopen(req)
    data = json.loads(response.read().decode('utf-8'))['data']
    invs = [i for i in data if i['NumeroD'] in ['00116917', '0513686']]
    for i in invs:
        print(f"NumeroD: {i['NumeroD']}, Monto: {i['Monto']}, TotalBsAbonado: {i['TotalBsAbonado']}, Saldo: {i['Saldo']}")
except Exception as e:
    print(e)
