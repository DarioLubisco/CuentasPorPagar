import requests

r = requests.get('http://localhost:8080/api/procurement/cxp-status?cod_prov=INSUAMED&numero_d=B0119408')
print("Status code:", r.status_code)
print("Response text:", r.text)

r2 = requests.get('http://localhost:8080/api/procurement/cxp-status?cod_prov=INSUAM&numero_d=B0119408')
print("Status code:", r2.status_code)
print("Response text:", r2.text)
