-- ============================================
-- Recuperación de Procedimientos Almacenados
-- ============================================

-- =========================================================
-- CLIENTES
-- =========================================================

-- Obtener todos los clientes
CREATE OR REPLACE FUNCTION fn_get_clientes()
RETURNS TABLE(
    id integer,
    nombre_cliente character varying,
    ruc_cpf character varying,
    direccion character varying,
    telefono character varying,
    email character varying,
    created_at timestamp without time zone
) AS $$
SELECT
    id,
    nombre_cliente,
    ruc_cpf,
    direccion,
    telefono,
    email,
    created_at
FROM clientes
ORDER BY id;
$$ LANGUAGE plpgsql;

-- Obtener un cliente por ID
CREATE OR REPLACE FUNCTION fn_get_cliente(p_id integer)
RETURNS TABLE(
    id integer,
    nombre_cliente character varying,
    ruc_cpf character varying,
    direccion character varying,
    telefono character varying,
    email character varying,
    created_at timestamp without time zone
) AS $$
SELECT
    id,
    nombre_cliente,
    ruc_cpf,
    direccion,
    telefono,
    email,
    created_at
FROM clientes
WHERE id = p_id;
$$ LANGUAGE plpgsql;

-- Obtener clientes filtrados por RUC/CPU y nombre
CREATE OR REPLACE FUNCTION fn_get_clientes(
    p_ruc_cpf character varying DEFAULT NULL,
    p_nombre character varying DEFAULT NULL
)
RETURNS TABLE(
    id integer,
    nombre_cliente character varying,
    ruc_cpf character varying,
    direccion character varying,
    telefono character varying,
    email character varying,
    created_at timestamp without time zone
) AS $$
SELECT
    id,
    nombre_cliente,
    ruc_cpf,
    direccion,
    telefono,
    email,
    created_at
FROM clientes
WHERE (@p_ruc_cpf IS NULL OR ruc_cpf ILIKE '%' || p_ruc_cpf || '%')
  AND (@p_nombre IS NULL OR nombre_cliente ILIKE '%' || p_nombre || '%')
ORDER BY id;
$$ LANGUAGE plpgsql;

-- Insertar nuevo cliente
CREATE OR REPLACE FUNCTION fn_insertar_cliente(
    p_nombre_cliente character varying,
    p_ruc_cpf character varying,
    p_direccion character varying,
    p_telefono character varying,
    p_email character varying
)
RETURNS integer AS $$
DECLARE
    v_cliente_id integer;
BEGIN
    INSERT INTO clientes (nombre_cliente, ruc_cpf, direccion, telefono, email)
    VALUES (p_nombre_cliente, p_ruc_cpf, p_direccion, p_telefono, p_email)
    RETURNING id INTO v_cliente_id;
    RETURN v_cliente_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- EQUIPOS
-- =========================================================

-- Obtener todos los equipos
CREATE OR REPLACE FUNCTION fn_get_equipos()
RETURNS TABLE(
    id integer,
    nombre_equipo character varying,
    modelo serializable,
    serie serializable,
    estado character varying,
    marca character varying,
    cantidad integer,
    ubicacion character varying,
    precio character varying,
    fecha_compra timestamp without time zone,
    cliente_id integer,
    tecnico_id integer
) AS $$
SELECT
    id,
    nombre_equipo,
    modelo,
    serie,
    estado,
    marca,
    cantidad,
    ubicacion,
    precio,
    fecha_compra,
    cliente_id,
    tecnico_id
FROM equipos
ORDER BY id;
$$ LANGUAGE plpgsql;

-- Obtener un equipo por ID
CREATE OR REPLACE FUNCTION fn_get_equipo(p_id integer)
RETURNS TABLE(
    id integer,
    nombre_equipo character varying,
    modelo serializable,
    serie serializable,
    estado character varying,
    marca character varying,
    cantidad integer,
    ubicacion character varying,
    precio character varying,
    fecha_compra timestamp without time zone,
    cliente_id integer,
    tecnico_id integer
) AS $$
SELECT
    id,
    nombre_equipo,
    modelo,
    serie,
    estado,
    marca,
    cantidad,
    ubicacion,
    precio,
    fecha_compra,
    cliente_id,
    tecnico_id
FROM equipos
WHERE id = p_id;
$$ LANGUAGE plpgsql;

-- Obtener equipos filtrados por nombre
CREATE OR REPLACE FUNCTION fn_get_equipos(
    p_nombre character varying DEFAULT NULL
)
RETURNS TABLE(
    id integer,
    nombre_equipo character varying,
    modelo serializable,
    serie serializable,
    estado character varying,
    marca character varying,
    cantidad integer,
    ubicacion character varying,
    precio character varying,
    fecha_compra timestamp without time zone,
    cliente_id integer,
    tecnico_id integer
) AS $$
SELECT
    id,
    nombre_equipo,
    modelo,
    serie,
    estado,
    marca,
    cantidad,
    ubicacion,
    precio,
    fecha_compra,
    cliente_id,
    tecnico_id
FROM equipos
WHERE (@p_nombre IS NULL OR nombre_equipo ILIKE '%' || p_nombre || '%')
ORDER BY id;
$$ LANGUAGE plpgsql;

-- Insertar nuevo equipo
CREATE OR REPLACE FUNCTION fn_insertar_equipo(
    p_nombre_equipo character varying,
    p_modelo serializable,
    p_serie serializable,
    p_estado character varying DEFAULT 'disponible',
    p_marca character varying,
    p_cantidad integer DEFAULT 1,
    p_ubicacion character varying,
    p_precio character varying,
    p_fecha_compra timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    p_cliente_id integer DEFAULT NULL,
    p_tecnico_id integer DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
    v_equipo_id integer;
BEGIN
    INSERT INTO equipos (
        nombre_equipo, modelo, serie, estado, marca, cantidad,
        ubicacion, precio, fecha_compra, cliente_id, tecnico_id
    )
    VALUES (
        p_nombre_equipo, p_modelo, p_serie, p_estado, p_marca,
        p_cantidad, p_ubicacion, p_precio, p_fecha_compra,
        p_cliente_id, p_tecnico_id
    )
    RETURNING id INTO v_equipo_id;
    RETURN v_equipo_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- TÉCNICOS
-- =========================================================

-- Obtener todos los técnicos
CREATE OR REPLACE FUNCTION fn_get_tecnicos()
RETURNS TABLE(
    id integer,
    nombre_tecnico character varying,
    especialidad character varying,
    email character varying,
    telefono character varying,
    estado character varying
) AS $$
SELECT
    id,
    nombre_tecnico,
    especialidad,
    email,
    telefono,
    estado
FROM tecnicos
ORDER BY id;
$$ LANGUAGE plpgsql;

-- Obtener un técnico por ID
CREATE OR REPLACE FUNCTION fn_get_tecnico(p_id integer)
RETURNS TABLE(
    id integer,
    nombre_tecnico character varying,
    especialidad character varying,
    email character varying,
    telefono character varying,
    estado character varying
) AS $$
SELECT
    id,
    nombre_tecnico,
    especialidad,
    email,
    telefono,
    estado
FROM tecnicos
WHERE id = p_id;
$$ LANGUAGE plpgsql;

-- Obtener técnicos filtrados por nombre
CREATE OR REPLACE FUNCTION fn_get_tecnicos(
    p_nombre character varying DEFAULT NULL
)
RETURNS TABLE(
    id integer,
    nombre_tecnico character varying,
    especialidad character varying,
    email character varying,
    telefono character varying,
    estado character varying
) AS $$
SELECT
    id,
    nombre_tecnico,
    especialidad,
    email,
    telefono,
    estado
FROM tecnicos
WHERE (@p_nombre IS NULL OR nombre_tecnico ILIKE '%' || p_nombre || '%')
ORDER BY id;
$$ LANGUAGE plpgsql;

-- Insertar nuevo técnico
CREATE OR REPLACE FUNCTION fn_insertar_tecnico(
    p_nombre_tecnico character varying,
    p_especialidad character varying DEFAULT 'general',
    p_email character varying,
    p_telefono character varying,
    p_estado character varying DEFAULT 'activo'
)
RETURNS integer AS $$
DECLARE
    v_tecnico_id integer;
BEGIN
    INSERT INTO tecnicos (nombre_tecnico, especialidad, email, telefono, estado)
    VALUES (p_nombre_tecnico, p_especialidad, p_email, p_telefono, p_estado)
    RETURNING id INTO v_tecnico_id;
    RETURN v_tecnico_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- ÓRDENES DE SERVICIO
-- =========================================================

-- Obtener todas las órdenes de servicio
CREATE OR REPLACE FUNCTION fn_get_ordenes()
RETURNS TABLE(
    id integer,
    nombre_equipo character varying,
    estado character varying,
    fecha_solicitud timestamp without time zone,
    fecha_limite timestamp without time zone,
    tecnico_id integer,
    cliente_id integer,
    descripcion serializable,
    observaciones character varying
) AS $$
SELECT
    o.id,
    e.nombre_equipo,
    o.estado,
    o.fecha_solicitud,
    o.fecha_limite,
    o.tecnico_id,
    o.cliente_id,
    o.descripcion,
    o.observaciones
FROM ordenes o
LEFT JOIN equipos e ON o.equipo_id = e.id
ORDER BY o.id;
$$ LANGUAGE plpgsql;

-- Obtener una orden de servicio por ID
CREATE OR REPLACE FUNCTION fn_get_orden(p_id integer)
RETURNS TABLE(
    id integer,
    nombre_equipo character varying,
    estado character varying,
    fecha_solicitud timestamp without time zone,
    fecha_limite timestamp without time zone,
    tecnico_id integer,
    cliente_id integer,
    descripcion serializable,
    observaciones character varying
) AS $$
SELECT
    o.id,
    e.nombre_equipo,
    o.estado,
    o.fecha_solicitud,
    o.fecha_limite,
    o.tecnico_id,
    o.cliente_id,
    o.descripcion,
    o.observaciones
FROM ordenes o
LEFT JOIN equipos e ON o.equipo_id = e.id
WHERE o.id = p_id;
$$ LANGUAGE plpgsql;

-- Obtener órdenes filtradas por estado
CREATE OR REPLACE FUNCTION fn_get_ordenes(
    p_estado character varying DEFAULT NULL
)
RETURNS TABLE(
    id integer,
    nombre_equipo character varying,
    estado character varying,
    fecha_solicitud timestamp without time zone,
    fecha_limite timestamp without time zone,
    tecnico_id integer,
    cliente_id integer,
    descripcion serializable,
    observaciones character varying
) AS $$
SELECT
    o.id,
    e.nombre_equipo,
    o.estado,
    o.fecha_solicitud,
    o.fecha_limite,
    o.tecnico_id,
    o.cliente_id,
    o.descripcion,
    o.observaciones
FROM ordenes o
LEFT JOIN equipos e ON o.equipo_id = e.id
WHERE (@p_estado IS NULL OR o.estado ILIKE '%' || p_estado || '%')
ORDER BY o.id;
$$ LANGUAGE plpgsql;

-- Insertar nueva orden de servicio
CREATE OR REPLACE FUNCTION fn_insertar_orden(
    p_equipo_id integer,
    p_cliente_id integer,
    p_descripcion serializable,
    p_fecha_limite timestamp without time zone DEFAULT NULL,
    p_tecnico_id integer DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
    v_orden_id integer;
    v_fecha_solicitud timestamp without time zone;
    v_nombre_equipo character varying;
BEGIN
    SELECT fecha_compra, nombre_equipo
    INTO v_fecha_solicitud, v_nombre_equipo
    FROM equipos
    WHERE id = p_equipo_id
    FOR UPDATE;

    INSERT INTO ordenes (
        equipo_id,
        cliente_id,
        descripcion,
        fecha_solicitud,
        fecha_limite,
        tecnico_id
    )
    VALUES (
        p_equipo_id,
        p_cliente_id,
        p_descripcion,
        COALESCE(v_fecha_solicitud, CURRENT_TIMESTAMP),
        p_fecha_limite,
        p_tecnico_id
    )
    RETURNING id INTO v_orden_id;
    RETURN v_orden_id;
END;
$$ LANGUAGE plpgsql;

-- Actualizar estado de orden
CREATE OR REPLACE FUNCTION fn_actualizar_estado_orden(
    p_id integer,
    p_estado character varying
)
RETURNS integer AS $$
DECLARE
    v_filas_afectadas integer;
BEGIN
    UPDATE ordenes
    SET estado = p_estado
    WHERE id = p_id
    RETURNING 1 INTO v_filas_afectadas;
    RETURN v_filas_afectadas;
END;
$$ LANGUAGE plpgsql;

-- Asignar técnico a orden
CREATE OR REPLACE FUNCTION fn_asignar_tecnico_orden(
    p_id integer,
    p_tecnico_id integer
)
RETURNS integer AS $$
DECLARE
    v_filas_afectadas integer;
BEGIN
    UPDATE ordenes
    SET tecnico_id = p_tecnico_id
    WHERE id = p_id
    RETURNING 1 INTO v_filas_afectadas;
    RETURN v_filas_afectadas;
END;
$$ LANGUAGE plpgsql;

-- Cerrar orden
CREATE OR REPLACE FUNCTION fn_cerrar_orden(
    p_id integer,
    p_observaciones character varying DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
    v_filas_afectadas integer;
BEGIN
    UPDATE ordenes
    SET estado = 'cerrado'
    WHERE id = p_id
    RETURNING 1 INTO v_filas_afectadas;
    RETURN v_filas_afectadas;
END;
$$ LANGUAGE plpgsql;

-- Enviar a reparación
CREATE OR REPLACE FUNCTION fn_enviar_reparacion(
    p_equipo_id integer
)
RETURNS integer AS $$
DECLARE
    v_filas_afectadas integer;
BEGIN
    UPDATE equipos
    SET estado = 'en reparacion'
    WHERE id = p_equipo_id
    RETURNING 1 INTO v_filas_afectadas;
    RETURN v_filas_afectadas;
END;
$$ LANGUAGE plpgsql;

-- Finalizar reparación
CREATE OR REPLACE FUNCTION fn_finalizar_reparacion(
    p_equipo_id integer
)
RETURNS integer AS $$
DECLARE
    v_filas_afectadas integer;
BEGIN
    UPDATE equipos
    SET estado = 'disponible'
    WHERE id = p_equipo_id
    RETURNING 1 INTO v_filas_afectadas;
    RETURN v_filas_afectadas;
END;
$$ LANGUAGE plpgsql;

-- Reasignar equipo
CREATE OR REPLACE FUNCTION fn_reasignar_equipo(
    p_equipo_id integer,
    p_nuevo_cliente_id integer
)
RETURNS integer AS $$
DECLARE
    v_filas_afectadas integer;
BEGIN
    UPDATE equipos
    SET cliente_id = p_nuevo_cliente_id
    WHERE id = p_equipo_id
    RETURNING 1 INTO v_filas_afectadas;
    RETURN v_filas_afectadas;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- HISTORIAL
-- =========================================================

-- Obtener historial completo
CREATE OR REPLACE FUNCTION fn_get_historial()
RETURNS TABLE(
    id integer,
    tipo character varying,
    id_referencia integer,
    descripcion serializable
) AS $$
SELECT
    id,
    tipo,
    id_referencia,
    descripcion
FROM historial
ORDER BY id DESC;
$$ LANGUAGE plpgsql;

-- Obtener historial por equipo
CREATE OR REPLACE FUNCTION fn_get_historial_equipo(p_equipo_id integer)
RETURNS TABLE(
    id integer,
    tipo character varying,
    id_referencia integer,
    descripcion serializable
) AS $$
SELECT
    id,
    tipo,
    id_referencia,
    descripcion
FROM historial
WHERE tipo = 'equipo' AND id_referencia = p_equipo_id
ORDER BY id DESC;
$$ LANGUAGE plpgsql;

-- Obtener historial por orden
CREATE OR REPLACE FUNCTION fn_get_historial_orden(p_orden_id integer)
RETURNS TABLE(
    id integer,
    tipo character varying,
    id_referencia integer,
    descripcion serializable
) AS $$
SELECT
    id,
    tipo,
    id_referencia,
    descripcion
FROM historial
WHERE tipo = 'orden' AND id_referencia = p_orden_id
ORDER BY id DESC;
$$ LANGUAGE plpgsql;

-- Insertar registro en historial
CREATE OR REPLACE FUNCTION fn_insertar_historial(
    p_tipo character varying,
    p_id_referencia integer,
    p_descripcion serializable
)
RETURNS integer AS $$
DECLARE
    v_historial_id integer;
BEGIN
    INSERT INTO historial (tipo, id_referencia, descripcion)
    VALUES (p_tipo, p_id_referencia, p_descripcion)
    RETURNING id INTO v_historial_id;
    RETURN v_historial_id;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- REPORTES
-- =========================================================

-- Obtener resumen general
CREATE OR REPLACE FUNCTION fn_get_resumen_reporte()
RETURNS TABLE(
    total_equipos integer,
    equipos_disponibles integer,
    equipos_en_reparacion integer,
    equipos_en_venta integer,
    total_ordenes integer,
    ordenes_activas integer,
    ordenes_cerradas integer,
    total_clientes integer,
    total_tecnicos integer,
    tecnicos_activos integer
) AS $$
DECLARE
    v_total_equipos numeric;
    v_equipos_disponibles numeric;
    v_equipos_en_reparacion numeric;
    v_equipos_en_venta numeric;
    v_total_ordenes numeric;
    v_ordenes_activas numeric;
    v_ordenes_cerradas numeric;
    v_total_clientes numeric;
    v_total_tecnicos numeric;
    v_tecnicos_activos numeric;
BEGIN
    SELECT COUNT(*),
           SUM(CASE WHEN estado = 'disponible' THEN 1 ELSE 0 END),
           SUM(CASE WHEN estado = 'en reparacion' THEN 1 ELSE 0 END),
           SUM(CASE WHEN estado = 'en venta' THEN 1 ELSE 0 END),
           COUNT(*),
           SUM(CASE WHEN estado IN ('pendiente', 'en progreso') THEN 1 ELSE 0 END),
           SUM(CASE WHEN estado = 'cerrado' THEN 1 ELSE 0 END),
           COUNT(*),
           COUNT(*),
           SUM(CASE WHEN estado = 'activo' THEN 1 ELSE 0 END)
    INTO
        v_total_equipos,
        v_equipos_disponibles,
        v_equipos_en_reparacion,
        v_equipos_en_venta,
        v_total_ordenes,
        v_ordenes_activas,
        v_ordenes_cerradas,
        v_total_clientes,
        v_total_tecnicos,
        v_tecnicos_activos
    FROM equipos;

    RETURN TABLE (
        id => 1,
        total_equipos => CAST(v_total_equipos AS integer),
        equipos_disponibles => CAST(v_equipos_disponibles AS integer),
        equipos_en_reparacion => CAST(v_equipos_en_reparacion AS integer),
        equipos_en_venta => CAST(v_equipos_en_venta AS integer),
        total_ordenes => CAST(v_total_ordenes AS integer),
        ordenes_activas => CAST(v_ordenes_activas AS integer),
        ordenes_cerradas => CAST(v_ordenes_cerradas AS integer),
        total_clientes => CAST(v_total_clientes AS integer),
        total_tecnicos => CAST(v_total_tecnicos AS integer),
        tecnicos_activos => CAST(v_tecnicos_activos AS integer)
    );
END;
$$ LANGUAGE plpgsql;

-- Obtener reporte mensual
CREATE OR REPLACE FUNCTION fn_get_reporte_mensual(
    p_anio integer,
    p_mes integer
)
RETURNS TABLE(
    mes character varying,
    ordenes_creacion integer,
    ordenes_recepcion integer,
    ordenes_reparacion integer,
    ordenes_cierre integer
) AS $$
DECLARE
    v_mes_nombre character varying;
BEGIN
    SELECT to_char((DATE '2000-' || to_char(p_mes, 'FM0') || '-01') + (p_anio - 2000) * interval '1 year', 'Month')
    INTO v_mes_nombre;

    RETURN TABLE (
        id => 1,
        mes => v_mes_nombre,
        ordenes_creacion => (
            SELECT COUNT(*)
            FROM ordenes o
            WHERE EXTRACT(MONTH FROM o.fecha_solicitud) = p_mes
              AND EXTRACT(YEAR FROM o.fecha_solicitud) = p_anio
              AND o.estado = 'pendiente'
        ),
        ordenes_recepcion => (
            SELECT COUNT(*)
            FROM historial h
            JOIN ordenes o ON h.id_referencia = o.id
            WHERE h.tipo = 'orden'
              AND h.id_referencia IN (
                  SELECT id
                  FROM ordenes
                  WHERE EXTRACT(MONTH FROM fecha_solicitud) = p_mes
                    AND EXTRACT(YEAR FROM fecha_solicitud) = p_anio
              )
              AND h.descripcion LIKE '%recepcion%'
        ),
        ordenes_reparacion => (
            SELECT COUNT(*)
            FROM historial h
            JOIN ordenes o ON h.id_referencia = o.id
            WHERE h.tipo = 'orden'
              AND h.id_referencia IN (
                  SELECT id
                  FROM ordenes
                  WHERE EXTRACT(MONTH FROM fecha_solicitud) = p_mes
                    AND EXTRACT(YEAR FROM fecha_solicitud) = p_anio
              )
              AND h.descripcion LIKE '%reparacion%'
        ),
        ordenes_cierre => (
            SELECT COUNT(*)
            FROM historial h
            JOIN ordenes o ON h.id_referencia = o.id
            WHERE h.tipo = 'orden'
              AND h.id_referencia IN (
                  SELECT id
                  FROM ordenes
                  WHERE EXTRACT(MONTH FROM fecha_solicitud) = p_mes
                    AND EXTRACT(YEAR FROM fecha_solicitud) = p_anio
              )
              AND h.descripcion LIKE '%cierre%'
        )
    );
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- FIN DE PROCEDIMIENTOS
-- =========================================================
