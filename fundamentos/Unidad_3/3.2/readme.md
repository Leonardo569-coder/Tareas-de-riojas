# 🔧 Tarea 3.2: Implementación Física en SGBD y Script DDL (`taller_db`)

## 👤 Datos de Identificación

* **Estudiante:** Leonardo Martinez Salinas

* **No. de Control:** I24050412

* **Semestre / Carrera:** 5° Semestre — Ingeniería en Sistemas Computacionales

* **Asignatura:** Fundamentos de Bases de Datos

* **Catedrático:** Ruben Miguel Riojas Rodriguez

* **Institución:** Tecnológico Nacional de México — ITSM Campus Monclova

## 📝 Descripción

En esta actividad se realiza la implementación física y validación del esquema relacional del **Sistema de Taller Mecánico y Refaccionaria (`taller_db`)** en **Microsoft SQL Server (T-SQL)** mediante el Lenguaje de Definición de Datos (LDD/DDL) y pruebas de integridad con el Lenguaje de Manipulación de Datos (LMD/DML):

1. **Mapeo Físico y Tipos de Datos (T-SQL):** Selección justificada de tipos físicos (`INT IDENTITY(1,1)`, `VARCHAR(18)`, `VARCHAR(17)`, `DECIMAL(10,2)`, `DATE`, `DATETIME2`, `NVARCHAR(MAX)`).

2. **Integridad Referencial y Cascadas:** Configuración de `ON DELETE CASCADE ON UPDATE CASCADE` en tablas dependientes (`TELEFONO_CLIENTE`, `CLIENTE`, `DETALLE_REFACCION_ORDEN`) y `ON DELETE NO ACTION` en entidades con historial operativo (`MECANICO`, `VEHICULO`, `REFACCION`, `ORDEN_SERVICIO`).

3. **Pruebas de Validación (`schema.sql`):** Inserción de datos semilla válidos y bloques controlados `BEGIN TRY ... BEGIN CATCH` para comprobar el bloqueo automático de salarios negativos (`salario_mensual <= 0`) y números de serie vehiculares (`VIN`) con longitud distinta de 17 caracteres.

## 📊 Visualización de Gráficos

### 1. Flujo de Ejecución DDL y Validación de Restricciones en el SGBD (Mermaid.js)

```mermaid
flowchart TD
    START(["🚀 Inicio de Ejecución: schema.sql"]) --> DB["Creación y Selección de BD: taller_db"]
    DB --> DROP["Limpieza Idempotente (DROP TABLE IF EXISTS en orden inverso)"]
    DROP --> DDL["Creación Jerárquica de 8 Tablas DDL"]

    DDL --> T_BASE["1. Superclase y Catálogo: PERSONA, REFACCION"]
    T_BASE --> T_SUB["2. Subtipos y Multivalorados: TELEFONO_CLIENTE, CLIENTE, MECANICO"]
    T_SUB --> T_ACT["3. Activos Registrados: VEHICULO"]
    T_ACT --> T_TRN["4. Operación y Detalle: ORDEN_SERVICIO, DETALLE_REFACCION_ORDEN"]

    T_TRN --> DML_OK["✅ Prueba A: Inserción DML Válida<br/>(Cliente, Vehículo VIN 17, Mecánico MEC-01, Orden ORD-2026-001)"]
    T_TRN --> DML_ERR1["❌ Prueba B (TRY/CATCH): Salario Negativo (-2500.00)<br/>Bloqueado por CONSTRAINT chk_mecanico_salario"]
    T_TRN --> DML_ERR2["❌ Prueba C (TRY/CATCH): VIN Inválido ('VIN-CORTO-123')<br/>Bloqueado por CONSTRAINT chk_vehiculo_vin_len"]

    DML_OK & DML_ERR1 & DML_ERR2 --> SELECT["📊 Verificación Final: SELECT * FROM Tablas"]
```

### 2. Estrategia de Tipos de Datos y Mapeo Físico en T-SQL

| Tipo de Dato Lógico | Tipo de Dato Físico (T-SQL) | Justificación Técnica y Dominio | 
| :--- | :--- | :--- | 
| **Claves Primarias Subrogadas** | `INT IDENTITY(1,1)` | Enteros autoincrementables de 4 bytes para llaves artificiales en `PERSONA`, `CLIENTE` y `DETALLE_REFACCION_ORDEN`. | 
| **Identificadores Estándar (`CURP`, `VIN`, `RFC`)** | `VARCHAR(18)` / `VARCHAR(17)` / `VARCHAR(13)` | Cadenas acotadas con verificación estricta de longitud mediante restricciones `CHECK`. | 
| **Nombres, Marcas y Catálogos** | `VARCHAR(40)` a `VARCHAR(100)` | Cadenas de longitud variable optimizadas para almacenamiento sin desperdicio de espacio. | 
| **Fallas y Diagnósticos** | `NVARCHAR(MAX)` | Soporte Unicode extendido para descripciones técnicas detalladas en `ORDEN_SERVICIO`. | 
| **Fechas y Marcas Temporales** | `DATE` / `DATETIME2` | Precisión cronológica para registros de alta y recepción de unidades con `SYSDATETIME()`. | 
| **Importes Monetarios** | `DECIMAL(10,2)` | Precisión decimal exacta para salarios, mano de obra y precios unitarios de refacciones. | 

## 📦 Entregables del Repositorio

* 📄 **Reporte Técnico PDF:** [`Tarea_3.2_Leonardo_Martinez.pdf`](./Tarea_3.2_Leonardo_Martinez.pdf)

* 💻 **Script SQL Formal DDL/DML:** [`schema.sql`](./schema.sql)

* 🎥 **Video Demostrativo en YouTube:** [Ver video en YouTube](https://youtu.be/bm-WJJ45vCk)

[![Ver PDF](https://img.shields.io/badge/PDF-Abrir_Reporte_Técnico-EC1C24?style=for-the-badge&logo=adobeacrobatreader&logoColor=white)](./Tarea_3.2_Leonardo_Martinez.pdf)
[![Ver SQL](https://img.shields.io/badge/SQL-Abrir_schema.sql-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](./schema.sql)
[![YouTube](https://img.shields.io/badge/YouTube-Ver_Video_Demostrativo-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/bm-WJJ45vCk)
