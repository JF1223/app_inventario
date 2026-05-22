-- ============================================
-- FUNCIONES PARA POSTGRESQL/SUPABASE
-- SISTEMA DE MANTENIMIENTO
-- ============================================

-- ============================================
-- TABLA: CLIENTES
-- ============================================

-- Crear cliente
CREATE OR REPLACE FUNCTION sp_cliente_create(
    p_nombre VARCHAR(150),
    p_documento VARCHAR(50),
    p_direccion VARCHAR(255),
    p_telefono VARCHAR(30),
    p_email VARCHAR(150)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    documento VARCHAR(50),
    direccion VARCHAR(255),
    telefono VARCHAR(30),
    email VARCHAR(150),
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO clientes(nombre, documento, direccion, telefono, email, activo)
    VALUES (p_nombre, p_documento, p_direccion, p_telefono, p_email, TRUE)
    RETURNING *;
END;
$$;

-- Listar todos los clientes (activos)
CREATE OR REPLACE FUNCTION sp_cliente_find_all()
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    documento VARCHAR(50),
    direccion VARCHAR(255),
    telefono VARCHAR(30),
    email VARCHAR(150),
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
    ORDER BY id ASC;
END;
$$;

-- Buscar cliente por ID
CREATE OR REPLACE FUNCTION sp_cliente_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    documento VARCHAR(50),
    direccion VARCHAR(255),
    telefono VARCHAR(30),
    email VARCHAR(150),
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
    WHERE id = p_id AND activo = TRUE;
END;
$$;

-- Actualizar cliente
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
    nombre VARCHAR(150),
    documento VARCHAR(50),
    direccion VARCHAR(255),
    telefono VARCHAR(30),
    email VARCHAR(150),
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE clientes
    SET
        nombre = COALESCE(p_nombre, nombre),
        documento = COALESCE(p_documento, documento),
        direccion = COALESCE(p_direccion, direccion),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        updated_at = NOW()
    WHERE id = p_id AND activo = TRUE;

    RETURN QUERY
    SELECT *
    FROM clientes
    WHERE id = p_id;
END;
$$;

-- "Eliminar" cliente (desactivar)
CREATE OR REPLACE FUNCTION sp_cliente_delete(p_id INT)
RETURNS TABLE (affected INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE clientes
    SET activo = FALSE, updated_at = NOW()
    WHERE id = p_id;

    RETURN QUERY
    SELECT 1 AS affected;
END;
$$;

-- ============================================
-- TABLA: EQUIPOS
-- ============================================

-- Crear equipo
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
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150),
    cliente_documento VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO equipos(
        placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente
    )
    VALUES (
        p_placa, p_estado, p_limpieza, p_uso, p_novedad, p_asignadas, p_observaciones, p_id_cliente
    )
    RETURNING
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre,
        c.documento AS cliente_documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id;
END;
$$;

-- Listar todos los equipos
CREATE OR REPLACE FUNCTION sp_equipo_find_all()
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150),
    cliente_documento VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre,
        c.documento AS cliente_documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    ORDER BY e.id ASC;
END;
$$;

-- Buscar equipo por ID
CREATE OR REPLACE FUNCTION sp_equipo_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150),
    cliente_documento VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre,
        c.documento AS cliente_documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END;
$$;

-- Actualizar equipo
CREATE OR REPLACE FUNCTION sp_equipo_update(
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
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150),
    cliente_documento VARCHAR(50)
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
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre,
        c.documento AS cliente_documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END;
$$;

-- Eliminar equipo
CREATE OR REPLACE FUNCTION sp_equipo_delete(p_id INT)
RETURNS TABLE (affected INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM equipos WHERE id = p_id;
    RETURN QUERY SELECT 1 AS affected;
END;
$$;

-- Buscar equipos por estado
CREATE OR REPLACE FUNCTION sp_equipo_find_by_estado(p_estado VARCHAR(50))
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.estado = p_estado
    ORDER BY e.id ASC;
END;
$$;

-- Buscar equipos operativos y disponibles
CREATE OR REPLACE FUNCTION sp_equipo_find_operativos_disponibles()
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.estado = 'operativo' AND e.novedad = 'disponible'
    ORDER BY e.id ASC;
END;
$$;

-- Enviar equipo a reparación
CREATE OR REPLACE FUNCTION sp_equipo_enviar_reparacion(p_id INT, p_observaciones TEXT)
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE equipos
    SET
        estado = 'en_reparacion',
        novedad = 'no_disponible',
        observaciones = COALESCE(p_observaciones, observaciones),
        updated_at = NOW()
    WHERE id = p_id;

    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END;
$$;

-- Finalizar reparación de equipo
CREATE OR REPLACE FUNCTION sp_equipo_finalizar_reparacion(p_id INT)
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE equipos
    SET
        estado = 'operativo',
        novedad = 'disponible',
        updated_at = NOW()
    WHERE id = p_id AND estado = 'en_reparacion';

    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END;
$$;

-- Reasignar equipo a otro cliente
CREATE OR REPLACE FUNCTION sp_equipo_reasignar(p_id INT, p_id_cliente INT)
RETURNS TABLE (
    id INT,
    placa VARCHAR(50),
    estado VARCHAR(50),
    tipo_reparacion VARCHAR(50),
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad VARCHAR(50),
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    cliente_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE equipos
    SET
        id_cliente = p_id_cliente,
        updated_at = NOW()
    WHERE id = p_id;

    RETURN QUERY
    SELECT
        e.id,
        e.placa,
        e.estado,
        e.tipo_reparacion,
        e.limpieza,
        e.uso,
        e.novedad,
        e.asignadas,
        e.observaciones,
        e.id_cliente,
        e.created_at,
        e.updated_at,
        c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END;
$$;

-- ============================================
-- TABLA: TECNICOS
-- ============================================

-- Crear técnico
CREATE OR REPLACE FUNCTION sp_tecnico_create(
    p_nombre VARCHAR(150),
    p_especialidad VARCHAR(100),
    p_contacto VARCHAR(50)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    especialidad VARCHAR(100),
    contacto VARCHAR(50),
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO tecnicos(nombre, especialidad, contacto, activo)
    VALUES (p_nombre, p_especialidad, p_contacto, TRUE)
    RETURNING *;
END;
$$;

-- Listar todos los técnicos (activos)
CREATE OR REPLACE FUNCTION sp_tecnico_find_all()
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    especialidad VARCHAR(100),
    contacto VARCHAR(50),
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM tecnicos
    WHERE activo = TRUE
    ORDER BY id ASC;
END;
$$;

-- Buscar técnico por ID
CREATE OR REPLACE FUNCTION sp_tecnico_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    especialidad VARCHAR(100),
    contacto VARCHAR(50),
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM tecnicos
    WHERE id = p_id AND activo = TRUE;
END;
$$;

-- Actualizar técnico
CREATE OR REPLACE FUNCTION sp_tecnico_update(
    p_id INT,
    p_nombre VARCHAR(150),
    p_especialidad VARCHAR(100),
    p_contacto VARCHAR(50)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR(150),
    especialidad VARCHAR(100),
    contacto VARCHAR(50),
    activo BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tecnicos
    SET
        nombre = COALESCE(p_nombre, nombre),
        especialidad = COALESCE(p_especialidad, especialidad),
        contacto = COALESCE(p_contacto, contacto),
        updated_at = NOW()
    WHERE id = p_id AND activo = TRUE;

    RETURN QUERY
    SELECT *
    FROM tecnicos
    WHERE id = p_id;
END;
$$;

-- "Eliminar" técnico (desactivar)
CREATE OR REPLACE FUNCTION sp_tecnico_delete(p_id INT)
RETURNS TABLE (affected INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tecnicos
    SET activo = FALSE, updated_at = NOW()
    WHERE id = p_id;

    RETURN QUERY
    SELECT 1 AS affected;
END;
$$;

-- ============================================
-- TABLA: ORDENES DE SERVICIO
-- ============================================

-- Crear orden de servicio
CREATE OR REPLACE FUNCTION sp_orden_create(
    p_id_equipo INT,
    p_tipo VARCHAR(50),
    p_descripcion TEXT,
    p_id_tecnico INT
)
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO ordenes_servicio(
        id_equipo, tipo, descripcion, id_tecnico, estado, fecha_limite
    )
    VALUES (
        p_id_equipo, p_tipo, p_descripcion, p_id_tecnico, 'pendiente', NOW() + INTERVAL '7 days'
    )
    RETURNING id INTO v_id;

    RETURN QUERY
    SELECT
        o.id,
        o.id_equipo,
        o.tipo,
        o.descripcion,
        o.id_tecnico,
        o.estado,
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = v_id;
END;
$$;

-- Listar todas las órdenes de servicio
CREATE OR REPLACE FUNCTION sp_orden_find_all()
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150),
    cliente_nombre VARCHAR(150)
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
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre,
        c.nombre AS cliente_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    LEFT JOIN clientes c ON eq.id_cliente = c.id
    ORDER BY o.id DESC;
END;
$$;

-- Buscar orden por ID
CREATE OR REPLACE FUNCTION sp_orden_find_one(p_id INT)
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150),
    cliente_nombre VARCHAR(150)
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
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre,
        c.nombre AS cliente_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    LEFT JOIN clientes c ON eq.id_cliente = c.id
    WHERE o.id = p_id;
END;
$$;

-- Asignar técnico a una orden
CREATE OR REPLACE FUNCTION sp_orden_asignar_tecnico(p_id_orden INT, p_id_tecnico INT)
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ordenes_servicio
    SET
        id_tecnico = p_id_tecnico,
        estado = 'en_proceso',
        fecha_inicio = NOW(),
        updated_at = NOW()
    WHERE id = p_id_orden;

    RETURN QUERY
    SELECT
        o.id,
        o.id_equipo,
        o.tipo,
        o.descripcion,
        o.id_tecnico,
        o.estado,
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = p_id_orden;
END;
$$;

-- Actualizar estado de una orden
CREATE OR REPLACE FUNCTION sp_orden_actualizar_estado(
    p_id_orden INT,
    p_nuevo_estado VARCHAR(50),
    p_observaciones TEXT
)
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ordenes_servicio
    SET
        estado = p_nuevo_estado,
        observaciones = COALESCE(p_observaciones, observaciones),
        updated_at = NOW()
    WHERE id = p_id_orden;

    RETURN QUERY
    SELECT
        o.id,
        o.id_equipo,
        o.tipo,
        o.descripcion,
        o.id_tecnico,
        o.estado,
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = p_id_orden;
END;
$$;

-- Cerrar orden de servicio
CREATE OR REPLACE FUNCTION sp_orden_cerrar(p_id_orden INT, p_observaciones TEXT)
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ordenes_servicio
    SET
        estado = 'finalizada',
        fecha_fin = NOW(),
        observaciones = COALESCE(p_observaciones, observaciones),
        updated_at = NOW()
    WHERE id = p_id_orden;

    UPDATE equipos
    SET
        estado = 'operativo',
        novedad = 'disponible',
        updated_at = NOW()
    WHERE id = (SELECT id_equipo FROM ordenes_servicio WHERE id = p_id_orden);

    RETURN QUERY
    SELECT
        o.id,
        o.id_equipo,
        o.tipo,
        o.descripcion,
        o.id_tecnico,
        o.estado,
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = p_id_orden;
END;
$$;

-- Verificar plazos de órdenes
CREATE OR REPLACE FUNCTION sp_orden_verificar_plazos()
RETURNS TABLE (
    id INT,
    id_equipo INT,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_tecnico INT,
    estado VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    fecha_limite TIMESTAMP,
    observaciones TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    equipo_placa VARCHAR(50),
    tecnico_nombre VARCHAR(150),
    estado_plazo VARCHAR(20)
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
        o.fecha_inicio,
        o.fecha_fin,
        o.fecha_limite,
        o.observaciones,
        o.created_at,
        o.updated_at,
        eq.placa AS equipo_placa,
        t.nombre AS tecnico_nombre,
        CASE
            WHEN o.fecha_limite < NOW() AND o.estado != 'finalizada' THEN 'VENCIDA'
            WHEN o.fecha_limite - INTERVAL '1 day' < NOW() AND o.estado != 'finalizada' THEN 'POR VENCER'
            ELSE 'OK'
        END AS estado_plazo
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.estado != 'finalizada'
    ORDER BY o.fecha_limite ASC;
END;
$$;

-- Eliminar orden de servicio
CREATE OR REPLACE FUNCTION sp_orden_delete(p_id INT)
RETURNS TABLE (affected INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ordenes_servicio WHERE id = p_id;
    RETURN QUERY SELECT 1 AS affected;
END;
$$;
