-- ============================================
-- CREAR EQUIPO
-- ============================================

CREATE OR REPLACE FUNCTION sp_crear_equipo(
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
    cliente_nombre VARCHAR,
    cliente_documento VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO equipos (
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
    );

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
        c.documento,
        e.created_at,
        e.updated_at
    FROM equipos e
    LEFT JOIN clientes c
        ON e.id_cliente = c.id
    ORDER BY e.id DESC
    LIMIT 1;

END;
$$;

-- ============================================
-- LISTAR EQUIPOS
-- ============================================

CREATE OR REPLACE FUNCTION sp_listar_equipos()
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
    cliente_documento VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
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
        c.documento,
        e.created_at,
        e.updated_at
    FROM equipos e
    LEFT JOIN clientes c
        ON e.id_cliente = c.id
    ORDER BY e.id ASC;

END;
$$;

-- ============================================
-- OBTENER EQUIPO
-- ============================================

CREATE OR REPLACE FUNCTION sp_obtener_equipo(
    p_id INT
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
    cliente_nombre VARCHAR,
    cliente_documento VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
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
        c.documento,
        e.created_at,
        e.updated_at
    FROM equipos e
    LEFT JOIN clientes c
        ON e.id_cliente = c.id
    WHERE e.id = p_id;

END;
$$;

-- ============================================
-- ACTUALIZAR EQUIPO
-- ============================================

CREATE OR REPLACE FUNCTION sp_actualizar_equipo(
    p_id INT,
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
    cliente_nombre VARCHAR,
    cliente_documento VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE equipos
    SET
        placa = COALESCE(p_placa, placa),
        estado = COALESCE(p_estado, estado),
        limpieza = COALESCE(p_limpieza, limpieza),
        uso = COALESCE(p_uso, uso),
        novedad = COALESCE(p_novedad, novedad),
        asignadas = COALESCE(p_asignadas, asignadas),
        observaciones = COALESCE(p_observaciones, observaciones),
        id_cliente = COALESCE(p_id_cliente, id_cliente),
        updated_at = NOW()
    WHERE id = p_id;

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
        c.documento,
        e.created_at,
        e.updated_at
    FROM equipos e
    LEFT JOIN clientes c
        ON e.id_cliente = c.id
    WHERE e.id = p_id;

END;
$$;

-- ============================================
-- ELIMINAR EQUIPO
-- ============================================

CREATE OR REPLACE FUNCTION sp_eliminar_equipo(
    p_id INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM equipos
    WHERE id = p_id;

    RETURN TRUE;

END;
$$;
