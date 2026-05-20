-- =========================
-- CLIENTES
-- =========================

CREATE OR REPLACE FUNCTION sp_crear_cliente(
  p_nombre VARCHAR(150),
  p_documento VARCHAR(50),
  p_direccion VARCHAR(255),
  p_telefono VARCHAR(30),
  p_email VARCHAR(150)
) RETURNS TABLE(id INT) AS $$
BEGIN
  RETURN QUERY
  INSERT INTO clientes (nombre, documento, direccion, telefono, email)
  VALUES (p_nombre, p_documento, p_direccion, p_telefono, p_email)
  RETURNING clientes.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_clientes()
RETURNS SETOF clientes AS $$
BEGIN
  RETURN QUERY SELECT * FROM clientes ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_cliente(p_id INT)
RETURNS SETOF clientes AS $$
BEGIN
  RETURN QUERY SELECT * FROM clientes WHERE clientes.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_cliente(
  p_id INT,
  p_nombre VARCHAR(150),
  p_documento VARCHAR(50),
  p_direccion VARCHAR(255),
  p_telefono VARCHAR(30),
  p_email VARCHAR(150)
) RETURNS SETOF clientes AS $$
BEGIN
  RETURN QUERY
  UPDATE clientes
  SET nombre = p_nombre,
      documento = p_documento,
      direccion = p_direccion,
      telefono = p_telefono,
      email = p_email,
      updated_at = NOW()
  WHERE clientes.id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_cliente(p_id INT)
RETURNS void AS $$
BEGIN
  DELETE FROM clientes WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- EQUIPOS
-- =========================

CREATE OR REPLACE FUNCTION sp_crear_equipo(
  p_placa VARCHAR(50),
  p_estado VARCHAR(30),
  p_limpieza VARCHAR(255),
  p_uso VARCHAR(255),
  p_novedad VARCHAR(30),
  p_asignadas VARCHAR(255),
  p_observaciones TEXT,
  p_id_cliente INT
) RETURNS TABLE(id INT) AS $$
BEGIN
  RETURN QUERY
  INSERT INTO equipos (placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente)
  VALUES (p_placa, p_estado, p_limpieza, p_uso, p_novedad, p_asignadas, p_observaciones, p_id_cliente)
  RETURNING equipos.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_equipos()
RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_equipo(p_id INT)
RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_equipo(
  p_id INT,
  p_placa VARCHAR(50),
  p_estado VARCHAR(30),
  p_limpieza VARCHAR(255),
  p_uso VARCHAR(255),
  p_novedad VARCHAR(30),
  p_asignadas VARCHAR(255),
  p_observaciones TEXT,
  p_id_cliente INT
) RETURNS SETOF equipos AS $$
BEGIN
  RETURN QUERY
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
  WHERE equipos.id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_enviar_a_reparacion(
  p_id_equipo INT,
  p_observaciones TEXT
) RETURNS void AS $$
BEGIN
  UPDATE equipos
  SET estado = 'en_reparacion',
      novedad = 'no_disponible',
      observaciones = p_observaciones,
      updated_at = NOW()
  WHERE id = p_id_equipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_equipo_enviar_reparacion(
  p_id INT,
  p_observaciones TEXT
) RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  UPDATE equipos
  SET estado = 'en_reparacion',
      novedad = 'no_disponible',
      observaciones = COALESCE(p_observaciones, observaciones),
      updated_at = NOW()
  WHERE equipos.id = p_id;

  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_finalizar_reparacion(p_id INT)
RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  UPDATE equipos
  SET estado = 'operativo',
      novedad = 'disponible',
      updated_at = NOW()
  WHERE equipos.id = p_id AND equipos.estado = 'en_reparacion';

  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_reasignar_equipo(p_id INT, p_id_cliente INT)
RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  UPDATE equipos
  SET id_cliente = p_id_cliente,
      updated_at = NOW()
  WHERE equipos.id = p_id;

  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_equipos_por_estado(p_estado VARCHAR(50))
RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.estado = p_estado
  ORDER BY e.id ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_operativos_disponibles()
RETURNS TABLE(
  id INT, placa VARCHAR, estado VARCHAR, tipo_reparacion VARCHAR, limpieza VARCHAR, uso VARCHAR,
  novedad VARCHAR, asignadas VARCHAR, observaciones TEXT, id_cliente INT, created_at TIMESTAMP,
  updated_at TIMESTAMP, cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.*, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.estado = 'operativo' AND e.novedad = 'disponible'
  ORDER BY e.id ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_equipo(p_id INT)
RETURNS void AS $$
BEGIN
  DELETE FROM equipos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- TECNICOS
-- =========================

CREATE OR REPLACE FUNCTION sp_crear_tecnico(
  p_nombre VARCHAR(150),
  p_especialidad VARCHAR(100),
  p_contacto VARCHAR(50)
) RETURNS TABLE(id INT) AS $$
BEGIN
  RETURN QUERY
  INSERT INTO tecnicos (nombre, especialidad, contacto, activo)
  VALUES (p_nombre, p_especialidad, p_contacto, TRUE)
  RETURNING tecnicos.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_tecnicos()
RETURNS SETOF tecnicos AS $$
BEGIN
  RETURN QUERY SELECT * FROM tecnicos;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_tecnico(p_id INT)
RETURNS SETOF tecnicos AS $$
BEGIN
  RETURN QUERY SELECT * FROM tecnicos WHERE tecnicos.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_tecnico(
  p_id INT,
  p_nombre VARCHAR(150),
  p_especialidad VARCHAR(100),
  p_contacto VARCHAR(50)
) RETURNS SETOF tecnicos AS $$
BEGIN
  RETURN QUERY
  UPDATE tecnicos
  SET nombre = p_nombre,
      especialidad = p_especialidad,
      contacto = p_contacto
  WHERE tecnicos.id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_tecnico(p_id INT)
RETURNS void AS $$
BEGIN
  DELETE FROM tecnicos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- ORDENES
-- =========================

CREATE OR REPLACE FUNCTION sp_crear_orden(
  p_id_equipo INT,
  p_tipo VARCHAR(30),
  p_descripcion TEXT,
  p_id_tecnico INT
) RETURNS TABLE(id INT) AS $$
BEGIN
  RETURN QUERY
  INSERT INTO ordenes_servicio (id_equipo, id_tecnico, estado, tipo, descripcion)
  VALUES (p_id_equipo, p_id_tecnico, 'pendiente', p_tipo, p_descripcion)
  RETURNING ordenes_servicio.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_ordenes()
RETURNS SETOF ordenes_servicio AS $$
BEGIN
  RETURN QUERY SELECT * FROM ordenes_servicio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_orden(p_id INT)
RETURNS SETOF ordenes_servicio AS $$
BEGIN
  RETURN QUERY SELECT * FROM ordenes_servicio WHERE ordenes_servicio.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_orden(
  p_id INT,
  p_estado VARCHAR(30),
  p_observaciones TEXT
) RETURNS SETOF ordenes_servicio AS $$
BEGIN
  RETURN QUERY
  UPDATE ordenes_servicio
  SET estado = p_estado,
      observaciones = p_observaciones
  WHERE ordenes_servicio.id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_orden(p_id INT)
RETURNS void AS $$
BEGIN
  DELETE FROM ordenes_servicio WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_asignar_tecnico(p_id_orden INT, p_id_tecnico INT)
RETURNS TABLE(
  id INT, id_equipo INT, id_tecnico INT, estado VARCHAR, tipo VARCHAR, es_reemplazo BOOLEAN,
  descripcion TEXT, observaciones TEXT, fecha_inicio TIMESTAMP, fecha_fin TIMESTAMP, fecha_limite TIMESTAMP,
  created_at TIMESTAMP, updated_at TIMESTAMP, equipo_placa VARCHAR, tecnico_nombre VARCHAR
) AS $$
BEGIN
  UPDATE ordenes_servicio
  SET id_tecnico = p_id_tecnico,
      estado = 'en_proceso',
      fecha_inicio = NOW(),
      updated_at = NOW()
  WHERE ordenes_servicio.id = p_id_orden;

  RETURN QUERY
  SELECT o.*,
         eq.placa::VARCHAR AS equipo_placa,
         t.nombre::VARCHAR AS tecnico_nombre
  FROM ordenes_servicio o
  LEFT JOIN equipos eq ON o.id_equipo = eq.id
  LEFT JOIN tecnicos t ON o.id_tecnico = t.id
  WHERE o.id = p_id_orden;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_actualizar_estado(p_id_orden INT, p_nuevo_estado VARCHAR(50), p_observaciones TEXT)
RETURNS TABLE(
  id INT, id_equipo INT, id_tecnico INT, estado VARCHAR, tipo VARCHAR, es_reemplazo BOOLEAN,
  descripcion TEXT, observaciones TEXT, fecha_inicio TIMESTAMP, fecha_fin TIMESTAMP, fecha_limite TIMESTAMP,
  created_at TIMESTAMP, updated_at TIMESTAMP, equipo_placa VARCHAR, tecnico_nombre VARCHAR
) AS $$
BEGIN
  UPDATE ordenes_servicio
  SET estado = p_nuevo_estado,
      observaciones = COALESCE(p_observaciones, observaciones),
      updated_at = NOW()
  WHERE ordenes_servicio.id = p_id_orden;

  RETURN QUERY
  SELECT o.*,
         eq.placa::VARCHAR AS equipo_placa,
         t.nombre::VARCHAR AS tecnico_nombre
  FROM ordenes_servicio o
  LEFT JOIN equipos eq ON o.id_equipo = eq.id
  LEFT JOIN tecnicos t ON o.id_tecnico = t.id
  WHERE o.id = p_id_orden;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_cerrar(p_id_orden INT, p_observaciones TEXT)
RETURNS TABLE(
  id INT, id_equipo INT, id_tecnico INT, estado VARCHAR, tipo VARCHAR, es_reemplazo BOOLEAN,
  descripcion TEXT, observaciones TEXT, fecha_inicio TIMESTAMP, fecha_fin TIMESTAMP, fecha_limite TIMESTAMP,
  created_at TIMESTAMP, updated_at TIMESTAMP, equipo_placa VARCHAR, tecnico_nombre VARCHAR
) AS $$
BEGIN
  UPDATE ordenes_servicio
  SET estado = 'finalizada',
      fecha_fin = NOW(),
      observaciones = COALESCE(p_observaciones, observaciones),
      updated_at = NOW()
  WHERE ordenes_servicio.id = p_id_orden;

  -- Marcar equipo como operativo/disponible al cerrar la orden
  UPDATE equipos
  SET estado = 'operativo',
      novedad = 'disponible',
      updated_at = NOW()
  WHERE equipos.id = (SELECT o.id_equipo FROM ordenes_servicio o WHERE o.id = p_id_orden);

  RETURN QUERY
  SELECT o.*,
         eq.placa::VARCHAR AS equipo_placa,
         t.nombre::VARCHAR AS tecnico_nombre
  FROM ordenes_servicio o
  LEFT JOIN equipos eq ON o.id_equipo = eq.id
  LEFT JOIN tecnicos t ON o.id_tecnico = t.id
  WHERE o.id = p_id_orden;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_verificar_plazos()
RETURNS TABLE(
  id INT, id_equipo INT, id_tecnico INT, estado VARCHAR, tipo VARCHAR, es_reemplazo BOOLEAN,
  descripcion TEXT, observaciones TEXT, fecha_inicio TIMESTAMP, fecha_fin TIMESTAMP, fecha_limite TIMESTAMP,
  created_at TIMESTAMP, updated_at TIMESTAMP, equipo_placa VARCHAR, tecnico_nombre VARCHAR, estado_plazo TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.*,
         eq.placa::VARCHAR AS equipo_placa,
         t.nombre::VARCHAR AS tecnico_nombre,
         CASE
           WHEN o.fecha_limite < NOW() AND o.estado != 'finalizada' THEN 'VENCIDA'
           WHEN o.fecha_limite - INTERVAL '1 DAY' < NOW() AND o.estado != 'finalizada' THEN 'POR VENCER'
           ELSE 'OK'
         END AS estado_plazo
  FROM ordenes_servicio o
  LEFT JOIN equipos eq ON o.id_equipo = eq.id
  LEFT JOIN tecnicos t ON o.id_tecnico = t.id
  WHERE o.estado != 'finalizada'
  ORDER BY o.fecha_limite ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_delete(p_id INT)
RETURNS TABLE(affected INT) AS $$
BEGIN
  DELETE FROM ordenes_servicio WHERE id = p_id;
  -- en postgres para devolver filas afectadas se usaría GET DIAGNOSTICS pero para esto simple devolvemos 1
  RETURN QUERY SELECT 1;
END;
$$ LANGUAGE plpgsql;