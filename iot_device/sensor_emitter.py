import requests
import time
import random

# ============================================
# CONFIGURACIÓN
# ============================================

API_URL = "http://localhost:8000/lecturas/"

# IDs de todas las estaciones que tienes en Flutter
ESTACIONES_IDS = [1, 2, 3, 4]

# PEGA AQUÍ TU TOKEN JWT
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc3OTkwMjUzMH0.zUEdzVqAvxudKc6Lc6C7nCdVhIMbavpnukVZx6qk4nA"

# ============================================
# SENSOR EMULADO
# ============================================

def leer_sensor_emulado():
    # Simula nivel de río entre 10 y 85 cm
    return round(random.uniform(10.0, 85.0), 2)

# ============================================
# ENVÍO DE TELEMETRÍA MULTI-ESTACIÓN
# ============================================

def enviar_telemetria():
    print("--- Iniciando Emisor IoT Multi-Estación ---")
    print(f"Monitoreando estaciones con IDs: {ESTACIONES_IDS}\n")

    while True:
        hay_alerta_global = False

        # Recorremos cada estación para enviarle su propia lectura simulada
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

                # ====================================
                # ENVÍO EXITOSO
                # ====================================
                if response.ok:
                    if valor > 70:
                        print(f"[ALERTA] Estación ID {estacion_id} -> ¡CRÍTICO! {valor} cm (Umbral superado)")
                        hay_alerta_global = True
                    else:
                        print(f"[OK] Estación ID {estacion_id} -> {valor} cm (Nivel normal)")

                # ====================================
                # ERROR HTTP
                # ====================================
                else:
                    print(f"[ERROR] Estación ID {estacion_id} -> Código HTTP: {response.status_code}")
                    print(response.text)

            # ====================================
            # ERROR DE CONEXIÓN
            # ====================================
            except Exception as e:
                print(f"[CRÍTICO] Estación ID {estacion_id} -> Sin conexión con el servidor: {e}")

        print("-" * 50)
        
        # Si alguna estación está en alerta, el sistema acelera el envío global
        if hay_alerta_global:
            print("[MODO EMERGENCIA] Hay alertas activas. Próxima ronda en 3 segundos...\n")
            time.sleep(3)
        else:
            print("[SISTEMA ESTABLE] Próxima ronda de telemetría en 10 segundos...\n")
            time.sleep(10)

# ============================================
# MAIN
# ============================================

if __name__ == "__main__":
    enviar_telemetria()