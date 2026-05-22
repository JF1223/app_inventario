-- ============================================
-- PROCEDIMIENTOS ALMACENADOS - SISTEMA DE MANTENIMIENTO
-- ============================================

-- ============================================
-- CLIENTES
-- ===========================================

DELIMITER $$

CREATE PROCEDURE sp_cliente_create(
    IN p_nombre VARCHAR(150),
    IN p_documento VARCHAR(50),               
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(30),
    IN p_email VARCHAR(150)
)
BEGIN
    INSERT INTO clientes (nombre, documento, direccion, telefono, email, activo)
    VALUES (p_nombre, p_documento, p_direccion, p_telefono, p_email, TRUE);

    SELECT * FROM clientes WHERE id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_cliente_find_all()
BEGIN
    SELECT * FROM clientes
    WHERE activo = TRUE
    ORDER BY id ASC;
END$$

CREATE PROCEDURE sp_cliente_find_one(IN p_id INT)
BEGIN
    SELECT * FROM clientes WHERE id = p_id AND activo = TRUE;
END$$

CREATE PROCEDURE sp_cliente_update(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_documento VARCHAR(50),
    IN p_direccion VARCHAR(255),
    IN p_telefono VARCHAR(30),
    IN p_email VARCHAR(150)
)
BEGIN
    UPDATE clientes
    SET nombre = COALESCE(p_nombre, nombre),
        documento = COALESCE(p_documento, documento),
        direccion = COALESCE(p_direccion, direccion),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        updated_at = NOW()
    WHERE id = p_id AND activo = TRUE;

    SELECT * FROM clientes WHERE id = p_id;
END$$

CREATE PROCEDURE sp_cliente_delete(IN p_id INT)
BEGIN
    UPDATE clientes SET activo = FALSE, updated_at = NOW() WHERE id = p_id;
    SELECT ROW_COUNT() AS affected;
END$$

-- ============================================
-- EQUIPOS
-- ============================================

CREATE PROCEDURE sp_equipo_create(
    IN p_placa VARCHAR(50),
    IN p_estado VARCHAR(50),
    IN p_limpieza VARCHAR(255),
    IN p_uso VARCHAR(255),
    IN p_novedad VARCHAR(50),
    IN p_asignadas VARCHAR(255),
    IN p_observaciones TEXT,
    IN p_id_cliente INT
)
BEGIN
    INSERT INTO equipos (placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente)
    VALUES (p_placa, p_estado, p_limpieza, p_uso, p_novedad, p_asignadas, p_observaciones, p_id_cliente);

    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_equipo_find_all()
BEGIN
    SELECT e.*, c.nombre AS cliente_nombre, c.documento AS cliente_documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    ORDER BY e.id ASC;
END$$

CREATE PROCEDURE sp_equipo_find_one(IN p_id INT)
BEGIN
    SELECT e.*, c.nombre AS cliente_nombre, c.documento AS cliente_documento
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END$$

CREATE PROCEDURE sp_equipo_update(
    IN p_id INT,
    IN p_placa VARCHAR(50),
    IN p_estado VARCHAR(50),
    IN p_limpieza VARCHAR(255),
    IN p_uso VARCHAR(255),
    IN p_novedad VARCHAR(50),
    IN p_asignadas VARCHAR(255),
    IN p_observaciones TEXT,
    IN p_id_cliente INT
)
BEGIN
    UPDATE equipos
    SET placa = COALESCE(p_placa, placa),
        estado = COALESCE(p_estado, estado),
        limpieza = COALESCE(p_limpieza, limpieza),
        uso = COALESCE(p_uso, uso),
        novedad = COALESCE(p_novedad, novedad),
        asignadas = COALESCE(p_asignadas, asignadas),
        observaciones = COALESCE(p_observaciones, observaciones),
        id_cliente = COALESCE(p_id_cliente, id_cliente),
        updated_at = NOW()
    WHERE id = p_id;

    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END$$

CREATE PROCEDURE sp_equipo_delete(IN p_id INT)
BEGIN
    DELETE FROM equipos WHERE id = p_id;
    SELECT ROW_COUNT() AS affected;
END$$

CREATE PROCEDURE sp_equipo_find_by_estado(IN p_estado VARCHAR(50))
BEGIN
    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.estado = p_estado
    ORDER BY e.id ASC;
END$$

CREATE PROCEDURE sp_equipo_find_operativos_disponibles()
BEGIN
    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.estado = 'operativo' AND e.novedad = 'disponible'
    ORDER BY e.id ASC;
END$$

CREATE PROCEDURE sp_equipo_enviar_reparacion(IN p_id INT, IN p_observaciones TEXT)
BEGIN
    UPDATE equipos
    SET estado = 'en_reparacion',
        novedad = 'no_disponible',
        observaciones = COALESCE(p_observaciones, observaciones),
        updated_at = NOW()
    WHERE id = p_id;

    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END$$

CREATE PROCEDURE sp_equipo_finalizar_reparacion(IN p_id INT)
BEGIN
    UPDATE equipos
    SET estado = 'operativo',
        novedad = 'disponible',
        updated_at = NOW()
    WHERE id = p_id AND estado = 'en_reparacion';

    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END$$

CREATE PROCEDURE sp_equipo_reasignar(IN p_id INT, IN p_id_cliente INT)
BEGIN
    UPDATE equipos
    SET id_cliente = p_id_cliente,
        updated_at = NOW()
    WHERE id = p_id;

    SELECT e.*, c.nombre AS cliente_nombre
    FROM equipos e
    LEFT JOIN clientes c ON e.id_cliente = c.id
    WHERE e.id = p_id;
END$$

-- ============================================
-- TECNICOS
-- ============================================

CREATE PROCEDURE sp_tecnico_create(
    IN p_nombre VARCHAR(150),
    IN p_especialidad VARCHAR(100),
    IN p_contacto VARCHAR(50)
)
BEGIN
    INSERT INTO tecnicos (nombre, especialidad, contacto, activo)
    VALUES (p_nombre, p_especialidad, p_contacto, TRUE);

    SELECT * FROM tecnicos WHERE id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_tecnico_find_all()
BEGIN
    SELECT * FROM tecnicos
    WHERE activo = TRUE
    ORDER BY id ASC;
END$$

CREATE PROCEDURE sp_tecnico_find_one(IN p_id INT)
BEGIN
    SELECT * FROM tecnicos WHERE id = p_id AND activo = TRUE;
END$$

CREATE PROCEDURE sp_tecnico_update(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_especialidad VARCHAR(100),
    IN p_contacto VARCHAR(50)
)
BEGIN
    UPDATE tecnicos
    SET nombre = COALESCE(p_nombre, nombre),
        especialidad = COALESCE(p_especialidad, especialidad),
        contacto = COALESCE(p_contacto, contacto),
        updated_at = NOW()
    WHERE id = p_id AND activo = TRUE;

    SELECT * FROM tecnicos WHERE id = p_id;
END$$

CREATE PROCEDURE sp_tecnico_delete(IN p_id INT)
BEGIN
    UPDATE tecnicos SET activo = FALSE, updated_at = NOW() WHERE id = p_id;
    SELECT ROW_COUNT() AS affected;
END$$

-- ============================================
-- ORDENES DE SERVICIO
-- ============================================

CREATE PROCEDURE sp_orden_create(
    IN p_id_equipo INT,
    IN p_tipo VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_id_tecnico INT
)
BEGIN
    INSERT INTO ordenes_servicio (id_equipo, tipo, descripcion, id_tecnico, estado, fecha_limite)
    VALUES (p_id_equipo, p_tipo, p_descripcion, p_id_tecnico, 'pendiente', DATE_ADD(NOW(), INTERVAL 7 DAY));

    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_orden_find_all()
BEGIN
    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre,
           c.nombre AS cliente_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    LEFT JOIN clientes c ON eq.id_cliente = c.id
    ORDER BY o.id DESC;
END$$

CREATE PROCEDURE sp_orden_find_one(IN p_id INT)
BEGIN
    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre,
           c.nombre AS cliente_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    LEFT JOIN clientes c ON eq.id_cliente = c.id
    WHERE o.id = p_id;
END$$

CREATE PROCEDURE sp_orden_asignar_tecnico(IN p_id_orden INT, IN p_id_tecnico INT)
BEGIN
    UPDATE ordenes_servicio
    SET id_tecnico = p_id_tecnico,
        estado = 'en_proceso',
        fecha_inicio = NOW(),
        updated_at = NOW()
    WHERE id = p_id_orden;

    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = p_id_orden;
END$$

CREATE PROCEDURE sp_orden_actualizar_estado(IN p_id_orden INT, IN p_nuevo_estado VARCHAR(50), IN p_observaciones TEXT)
BEGIN
    UPDATE ordenes_servicio
    SET estado = p_nuevo_estado,
        observaciones = COALESCE(p_observaciones, observaciones),
        updated_at = NOW()
    WHERE id = p_id_orden;

    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = p_id_orden;
END$$

CREATE PROCEDURE sp_orden_cerrar(IN p_id_orden INT, IN p_observaciones TEXT)
BEGIN
    UPDATE ordenes_servicio
    SET estado = 'finalizada',
        fecha_fin = NOW(),
        observaciones = COALESCE(p_observaciones, observaciones),
        updated_at = NOW()
    WHERE id = p_id_orden;

    UPDATE equipos
    SET estado = 'operativo', novedad = 'disponible', updated_at = NOW()
    WHERE id = (SELECT id_equipo FROM ordenes_servicio WHERE id = p_id_orden);

    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.id = p_id_orden;
END$$

CREATE PROCEDURE sp_orden_verificar_plazos()
BEGIN
    SELECT o.*,
           eq.placa AS equipo_placa,
           t.nombre AS tecnico_nombre,
           CASE
               WHEN o.fecha_limite < NOW() AND o.estado != 'finalizada' THEN 'VENCIDA'
               WHEN DATE_ADD(o.fecha_limite, INTERVAL -1 DAY) < NOW() AND o.estado != 'finalizada' THEN 'POR VENCER'
               ELSE 'OK'
           END AS estado_plazo
    FROM ordenes_servicio o
    LEFT JOIN equipos eq ON o.id_equipo = eq.id
    LEFT JOIN tecnicos t ON o.id_tecnico = t.id
    WHERE o.estado != 'finalizada'
    ORDER BY o.fecha_limite ASC;
END$$

CREATE PROCEDURE sp_orden_delete(IN p_id INT)
BEGIN
    DELETE FROM ordenes_servicio WHERE id = p_id;
    SELECT ROW_COUNT() AS affected;
END$$

DELIMITER ;
