
-- ============================================
-- FUNCIONES Y PROCEDIMIENTOS - POSTGRESQL
-- SISTEMA DE MANTENIMIENTO
-- ============================================

-- ============================================
-- CLIENTES
-- ============================================

CREATE OR REPLACE FUNCTION sp_cliente_create(
    p_nombre VARCHAR(150),
    p_documento VARCHAR(50),
    p_direccion VARCHAR(255),
    p_telefono VARCHAR(30),
    p_email VARCHAR(150)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    documento VARCHAR,
    direccion VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO clientes(nombre, documento, direccion, telefono, email, activo)
    VALUES (p_nombre, p_documento, p_direccion, p_telefono, p_email, TRUE);

    RETURN QUERY
    SELECT c.*
    FROM clientes c
    ORDER BY c.id DESC
    LIMIT 1;
END;
$$;

CREATE OR REPLACE FUNCTION sp_cliente_find_all()
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    documento VARCHAR,
    direccion VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM clientes
    WHERE activo = TRUE
    ORDER BY clientes.id ASC;
END;
$$;

CREATE OR REPLACE FUNCTION sp_cliente_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    documento VARCHAR,
    direccion VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM clientes
    WHERE clientes.id = p_id
    AND activo = TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION sp_cliente_update(
    p_id INT,
    p_nombre VARCHAR(150),
    p_documento VARCHAR(50),
    p_direccion VARCHAR(255),
    p_telefono VARCHAR(30),
    p_email VARCHAR(150)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    documento VARCHAR,
    direccion VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE clientes
    SET nombre = COALESCE(p_nombre, nombre),
        documento = COALESCE(p_documento, documento),
        direccion = COALESCE(p_direccion, direccion),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        updated_at = NOW()
    WHERE clientes.id = p_id
    AND activo = TRUE;

    RETURN QUERY
    SELECT *
    FROM clientes
    WHERE clientes.id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION sp_cliente_delete(p_id INT)
RETURNS TABLE (affected INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE clientes
    SET activo = FALSE,
        updated_at = NOW()
    WHERE clientes.id = p_id;

    RETURN QUERY
    SELECT 1;
END;
$$;

-- ============================================
-- EQUIPOS
-- ============================================

CREATE OR REPLACE FUNCTION sp_equipo_create(
    p_placa VARCHAR(50),
    p_estado VARCHAR(50),
    p_limpieza VARCHAR(255),
    p_uso VARCHAR(255),
    p_novedad VARCHAR(50),
    p_asignadas VARCHAR(255),
    p_observaciones TEXT,
    p_id_cliente INT
)
RETURNS TABLE (
    id INT,
    placa VARCHAR,
    estado VARCHAR,
    limpieza VARCHAR,
    uso VARCHAR,
    novedad VARCHAR,
    asignadas VARCHAR,
    observaciones TEXT,
    id_cliente INT,
    cliente_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO equipos(
        placa,
        estado,
        limpieza,
        uso,
        novedad,
        asignadas,
        observaciones,
        id_cliente
    )
    VALUES (
        p_placa,
        p_estado,
        p_limpieza,
        p_uso,
        p_novedad,
        p_asignadas,
        p_observaciones,
        p_id_cliente
    )
    RETURNING equipos.id INTO v_id;

    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = v_id;
END;
$$;

CREATE OR REPLACE FUNCTION sp_equipo_find_all()
RETURNS TABLE (
    id INT,
    placa VARCHAR,
    estado VARCHAR,
    limpieza VARCHAR,
    uso VARCHAR,
    novedad VARCHAR,
    asignadas VARCHAR,
    observaciones TEXT,
    id_cliente INT,
    cliente_nombre VARCHAR,
    cliente_documento VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        c.nombre,
        c.documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    ORDER BY e.id ASC;
END;
$$;

CREATE OR REPLACE FUNCTION sp_equipo_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    placa VARCHAR,
    estado VARCHAR,
    limpieza VARCHAR,
    uso VARCHAR,
    novedad VARCHAR,
    asignadas VARCHAR,
    observaciones TEXT,
    id_cliente INT,
    cliente_nombre VARCHAR,
    cliente_documento VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        c.nombre,
        c.documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END;
$$;

-- ============================================
-- TECNICOS
-- ============================================

CREATE OR REPLACE FUNCTION sp_tecnico_create(
    p_nombre VARCHAR(150),
    p_especialidad VARCHAR(100),
    p_contacto VARCHAR(50)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    especialidad VARCHAR,
    contacto VARCHAR,
    activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tecnicos(nombre, especialidad, contacto, activo)
    VALUES (p_nombre, p_especialidad, p_contacto, TRUE);

    RETURN QUERY
    SELECT *
    FROM tecnicos
    ORDER BY tecnicos.id DESC
    LIMIT 1;
END;
$$;

CREATE OR REPLACE FUNCTION sp_tecnico_find_all()
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    especialidad VARCHAR,
    contacto VARCHAR,
    activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM tecnicos
    WHERE activo = TRUE
    ORDER BY tecnicos.id ASC;
END;
$$;

CREATE OR REPLACE FUNCTION sp_tecnico_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    nombre VARCHAR,
    especialidad VARCHAR,
    contacto VARCHAR,
    activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM tecnicos
    WHERE tecnicos.id = p_id
    AND activo = TRUE;
END;
$$;

-- ============================================
-- ORDENES DE SERVICIO
-- ============================================

CREATE OR REPLACE FUNCTION sp_orden_create(
    p_id_equipo INT,
    p_tipo VARCHAR(50),
    p_descripcion TEXT,
    p_id_tecnico INT
)
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR,
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR,
    fecha_limite TIMESTAMP,
    equipo_placa VARCHAR,
    tecnico_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO ordenes_servicio(
        id_equipo,
        tipo,
        descripcion,
        id_tecnico,
        estado,
        fecha_limite
    )
    VALUES (
        p_id_equipo,
        p_tipo,
        p_descripcion,
        p_id_tecnico,
        'pendiente',
        NOW() + INTERVAL '7 days'
    )
    RETURNING ordenes_servicio.id INTO v_id;

    RETURN QUERY
    SELECT
        o.id,
        o.id_equipo,
        o.tipo,
        o.descripcion,
        o.id_tecnico,
        o.estado,
        o.fecha_limite,
        eq.placa,
        t.nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = v_id;
END;
$$;

CREATE OR REPLACE FUNCTION sp_orden_find_all()
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR,
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR,
    fecha_limite TIMESTAMP,
    equipo_placa VARCHAR,
    tecnico_nombre VARCHAR,
    cliente_nombre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id,
        o.id_equipo,
        o.tipo,
        o.descripcion,
        o.id_tecnico,
        o.estado,
        o.fecha_limite,
        eq.placa,
        t.nombre,
        c.nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    LEFT JOIN clientes c ON eq.id_cliente = c.id
    ORDER BY o.id DESC;
END;
$$;
```
