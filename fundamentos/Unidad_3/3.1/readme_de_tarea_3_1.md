# 📙 Tarea 3.1: Transformación de Modelo E-R a Esquema Relacional y Reglas de Integridad

---

## 👤 Datos de Identificación

- **Nombre:** Leonardo Martinez Salinas
- **Matrícula:** I24050412
- **Maestro:** Ruben Miguel Riojas Rodriguez
- **Asignatura:** Fundamentos de Bases de Datos
- **Institución:** Tecnológico Nacional de México — ITSM Campus Monclova
- **Unidad:** Unidad 3 — Modelo Relacional e Implementación Física DDL

---

## 📝 Descripción

En esta actividad se fundamentan los componentes formales del **Modelo Relacional** y se aplica la transformación metodológica del diagrama conceptual E-R del **Hospital Regional Universitario** hacia un esquema relacional normalizado:
1. **Componentes Formales del Modelo Relacional:** Definición de Dominio ($D$), Atributo ($A$), Relación ($r(R) \subseteq D_1 \times D_2 \times \dots \times D_n$) y Tupla ($t$), junto con su correspondencia en SQL.
2. **Restricciones de Integridad:** Especificación de Integridad de Dominio, Integridad de Entidad (`PRIMARY KEY` / `NOT NULL`) e Integridad Referencial (`FOREIGN KEY` con `CASCADE`, `SET NULL` y `NO ACTION`).
3. **Transformación E-R a Esquema Relacional:** Resolución de atributos compuestos/derivados, atributos multivalorados (`1FN`), jerarquías de especialización multinivel (`PERSONA` $\rightarrow$ `PACIENTE` / `EMPLEADO` $\rightarrow$ `MEDICO` / `ENFERMERO` / `ADMINISTRATIVO`), relación `1:N` opcional (`ASEGURADORA`), agregación (`CONSULTA`) y relación `N:M` (`PRESCRIPCION`) en [`esquema_ddl_hospital.sql`](./esquema_ddl_hospital.sql).

---

## 📊 Visualización de Gráficos

### 1. Diagrama del Esquema Relacional del Hospital Regional Universitario (Mermaid.js)

```mermaid
erDiagram
    PERSONA {
        varchar_18 id_persona PK "CHECK LEN=18"
        varchar_50 primer_nombre "NOT NULL"
        varchar_50 apellido_paterno "NOT NULL"
        varchar_50 apellido_materno "NULL"
        varchar_100 calle "NOT NULL"
        varchar_20 numero "NOT NULL"
        varchar_100 colonia "NOT NULL"
        char_5 codigo_postal "CHECK 5 digitos"
        varchar_60 ciudad "NOT NULL"
        date fecha_nacimiento "NOT NULL"
    }
    TELEFONO_PERSONA {
        varchar_18 id_persona PK,FK "ON DELETE CASCADE"
        varchar_15 telefono PK "CHECK >= 7 digitos"
    }
    PACIENTE {
        varchar_18 id_persona PK,FK "ON DELETE CASCADE"
        varchar_30 no_expediente UK "NOT NULL"
        varchar_5 tipo_sangre "CHECK IN (A+, O+, ...)"
    }
    EMPLEADO {
        varchar_18 id_persona PK,FK "ON DELETE CASCADE"
        varchar_13 rfc_empleado UK "CHECK LEN 12-13"
        date fecha_ingreso "NOT NULL"
        decimal_10_2 sueldo_base "CHECK > 0"
    }
    MEDICO {
        varchar_18 id_persona PK,FK "ON DELETE CASCADE"
        varchar_20 cedula_profesional UK "NOT NULL"
        varchar_100 especialidad "NOT NULL"
    }
    ENFERMERO {
        varchar_18 id_persona PK,FK "ON DELETE CASCADE"
        varchar_20 turno "CHECK IN (...)"
        varchar_80 area_asignada "NOT NULL"
    }
    ADMINISTRATIVO {
        varchar_18 id_persona PK,FK "ON DELETE CASCADE"
        varchar_80 puesto "NOT NULL"
        varchar_80 departamento "NOT NULL"
    }
    ASEGURADORA {
        varchar_20 id_aseguradora PK
        varchar_120 nombre_empresa UK "NOT NULL"
        decimal_5_2 porcentaje_cobertura "CHECK 0..100"
    }
    TRATAMIENTO {
        int id_tratamiento PK "IDENTITY(1,1)"
        varchar_150 medicamento "NOT NULL"
        varchar_100 dosis "NOT NULL"
        int duracion_dias "CHECK > 0"
    }
    CONSULTA {
        int id_consulta PK "IDENTITY(1,1)"
        date fecha "NOT NULL"
        time_0 hora "NOT NULL"
        varchar_max diagnostico "NOT NULL"
        decimal_10_2 costo "CHECK >= 0"
        varchar_18 id_medico FK "NO ACTION"
        varchar_18 id_paciente FK "NO ACTION"
        varchar_20 id_aseguradora FK "NULL / SET NULL"
    }
    PRESCRIPCION {
        int id_consulta PK,FK "ON DELETE CASCADE"
        int id_tratamiento PK,FK "ON DELETE NO ACTION"
        varchar_100 dosis_prescrita "NOT NULL"
        varchar_100 frecuencia "NOT NULL"
        int duracion_dias "CHECK > 0"
    }

    PERSONA ||--o{ TELEFONO_PERSONA : "1:N Multivalorado"
    PERSONA ||--o| PACIENTE : "Especialización (1:1)"
    PERSONA ||--o| EMPLEADO : "Especialización (1:1)"
    EMPLEADO ||--o| MEDICO : "Subclase Nivel 2"
    EMPLEADO ||--o| ENFERMERO : "Subclase Nivel 2"
    EMPLEADO ||--o| ADMINISTRATIVO : "Subclase Nivel 2"
    MEDICO ||--o{ CONSULTA : "1:N Atiende"
    PACIENTE ||--o{ CONSULTA : "1:N Recibe"
    ASEGURADORA |o--o{ CONSULTA : "0..1:N Cubre"
    CONSULTA ||--o{ PRESCRIPCION : "1:N Agregación"
    TRATAMIENTO ||--o{ PRESCRIPCION : "1:N Prescripción"
```

### 2. Restricciones de Integridad en el Modelo Relacional

| Categoría de Integridad | Definición de la Regla | Mecanismo de Implementación en SQL Server |
| :--- | :--- | :--- |
| **Integridad de Dominio** | Cada atributo debe tomar valores atómicos dentro del dominio permitido. | Tipos de datos (`VARCHAR`, `CHAR`, `DATE`, `DECIMAL`), `NOT NULL` y `CHECK`. |
| **Integridad de Entidad** | Ningún atributo de la clave primaria (`PK`) puede ser `NULL` ni repetirse. | `PRIMARY KEY` simple o compuesta en cada relación. |
| **Integridad Referencial** | Las claves foráneas (`FK`) deben apuntar a una `PK` existente o ser `NULL` si es opcional. | `FOREIGN KEY REFERENCES` con `CASCADE`, `SET NULL` o `NO ACTION`. |

### 3. Mapeo Riguroso del Esquema Relacional

| Tabla Relacional | Atributos / Columnas | Claves (PK / FK / UK) | Transformación Aplicada |
| :--- | :--- | :--- | :--- |
| `PERSONA` | `id_persona`, `primer_nombre`, `apellido_paterno`, `apellido_materno`, `calle`, `numero`, `colonia`, `codigo_postal`, `ciudad`, `fecha_nacimiento` | **PK:** `id_persona` | Superclase raíz con atributos compuestos desglosados (sin `edad` derivada). |
| `TELEFONO_PERSONA` | `id_persona`, `telefono` | **PK/FK:** `(id_persona, telefono)` $\rightarrow$ `PERSONA` (`CASCADE`) | Atributo multivalorado normalizado a 1FN. |
| `PACIENTE` | `id_persona`, `no_expediente`, `tipo_sangre` | **PK/FK:** `id_persona` $\rightarrow$ `PERSONA` (`CASCADE`) \| **UK:** `no_expediente` | Subclase de especialización (Nivel 1). |
| `EMPLEADO` | `id_persona`, `rfc_empleado`, `fecha_ingreso`, `sueldo_base` | **PK/FK:** `id_persona` $\rightarrow$ `PERSONA` (`CASCADE`) \| **UK:** `rfc_empleado` | Subclase de especialización (Nivel 1). |
| `MEDICO` | `id_persona`, `cedula_profesional`, `especialidad` | **PK/FK:** `id_persona` $\rightarrow$ `EMPLEADO` (`CASCADE`) \| **UK:** `cedula_profesional` | Subclase especializada (Nivel 2). |
| `ENFERMERO` | `id_persona`, `turno`, `area_asignada` | **PK/FK:** `id_persona` $\rightarrow$ `EMPLEADO` (`CASCADE`) | Subclase especializada (Nivel 2). |
| `ADMINISTRATIVO` | `id_persona`, `puesto`, `departamento` | **PK/FK:** `id_persona` $\rightarrow$ `EMPLEADO` (`CASCADE`) | Subclase especializada (Nivel 2). |
| `ASEGURADORA` | `id_aseguradora`, `nombre_empresa`, `porcentaje_cobertura` | **PK:** `id_aseguradora` \| **UK:** `nombre_empresa` | Catálogo de cobertura médica. |
| `TRATAMIENTO` | `id_tratamiento`, `medicamento`, `dosis`, `duracion_dias` | **PK:** `id_tratamiento` | Catálogo de tratamientos médicos. |
| `CONSULTA` | `id_consulta`, `fecha`, `hora`, `diagnostico`, `costo`, `id_medico`, `id_paciente`, `id_aseguradora` | **PK:** `id_consulta` \| **FK:** `id_medico`, `id_paciente` (`NO ACTION`), `id_aseguradora` (`SET NULL`) | Entidad agregada de atención médica y relación `1:N` opcional. |
| `PRESCRIPCION` | `id_consulta`, `id_tratamiento`, `dosis_prescrita`, `frecuencia`, `duracion_dias` | **PK/FK:** `(id_consulta, id_tratamiento)` $\rightarrow$ `CONSULTA` (`CASCADE`), `TRATAMIENTO` (`NO ACTION`) | Relación `N:M` con atributos propios. |

---

## 📦 Entregables

- 📄 **Reporte Técnico en PDF:** `Tarea_3.1_Leonardo_Martinez.pdf`
- 💻 **Script SQL DDL:** [`esquema_ddl_hospital.sql`](./esquema_ddl_hospital.sql)
- 🎥 **Video Explicativo en YouTube:** [Ver video en YouTube](https://youtu.be/qlXaavuqU6A)

[![Ver SQL](https://img.shields.io/badge/SQL-Abrir_esquema_ddl_hospital.sql-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](./esquema_ddl_hospital.sql)
[![YouTube](https://img.shields.io/badge/YouTube-Ver_Video_Explicativo-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/qlXaavuqU6A)