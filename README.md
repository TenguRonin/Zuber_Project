# Proyecto SQL – Zuber (Análisis de viajes en taxi en Chicago)

## Descripción del proyecto
Zuber es una nueva empresa de viajes compartidos que se está lanzando en Chicago.  
El objetivo de este proyecto es analizar datos históricos de viajes en taxi para identificar patrones de uso, evaluar el desempeño de las compañías competidoras y analizar el impacto de factores externos —especialmente el clima— en la duración de los viajes.

Este proyecto forma parte del **curso de SQL** y combina análisis en **SQL** y **Python**, incluyendo una prueba de hipótesis estadística.

---

## Objetivos
- Analizar la actividad de viajes por empresa de taxis.
- Identificar las compañías más populares en distintos periodos.
- Evaluar el comportamiento de los viajes según las condiciones climáticas.
- Probar estadísticamente si el clima afecta la duración de los viajes.
- Visualizar resultados y extraer conclusiones basadas en datos.

---

## Datos utilizados

### Base de datos (SQL)
La base de datos contiene información sobre viajes en taxi en Chicago:

**Tabla `neighborhoods`**
- `neighborhood_id`: identificador del barrio
- `name`: nombre del barrio

**Tabla `cabs`**
- `cab_id`: identificador del taxi
- `vehicle_id`: identificador técnico del vehículo
- `company_name`: empresa propietaria del taxi

**Tabla `trips`**
- `trip_id`: identificador del viaje
- `cab_id`: identificador del taxi
- `start_ts`: fecha y hora de inicio del viaje (redondeada a la hora)
- `end_ts`: fecha y hora de fin del viaje (redondeada a la hora)
- `duration_seconds`: duración del viaje en segundos
- `distance_miles`: distancia recorrida
- `pickup_location_id`: barrio de inicio
- `dropoff_location_id`: barrio de destino

**Tabla `weather_records`**
- `record_id`: identificador del registro climático
- `ts`: fecha y hora del registro (redondeada a la hora)
- `temperature`: temperatura
- `description`: descripción de las condiciones climáticas

> Nota: las tablas `trips` y `weather_records` se relacionan mediante la hora (`start_ts = ts`).

---

## Análisis realizado

### Paso 1. Análisis del clima (Python)
- Se extrajeron datos del clima de Chicago para **noviembre de 2017** desde un sitio web.
- Se creó el DataFrame `weather_records`.
- Los datos se guardaron en un archivo CSV para su uso posterior.

---

### Paso 2. Análisis exploratorio en SQL
Se realizaron las siguientes consultas:

1. Número de viajes por empresa de taxis del **15 al 16 de noviembre de 2017**.
2. Cantidad de viajes por empresa cuyo nombre contiene **"Yellow"** o **"Blue"** del **1 al 7 de noviembre de 2017**.
3. Comparación entre **Flash Cab**, **Taxi Affiliation Services** y el grupo **Other** (resto de empresas) durante el mismo periodo.

---

### Paso 3. Prueba de hipótesis en SQL
- Se identificaron los barrios **Loop** y **O’Hare**.
- Se clasificaron las condiciones climáticas en:
  - **Bad**: lluvia o tormenta
  - **Good**: resto de condiciones
- Se recuperaron viajes:
  - Iniciados en Loop
  - Finalizados en O’Hare
  - Realizados en sábado
- Se obtuvo la duración de cada viaje junto con las condiciones climáticas.

---

### Paso 4. Análisis exploratorio en Python
Se trabajó con los siguientes archivos:

- `project_sql_result_01.csv`: viajes por empresa
- `project_sql_result_04.csv`: promedio de viajes por barrio

Acciones realizadas:
- Importación y revisión de datos
- Verificación de tipos de datos y valores nulos
- Identificación del **Top 10 de barrios** por número promedio de finalizaciones
- Visualización de:
  - Empresas de taxis vs número de viajes
  - Barrios con más viajes finalizados
- Análisis e interpretación de gráficos

---

### Paso 5. Prueba de hipótesis en Python
Archivo utilizado:
- `project_sql_result_07.csv`

**Hipótesis:**
- **H₀ (nula):** La duración promedio de los viajes desde Loop hasta O’Hare no cambia en sábados lluviosos.
- **H₁ (alternativa):** La duración promedio de los viajes desde Loop hasta O’Hare sí cambia en sábados lluviosos.

**Método:**
- Prueba t de Student para dos muestras independientes
- Nivel de significación: α = 0.05

**Resultados:**
- Estadístico t ≈ 7.19
- p-value < 0.001

**Conclusión:**
Se rechaza la hipótesis nula.  
Existe evidencia estadísticamente significativa de que el clima lluvioso afecta la duración de los viajes desde Loop hasta el Aeropuerto Internacional O’Hare los sábados.

---

## Tecnologías utilizadas
- SQL
- Python (pandas, matplotlib, scipy)
- Jupyter Notebook

---

