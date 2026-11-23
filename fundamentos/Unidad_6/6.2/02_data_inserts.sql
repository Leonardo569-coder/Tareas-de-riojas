-- ============================================================================
-- SGBD: Microsoft SQL Server (T-SQL)
-- Proyecto: Hospital Regional Universitario (HospitalRegionalDB)
-- Estudiante: Leonardo Martinez Salinas (No. Control: I24050412)
-- Asignatura: Fundamentos de Bases de Datos - Unidad 6 (Tarea 6.2)
-- Catedratico: Ruben Miguel Riojas Rodriguez
-- Institucion: Tecnologico Nacional de Mexico - ITSM Campus Monclova
-- Archivo: 02_data_inserts.sql
-- Descripcion: Fase 2 (LMD / DML) - Poblado de datos de prueba en orden
--              jerarquico para validar claves primarias, foraneas y reglas
--              de integridad referencial.
-- ============================================================================

USE HospitalRegionalDB;
GO

-- 1. PERSONAS (10 registros: medicos, enfermeros, administrativos y pacientes)
INSERT INTO dbo.PERSONA (id_persona, primer_nombre, apellido_paterno, apellido_materno, calle, numero, colonia, codigo_postal, ciudad, fecha_nacimiento)
VALUES
    ('PER000000000000001', 'Carlos',   'Mendoza',   'Ruiz',     'Av. Morelos',     '120',  'Centro',      '25700', 'Monclova', '1980-04-15'),
    ('PER000000000000002', 'Elena',    'Castillo',  'Soto',     'Calle Hidalgo',   '405',  'Obrera Sur',  '25750', 'Monclova', '1985-09-22'),
    ('PER000000000000003', 'Javier',   'Ortiz',     'Vega',     'Blvd. Madero',    '890',  'San Jose',    '25720', 'Monclova', '1978-01-10'),
    ('PER000000000000004', 'Sofia',    'Navarro',   'Luna',     'Calle Juarez',    '212',  'El Pueblo',   '25730', 'Monclova', '1992-07-03'),
    ('PER000000000000005', 'Diego',    'Herrera',   'Paz',      'Av. Industrial',  '55',   'Guadalupe',   '25740', 'Monclova', '1988-11-30'),
    ('PER000000000000006', 'Valeria',  'Rios',      'Cruz',     'Calle Allende',   '710',  'Bellavista',  '25710', 'Monclova', '1995-03-18'),
    ('PER000000000000007', 'Mateo',    'Salazar',   'Diaz',     'Calle Zaragoza',  '304',  'Estancias',   '25760', 'Monclova', '1990-06-12'),
    ('PER000000000000008', 'Camila',   'Paredes',   'Mora',     'Av. Las Torres',  '1010', 'Miravalle',   '25770', 'Monclova', '1983-12-05'),
    ('PER000000000000009', 'Fernanda', 'Villarreal','Gomez',    'Calle Victoria',  '615',  'Tecnologico', '25716', 'Monclova', '1991-08-25'),
    ('PER000000000000010', 'Andres',   'Trevino',   'Garza',    'Blvd. Pape',      '1420', 'Los Pinos',   '25725', 'Monclova', '1987-02-14');
GO

-- 2. TELEFONOS MULTIVALORADOS
INSERT INTO dbo.TELEFONO_PERSONA (id_persona, telefono)
VALUES
    ('PER000000000000001', '8661001101'),
    ('PER000000000000001', '8661001199'),
    ('PER000000000000002', '8661002201'),
    ('PER000000000000004', '8662002202'),
    ('PER000000000000006', '8663003303'),
    ('PER000000000000007', '8664004404'),
    ('PER000000000000009', '8665005505');
GO

-- 3. CATALOGO DE ESPECIALIDADES
INSERT INTO dbo.ESPECIALIDAD (nombre_especialidad, descripcion)
VALUES
    ('Cardiologia',      'Diagnostico y tratamiento de enfermedades cardiovasculares'),
    ('Pediatria',        'Atencion medica integral de recien nacidos, ninos y adolescentes'),
    ('Medicina Interna', 'Atencion clinica integral de enfermedades del adulto'),
    ('Traumatologia',    'Lesiones del sistema musculoesqueletico y ortopedia');
GO

-- 4. CATALOGO DE ASEGURADORAS
INSERT INTO dbo.ASEGURADORA (id_aseguradora, nombre_empresa, porcentaje_cobertura)
VALUES
    ('SEG-01', 'Salud Integral del Norte',  80.00),
    ('SEG-02', 'Cobertura Medica Nacional', 50.00),
    ('SEG-03', 'Proteccion Familiar Plus', 100.00);
GO

-- 5. CATALOGO DE TRATAMIENTOS
INSERT INTO dbo.TRATAMIENTO (medicamento, dosis, duracion_dias)
VALUES
    ('Paracetamol 500mg', '1 tableta cada 8 hrs',  5),
    ('Amoxicilina 500mg', '1 capsula cada 8 hrs',  7),
    ('Ibuprofeno 400mg',  '1 tableta cada 8 hrs',  5),
    ('Omeprazol 20mg',    '1 capsula en ayunas',  14),
    ('Losartan 50mg',     '1 tableta cada 24 hrs',30);
GO

-- 6. PACIENTES (Nota: PER000000000000004 es paciente y tambien empleada administrativa)
INSERT INTO dbo.PACIENTE (id_persona, no_expediente, tipo_sangre)
VALUES
    ('PER000000000000004', 'EXP-2026-001', 'O+'),
    ('PER000000000000006', 'EXP-2026-002', 'A+'),
    ('PER000000000000007', 'EXP-2026-003', 'B+'),
    ('PER000000000000008', 'EXP-2026-004', 'O-');
GO

-- 7. EMPLEADOS
INSERT INTO dbo.EMPLEADO (id_persona, rfc_empleado, fecha_ingreso, sueldo_base)
VALUES
    ('PER000000000000001', 'MERC800415H01', '2015-02-01', 38500.00),
    ('PER000000000000002', 'CASE850922M02', '2018-06-15', 34200.00),
    ('PER000000000000003', 'ORTJ780110H03', '2012-09-10', 42000.00),
    ('PER000000000000004', 'NALS920703M04', '2021-03-01', 18500.00),
    ('PER000000000000005', 'HEDD881130H05', '2020-01-20', 21500.00),
    ('PER000000000000009', 'VIGF910825M06', '2019-07-12', 22000.00),
    ('PER000000000000010', 'TEGA870214H07', '2017-11-05', 19800.00);
GO

-- 8. SUBCLASES DE EMPLEADO: MEDICO, ENFERMERO Y ADMINISTRATIVO
INSERT INTO dbo.MEDICO (id_persona, cedula_profesional, id_especialidad)
VALUES
    ('PER000000000000001', 'CED-MED-1001', 1),
    ('PER000000000000002', 'CED-MED-1002', 2),
    ('PER000000000000003', 'CED-MED-1003', 3);
GO

INSERT INTO dbo.ENFERMERO (id_persona, turno, area_asignada)
VALUES
    ('PER000000000000005', 'Matutino',   'Urgencias'),
    ('PER000000000000009', 'Vespertino', 'Hospitalizacion');
GO

INSERT INTO dbo.ADMINISTRATIVO (id_persona, puesto, departamento)
VALUES
    ('PER000000000000004', 'Coordinadora de Admision', 'Archivo Clinico'),
    ('PER000000000000010', 'Analista de Facturacion',  'Finanzas y Seguros');
GO

-- 9. CONSULTAS MEDICAS (incluye consultas con aseguradora y consultas particulares NULL)
INSERT INTO dbo.CONSULTA (fecha, hora, diagnostico, costo, id_medico, id_paciente, id_aseguradora)
VALUES
    ('2026-11-05', '09:30:00', 'Hipertension arterial leve',      900.00,  'PER000000000000001', 'PER000000000000004', 'SEG-01'),
    ('2026-11-10', '11:00:00', 'Faringoamigdalitis aguda',        650.00,  'PER000000000000002', 'PER000000000000006', NULL),
    ('2026-11-14', '16:15:00', 'Gastritis cronica',               750.00,  'PER000000000000003', 'PER000000000000004', 'SEG-02'),
    ('2026-11-18', '10:45:00', 'Arritmia benigna en seguimiento', 1200.00, 'PER000000000000001', 'PER000000000000007', 'SEG-01'),
    ('2026-11-20', '12:30:00', 'Control metabolico general',      550.00,  'PER000000000000003', 'PER000000000000007', NULL),
    ('2026-11-22', '08:45:00', 'Evaluacion cardiovascular anual', 1100.00, 'PER000000000000001', 'PER000000000000006', 'SEG-03');
GO

-- 10. PRESCRIPCIONES (Relacion N:M entre CONSULTA y TRATAMIENTO)
INSERT INTO dbo.PRESCRIPCION (id_consulta, id_tratamiento, dosis_prescrita, frecuencia, duracion_dias)
VALUES
    (1, 5, '50 mg via oral',  'Cada 24 horas', 30),
    (1, 1, '500 mg via oral', 'En caso de cefalea', 5),
    (2, 2, '500 mg via oral', 'Cada 8 horas',   7),
    (2, 3, '400 mg via oral', 'Cada 8 horas',   5),
    (3, 4, '20 mg en ayunas', 'Cada 24 horas', 14),
    (4, 5, '50 mg via oral',  'Cada 24 horas', 30),
    (6, 1, '500 mg via oral', 'Cada 8 horas',   3);
GO

PRINT 'Fase 2 (02_data_inserts.sql) ejecutada correctamente: datos cargados.';
GO