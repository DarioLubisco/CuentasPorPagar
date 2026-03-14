import urllib.request
import json
import traceback

try:
    url = 'http://localhost:8080/api/cuentas-por-pagar?search=00116917'
    req = urllib.request.Request(url)
    response = urllib.request.urlopen(req)
    data = json.loads(response.read().decode('utf-8'))['data']
    print("Results for search=00116917:")
    for i in data:
        if i['NumeroD'] == '00116917':
            print(f"  NumeroD: {i['NumeroD']}")
            print(f"  Monto: {i['Monto']}")
            print(f"  TotalBsAbonado: {i['TotalBsAbonado']}")
            print(f"  Has_Abonos: {i['Has_Abonos']}")
            
    url2 = 'http://localhost:8080/api/cuentas-por-pagar?search=0513686'
    req2 = urllib.request.Request(url2)
    response2 = urllib.request.urlopen(req2)
    data2 = json.loads(response2.read().decode('utf-8'))['data']
    print("\nResults for search=0513686:")
    for i in data2:
        if i['NumeroD'] == '0513686':
            print(f"  NumeroD: {i['NumeroD']}")
            print(f"  Monto: {i['Monto']}")
            print(f"  TotalBsAbonado: {i['TotalBsAbonado']}")
            print(f"  Has_Abonos: {i['Has_Abonos']}")
            
except Exception as e:
    traceback.print_exc()
