import requests

r = requests.get('http://localhost:8080/api/procurement/cxp-status?cod_prov=J-412413740&numero_d=B0119408')
print("Status code:", r.status_code)
print("Response text:", r.text[:200])
