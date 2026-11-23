-- ============================================================================
-- SCRIPT DDL NORMALIZADO (3FN / FNBC): HOSPITAL REGIONAL UNIVERSITARIO
-- Motor Target: Microsoft SQL Server 2019 / 2022 (T-SQL)
-- Estudiante: Leonardo Martinez Salinas
-- No. de Control: I24050412
-- Institución: Tecnológico Nacional de México — ITSM Campus Monclova
-- Asignatura: Fundamentos de Bases de Datos - Unidad 4 (Tarea 4.2)
-- Catedrático: Ruben Miguel Riojas Rodriguez
-- Archivo: normalized_schema.sql
-- ============================================================================

-- 1. CREACIÓN Y SELECCIÓN DE BASE DE DATOS
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HospitalRegionalDB')
BEGIN
    ALTER DATABASE HospitalRegionalDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalRegionalDB;
END
GO

CREATE DATABASE HospitalRegionalDB
COLLATE Latin1_General_CI_AS;
GO

USE HospitalRegionalDB;
GO

-- ============================================================================
-- 2. TABLAS BASE Y CATÁLOGOS NORMALIZADOS (1FN - 3FN)
-- ============================================================================

-- Superclase PERSONA (Atributos compuestos desglosados en columnas atómicas - 1FN)
CREATE TABLE PERSONA (
    id_persona          VARCHAR(18)     NOT NULL,
    primer_nombre       VARCHAR(50)     NOT NULL,
    apellido_paterno    VARCHAR(50)     NOT NULL,
    apellido_materno    VARCHAR(50)     NULL,
    calle               VARCHAR(100)    NOT NULL,
    numero              VARCHAR(20)     NOT NULL,
    colonia             VARCHAR(100)    NOT NULL,
    codigo_postal       CHAR(5)         NOT NULL,
    ciudad              VARCHAR(60)     NOT NULL,
    fecha_nacimiento    DATE            NOT NULL,

    CONSTRAINT PK_Persona PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT CHK_Persona_IdLen CHECK (LEN(id_persona) = 18),
    CONSTRAINT CHK_Persona_FechaNac CHECK (fecha_nacimiento <= CAST(GETDATE() AS DATE)),
    CONSTRAINT CHK_Persona_CP CHECK (codigo_postal LIKE '[0-9][0-9][0-9][0-9][0-9]')
);
GO

-- Atributo multivalorado TELEFONO_PERSONA (Eliminación de grupos repetitivos - 1FN)
CREATE TABLE TELEFONO_PERSONA (
    id_persona          VARCHAR(18)     NOT NULL,
    telefono            VARCHAR(15)     NOT NULL,

    CONSTRAINT PK_TelefonoPersona PRIMARY KEY CLUSTERED (id_persona, telefono),
    CONSTRAINT FK_TelefonoPersona_Persona FOREIGN KEY (id_persona)
        REFERENCES PERSONA (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Telefono_Formato CHECK (LEN(telefono) >= 7 AND telefono NOT LIKE '%[^0-9]%')
);
GO

-- Catálogo ESPECIALIDAD (Elimina dependencia transitiva id_medico -> id_especialidad -> nombre_especialidad - 3FN)
CREATE TABLE ESPECIALIDAD (
    id_especialidad     INT IDENTITY(1,1) NOT NULL,
    nombre_especialidad VARCHAR(100)      NOT NULL,
    descripcion         VARCHAR(250)      NULL,

    CONSTRAINT PK_Especialidad PRIMARY KEY CLUSTERED (id_especialidad),
    CONSTRAINT UQ_Especialidad_Nombre UNIQUE (nombre_especialidad)
);
GO

-- Catálogo ASEGURADORA (Elimina dependencia transitiva en CONSULTA - 3FN)
CREATE TABLE ASEGURADORA (
    id_aseguradora       VARCHAR(20)    NOT NULL,
    nombre_empresa       VARCHAR(120)   NOT NULL,
    porcentaje_cobertura DECIMAL(5,2)   NOT NULL,

    CONSTRAINT PK_Aseguradora PRIMARY KEY CLUSTERED (id_aseguradora),
    CONSTRAINT UQ_Aseguradora_Nombre UNIQUE (nombre_empresa),
    CONSTRAINT CHK_Aseguradora_Porcentaje CHECK (porcentaje_cobertura BETWEEN 0.00 AND 100.00)
);
GO

-- Catálogo TRATAMIENTO (Elimina dependencia parcial sobre (id_consulta, id_tratamiento) - 2FN)
CREATE TABLE TRATAMIENTO (
    id_tratamiento      INT IDENTITY(1,1) NOT NULL,
    medicamento         VARCHAR(150)      NOT NULL,
    dosis               VARCHAR(100)      NOT NULL,
    duracion_dias       INT               NOT NULL,

    CONSTRAINT PK_Tratamiento PRIMARY KEY CLUSTERED (id_tratamiento),
    CONSTRAINT CHK_Tratamiento_Duracion CHECK (duracion_dias > 0)
);
GO

-- ============================================================================
-- 3. JERARQUÍAS DE ESPECIALIZACIÓN (3FN / FNBC)
-- ============================================================================

-- Subclase PACIENTE
CREATE TABLE PACIENTE (
    id_persona          VARCHAR(18)     NOT NULL,
    no_expediente       VARCHAR(30)     NOT NULL,
    tipo_sangre         VARCHAR(5)      NOT NULL,

    CONSTRAINT PK_Paciente PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Paciente_Expediente UNIQUE (no_expediente),
    CONSTRAINT FK_Paciente_Persona FOREIGN KEY (id_persona)
        REFERENCES PERSONA (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Paciente_TipoSangre CHECK (tipo_sangre IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);
GO

-- Subclase EMPLEADO
CREATE TABLE EMPLEADO (
    id_persona          VARCHAR(18)     NOT NULL,
    rfc_empleado        VARCHAR(13)     NOT NULL,
    fecha_ingreso       DATE            NOT NULL,
    sueldo_base         DECIMAL(10,2)   NOT NULL,

    CONSTRAINT PK_Empleado PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Empleado_RFC UNIQUE (rfc_empleado),
    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (id_persona)
        REFERENCES PERSONA (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Empleado_RFCLen CHECK (LEN(rfc_empleado) IN (12, 13)),
    CONSTRAINT CHK_Empleado_Sueldo CHECK (sueldo_base > 0),
    CONSTRAINT CHK_Empleado_FechaIngreso CHECK (fecha_ingreso <= CAST(GETDATE() AS DATE))
);
GO

-- Subclase MEDICO (Vinculada a ESPECIALIDAD en 3FN / FNBC)
CREATE TABLE MEDICO (
    id_persona          VARCHAR(18)     NOT NULL,
    cedula_profesional  VARCHAR(20)     NOT NULL,
    id_especialidad     INT             NOT NULL,

    CONSTRAINT PK_Medico PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Medico_Cedula UNIQUE (cedula_profesional),
    CONSTRAINT FK_Medico_Empleado FOREIGN KEY (id_persona)
        REFERENCES EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Medico_Especialidad FOREIGN KEY (id_especialidad)
        REFERENCES ESPECIALIDAD (id_especialidad)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

-- Subclase ENFERMERO
CREATE TABLE ENFERMERO (
    id_persona          VARCHAR(18)     NOT NULL,
    turno               VARCHAR(20)     NOT NULL,
    area_asignada       VARCHAR(80)     NOT NULL,

    CONSTRAINT PK_Enfermero PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_Enfermero_Empleado FOREIGN KEY (id_persona)
        REFERENCES EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Enfermero_Turno CHECK (turno IN ('Matutino', 'Vespertino', 'Nocturno', 'Mixto'))
);
GO

-- Subclase ADMINISTRATIVO
CREATE TABLE ADMINISTRATIVO (
    id_persona          VARCHAR(18)     NOT NULL,
    puesto              VARCHAR(80)     NOT NULL,
    departamento        VARCHAR(80)     NOT NULL,

    CONSTRAINT PK_Administrativo PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_Administrativo_Empleado FOREIGN KEY (id_persona)
        REFERENCES EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO

-- ============================================================================
-- 4. ENTIDADES TRANSACCIONALES Y ASOCIATIVAS NORMALIZADAS (2FN - 3FN)
-- ============================================================================

-- Entidad CONSULTA (Sin dependencias transitivas de paciente, médico o aseguradora)
CREATE TABLE CONSULTA (
    id_consulta         INT IDENTITY(1,1) NOT NULL,
    fecha               DATE            NOT NULL,
    hora                TIME(0)         NOT NULL,
    diagnostico         VARCHAR(MAX)    NOT NULL,
    costo               DECIMAL(10,2)   NOT NULL,
    id_medico           VARCHAR(18)     NOT NULL,
    id_paciente         VARCHAR(18)     NOT NULL,
    id_aseguradora      VARCHAR(20)     NULL,

    CONSTRAINT PK_Consulta PRIMARY KEY CLUSTERED (id_consulta),
    CONSTRAINT FK_Consulta_Medico FOREIGN KEY (id_medico)
        REFERENCES MEDICO (id_persona)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Consulta_Paciente FOREIGN KEY (id_paciente)
        REFERENCES PACIENTE (id_persona)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Consulta_Aseguradora FOREIGN KEY (id_aseguradora)
        REFERENCES ASEGURADORA (id_aseguradora)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT CHK_Consulta_Costo CHECK (costo >= 0.00)
);
GO

-- Tabla asociativa PRESCRIPCION (Dependencia funcional completa sobre clave compuesta - 2FN)
CREATE TABLE PRESCRIPCION (
    id_consulta         INT             NOT NULL,
    id_tratamiento      INT             NOT NULL,
    dosis_prescrita     VARCHAR(100)    NOT NULL,
    frecuencia          VARCHAR(100)    NOT NULL,
    duracion_dias       INT             NOT NULL,

    CONSTRAINT PK_Prescripcion PRIMARY KEY CLUSTERED (id_consulta, id_tratamiento),
    CONSTRAINT FK_Prescripcion_Consulta FOREIGN KEY (id_consulta)
        REFERENCES CONSULTA (id_consulta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Prescripcion_Tratamiento FOREIGN KEY (id_tratamiento)
        REFERENCES TRATAMIENTO (id_tratamiento)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CHK_Prescripcion_Duracion CHECK (duracion_dias > 0)
);
GO

-- ============================================================================
-- 5. PRUEBAS DML DE VALIDACIÓN DEL ESQUEMA NORMALIZADO
-- ============================================================================

INSERT INTO ESPECIALIDAD (nombre_especialidad, descripcion)
VALUES ('Cardiologia', 'Diagnostico y tratamiento de enfermedades cardiovasculares');

INSERT INTO ASEGURADORA (id_aseguradora, nombre_empresa, porcentaje_cobertura)
VALUES ('ASEG-01', 'Seguros Monterrey Salud', 80.00);

INSERT INTO TRATAMIENTO (medicamento, dosis, duracion_dias)
VALUES ('Losartan 50 mg', '1 tableta cada 24 horas', 30);

-- Registro de Médico
INSERT INTO PERSONA (id_persona, primer_nombre, apellido_paterno, apellido_materno, calle, numero, colonia, codigo_postal, ciudad, fecha_nacimiento)
VALUES ('MECJ850101HMNCLR01', 'Juan', 'Mendoza', 'Cruz', 'Blvd. Harold R. Pape', '412', 'Guadalupe', '25750', 'Monclova', '1985-01-01');

INSERT INTO TELEFONO_PERSONA (id_persona, telefono)
VALUES ('MECJ850101HMNCLR01', '8661002030');

INSERT INTO EMPLEADO (id_persona, rfc_empleado, fecha_ingreso, sueldo_base)
VALUES ('MECJ850101HMNCLR01', 'MECJ850101AB1', '2020-03-15', 38000.00);

INSERT INTO MEDICO (id_persona, cedula_profesional, id_especialidad)
VALUES ('MECJ850101HMNCLR01', 'CED-987654', 1);

-- Registro de Paciente
INSERT INTO PERSONA (id_persona, primer_nombre, apellido_paterno, apellido_materno, calle, numero, colonia, codigo_postal, ciudad, fecha_nacimiento)
VALUES ('GARA920512MMNCLR02', 'Ana', 'Garcia', 'Rios', 'Calle Hidalgo', '108', 'Zona Centro', '25700', 'Monclova', '1992-05-12');

INSERT INTO PACIENTE (id_persona, no_expediente, tipo_sangre)
VALUES ('GARA920512MMNCLR02', 'EXP-2026-001', 'O+');

-- Registro de Consulta y Prescripción
INSERT INTO CONSULTA (fecha, hora, diagnostico, costo, id_medico, id_paciente, id_aseguradora)
VALUES ('2026-11-22', '10:30:00', 'Hipertension arterial controlada', 850.00, 'MECJ850101HMNCLR01', 'GARA920512MMNCLR02', 'ASEG-01');

INSERT INTO PRESCRIPCION (id_consulta, id_tratamiento, dosis_prescrita, frecuencia, duracion_dias)
VALUES (1, 1, '50 mg via oral', 'Cada 24 horas por la manana', 30);
GO

SELECT * FROM PERSONA;
SELECT * FROM ESPECIALIDAD;
SELECT * FROM MEDICO;
SELECT * FROM PACIENTE;
SELECT * FROM CONSULTA;
SELECT * FROM PRESCRIPCION;
GO