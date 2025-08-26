import requests
import json

# Token admin valide
token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU2MDQ3Njg3LCJpYXQiOjE3NTYwNDczODcsImp0aSI6IjdlNWYzYWFkYmU1NjQ3NzI5M2IzMWMwM2I4YzMzNDM4IiwidXNlcl9pZCI6MjJ9.AUVcVbPEt3kHvftkv4o0goDBGfnle8IuRJw1YKEAJoA"

print("🧪 Test de l'API admin/statistics/")
print("=" * 50)

url = "http://localhost:8000/api/admin/statistics/"

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

try:
    print(f"📡 Appel de l'API: {url}")
    print(f"🔑 Token: {token[:50]}...")
    
    response = requests.get(url, headers=headers)
    
    print(f"📊 Status Code: {response.status_code}")
    print(f"📄 Response: {response.text}")
    
    if response.status_code == 200:
        print("✅ API admin/statistics/ fonctionne!")
        data = response.json()
        print(f"📊 Données reçues: {json.dumps(data, indent=2)}")
    else:
        print("❌ Erreur API admin/statistics/")
        
except Exception as e:
    print(f"❌ Erreur: {e}")

print("\n🧪 Test de l'API admin/dashboard/")
print("=" * 50)

url2 = "http://localhost:8000/api/admin/dashboard/"

try:
    print(f"📡 Appel de l'API: {url2}")
    
    response2 = requests.get(url2, headers=headers)
    
    print(f"📊 Status Code: {response2.status_code}")
    print(f"📄 Response: {response2.text}")
    
    if response2.status_code == 200:
        print("✅ API admin/dashboard/ fonctionne!")
        data2 = response2.json()
        print(f"📊 Données reçues: {json.dumps(data2, indent=2)}")
    else:
        print("❌ Erreur API admin/dashboard/")
        
except Exception as e:
    print(f"❌ Erreur: {e}")
