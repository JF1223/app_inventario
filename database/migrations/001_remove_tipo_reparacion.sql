-- ============================================================
-- Migración: Eliminar columna tipo_reparacion
-- Fecha: 2026-04-14
-- Descripción: Elimina la columna tipo_reparacion de la tabla equipos
--              y actualiza los procedimientos almacenados afectados
-- ============================================================

USE neveras_db;

-- ------------------------------------------------------------
-- 1. Eliminar columna tipo_reparacion de equipos
-- ------------------------------------------------------------
ALTER TABLE equipos DROP COLUMN tipo_reparacion;

-- ------------------------------------------------------------
-- 2. Actualizar procedimiento enviar_reparacion
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS enviar_reparacion;

DELIMITER //

CREATE PROCEDURE enviar_reparacion(
  IN p_id_equipo INT
)
BEGIN
  DECLARE v_equipo_estado VARCHAR(30);
  DECLARE v_cliente_id INT;

  SELECT estado, id_cliente INTO v_equipo_estado, v_cliente_id
  FROM equipos WHERE id = p_id_equipo;

  IF v_equipo_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El equipo no existe';
  END IF;

  IF v_equipo_estado = 'en_reparacion' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El equipo ya está en reparación';
  END IF;

  -- Cambiar estado a en_reparacion, desasignar del cliente
  UPDATE equipos
  SET estado = 'en_reparacion',
      id_cliente = NULL,
      novedad = 'no_disponible'
  WHERE id = p_id_equipo;

  -- Registrar en historial de equipos
  INSERT INTO historial_equipos (id_equipo, estado_anterior, estado_nuevo, id_cliente_anterior, observaciones)
  VALUES (p_id_equipo, v_equipo_estado, 'en_reparacion', v_cliente_id,
    'Enviado a reparación');

  SELECT ROW_COUNT() AS filas_afectadas;
END //

DELIMITER ;

-- ------------------------------------------------------------
-- 3. Actualizar procedimiento cerrar_orden
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS cerrar_orden;

DELIMITER //

CREATE PROCEDURE cerrar_orden(
  IN p_id_orden INT,
  IN p_observaciones TEXT
)
BEGIN
  DECLARE v_estado_actual VARCHAR(30);
  DECLARE v_id_equipo INT;
  DECLARE v_tipo VARCHAR(30);
  DECLARE v_equipo_estado VARCHAR(30);

  SELECT estado, id_equipo, tipo
  INTO v_estado_actual, v_id_equipo, v_tipo
  FROM ordenes_servicio WHERE id = p_id_orden;

  IF v_estado_actual IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden no existe';
  END IF;

  IF v_estado_actual = 'finalizada' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La orden ya está finalizada';
  END IF;

  -- Cerrar la orden
  UPDATE ordenes_servicio
  SET estado = 'finalizada',
      fecha_fin = NOW(),
      observaciones = IFNULL(CONCAT(IFNULL(observaciones, ''), '\n', p_observaciones), observaciones)
  WHERE id = p_id_orden;

  -- Si es una orden de reparación, el equipo vuelve a operativo y disponible
  SELECT estado INTO v_equipo_estado FROM equipos WHERE id = v_id_equipo;

  IF v_tipo = 'reparacion' AND v_equipo_estado = 'en_reparacion' THEN
    -- El equipo reparado queda disponible (sin cliente hasta que se reasigne)
    UPDATE equipos SET estado = 'operativo', id_cliente = NULL, novedad = 'disponible' WHERE id = v_id_equipo;

    INSERT INTO historial_equipos (id_equipo, estado_anterior, estado_nuevo, observaciones)
    VALUES (v_id_equipo, v_equipo_estado, 'operativo', 'Equipo reparado y disponible');
  ELSEIF v_tipo = 'mantenimiento' THEN
    UPDATE equipos SET estado = 'operativo' WHERE id = v_id_equipo;

    INSERT INTO historial_equipos (id_equipo, estado_anterior, estado_nuevo, id_cliente_nuevo, observaciones)
    SELECT v_id_equipo, v_equipo_estado, 'operativo', id_cliente, 'Mantenimiento completado'
    FROM equipos WHERE id = v_id_equipo;
  END IF;

  -- Registrar en historial
  INSERT INTO historial_ordenes (id_orden, estado_anterior, estado_nuevo, observaciones)
  VALUES (p_id_orden, v_estado_actual, 'finalizada', p_observaciones);

  SELECT ROW_COUNT() AS filas_afectadas;
END //

DELIMITER ;

-- ------------------------------------------------------------
-- Fin de la migración
-- ------------------------------------------------------------
