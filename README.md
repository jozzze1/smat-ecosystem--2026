# SMAT - Sistema de Monitoreo de Alerta Temprana

API desarrollada con **FastAPI** para la gestión y monitoreo de desastres naturales mediante sensores en tiempo real.
Permite registrar estaciones, capturar lecturas y analizar niveles de riesgo.

---

## Características

* Registro de estaciones de monitoreo
* Captura de lecturas de sensores
* Validación de integridad de datos (estaciones existentes)
* Autenticación con JWT
* Estadísticas globales
* Reportes históricos por estación
* Configuración CORS habilitada

---

## Tecnologías utilizadas

* Python
* FastAPI
* SQLAlchemy
* JWT
* Uvicorn

---

## Estructura del proyecto

```
.
├── main.py
├── models.py
├── schemas.py
├── crud.py
├── database.py
└── auth.py
```

---

## Instalación y ejecución

1. Crear entorno virtual:

```bash
python -m venv venv
source venv/bin/activate
```

2. Instalar dependencias:

```bash
pip install fastapi uvicorn sqlalchemy
```

3. Ejecutar el servidor:

```bash
uvicorn main:app --reload
```

---

## Autenticación

### Obtener token

**POST /token**

Respuesta:

```json
{
  "access_token": "TOKEN",
  "token_type": "bearer"
}
```

Usar en headers:

```
Authorization: Bearer TOKEN
```

---

## Endpoints principales

### 🔹 Seguridad

* `POST /token` → Genera token JWT

### 🔹 Gestión de Infraestructura

* `POST /estaciones/` → Crear estación

### 🔹 Telemetría de Sensores

* `POST /lecturas/` → Registrar lectura

  * ✔ Verifica que la estación exista

### 🔹 Auditoría

* `GET /estaciones/stats` → Estadísticas globales

### 🔹 Reportes

* `GET /estaciones/{id}/historial` → Historial de lecturas

---

## Ejemplo de uso

```bash
curl -X POST http://127.0.0.1:8000/token
```

---

## Documentación interactiva

Una vez ejecutado el servidor, puedes acceder a:

* Swagger UI:
   http://127.0.0.1:8000/docs

---

## Autor

* Jose Pacara
* Universidad Nacional Mayor de San Marcos (UNMSM)

---

## Licencia

UNMSM 2.0
