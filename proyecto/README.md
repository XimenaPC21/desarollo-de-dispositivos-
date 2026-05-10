# ECG_SpineForce

Aplicación móvil desarrollada en Flutter para el monitoreo en tiempo real de la actividad eléctrica del corazón mediante un sensor ECG AD8232 conectado a un microcontrolador ESP32, comunicados a través de WiFi.

## Descripción de la app

La aplicación permite visualizar la señal ECG en tiempo real, calcular la frecuencia cardíaca (BPM) mediante detección de complejos QRS y emitir recomendaciones personalizadas de salud cardiovascular basadas en el perfil demográfico del usuario (edad, sexo, act. física).

La aplicación posee cuatro pantallas. Al inicializar la app se muestra el logo en la primera pantalla. En la segunda se solicitan datos demográficos como nombre, edad, sexo y nivel de actividad física. Posteriormente, en la tercer pantalla, establece la conexión con el ESP32 y despliega una gráfica en tiempo real de la señal ECG donde es posible visualizar el trazo cardíaco. La app calcula automáticamente la frecuencia cardíaca en latidos por minuto (BPM) mediante la detección de picos QRS y el análisis de los intervalos RR. Finalmente presenta una pantalla de resultados con el BPM promedio medido durante 15 segundos y emite una recomendación de seguimiento personalizada basada en el perfil demográfico del usuario.

## Integrantes

| Nombre | Matrícula | Contribución |
|--------|-----------|--------------|
| Ana Ximena Pozos Cárdenas | A01643646 | Pantalla de datos demográficos |
| José Luis González Lomas | A01643655 | Pantalla principal y modelo de datos |
| Luis Jorge Lizárraga Mardueño | A01643374 | Pantalla ECG con gráfica en tiempo real |
| Valeria Mata Silva | A01637731 | Pantalla de resultados y navegación |

## Conexiones ESP32 — AD8232

| AD8232 | ESP32 |
|--------|-------|
| 3.3V | 3.3V |
| GND | GND |
| OUTPUT | GPIO34 |
| LO+ | GPIO16 |
| LO- | GPIO17 |
| SDN | N/A |

## ¿Cómo funciona la aplicación?

El sistema integra hardware y software de forma completa:

1. El sensor AD8232 adquiere la señal eléctrica del corazón mediante 
   3 electrodos superficiales acomodados anatómicamente de acuerdo al 
   triángulo de Einthoven.
2. El ESP32 digitaliza la señal y la transmite por WiFi al celular mediante 
   un socket TCP en la IP y puerto.
3. La app Flutter recibe los datos, filtra valores y grafica en tiempo real una ventana     deslizante actualizada cada `3 muestras`.
4. Se detectan los picos QRS usando un umbral dinámico sobre un buffer de `200 muestras`, con un tiempo mínimo de `0.3 segundos` entre picos para evitar doble detección.
5. El BPM se calcula promediando los últimos `8 intervalos RR` válidos durante una medición de `15 segundos`.
6. Se genera una recomendación personalizada basada en el perfil 
   demográfico del usuario y su frecuencia cardíaca promedio medida.

## Flujo del código

### Conexión al ESP32
La app se conecta al ESP32 mediante un socket TCP a la IP del microcontrolador
en el puerto deseado, con un timeout de 10 segundos. Si la conexión se pierde, 
intenta reconectarse automáticamente después de 2 segundos.

### Recepción y filtrado de datos
Los datos llegan como strings separados por `\n`, se parsean a `double` 
y se descartan valores fuera del rango `100–3300 mV`. Cada muestra válida 
incrementa un contador de tiempo en `0.05` segundos (equivalente a 20 Hz 
de muestreo efectivo). La señal se almacena en un buffer de máximo 
`200 muestras`.

### Detección de complejos QRS
Con un mínimo de `20 muestras` en el buffer, se calcula un umbral dinámico:

umbral = min + (max - min) * 0.5

Se detecta un pico QRS cuando:
- La muestra actual supera el umbral
- Es mayor que las 2 muestras anteriores
- La diferencia con la muestra previa es mayor a `50 mV`
- Han pasado al menos `0.3 segundos` desde el último pico

### Cálculo de BPM
Se almacenan los últimos `8 intervalos RR`. Solo se aceptan intervalos 
menores a `2.0 segundos` (descartar arritmias extremas). El BPM se calcula 
con:

BPM = 60 / promedio_RR

Se requieren mínimo `2 intervalos RR` para comenzar a calcular.

### Gráfica en tiempo real
Se usa `fl_chart` con una ventana deslizante de `100 puntos`. La gráfica 
se actualiza cada `3 muestras`. El eje Y va de `1000` a `3200 mV` con líneas de grilla cada `500 unidades`. El eje X nmantiene su medida predeterminada.

### Medición de 15 segundos
Al presionar el botón, se reinician los intervalos RR y el BPM, se espera 
`15 segundos` con `Future.delayed`, se guarda el `_bpmActual` en 
`widget.patient.bpmPromedio` y se navega a `ResultScreen`.

## Requisitos

- Flutter SDK ^3.11.4
- Android 6.0 o superior
- ESP32 conectado al mismo hotspot que el celular