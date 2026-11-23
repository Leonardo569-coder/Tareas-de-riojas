-- ============================================================================
-- SGBD: Microsoft SQL Server (T-SQL)
-- Proyecto: Hospital Regional Universitario (HospitalRegionalDB)
-- Estudiante: Leonardo Martinez Salinas (No. Control: I24050412)
-- Asignatura: Fundamentos de Bases de Datos - Unidad 5 (Tarea 5.2)
-- Catedratico: Ruben Miguel Riojas Rodriguez
-- Institucion: Tecnologico Nacional de Mexico - ITSM Campus Monclova
-- Archivo: consultas_algebra_relacional_5_2.sql
-- Descripcion: Implementacion fisica en SQL Server de las 10 consultas
--              formalizadas en Algebra Relacional (basica y extendida)
--              sobre el esquema normalizado del Hospital Regional Universitario.
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
-- 1. DEFINICION DEL ESQUEMA RELACIONAL NORMALIZADO
-- ----------------------------------------------------------------------------

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

CREATE TABLE ASEGURADORA (
    id_aseguradora      VARCHAR(20)     NOT NULL,
    nombre_empresa      VARCHAR(120)    NOT NULL,
    porcentaje_cobertura DECIMAL(5,2)   NOT NULL,

    CONSTRAINT PK_Aseguradora PRIMARY KEY CLUSTERED (id_aseguradora),
    CONSTRAINT UQ_Aseguradora_Nombre UNIQUE (nombre_empresa),
    CONSTRAINT CHK_Aseguradora_Porcentaje CHECK (porcentaje_cobertura BETWEEN 0.00 AND 100.00)
);
GO

CREATE TABLE TRATAMIENTO (
    id_tratamiento      INT IDENTITY(1,1) NOT NULL,
    medicamento         VARCHAR(150)      NOT NULL,
    dosis               VARCHAR(100)      NOT NULL,
    duracion_dias       INT               NOT NULL,

    CONSTRAINT PK_Tratamiento PRIMARY KEY CLUSTERED (id_tratamiento),
    CONSTRAINT CHK_Tratamiento_Duracion CHECK (duracion_dias > 0)
);
GO

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

CREATE TABLE MEDICO (
    id_persona          VARCHAR(18)     NOT NULL,
    cedula_profesional  VARCHAR(20)     NOT NULL,
    especialidad        VARCHAR(100)    NOT NULL,

    CONSTRAINT PK_Medico PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_Medico_Cedula UNIQUE (cedula_profesional),
    CONSTRAINT FK_Medico_Empleado FOREIGN KEY (id_persona)
        REFERENCES EMPLEADO (id_persona)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO

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

-- ----------------------------------------------------------------------------
-- 2. DATOS DE PRUEBA PARA VALIDAR LAS 10 CONSULTAS
-- ----------------------------------------------------------------------------

INSERT INTO PERSONA VALUES
('PER000000000000001', 'Carlos',   'Mendoza',  'Ruiz',     'Av. Morelos',     '120',  'Centro',      '25700', 'Monclova', '1980-04-15'),
('PER000000000000002', 'Elena',    'Castillo', 'Soto',     'Calle Hidalgo',   '405',  'Obrera Sur',  '25750', 'Monclova', '1985-09-22'),
('PER000000000000003', 'Javier',   'Ortiz',    'Vega',     'Blvd. Madero',    '890',  'San Jose',    '25720', 'Monclova', '1978-01-10'),
('PER000000000000004', 'Sofia',    'Navarro',  'Luna',     'Calle Juarez',    '212',  'El Pueblo',   '25730', 'Monclova', '1992-07-03'),
('PER000000000000005', 'Diego',    'Herrera',  'Paz',      'Av. Industrial',  '55',   'Guadalupe',   '25740', 'Monclova', '1988-11-30'),
('PER000000000000006', 'Valeria',  'Rios',     'Cruz',     'Calle Allende',   '710',  'Bellavista',  '25710', 'Monclova', '1995-03-18'),
('PER000000000000007', 'Mateo',    'Salazar',  'Diaz',     'Calle Zaragoza',  '304',  'Estancias',   '25760', 'Monclova', '1990-06-12'),
('PER000000000000008', 'Camila',   'Paredes',  'Mora',     'Av. Las Torres',  '1010', 'Miravalle',   '25770', 'Monclova', '1983-12-05');
GO

INSERT INTO TELEFONO_PERSONA VALUES
('PER000000000000001', '8661001101'),
('PER000000000000001', '8661001199'),
('PER000000000000004', '8662002202'),
('PER000000000000006', '8663003303');
GO

INSERT INTO ASEGURADORA VALUES
('SEG-01', 'Salud Integral del Norte', 80.00),
('SEG-02', 'Cobertura Medica Nacional', 50.00),
('SEG-03', 'Proteccion Familiar Plus', 100.00);
GO

INSERT INTO TRATAMIENTO (medicamento, dosis, duracion_dias) VALUES
('Paracetamol 500mg', '1 tableta cada 8 hrs', 5),
('Amoxicilina 500mg', '1 capsula cada 8 hrs', 7),
('Ibuprofeno 400mg',  '1 tableta cada 8 hrs', 5),
('Omeprazol 20mg',    '1 capsula en ayunas', 14);
GO

INSERT INTO PACIENTE VALUES
('PER000000000000004', 'EXP-2026-001', 'O+'),
('PER000000000000006', 'EXP-2026-002', 'A+'),
('PER000000000000007', 'EXP-2026-003', 'B+'),
('PER000000000000008', 'EXP-2026-004', 'O-');
GO

INSERT INTO EMPLEADO VALUES
('PER000000000000001', 'MERC800415H01', '2015-02-01', 38500.00),
('PER000000000000002', 'CASE850922M02', '2018-06-15', 34200.00),
('PER000000000000003', 'ORTJ780110H03', '2012-09-10', 42000.00),
('PER000000000000005', 'HEDD881130H04', '2020-01-20', 21500.00);
GO

INSERT INTO MEDICO VALUES
('PER000000000000001', 'CED-MED-1001', 'Cardiologia'),
('PER000000000000002', 'CED-MED-1002', 'Pediatria'),
('PER000000000000003', 'CED-MED-1003', 'Medicina Interna');
GO

INSERT INTO ENFERMERO VALUES
('PER000000000000005', 'Matutino', 'Urgencias');
GO

INSERT INTO CONSULTA (fecha, hora, diagnostico, costo, id_medico, id_paciente, id_aseguradora) VALUES
('2026-10-05', '09:30:00', 'Hipertension arterial leve',      900.00,  'PER000000000000001', 'PER000000000000004', 'SEG-01'),
('2026-10-12', '11:00:00', 'Infeccion respiratoria aguda',    650.00,  'PER000000000000002', 'PER000000000000006', NULL),
('2026-10-18', '16:15:00', 'Gastritis cronica',               750.00,  'PER000000000000003', 'PER000000000000004', 'SEG-02'),
('2026-10-25', '10:45:00', 'Arritmia benigna en seguimiento', 1200.00, 'PER000000000000001', 'PER000000000000007', 'SEG-01');
GO

INSERT INTO PRESCRIPCION VALUES
(1, 1, '500 mg cada 8 hrs', 'Cada 8 horas',  5),
(1, 3, '400 mg cada 8 hrs', 'Cada 8 horas',  5),
(2, 1, '500 mg cada 8 hrs', 'Cada 8 horas',  5),
(2, 2, '500 mg cada 8 hrs', 'Cada 8 horas',  7),
(3, 4, '20 mg cada 24 hrs', 'Cada 24 horas', 14),
(4, 1, '500 mg cada 8 hrs', 'Cada 8 horas',  5),
(4, 3, '400 mg cada 8 hrs', 'Cada 8 horas',  5);
GO

-- ----------------------------------------------------------------------------
-- 3. CATALOGO DE 10 CONSULTAS EN SQL (EQUIVALENTES AL ALGEBRA RELACIONAL)
-- ----------------------------------------------------------------------------

-- Consulta 1 (Seleccion + Proyeccion):
-- pi_{no_expediente, tipo_sangre}(sigma_{tipo_sangre = 'O+'}(PACIENTE))
SELECT
    no_expediente,
    tipo_sangre
FROM PACIENTE
WHERE tipo_sangre = 'O+';
GO

-- Consulta 2 (Seleccion con predicado compuesto):
-- pi_{id_consulta, fecha, costo, diagnostico}(sigma_{costo >= 800.00 AND id_aseguradora IS NOT NULL}(CONSULTA))
SELECT
    id_consulta,
    fecha,
    costo,
    diagnostico
FROM CONSULTA
WHERE costo >= 800.00
  AND id_aseguradora IS NOT NULL;
GO

-- Consulta 3 (Reunion natural / equi-join entre MEDICO y PERSONA):
-- pi_{cedula_profesional, primer_nombre, apellido_paterno, especialidad}(MEDICO |x|_{id_persona = id_persona} PERSONA)
SELECT
    M.cedula_profesional,
    P.primer_nombre,
    P.apellido_paterno,
    M.especialidad
FROM MEDICO AS M
INNER JOIN PERSONA AS P
    ON M.id_persona = P.id_persona;
GO

-- Consulta 4 (Reunion de 3 tablas: CONSULTA, PACIENTE y PERSONA):
-- pi_{id_consulta, fecha, no_expediente, primer_nombre, apellido_paterno, diagnostico}((CONSULTA |x| PACIENTE) |x| PERSONA)
SELECT
    C.id_consulta,
    C.fecha,
    PA.no_expediente,
    PE.primer_nombre,
    PE.apellido_paterno,
    C.diagnostico
FROM CONSULTA AS C
INNER JOIN PACIENTE AS PA
    ON C.id_paciente = PA.id_persona
INNER JOIN PERSONA AS PE
    ON PA.id_persona = PE.id_persona;
GO

-- Consulta 5 (Reunion externa izquierda - LEFT OUTER JOIN):
-- pi_{primer_nombre, apellido_paterno, especialidad, id_consulta, fecha}((MEDICO |x| PERSONA) LEFT OUTER JOIN_{id_persona = id_medico} CONSULTA)
SELECT
    P.primer_nombre,
    P.apellido_paterno,
    M.especialidad,
    C.id_consulta,
    C.fecha
FROM MEDICO AS M
INNER JOIN PERSONA AS P
    ON M.id_persona = P.id_persona
LEFT OUTER JOIN CONSULTA AS C
    ON M.id_persona = C.id_medico;
GO

-- Consulta 6 (Diferencia de conjuntos - EXCEPT):
-- pi_{id_persona}(PACIENTE) - pi_{id_paciente}(CONSULTA)
SELECT
    id_persona
FROM PACIENTE
EXCEPT
SELECT
    id_paciente
FROM CONSULTA;
GO

-- Consulta 7 (Interseccion de conjuntos - INTERSECT):
-- pi_{id_persona}(PERSONA) INTERSECT pi_{id_persona}(TELEFONO_PERSONA)
SELECT
    id_persona
FROM PERSONA
INTERSECT
SELECT
    id_persona
FROM TELEFONO_PERSONA;
GO

-- Consulta 8 (Union de conjuntos compatibles - UNION):
-- pi_{id_persona, primer_nombre, apellido_paterno}(PACIENTE |x| PERSONA) UNION pi_{id_persona, primer_nombre, apellido_paterno}(MEDICO |x| PERSONA)
SELECT
    PA.id_persona,
    PE.primer_nombre,
    PE.apellido_paterno
FROM PACIENTE AS PA
INNER JOIN PERSONA AS PE
    ON PA.id_persona = PE.id_persona
UNION
SELECT
    M.id_persona,
    PE.primer_nombre,
    PE.apellido_paterno
FROM MEDICO AS M
INNER JOIN PERSONA AS PE
    ON M.id_persona = PE.id_persona;
GO

-- Consulta 9 (Agrupacion y agregacion extendida - G):
-- _{id_medico}G_{COUNT(id_consulta) AS total_consultas, SUM(costo) AS monto_total}(CONSULTA)
SELECT
    id_medico,
    COUNT(id_consulta) AS total_consultas,
    SUM(costo) AS monto_total
FROM CONSULTA
GROUP BY id_medico;
GO

-- Consulta 10 (Division relacional - NOT EXISTS / NOT EXISTS):
-- Pacientes que han recibido TODOS los tratamientos registrados en TRATAMIENTO
SELECT
    PA.id_persona,
    PA.no_expediente
FROM PACIENTE AS PA
WHERE NOT EXISTS (
    SELECT T.id_tratamiento
    FROM TRATAMIENTO AS T
    WHERE NOT EXISTS (
        SELECT 1
        FROM CONSULTA AS C
        INNER JOIN PRESCRIPCION AS PR
            ON C.id_consulta = PR.id_consulta
        WHERE C.id_paciente = PA.id_persona
          AND PR.id_tratamiento = T.id_tratamiento
    )
);
GO
