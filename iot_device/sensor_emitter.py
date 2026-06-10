import requests
import time
import random

API_URL = "http://localhost:8000/lecturas/"

ESTACIONES_IDS = [1, 2, 3, 4]

# PEGA AQUÍ TU TOKEN JWT
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc4MTEwNTgzOH0.WI3_aeuW0Sj9HkirCEO2blLCvo2QTZ3MQXkzBYnemhQ"

def leer_sensor_emulado():
    
    return round(random.uniform(10.0, 85.0), 2)

def enviar_telemetria():
    print("--- Iniciando Emisor IoT Multi-Estación ---")
    print(f"Monitoreando estaciones con IDs: {ESTACIONES_IDS}\n")

    while True:
        hay_alerta_global = False

        for estacion_id in ESTACIONES_IDS:
            valor = leer_sensor_emulado()

            payload = {
                "valor": valor,
                "estacion_id": estacion_id
            }

            headers = {
                "Authorization": f"Bearer {TOKEN}"
            }

            try:
                response = requests.post(
                    API_URL,
                    json=payload,
                    headers=headers
                )

                if response.ok:
                    if valor > 70:
                        print(f"[ALERTA] Estación ID {estacion_id} -> ¡CRÍTICO! {valor} cm (Umbral superado)")
                        hay_alerta_global = True
                    else:
                        print(f"[OK] Estación ID {estacion_id} -> {valor} cm (Nivel normal)")

                else:
                    print(f"[ERROR] Estación ID {estacion_id} -> Código HTTP: {response.status_code}")
                    print(response.text)

            except Exception as e:
                print(f"[CRÍTICO] Estación ID {estacion_id} -> Sin conexión con el servidor: {e}")

        print("-" * 50)

        if hay_alerta_global:
            print("[MODO EMERGENCIA] Hay alertas activas. Próxima ronda en 3 segundos...\n")
            time.sleep(3)
        else:
            print("[SISTEMA ESTABLE] Próxima ronda de telemetría en 10 segundos...\n")
            time.sleep(10)

if __name__ == "__main__":
    enviar_telemetria()