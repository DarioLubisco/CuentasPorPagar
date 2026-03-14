import requests

def test_apis():
    base_url = "http://localhost:8080/api/reports"
    endpoints = ["/compras", "/aging", "/cashflow", "/dpo"]
    
    for endp in endpoints:
        try:
            res = requests.get(f"{base_url}{endp}")
            print(f"--- {endp} ---")
            print(f"Status: {res.status_code}")
            if res.status_code != 200:
                print(res.text)
            else:
                data = res.json().get('data', [])
                print(f"Returned {len(data)} rows")
                if len(data) > 0:
                    print("Sample:", data[0])
        except Exception as e:
            print(f"Error calling {endp}: {e}")

if __name__ == "__main__":
    test_apis()
