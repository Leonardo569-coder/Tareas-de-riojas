-- ============================================================================
-- SGBD: Microsoft SQL Server (T-SQL)
-- Proyecto: Hospital Regional Universitario (HospitalRegionalDB)
-- Estudiante: Leonardo Martinez Salinas (No. Control: I24050412)
-- Asignatura: Fundamentos de Bases de Datos - Unidad 6 (Tarea 6.2)
-- Catedratico: Ruben Miguel Riojas Rodriguez
-- Institucion: Tecnologico Nacional de Mexico - ITSM Campus Monclova
-- Archivo: 03_queries_dml.sql
-- Descripcion: Fase 3 (LMD / DML) - Consultas SELECT basicas, filtros WHERE,
--              ordenamiento ORDER BY, agrupaciones GROUP BY/HAVING, funciones
--              de agregacion (COUNT, SUM, AVG, MAX, MIN), reuniones (INNER JOIN,
--              LEFT JOIN) y pruebas controladas de UPDATE y DELETE.
-- ============================================================================

USE HospitalRegionalDB;
GO

-- ----------------------------------------------------------------------------
-- 1. CONSULTA SELECT BASICA CON FILTRO CONDICIONAL (WHERE) Y ORDENAMIENTO (ORDER BY)
-- ----------------------------------------------------------------------------
SELECT
    id_consulta,
    fecha,
    hora,
    diagnostico,
    costo
FROM dbo.CONSULTA
WHERE costo >= 700.00
ORDER BY costo DESC, fecha ASC;
GO

-- ----------------------------------------------------------------------------
-- 2. REUNION INTERNA (INNER JOIN): MEDICOS, DATOS PERSONALES Y ESPECIALIDAD
-- ----------------------------------------------------------------------------
SELECT
    M.cedula_profesional,
    P.primer_nombre + ' ' + P.apellido_paterno AS nombre_medico,
    E.nombre_especialidad,
    EMP.sueldo_base
FROM dbo.MEDICO AS M
INNER JOIN dbo.EMPLEADO AS EMP
    ON M.id_persona = EMP.id_persona
INNER JOIN dbo.PERSONA AS P
    ON EMP.id_persona = P.id_persona
INNER JOIN dbo.ESPECIALIDAD AS E
    ON M.id_especialidad = E.id_especialidad
ORDER BY E.nombre_especialidad ASC, nombre_medico ASC;
GO

-- ----------------------------------------------------------------------------
-- 3. REUNION EXTERNA IZQUIERDA (LEFT JOIN): TODAS LAS CONSULTAS CON O SIN SEGURO
-- ----------------------------------------------------------------------------
SELECT
    C.id_consulta,
    C.fecha,
    PA.no_expediente,
    PER.primer_nombre + ' ' + PER.apellido_paterno AS paciente,
    C.costo,
    COALESCE(A.nombre_empresa, 'Particular (Sin aseguradora)') AS aseguradora,
    COALESCE(A.porcentaje_cobertura, 0.00) AS cobertura_pct
FROM dbo.CONSULTA AS C
INNER JOIN dbo.PACIENTE AS PA
    ON C.id_paciente = PA.id_persona
INNER JOIN dbo.PERSONA AS PER
    ON PA.id_persona = PER.id_persona
LEFT JOIN dbo.ASEGURADORA AS A
    ON C.id_aseguradora = A.id_aseguradora
ORDER BY C.id_consulta ASC;
GO

-- ----------------------------------------------------------------------------
-- 4. AGRUPACION (GROUP BY / HAVING) Y FUNCIONES DE AGREGACION
--    (COUNT, SUM, AVG, MAX, MIN) POR MEDICO
-- ----------------------------------------------------------------------------
SELECT
    M.cedula_profesional,
    P.primer_nombre + ' ' + P.apellido_paterno AS medico,
    COUNT(C.id_consulta) AS total_consultas,
    SUM(C.costo)         AS ingreso_total,
    AVG(C.costo)         AS costo_promedio,
    MAX(C.costo)         AS costo_maximo,
    MIN(C.costo)         AS costo_minimo
FROM dbo.MEDICO AS M
INNER JOIN dbo.PERSONA AS P
    ON M.id_persona = P.id_persona
INNER JOIN dbo.CONSULTA AS C
    ON M.id_persona = C.id_medico
GROUP BY M.cedula_profesional, P.primer_nombre, P.apellido_paterno
HAVING COUNT(C.id_consulta) >= 1
ORDER BY ingreso_total DESC;
GO

-- ----------------------------------------------------------------------------
-- 5. PRUEBAS CONTROLADAS DE MANTENIMIENTO (UPDATE Y DELETE) E INTEGRIDAD
-- ----------------------------------------------------------------------------

-- 5.1 UPDATE controlado sobre consulta especifica
UPDATE dbo.CONSULTA
SET costo = 950.00,
    diagnostico = 'Hipertension arterial leve (control actualizado)'
WHERE id_consulta = 1;
GO

SELECT id_consulta, diagnostico, costo
FROM dbo.CONSULTA
WHERE id_consulta = 1;
GO

-- 5.2 Prueba de integridad referencial en UPDATE (ON UPDATE CASCADE)
BEGIN TRANSACTION;
    UPDATE dbo.ASEGURADORA
    SET id_aseguradora = 'SEG-01-REN'
    WHERE id_aseguradora = 'SEG-01';

    -- Comprobacion de propagacion automatica en CONSULTA
    SELECT id_consulta, id_aseguradora
    FROM dbo.CONSULTA
    WHERE id_aseguradora = 'SEG-01-REN';
ROLLBACK TRANSACTION;
GO

-- 5.3 Prueba de proteccion referencial en DELETE (ON DELETE NO ACTION)
BEGIN TRY
    DELETE FROM dbo.MEDICO
    WHERE id_persona = 'PER000000000000001';
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER()  AS codigo_error,
        ERROR_MESSAGE() AS mensaje_integridad_referencial;
END CATCH;
GO

-- 5.4 Prueba de DELETE controlado con cascada en PRESCRIPCION (ON DELETE CASCADE)
BEGIN TRANSACTION;
    DELETE FROM dbo.CONSULTA
    WHERE id_consulta = 6;

    -- Verifica que la prescripcion de la consulta 6 tambien se elimino en cascada
    SELECT COUNT(*) AS prescripciones_restantes_consulta_6
    FROM dbo.PRESCRIPCION
    WHERE id_consulta = 6;
ROLLBACK TRANSACTION;
GO

PRINT 'Fase 3 (03_queries_dml.sql) ejecutada correctamente.';
GO