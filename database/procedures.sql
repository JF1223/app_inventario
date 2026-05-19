USE neveras_db;

DELIMITER //

-- =========================
-- CLIENTES
-- =========================

DROP PROCEDURE IF EXISTS sp_crear_cliente;
CREATE PROCEDURE sp_crear_cliente(
  IN p_nombre VARCHAR(150),
  IN p_documento VARCHAR(50),
  IN p_direccion VARCHAR(255),
  IN p_telefono VARCHAR(30),
  IN p_email VARCHAR(150)
)
BEGIN
  INSERT INTO clientes (nombre, documento, direccion, telefono, email)
  VALUES (p_nombre, p_documento, p_direccion, p_telefono, p_email);

  SELECT LAST_INSERT_ID() AS id;
END //

DROP PROCEDURE IF EXISTS sp_listar_clientes;
CREATE PROCEDURE sp_listar_clientes()
BEGIN
  SELECT * FROM clientes ORDER BY created_at DESC;
END //

DROP PROCEDURE IF EXISTS sp_obtener_cliente;
CREATE PROCEDURE sp_obtener_cliente(IN p_id INT)
BEGIN
  SELECT * FROM clientes WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_actualizar_cliente;
CREATE PROCEDURE sp_actualizar_cliente(
  IN p_id INT,
  IN p_nombre VARCHAR(150),
  IN p_documento VARCHAR(50),
  IN p_direccion VARCHAR(255),
  IN p_telefono VARCHAR(30),
  IN p_email VARCHAR(150)
)
BEGIN
  UPDATE clientes
  SET nombre = p_nombre,
      documento = p_documento,
      direccion = p_direccion,
      telefono = p_telefono,
      email = p_email,
      updated_at = NOW()
  WHERE id = p_id;

  SELECT * FROM clientes WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_eliminar_cliente;
CREATE PROCEDURE sp_eliminar_cliente(IN p_id INT)
BEGIN
  DELETE FROM clientes WHERE id = p_id;
END //

-- =========================
-- EQUIPOS
-- =========================

DROP PROCEDURE IF EXISTS sp_crear_equipo;
CREATE PROCEDURE sp_crear_equipo(
  IN p_placa VARCHAR(50),
  IN p_estado VARCHAR(30),
  IN p_limpieza VARCHAR(255),
  IN p_uso VARCHAR(255),
  IN p_novedad VARCHAR(30),
  IN p_asignadas VARCHAR(255),
  IN p_observaciones TEXT,
  IN p_id_cliente INT
)
BEGIN
  INSERT INTO equipos (placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente)
  VALUES (p_placa, p_estado, p_limpieza, p_uso, p_novedad, p_asignadas, p_observaciones, p_id_cliente);

  SELECT LAST_INSERT_ID() AS id;
END //

DROP PROCEDURE IF EXISTS sp_listar_equipos;
CREATE PROCEDURE sp_listar_equipos()
BEGIN
  SELECT e.*, c.nombre AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id;
END //

DROP PROCEDURE IF EXISTS sp_obtener_equipo;
CREATE PROCEDURE sp_obtener_equipo(IN p_id INT)
BEGIN
  SELECT e.*, c.nombre AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_actualizar_equipo;
CREATE PROCEDURE sp_actualizar_equipo(
  IN p_id INT,
  IN p_placa VARCHAR(50),
  IN p_estado VARCHAR(30),
  IN p_limpieza VARCHAR(255),
  IN p_uso VARCHAR(255),
  IN p_novedad VARCHAR(30),
  IN p_asignadas VARCHAR(255),
  IN p_observaciones TEXT,
  IN p_id_cliente INT
)
BEGIN
  UPDATE equipos
  SET placa = p_placa,
      estado = p_estado,
      limpieza = p_limpieza,
      uso = p_uso,
      novedad = p_novedad,
      asignadas = p_asignadas,
      observaciones = p_observaciones,
      id_cliente = p_id_cliente,
      updated_at = NOW()
  WHERE id = p_id;

  SELECT * FROM equipos WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_enviar_a_reparacion;
CREATE PROCEDURE sp_enviar_a_reparacion(
  IN p_id_equipo INT,
  IN p_observaciones TEXT
)
BEGIN
  UPDATE equipos
  SET estado = 'en_reparacion',
      novedad = 'no_disponible',
      observaciones = p_observaciones,
      updated_at = NOW()
  WHERE id = p_id_equipo;
END //

-- Alias requerido por el backend
DROP PROCEDURE IF EXISTS sp_equipo_enviar_reparacion;
CREATE PROCEDURE sp_equipo_enviar_reparacion(
  IN p_id INT,
  IN p_observaciones TEXT
)
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
END //

DROP PROCEDURE IF EXISTS sp_finalizar_reparacion;
CREATE PROCEDURE sp_finalizar_reparacion(IN p_id INT)
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
END //

DROP PROCEDURE IF EXISTS sp_reasignar_equipo;
CREATE PROCEDURE sp_reasignar_equipo(IN p_id INT, IN p_id_cliente INT)
BEGIN
  UPDATE equipos
  SET id_cliente = p_id_cliente,
      updated_at = NOW()
  WHERE id = p_id;

  SELECT e.*, c.nombre AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_listar_equipos_por_estado;
CREATE PROCEDURE sp_listar_equipos_por_estado(IN p_estado VARCHAR(50))
BEGIN
  SELECT e.*, c.nombre AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.estado = p_estado
  ORDER BY e.id ASC;
END //

DROP PROCEDURE IF EXISTS sp_listar_operativos_disponibles;
CREATE PROCEDURE sp_listar_operativos_disponibles()
BEGIN
  SELECT e.*, c.nombre AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.estado = 'operativo' AND e.novedad = 'disponible'
  ORDER BY e.id ASC;
END //

DROP PROCEDURE IF EXISTS sp_eliminar_equipo;
CREATE PROCEDURE sp_eliminar_equipo(IN p_id INT)
BEGIN
  DELETE FROM equipos WHERE id = p_id;
END //

-- =========================
-- TECNICOS
-- =========================

DROP PROCEDURE IF EXISTS sp_crear_tecnico;
CREATE PROCEDURE sp_crear_tecnico(
  IN p_nombre VARCHAR(150),
  IN p_especialidad VARCHAR(100),
  IN p_contacto VARCHAR(50)
)
BEGIN
  INSERT INTO tecnicos (nombre, especialidad, contacto, activo)
  VALUES (p_nombre, p_especialidad, p_contacto, TRUE);

  SELECT LAST_INSERT_ID() AS id;
END //

DROP PROCEDURE IF EXISTS sp_listar_tecnicos;
CREATE PROCEDURE sp_listar_tecnicos()
BEGIN
  SELECT * FROM tecnicos;
END //

DROP PROCEDURE IF EXISTS sp_obtener_tecnico;
CREATE PROCEDURE sp_obtener_tecnico(IN p_id INT)
BEGIN
  SELECT * FROM tecnicos WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_actualizar_tecnico;
CREATE PROCEDURE sp_actualizar_tecnico(
  IN p_id INT,
  IN p_nombre VARCHAR(150),
  IN p_especialidad VARCHAR(100),
  IN p_contacto VARCHAR(50)
)
BEGIN
  UPDATE tecnicos
  SET nombre = p_nombre,
      especialidad = p_especialidad,
      contacto = p_contacto
  WHERE id = p_id;

  SELECT * FROM tecnicos WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_eliminar_tecnico;
CREATE PROCEDURE sp_eliminar_tecnico(IN p_id INT)
BEGIN
  DELETE FROM tecnicos WHERE id = p_id;
END //

-- =========================
-- ORDENES
-- =========================

DROP PROCEDURE IF EXISTS sp_crear_orden;
CREATE PROCEDURE sp_crear_orden(
  IN p_id_equipo INT,
  IN p_tipo VARCHAR(30),
  IN p_descripcion TEXT,
  IN p_id_tecnico INT
)
BEGIN
  INSERT INTO ordenes_servicio (id_equipo, id_tecnico, estado, tipo, descripcion)
  VALUES (p_id_equipo, p_id_tecnico, 'pendiente', p_tipo, p_descripcion);

  SELECT LAST_INSERT_ID() AS id;
END //

DROP PROCEDURE IF EXISTS sp_listar_ordenes;
CREATE PROCEDURE sp_listar_ordenes()
BEGIN
  SELECT * FROM ordenes_servicio;
END //

DROP PROCEDURE IF EXISTS sp_obtener_orden;
CREATE PROCEDURE sp_obtener_orden(IN p_id INT)
BEGIN
  SELECT * FROM ordenes_servicio WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_actualizar_orden;
CREATE PROCEDURE sp_actualizar_orden(
  IN p_id INT,
  IN p_estado VARCHAR(30),
  IN p_observaciones TEXT
)
BEGIN
  UPDATE ordenes_servicio
  SET estado = p_estado,
      observaciones = p_observaciones
  WHERE id = p_id;

  SELECT * FROM ordenes_servicio WHERE id = p_id;
END //

DROP PROCEDURE IF EXISTS sp_eliminar_orden;
CREATE PROCEDURE sp_eliminar_orden(IN p_id INT)
BEGIN
  DELETE FROM ordenes_servicio WHERE id = p_id;
END //

-- Procedimientos requeridos por el backend (nombres usados en ordenes.service.ts)

DROP PROCEDURE IF EXISTS sp_orden_asignar_tecnico;
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
END //

DROP PROCEDURE IF EXISTS sp_orden_actualizar_estado;
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
END //

DROP PROCEDURE IF EXISTS sp_orden_cerrar;
CREATE PROCEDURE sp_orden_cerrar(IN p_id_orden INT, IN p_observaciones TEXT)
BEGIN
  UPDATE ordenes_servicio
  SET estado = 'finalizada',
      fecha_fin = NOW(),
      observaciones = COALESCE(p_observaciones, observaciones),
      updated_at = NOW()
  WHERE id = p_id_orden;

  -- Marcar equipo como operativo/disponible al cerrar la orden
  UPDATE equipos
  SET estado = 'operativo',
      novedad = 'disponible',
      updated_at = NOW()
  WHERE id = (SELECT id_equipo FROM ordenes_servicio WHERE id = p_id_orden);

  SELECT o.*,
         eq.placa AS equipo_placa,
         t.nombre AS tecnico_nombre
  FROM ordenes_servicio o
  LEFT JOIN equipos eq ON o.id_equipo = eq.id
  LEFT JOIN tecnicos t ON o.id_tecnico = t.id
  WHERE o.id = p_id_orden;
END //

DROP PROCEDURE IF EXISTS sp_orden_verificar_plazos;
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
END //

DROP PROCEDURE IF EXISTS sp_orden_delete;
CREATE PROCEDURE sp_orden_delete(IN p_id INT)
BEGIN
  DELETE FROM ordenes_servicio WHERE id = p_id;
  SELECT ROW_COUNT() AS affected;
END //

DELIMITER ;