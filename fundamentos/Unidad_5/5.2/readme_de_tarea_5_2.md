# 📘 Tarea 5.2: Resolución de Consultas sobre el Esquema Relacional con Álgebra Formal

## 👤 Datos de Identificación

* **Nombre:** Leonardo Martinez Salinas

* **No. de Control:** I24050412

* **Semestre / Carrera:** 5.º Semestre — Ingeniería en Sistemas Computacionales

* **Asignatura:** Fundamentos de Bases de Datos

* **Catedrático:** Ruben Miguel Riojas Rodriguez

* **Institución:** Tecnológico Nacional de México — ITSM Campus Monclova

* **Unidad:** Unidad 5 — Álgebra Relacional y Cálculo Relacional

## 📝 Descripción

En esta actividad se plantea y resuelve un catálogo de **10 consultas de complejidad progresiva** (básicas, intermedias, avanzadas y división relacional) sobre el esquema relacional normalizado del **Hospital Regional Universitario (`HospitalRegionalDB`)**:

1. **Expresiones Formales en Álgebra Relacional:** Uso de selección ($\sigma$), proyección ($\pi$), reunión ($\bowtie$), diferencia ($-$), intersección ($\cap$), reunión externa izquierda ($\⟕$), agregación ($\mathcal{G}$), proyección generalizada y división ($\div$).

2. **Tablas Intermedias y Lenguaje Natural:** Desglose paso a paso de cada relación intermedia y traducción precisa del requerimiento de información.

3. **Validación y Simulación:** Verificación de integridad de esquemas, tipos y reglas relacionales, compatible con entornos como *RelaX Calculator* y SQL Server.

## 📊 Visualización de Gráficos

### 1. Flujo de Resolución de Consultas en Álgebra Relacional (Mermaid.js)

```
flowchart LR
    REQ["Requerimiento en Lenguaje Natural"] --> EXP["Expresión Formal en Álgebra Relacional"]
    EXP --> INT["Tablas / Relaciones Intermedias (T1, T2, ...)"]
    INT --> VAL["Validación de Dominios, Claves y Cardinalidad"]
    VAL --> RES["Relación Resultado Final"]

```

### 2. Resumen del Catálogo de 10 Consultas

| \# | Complejidad | Operadores Principales | Requerimiento Sintetizado | 
| ----- | ----- | ----- | ----- | 
| **1** | Básica | $\sigma$, $\pi$ | Expediente y tipo de sangre de pacientes con tipo `'O+'`. | 
| **2** | Básica | $\sigma$ ($\land$, $\ge$), $\pi$ | Consultas en `'2026-11-22'` con costo mayor o igual a `500.00`. | 
| **3** | Intermedia | $\bowtie_\theta$, $\pi$ | Nombre, apellido paterno y teléfono por persona. | 
| **4** | Intermedia | $\bowtie_\theta$ (3 tablas), $\pi$ | Nombre, cédula profesional y especialidad de médicos. | 
| **5** | Intermedia | $\pi$, $-$ (Diferencia) | Médicos sin consultas registradas. | 
| **6** | Intermedia | $\pi$, $\cap$ (Intersección) | Personas que son pacientes y empleados a la vez. | 
| **7** | Avanzada | $\⟕$ (Left Outer Join), $\pi$ | Consultas incluyendo las particulares sin aseguradora (`NULL`). | 
| **8** | Avanzada | $\mathcal{G}$ (`COUNT`, `SUM`) | Total de consultas y monto facturado por médico. | 
| **9** | Avanzada | $\bowtie_\theta$, Proyección Generalizada | Cálculo del monto cubierto por aseguradora en cada consulta. | 
| **10** | Compleja | $\div$ (División), $\pi$, $-$ | Consultas que incluyen todos los tratamientos de un conjunto dado. | 

## 📦 Entregables

* 📄 **Reporte Técnico en PDF:** `Tarea_5.2_Leonardo_Martinez.pdf`

* 💻 **Archivo Fuente del Informe:** [`Tarea_5.2_Leonardo_Martinez.html`](./Tarea_5.2_Leonardo_Martinez.html)

* 🗄️ **Script SQL de Validación:** [`consultas_algebra_relacional_5_2.sql`](./consultas_algebra_relacional_5_2.sql)

* 🎥 **Video Explicativo en YouTube:** [Ver video en YouTube](https://youtu.be/_rMmQaM-vnw)