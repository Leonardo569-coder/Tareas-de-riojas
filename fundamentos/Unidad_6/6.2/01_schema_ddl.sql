-- ============================================================================
-- SGBD: Microsoft SQL Server (T-SQL)
-- Proyecto: Hospital Regional Universitario (HospitalRegionalDB)
-- Estudiante: Leonardo Martinez Salinas (No. Control: I24050412)
-- Asignatura: Fundamentos de Bases de Datos - Unidad 6 (Tarea 6.2)
-- Catedratico: Ruben Miguel Riojas Rodriguez
-- Institucion: Tecnologico Nacional de Mexico - ITSM Campus Monclova
-- Archivo: 01_schema_ddl.sql
-- Descripcion: Fase 1 (LDD / DDL) - Creacion de la base de datos, tablas
--              normalizadas (3FN/FNBC), claves primarias, foraneas y
--              restricciones de dominio e integridad referencial.
-- ============================================================================

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

-- ----------------------------------------------------------------------------
-- 1. SUPERCLASE Y CATALOGOS INDEPENDIENTES
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.PERSONA (
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

CREATE TABLE dbo.TELEFONO_PERSONA (
    id_persona          VARCHAR(18)     NOT NULL,
    telefono            VARCHAR(15)     NOT NULL,

    CONSTRAINT PK_TelefonoPersona PRIMARY KEY CLUSTERED (id_persona, telefono),
    CONSTRAINT FK_TelefonoPersona_Persona FOREIGN KEY (id_persona)
        REFERENCES dbo.PERSONA (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Telefono_Formato CHECK (LEN(telefono) >= 7 AND telefono NOT LIKE '%[^0-9]%')
);
GO

CREATE TABLE dbo.ESPECIALIDAD (
    id_especialidad     INT IDENTITY(1,1) NOT NULL,
    nombre_especialidad VARCHAR(100)      NOT NULL,
    descripcion         VARCHAR(250)      NULL,

    CONSTRAINT PK_Especialidad PRIMARY KEY CLUSTERED (id_especialidad),
    CONSTRAINT UQ_Especialidad_Nombre UNIQUE (nombre_especialidad)
);
GO

CREATE TABLE dbo.ASEGURADORA (
    id_aseguradora       VARCHAR(20)     NOT NULL,
    nombre_empresa       VARCHAR(120)    NOT NULL,
    porcentaje_cobertura DECIMAL(5,2)    NOT NULL,

    CONSTRAINT PK_Aseguradora PRIMARY KEY CLUSTERED (id_aseguradora),
    CONSTRAINT UQ_Aseguradora_Nombre UNIQUE (nombre_empresa),
    CONSTRAINT CHK_Aseguradora_Porcentaje CHECK (porcentaje_cobertura BETWEEN 0.00 AND 100.00)
);
GO

CREATE TABLE dbo.TRATAMIENTO (
    id_tratamiento      INT IDENTITY(1,1) NOT NULL,
    medicamento         VARCHAR(150)      NOT NULL,
    dosis               VARCHAR(100)      NOT NULL,
    duracion_dias       INT               NOT NULL,

    CONSTRAINT PK_Tratamiento PRIMARY KEY CLUSTERED (id_tratamiento),
    CONSTRAINT CHK_Tratamiento_Duracion CHECK (duracion_dias > 0)
);
GO

-- ----------------------------------------------------------------------------
-- 2. SUBCLASES DE NIVEL 1: PACIENTE Y EMPLEADO
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.PACIENTE (
    id_persona          VARCHAR(18)     NOT NULL,
    no_expediente       VARCHAR(30)     NOT NULL,
    tipo_sangre         VARCHAR(5)      NOT NULL,

    CONSTRAINT PK_Paciente PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Paciente_Expediente UNIQUE (no_expediente),
    CONSTRAINT FK_Paciente_Persona FOREIGN KEY (id_persona)
        REFERENCES dbo.PERSONA (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Paciente_TipoSangre CHECK (tipo_sangre IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);
GO

CREATE TABLE dbo.EMPLEADO (
    id_persona          VARCHAR(18)     NOT NULL,
    rfc_empleado        VARCHAR(13)     NOT NULL,
    fecha_ingreso       DATE            NOT NULL,
    sueldo_base         DECIMAL(10,2)   NOT NULL,

    CONSTRAINT PK_Empleado PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Empleado_RFC UNIQUE (rfc_empleado),
    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (id_persona)
        REFERENCES dbo.PERSONA (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Empleado_RFCLen CHECK (LEN(rfc_empleado) IN (12, 13)),
    CONSTRAINT CHK_Empleado_Sueldo CHECK (sueldo_base > 0),
    CONSTRAINT CHK_Empleado_FechaIngreso CHECK (fecha_ingreso <= CAST(GETDATE() AS DATE))
);
GO

-- ----------------------------------------------------------------------------
-- 3. SUBCLASES DE NIVEL 2: MEDICO, ENFERMERO Y ADMINISTRATIVO
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.MEDICO (
    id_persona          VARCHAR(18)     NOT NULL,
    cedula_profesional  VARCHAR(20)     NOT NULL,
    id_especialidad     INT             NOT NULL,

    CONSTRAINT PK_Medico PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Medico_Cedula UNIQUE (cedula_profesional),
    CONSTRAINT FK_Medico_Empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Medico_Especialidad FOREIGN KEY (id_especialidad)
        REFERENCES dbo.ESPECIALIDAD (id_especialidad)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

CREATE TABLE dbo.ENFERMERO (
    id_persona          VARCHAR(18)     NOT NULL,
    turno               VARCHAR(20)     NOT NULL,
    area_asignada       VARCHAR(80)     NOT NULL,

    CONSTRAINT PK_Enfermero PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_Enfermero_Empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT CHK_Enfermero_Turno CHECK (turno IN ('Matutino', 'Vespertino', 'Nocturno', 'Mixto'))
);
GO

CREATE TABLE dbo.ADMINISTRATIVO (
    id_persona          VARCHAR(18)     NOT NULL,
    puesto              VARCHAR(80)     NOT NULL,
    departamento        VARCHAR(80)     NOT NULL,

    CONSTRAINT PK_Administrativo PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_Administrativo_Empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO

-- ----------------------------------------------------------------------------
-- 4. TRANSACCIONES CLINICAS: CONSULTA Y PRESCRIPCION
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.CONSULTA (
    id_consulta         INT IDENTITY(1,1) NOT NULL,
    fecha               DATE            NOT NULL,
    hora                TIME(0)         NOT NULL,
    diagnostico         VARCHAR(300)    NOT NULL,
    costo               DECIMAL(10,2)   NOT NULL,
    id_medico           VARCHAR(18)     NOT NULL,
    id_paciente         VARCHAR(18)     NOT NULL,
    id_aseguradora      VARCHAR(20)     NULL,

    CONSTRAINT PK_Consulta PRIMARY KEY CLUSTERED (id_consulta),
    CONSTRAINT FK_Consulta_Medico FOREIGN KEY (id_medico)
        REFERENCES dbo.MEDICO (id_persona)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Consulta_Paciente FOREIGN KEY (id_paciente)
        REFERENCES dbo.PACIENTE (id_persona)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Consulta_Aseguradora FOREIGN KEY (id_aseguradora)
        REFERENCES dbo.ASEGURADORA (id_aseguradora)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT CHK_Consulta_Costo CHECK (costo >= 0.00)
);
GO

CREATE TABLE dbo.PRESCRIPCION (
    id_consulta         INT             NOT NULL,
    id_tratamiento      INT             NOT NULL,
    dosis_prescrita     VARCHAR(100)    NOT NULL,
    frecuencia          VARCHAR(100)    NOT NULL,
    duracion_dias       INT             NOT NULL,

    CONSTRAINT PK_Prescripcion PRIMARY KEY CLUSTERED (id_consulta, id_tratamiento),
    CONSTRAINT FK_Prescripcion_Consulta FOREIGN KEY (id_consulta)
        REFERENCES dbo.CONSULTA (id_consulta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Prescripcion_Tratamiento FOREIGN KEY (id_tratamiento)
        REFERENCES dbo.TRATAMIENTO (id_tratamiento)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CHK_Prescripcion_Duracion CHECK (duracion_dias > 0)
);
GO

PRINT 'Fase 1 (01_schema_ddl.sql) ejecutada correctamente: 12 tablas creadas.';
GO