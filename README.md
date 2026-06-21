# Lab 04: Visualización usando pantalla LCD 16x2 en modo paralelo

- **Janpier Sebastian Zuñiga Ramos / 1061702939**
- **Luis Felipe Vargas Bernal / 1031643563**
- **Cristian Camilo Fonseca Flores / 1029660127**

---

## 📚 Contenido
- [Introducción](#1-introducción)
- [Descripción](#2-descripción)
- [Objetivos](#3-objetivos)
- [Marco teórico](#4-marco-teórico)
- [Materiales](#5-materiales)
- [Metodología](#6-metodología)
- [Resultados](#7-resultados)
- [Conclusiones](#8-conclusiones)

---

## 1. Introducción

En los sistemas embebidos y arquitecturas digitales, la capacidad de presentar información en tiempo real es fundamental para la interacción entre el usuario y el sistema. Entre los dispositivos de visualización más empleados en este contexto, la pantalla LCD alfanumérica de 16×2 destaca por su simplicidad, bajo consumo y amplia disponibilidad.

Sin embargo, controlar una pantalla LCD no es trivial: requiere una secuencia precisa de comandos de inicialización y escritura, respetando tiempos de habilitación y protocolos de comunicación paralela. En este contexto, el uso de una Máquina de Estados Finitos (FSM) implementada en Verilog sobre una FPGA Cyclone IV permite gestionar de forma estructurada y confiable ese flujo de señales de control y datos.

Este laboratorio introduce el diseño de sistemas digitales secuenciales orientados al control de periféricos externos, sentando las bases para aplicaciones más complejas de visualización dinámica en hardware.

---

## 2. Descripción

El laboratorio se divide en dos partes. En la **Parte 1**, se analiza, simula e implementa una descripción de hardware preexistente que visualiza texto estático en las dos líneas de la pantalla LCD 16×2 conectada a la FPGA Cyclone IV. En la **Parte 2**, se extiende ese diseño para mostrar texto dinámico: dos valores numéricos de 8 bits provenientes de switches físicos se muestran en la pantalla junto al texto estático, actualizándose en función del estado de las entradas.

El sistema completo recibe una señal de reloj de 50 MHz de la FPGA, genera internamente un reloj más lento (≈16 ms) para el ciclo de escritura de la LCD, y gestiona la secuencia de inicialización y escritura mediante una FSM de cinco estados.

---

## 3. Objetivos

### 3.1 Objetivo general
Comprender e implementar el control de una pantalla LCD 16×2 en modo paralelo de 8 bits mediante una Máquina de Estados Finitos descrita en Verilog, sobre una FPGA Altera Cyclone IV.

### 3.2 Objetivos específicos
- Introducir el concepto de FSM en el diseño de hardware para control de periféricos.
- Analizar y diagramar la unidad de control y la arquitectura completa del sistema LCD.
- Realizar la simulación del diseño mediante un testbench en Verilog.
- Implementar el diseño en la tarjeta de desarrollo Cyclone IV y verificar su funcionamiento físico.
- Extender el diseño para mostrar texto dinámico a partir de entradas de 8 bits provenientes de switches.
- Comprender el protocolo de comunicación paralela de la LCD y el uso del código ASCII para la escritura de caracteres.

---

## 4. Marco teórico

### 4.1 Pantalla LCD 16×2

Una pantalla LCD (Liquid Crystal Display) alfanumérica de 16×2 puede mostrar 32 caracteres en total, distribuidos en 2 filas de 16 columnas. Cada carácter se representa en una matriz de 5×8 píxeles. Opera entre 4.7 V y 5.3 V, con un consumo de aproximadamente 1 mA sin retroiluminación.

La interfaz de comunicación con el módulo se realiza a través de los siguientes pines principales:

| Pin  | Nombre | Función |
|------|--------|---------|
| 1    | Vss    | GND |
| 2    | Vdd    | Alimentación (+3.3V a +5V) |
| 3    | Vo     | Ajuste de contraste |
| 4    | RS     | Selección de registro: 0=Comando, 1=Dato |
| 5    | R/W    | Modo: 0=Escritura, 1=Lectura |
| 6    | E      | Enable (clock de la LCD, flanco de bajada) |
| 7-14 | D0-D7  | Bus de datos (8 bits) |
| 15   | A      | Ánodo retroiluminación (+) |
| 16   | K      | Cátodo retroiluminación (−) |



La pantalla opera en **modo de 8 bits**: los datos y comandos se envían completos en un ciclo, usando el bus D0–D7.

### 4.2 Protocolo de escritura

Para escribir un dato o comando en la LCD se debe seguir la siguiente secuencia:
1. Establecer RS (0 para comando, 1 para dato) y R/W=0 (escritura).
2. Colocar el byte en el bus D0–D7.
3. Generar un pulso en la señal E (Enable): alto → bajo.
4. Esperar el tiempo de procesamiento del controlador interno (HD44780).

### 4.3 Máquina de Estados Finitos (FSM)

Una FSM es un modelo computacional que describe el comportamiento de un sistema en términos de un conjunto finito de estados, transiciones entre ellos condicionadas por entradas, y salidas asociadas a cada estado. En Verilog se implementan típicamente con bloques `always` separados: uno para la actualización del estado actual (secuencial) y otro para la lógica del siguiente estado y las salidas (combinacional).

En este laboratorio, la FSM controla la secuencia de inicialización y escritura de la LCD, garantizando que los comandos y datos se envíen en el orden y con los tiempos correctos.

### 4.4 Código ASCII

La pantalla LCD almacena internamente una tabla de caracteres basada en el código ASCII. Para escribir un carácter, basta con enviar su código hexadecimal: por ejemplo, la letra `'A'` corresponde a `0x41`, y los dígitos del `'0'` al `'9'` van de `0x30` a `0x39`. Esto permite convertir un valor numérico binario a su representación decimal visible sumando `0x30` al dígito correspondiente.

---

## 5. Materiales

### 5.1 Hardware
- Tarjeta de desarrollo FPGA Altera Cyclone IV (DE0 o similar).
- Pantalla LCD alfanumérica 16×2.
- Cables de conexión.
- Potenciómetro (ajuste de contraste Vo).
- Switches de la placa FPGA.

### 5.2 Software
- Intel Quartus Prime (síntesis, implementación y programación).
- Verilog HDL.
- Herramienta de simulación (ModelSim / Icarus Verilog + GTKWave).

---

## 6. Metodología

El desarrollo del laboratorio siguió una metodología de diseño modular en cuatro etapas:

**Etapa 1 – Análisis del hardware base:** Se estudió en detalle la descripción Verilog proporcionada, identificando los cinco estados de la FSM, los módulos de generación de reloj lento, la memoria de texto estático y los registros de configuración.

**Etapa 2 – Diagramación:** Se elaboraron el diagrama de la FSM (estados, transiciones y salidas) y el diagrama de bloques de la arquitectura completa del sistema.

**Etapa 3 – Simulación:** Usando el testbench incluido en la carpeta `test` del repositorio, se verificó el comportamiento de las señales `rs`, `enable` y `data` a lo largo de la secuencia de inicialización y escritura, validando tiempos y orden de comandos.

**Etapa 4 – Implementación y extensión (Parte 2):** Se realizó la asignación de pines en Quartus (Pin Planner), se configuró el pin 101 (nCEO) como I/O regular, se conectó físicamente la LCD al header J2 de la tarjeta y se programó la FPGA. Posteriormente, se modificó el diseño para incorporar el decodificador de switches a ASCII y se repitió el flujo completo de simulación e implementación.

### 6.1 Diagrama de la FSM

La FSM del controlador LCD cuenta con cinco estados:

| Estado | Función |
|--------|---------|
| `IDLE` | Espera la señal `ready_i` para comenzar |
| `CONFIG_CMD1` | Envía los 4 comandos de inicialización |
| `WR_STATIC_TEXT_1L` | Escribe los 16 caracteres de la línea 1 |
| `CONFIG_CMD2` | Envía el comando de salto a línea 2 (`0xC0`) |
| `WR_STATIC_TEXT_2L` | Escribe los 16 caracteres de la línea 2 |



### 6.2 Diagrama de bloques de la arquitectura

<img width="1440" height="800" alt="image" src="https://github.com/user-attachments/assets/43094245-f381-4885-8128-9390b649a40c" />


El sistema se compone de:
- **Divisor de frecuencia:** genera `clk_16ms` a partir del reloj de 50 MHz usando un contador de hasta `COUNT_MAX = 800000` ciclos.
- **FSM (unidad de control):** gestiona la secuencia de estados y genera las señales `rs`, `rw` y `enable`.
- **Memoria de texto estático:** arreglo de 32 bytes cargado desde un archivo `.txt` con los caracteres en hexadecimal ASCII.
- **Decodificador (Parte 2):** convierte los 3 bits superiores e inferiores de `sw[5:0]` a su representación ASCII sumando `0x30`.
- **Multiplexor de datos:** selecciona entre la memoria estática y el decodificador según la posición del cursor.

---

## 7. Resultados

### 7.1 Parte 1 – Texto estático

#### 7.1.1 Simulación

Se ejecutó el testbench sobre el diseño base. La simulación mostró la correcta secuencia de inicialización: primero los cuatro comandos de configuración (`0x38`, `0x06`, `0x0C`, `0x01`) con `rs=0`, seguidos de los 16 bytes de texto para la línea 1 con `rs=1`, el comando de salto a línea 2 (`0xC0`), y finalmente los 16 bytes de la segunda línea.

<img width="941" height="210" alt="image" src="https://github.com/user-attachments/assets/50d48dc1-6432-4cb6-a513-6a11d35485fe" />

#### 7.1.2 Implementación en FPGA

Se realizó la asignación de pines según la tabla de la PCB de la tarjeta y se configuró el pin 101 (`nCEO`) como I/O regular desde `Assignments → Device → Device and Pin Options → Dual-Purpose Pins`. La LCD se conectó al header J2 alineando el pin 1 de la pantalla con el pin 1 marcado en la tarjeta.

<img width="821" height="497" alt="image" src="https://github.com/user-attachments/assets/eea3dd1e-bb7b-485d-9ab1-c0b8c7746a19" />


### 7.2 Parte 2 – Texto dinámico

#### 7.2.1 Decodificador de switches a ASCII

Para mostrar el valor numérico de los switches en la pantalla, se implementó un decodificador combinacional que toma los 3 bits superiores (`sw[5:3]`) para la línea 1 y los 3 bits inferiores (`sw[2:0]`) para la línea 2, y los convierte al carácter ASCII correspondiente sumando `0x30`:

```verilog
assign decodificador_L1 = 8'h30 + sw[5:3];
assign decodificador_L2 = 8'h30 + sw[2:0];
```

Esto permite mostrar dígitos del `'0'` al `'7'` en función del valor binario de cada grupo de 3 switches.

#### 7.2.2 Multiplexor de datos

En los estados `WR_STATIC_TEXT_1L` y `WR_STATIC_TEXT_2L`, se incorporó una condición que selecciona la fuente del dato según la posición del cursor:

```verilog
if (data_counter == 4'd12) begin
    data <= decodificador_L1;  // Posición dinámica
end else begin
    data <= static_data_mem[data_counter];  // Texto estático
end
```

El carácter dinámico se ubica en la posición 12 de cada línea, dejando los primeros 12 caracteres para el texto estático fijo.

#### 7.2.3 Simulación

Se repitió la simulación con el diseño extendido, modificando el valor de `sw` en el testbench para verificar que la señal `data` cambia correctamente en la posición 12 de cada línea al variar las entradas.

<img width="2260" height="231" alt="image" src="https://github.com/user-attachments/assets/ab26a8a9-b35c-4fc3-b1b2-fffed9a27173" />


#### 7.2.4 Implementación y evidencias

Se reprogramó la FPGA con el diseño extendido. Al variar los switches, el dígito en la posición 12 de cada línea se actualiza en la pantalla tras completar el ciclo de escritura.

<img width="1200" height="1600" alt="WhatsApp Image 2026-06-21 at 10 23 10 AM" src="https://github.com/user-attachments/assets/58f2025a-b983-48a8-9d95-547a4161415e" />


## 8. Conclusiones

- El uso de una FSM en Verilog demostró ser la estrategia natural para el control de la LCD 16×2, ya que el protocolo de inicialización y escritura exige un orden estricto de comandos que se mapea directamente a una secuencia de estados.
- La separación entre la lógica del siguiente estado (combinacional) y la actualización del estado actual (secuencial) facilita la depuración y verificación del diseño, manteniendo el código ordenado y predecible.
- El divisor de frecuencia implementado mediante un contador permite adaptar el reloj de 50 MHz de la FPGA al tiempo de habilitación requerido por el controlador HD44780 de la LCD, evidenciando la importancia de calcular correctamente los parámetros temporales antes de la implementación.
- La extensión hacia texto dinámico (Parte 2) mostró que basta con incorporar un decodificador combinacional y un multiplexor en la ruta de datos para pasar de visualización estática a dinámica, sin modificar la estructura de la FSM.
- La conversión de valores binarios a código ASCII mediante la operación `valor + 0x30` es una técnica simple y eficiente para representar dígitos numéricos en pantallas LCD, ampliamente aplicable en sistemas embebidos.
- La configuración del pin 101 (`nCEO`) como I/O regular fue un paso crítico para el correcto funcionamiento físico del sistema, ya que sin este ajuste la señal de `enable` no habría llegado correctamente a la pantalla.
