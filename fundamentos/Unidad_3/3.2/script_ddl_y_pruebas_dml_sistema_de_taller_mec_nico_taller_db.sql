-- =====================================================================
-- SCRIPT LDD / DDL: SISTEMA DE TALLER MECÁNICO Y REFACCIONARIA (taller_db)
-- Motor Target: Microsoft SQL Server (T-SQL)
-- Estudiante: Leonardo Martinez Salinas
-- No. de Control: I24050412
-- Asignatura: Fundamentos de Bases de Datos
-- Catedrático: Ruben Miguel Riojas Rodriguez
-- =====================================================================

-- 0. Creación y selección de la base de datos
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'taller_db')
BEGIN
    CREATE DATABASE taller_db;
END
GO

USE taller_db;
GO

-- Limpieza previa en orden inverso de dependencias
DROP TABLE IF EXISTS DETALLE_REFACCION_ORDEN;
DROP TABLE IF EXISTS ORDEN_SERVICIO;
DROP TABLE IF EXISTS REFACCION;
DROP TABLE IF EXISTS VEHICULO;
DROP TABLE IF EXISTS MECANICO;
DROP TABLE IF EXISTS CLIENTE;
DROP TABLE IF EXISTS TELEFONO_CLIENTE;
DROP TABLE IF EXISTS PERSONA;
GO

-- 1. Tabla PERSONA (Superclase)
CREATE TABLE PERSONA (
    id_persona      INT IDENTITY(1,1) NOT NULL,
    curp            VARCHAR(18)       NOT NULL,
    nombre          VARCHAR(60)       NOT NULL,
    apellido_pat    VARCHAR(60)       NOT NULL,
    apellido_mat    VARCHAR(60)       NULL,
    fecha_registro  DATE              NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT pk_persona PRIMARY KEY (id_persona),
    CONSTRAINT uq_persona_curp UNIQUE (curp),
    CONSTRAINT chk_persona_curp_len CHECK (LEN(curp) = 18)
);
GO

-- 2. Tabla TELEFONO_CLIENTE (Atributo multivalorado)
CREATE TABLE TELEFONO_CLIENTE (
    id_telefono     INT IDENTITY(1,1) NOT NULL,
    id_persona      INT               NOT NULL,
    numero_tel      VARCHAR(15)       NOT NULL,
    tipo_linea      VARCHAR(15)       NOT NULL DEFAULT 'Celular',
    CONSTRAINT pk_telefono_cliente PRIMARY KEY (id_telefono),
    CONSTRAINT fk_tel_persona FOREIGN KEY (id_persona)
        REFERENCES PERSONA(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_tipo_linea CHECK (tipo_linea IN ('Celular', 'Casa', 'Trabajo'))
);
GO

-- 3. Tabla CLIENTE (Subtipo de PERSONA)
CREATE TABLE CLIENTE (
    id_cliente      INT IDENTITY(1,1) NOT NULL,
    id_persona      INT               NOT NULL,
    rfc             VARCHAR(13)       NULL,
    correo          VARCHAR(100)      NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_persona UNIQUE (id_persona),
    CONSTRAINT fk_cliente_persona FOREIGN KEY (id_persona)
        REFERENCES PERSONA(id_persona) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_cliente_rfc_len CHECK (rfc IS NULL OR LEN(rfc) IN (12, 13))
);
GO

-- 4. Tabla MECANICO (Subtipo de PERSONA)
CREATE TABLE MECANICO (
    num_empleado    VARCHAR(20)       NOT NULL,
    id_persona      INT               NOT NULL,
    especialidad    VARCHAR(60)       NOT NULL,
    salario_mensual DECIMAL(10,2)     NOT NULL,
    activo          BIT               NOT NULL DEFAULT 1,
    CONSTRAINT pk_mecanico PRIMARY KEY (num_empleado),
    CONSTRAINT uq_mecanico_persona UNIQUE (id_persona),
    CONSTRAINT fk_mecanico_persona FOREIGN KEY (id_persona)
        REFERENCES PERSONA(id_persona) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT chk_mecanico_salario CHECK (salario_mensual > 0)
);
GO

-- 5. Tabla VEHICULO
CREATE TABLE VEHICULO (
    vin             VARCHAR(17)       NOT NULL,
    id_cliente      INT               NOT NULL,
    marca           VARCHAR(40)       NOT NULL,
    modelo          VARCHAR(40)       NOT NULL,
    anio            INT               NOT NULL,
    color           VARCHAR(30)       NOT NULL,
    CONSTRAINT pk_vehiculo PRIMARY KEY (vin),
    CONSTRAINT fk_vehiculo_cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT chk_vehiculo_vin_len CHECK (LEN(vin) = 17),
    CONSTRAINT chk_vehiculo_anio CHECK (anio BETWEEN 1950 AND 2027)
);
GO

-- 6. Tabla REFACCION
CREATE TABLE REFACCION (
    sku             VARCHAR(25)       NOT NULL,
    nombre_pieza    VARCHAR(100)      NOT NULL,
    precio_unitario DECIMAL(10,2)     NOT NULL,
    stock_actual    INT               NOT NULL DEFAULT 0,
    CONSTRAINT pk_refaccion PRIMARY KEY (sku),
    CONSTRAINT chk_refaccion_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_refaccion_stock CHECK (stock_actual >= 0)
);
GO

-- 7. Tabla ORDEN_SERVICIO
CREATE TABLE ORDEN_SERVICIO (
    folio_orden     VARCHAR(20)       NOT NULL,
    vin_vehiculo    VARCHAR(17)       NOT NULL,
    num_empleado    VARCHAR(20)       NOT NULL,
    fecha_ingreso   DATETIME2         NOT NULL DEFAULT SYSDATETIME(),
    falla_reportada NVARCHAR(MAX)     NOT NULL,
    mano_obra       DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
    estado          VARCHAR(20)       NOT NULL DEFAULT 'Abierta',
    CONSTRAINT pk_orden_servicio PRIMARY KEY (folio_orden),
    CONSTRAINT fk_orden_vehiculo FOREIGN KEY (vin_vehiculo)
        REFERENCES VEHICULO(vin) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT fk_orden_mecanico FOREIGN KEY (num_empleado)
        REFERENCES MECANICO(num_empleado) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT chk_orden_mano_obra CHECK (mano_obra >= 0),
    CONSTRAINT chk_orden_estado CHECK (estado IN ('Abierta', 'En Diagnostico', 'En Reparacion', 'Entregada', 'Cancelada'))
);
GO

-- 8. Tabla DETALLE_REFACCION_ORDEN
CREATE TABLE DETALLE_REFACCION_ORDEN (
    id_detalle      INT IDENTITY(1,1) NOT NULL,
    folio_orden     VARCHAR(20)       NOT NULL,
    sku_refaccion   VARCHAR(25)       NOT NULL,
    cantidad        INT               NOT NULL,
    subtotal        DECIMAL(10,2)     NOT NULL,
    CONSTRAINT pk_detalle_refaccion PRIMARY KEY (id_detalle),
    CONSTRAINT fk_detalle_orden FOREIGN KEY (folio_orden)
        REFERENCES ORDEN_SERVICIO(folio_orden) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_refaccion FOREIGN KEY (sku_refaccion)
        REFERENCES REFACCION(sku) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0)
);
GO

-- =====================================================================
-- A. INSERCIÓN DE DATOS DE PRUEBA VÁLIDOS (DML)
-- =====================================================================

-- Cliente y vehículo
INSERT INTO PERSONA (curp, nombre, apellido_pat, apellido_mat)
VALUES ('MAGL900415HMNCLR01', 'Luis', 'Martinez', 'Garza');

INSERT INTO CLIENTE (id_persona, rfc, correo)
VALUES (1, 'MAGL900415AB1', 'luis.martinez@taller.mx');

INSERT INTO TELEFONO_CLIENTE (id_persona, numero_tel, tipo_linea)
VALUES (1, '8661234567', 'Celular');

INSERT INTO VEHICULO (vin, id_cliente, marca, modelo, anio, color)
VALUES ('1HGCM82633A004352', 1, 'Honda', 'Accord', 2018, 'Plata');

-- Mecánico, refacción y orden de servicio
INSERT INTO PERSONA (curp, nombre, apellido_pat, apellido_mat)
VALUES ('ROSR821103HMNCLR02', 'Roberto', 'Sanchez', 'Ruiz');

INSERT INTO MECANICO (num_empleado, id_persona, especialidad, salario_mensual)
VALUES ('MEC-01', 2, 'Suspension y Frenos', 18500.00);

INSERT INTO REFACCION (sku, nombre_pieza, precio_unitario, stock_actual)
VALUES ('REF-BAL-001', 'Juego de balatas delanteras ceramicas', 850.00, 15);

INSERT INTO ORDEN_SERVICIO (folio_orden, vin_vehiculo, num_empleado, falla_reportada, mano_obra, estado)
VALUES ('ORD-2026-001', '1HGCM82633A004352', 'MEC-01', 'Rechinido al frenar y vibracion en volante', 650.00, 'En Reparacion');

INSERT INTO DETALLE_REFACCION_ORDEN (folio_orden, sku_refaccion, cantidad, subtotal)
VALUES ('ORD-2026-001', 'REF-BAL-001', 1, 850.00);
GO

-- =====================================================================
-- B. PRUEBA DE FALLO POR RESTRICCIÓN CHECK (SALARIO NEGATIVO)
-- =====================================================================
INSERT INTO PERSONA (curp, nombre, apellido_pat, apellido_mat)
VALUES ('TEST950101HMNCLR99', 'Carlos', 'Lopez', 'Diaz');

BEGIN TRY
    INSERT INTO MECANICO (num_empleado, id_persona, especialidad, salario_mensual)
    VALUES ('MEC-ERR', 3, 'Electrico', -2500.00);
END TRY
BEGIN CATCH
    PRINT 'Prueba Salario Negativo bloqueada correctamente: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =====================================================================
-- C. PRUEBA DE FALLO POR RESTRICCIÓN CHECK (VIN INVÁLIDO)
-- =====================================================================
BEGIN TRY
    INSERT INTO VEHICULO (vin, id_cliente, marca, modelo, anio, color)
    VALUES ('VIN-CORTO-123', 1, 'Nissan', 'Versa', 2021, 'Blanco');
END TRY
BEGIN CATCH
    PRINT 'Prueba VIN Inválido bloqueada correctamente: ' + ERROR_MESSAGE();
END CATCH;
GO

-- =====================================================================
-- D. CONSULTAS DE VERIFICACIÓN DE RESULTADOS
-- =====================================================================
SELECT * FROM PERSONA;
SELECT * FROM CLIENTE;
SELECT * FROM MECANICO;
SELECT * FROM VEHICULO;
SELECT * FROM ORDEN_SERVICIO;
SELECT * FROM DETALLE_REFACCION_ORDEN;
GO