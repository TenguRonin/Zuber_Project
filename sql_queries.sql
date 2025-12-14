/* =========================================================
   PROYECTO SQL – ZUBER (Chicago Taxi Analysis)
   Objetivo:
   Analizar patrones de viajes en taxi y evaluar el impacto
   del clima en la duración de los viajes Loop → O'Hare.
   ========================================================= */


/* =========================================================
   PASO 1. ANÁLISIS DEL CLIMA (WEB → DATAFRAME → CSV)
   ========================================================= */

# Se importan las librerías necesarias para el análisis
import os
import pandas as pd

# URL oficial proporcionada por la plataforma con los datos del clima
URL = "https://practicum-content.s3.us-west-1.amazonaws.com/data-analyst-eng/moved_chicago_weather_2017.html"

# 1) Leer la tabla HTML con id="weather_records"
# Se especifica el atributo id para asegurar que se extrae
# exactamente la tabla requerida por el proyecto
weather_records = pd.read_html(URL, attrs={"id": "weather_records"})[0]

# 2) Imprimir el DataFrame completo
# Se muestra todo el contenido para verificar que la carga fue exitosa
with pd.option_context("display.max_rows", None, "display.max_columns", None, "display.width", 0):
    print(weather_records)

# 3) Limpieza y estandarización de los datos
# Se trabaja sobre una copia para preservar el DataFrame original
df = weather_records.copy()

# Normalización de nombres de columnas (minúsculas, sin espacios)
df.columns = [c.strip().lower() for c in df.columns]

# Mapeo de posibles nombres alternativos a los nombres estándar requeridos
mapping = {
    "ts": "ts", "date and time": "ts", "date & time": "ts", "date_time": "ts",
    "datetime": "ts", "date": "ts", "time": "ts", "timestamp": "ts",
    "temperature": "temperature", "temp": "temperature", "temp_f": "temperature", "temp_c": "temperature",
    "description": "description", "weather": "description", "conditions": "description",
}
df.columns = [mapping.get(c, c) for c in df.columns]

# Verificación defensiva: si falta alguna columna requerida, se detiene el proceso
required = ["ts", "temperature", "description"]
missing = [c for c in required if c not in df.columns]
if missing:
    raise ValueError(
        f"No se encontraron columnas requeridas: {missing}. "
        f"Columnas actuales: {df.columns.tolist()}"
    )

# Selección final de columnas relevantes
df = df[required].copy()

# Conversión de tipos de datos
# - ts a datetime para permitir filtrado por fechas
# - temperature a numérico
# - description a texto limpio en minúsculas
df["ts"] = pd.to_datetime(df["ts"])
df["temperature"] = pd.to_numeric(df["temperature"], errors="coerce")
df["description"] = df["description"].astype(str).str.strip().str.lower()

# Filtrado de registros correspondientes únicamente a noviembre de 2017
mask = (df["ts"] >= "2017-11-01") & (df["ts"] < "2017-12-01")
weather_nov_2017 = df.loc[mask].sort_values("ts").reset_index(drop=True)

# 4) Guardado del archivo CSV
# Se asegura la existencia de la carpeta /data para evitar errores
out_dir = "data"
os.makedirs(out_dir, exist_ok=True)

out_path = os.path.join(out_dir, "weather_nov_2017.csv")
weather_nov_2017.to_csv(out_path, index=False)

print(f"Archivo guardado: {out_path} | Filas: {len(weather_nov_2017)}")

/* Conclusión Paso 1:
   Los datos meteorológicos de Chicago para noviembre de 2017
   fueron extraídos correctamente desde la web, limpiados,
   estandarizados y almacenados en un CSV listo para análisis
   y para su vinculación con los viajes.
*/


/* =========================================================
   PASO 2. ANÁLISIS EXPLORATORIO DE DATOS (SQL)
   ========================================================= */

-- 2.1 Número de viajes por empresa (15–16 de noviembre de 2017)
-- Se cuentan los viajes por compañía y se ordenan de mayor a menor
SELECT
  c.company_name,
  COUNT(*) AS trips_amount
FROM trips AS t
JOIN cabs  AS c ON c.cab_id = t.cab_id
WHERE DATE(t.start_ts) IN ('2017-11-15','2017-11-16')
GROUP BY c.company_name
ORDER BY trips_amount DESC;


-- 2.2 Viajes de empresas cuyo nombre contiene "Yellow" o "Blue"
-- Periodo: 1–7 de noviembre de 2017
-- Se usa LOWER + LIKE para evitar problemas de mayúsculas/minúsculas
SELECT
  c.company_name,
  COUNT(*) AS trips_amount
FROM trips AS t
JOIN cabs  AS c ON c.cab_id = t.cab_id
WHERE DATE(t.start_ts) BETWEEN '2017-11-01' AND '2017-11-07'
  AND (
    LOWER(c.company_name) LIKE '%yellow%' OR
    LOWER(c.company_name) LIKE '%blue%'
  )
GROUP BY c.company_name
ORDER BY c.company_name;


-- 2.3 Comparación: Flash Cab vs Taxi Affiliation Services vs Other
-- Se agrupan todas las demás compañías bajo la categoría "Other"
SELECT
  CASE
    WHEN c.company_name = 'Flash Cab' THEN 'Flash Cab'
    WHEN c.company_name = 'Taxi Affiliation Services' THEN 'Taxi Affiliation Services'
    ELSE 'Other'
  END AS company,
  COUNT(*) AS trips_amount
FROM trips AS t
JOIN cabs  AS c ON c.cab_id = t.cab_id
WHERE DATE(t.start_ts) BETWEEN '2017-11-01' AND '2017-11-07'
GROUP BY company
ORDER BY trips_amount DESC;


/* =========================================================
   PASO 3. PRUEBA DE HIPÓTESIS: IMPACTO DEL CLIMA
   ========================================================= */

-- 3.1 Identificadores de barrios: Loop y O'Hare
-- O'Hare se escribe como O''Hare para escapar el apóstrofe
SELECT
  n.name,
  n.neighborhood_id
FROM neighborhoods AS n
WHERE TRIM(n.name) IN ('O''Hare', 'Loop')
ORDER BY n.name;


-- 3.2 Clasificación de condiciones meteorológicas por hora
-- "Bad" si hay lluvia o tormenta, "Good" en caso contrario
SELECT
  wr.ts,
  CASE
    WHEN LOWER(wr.description) LIKE '%rain%'
      OR LOWER(wr.description) LIKE '%storm%'
    THEN 'Bad'
    ELSE 'Good'
  END AS weather_conditions
FROM weather_records AS wr
ORDER BY wr.ts;


-- 3.3 Viajes Loop → O'Hare en sábado con duración y clima
-- Se unen viajes y clima por hora exacta
-- Se ignoran automáticamente viajes sin datos climáticos
SELECT
  t.start_ts,
  CASE
    WHEN LOWER(w.description) LIKE '%rain%'
      OR LOWER(w.description) LIKE '%storm%'
    THEN 'Bad'
    ELSE 'Good'
  END AS weather_conditions,
  t.duration_seconds
FROM trips AS t
JOIN weather_records AS w
  ON t.start_ts = w.ts
WHERE
  t.pickup_location_id = 50   -- Loop
  AND t.dropoff_location_id = 63  -- O'Hare
  AND EXTRACT(DOW FROM t.start_ts) = 6  -- Sábado
ORDER BY t.trip_id;


/* Conclusión Paso 3:
   Se construyó el dataset final que relaciona duración del viaje
   y condiciones climáticas para viajes Loop → O'Hare en sábados,
   permitiendo posteriormente realizar la prueba estadística
   de hipótesis en Python.
*/


