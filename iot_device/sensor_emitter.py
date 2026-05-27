import requests
import time
import random

# ============================================
# CONFIGURACIÓN
# ============================================

API_URL = "http://localhost:8000/lecturas/"

ESTACION_ID = 1

# PEGA AQUÍ TU TOKEN JWT
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc3OTg5NzI3Nn0.3mxLcSZRiGCdgXEJDoitoj74Dgs1WpsVgq_NtDr2Mu0"

# ============================================
# SENSOR EMULADO
# ============================================

def leer_sensor_emulado():

    # Simula nivel de río entre 10 y 85 cm
    return round(random.uniform(10.0, 85.0), 2)

# ============================================
# ENVÍO DE TELEMETRÍA
# ============================================

def enviar_telemetria():

    print(f"--- Iniciando Emisor IoT para Estación {ESTACION_ID} ---")

    while True:

        valor = leer_sensor_emulado()

        payload = {
            "valor": valor,
            "estacion_id": ESTACION_ID
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

                print(f"[OK] Lectura enviada: {valor} cm")

                # ====================================
                # ALERTA DE INUNDACIÓN
                # ====================================

                if valor > 70:

                    print("[ALERTA] Umbral de inundación superado")

                    print("[MODO EMERGENCIA] Enviando cada 2 segundos")

                    time.sleep(2)

                else:

                    print("[NORMAL] Enviando cada 10 segundos")

                    time.sleep(10)

            # ====================================
            # ERROR HTTP
            # ====================================

            else:

                print(f"[ERROR] Código HTTP: {response.status_code}")

                print(response.text)

                time.sleep(5)

        # ====================================
        # ERROR DE CONEXIÓN
        # ====================================

        except Exception as e:

            print(f"[CRÍTICO] No hay conexión con el servidor: {e}")

            time.sleep(5)

# ============================================
# MAIN
# ============================================

if __name__ == "__main__":

    enviar_telemetria()