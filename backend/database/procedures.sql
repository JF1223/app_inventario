-- =========================
-- CLIENTES
-- =========================

-- ✅ CORREGIDO: Usar RETURNS TABLE explícito con columnas en lugar de SETOF
-- (así sí se puede llamar con SELECT * FROM sp_crear_cliente(...))
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

-- ✅ CORREGIDO: Para listar todos, mejor usar VIEW o función con RETURNS TABLE
-- Opción A: Si quieres mantener función, definir columnas explícitas
CREATE OR REPLACE FUNCTION sp_listar_clientes()
RETURNS TABLE (
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY 
  SELECT c.id, c.nombre, c.documento, c.direccion, c.telefono, c.email, c.created_at, c.updated_at
  FROM clientes c
  ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ✅ Opción B (RECOMENDADA): Usar una VIEW en su lugar
-- DROP VIEW IF EXISTS vw_clientes;
-- CREATE OR REPLACE VIEW vw_clientes AS
-- SELECT * FROM clientes ORDER BY created_at DESC;
-- -- Luego en NestJS: SELECT * FROM vw_clientes

CREATE OR REPLACE FUNCTION sp_obtener_cliente(p_id INT)
RETURNS TABLE (
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY 
  SELECT c.id, c.nombre, c.documento, c.direccion, c.telefono, c.email, c.created_at, c.updated_at
  FROM clientes c
  WHERE c.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_cliente(
  p_id INT,
  p_nombre VARCHAR(150),
  p_documento VARCHAR(50),
  p_direccion VARCHAR(255),
  p_telefono VARCHAR(30),
  p_email VARCHAR(150)
) RETURNS TABLE (
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
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
  RETURNING clientes.id, clientes.nombre, clientes.documento, clientes.direccion, 
            clientes.telefono, clientes.email, clientes.created_at, clientes.updated_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_cliente(p_id INT)
RETURNS TABLE(eliminado BOOLEAN) AS $$
BEGIN
  DELETE FROM clientes WHERE id = p_id;
  RETURN QUERY SELECT TRUE;
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

-- ✅ CORREGIDO: Definir columnas explícitas en RETURNS TABLE
CREATE OR REPLACE FUNCTION sp_listar_equipos()
RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_equipo(p_id INT)
RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
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
) RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
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
  RETURNING equipos.id, equipos.placa, equipos.estado, equipos.tipo_reparacion, 
            equipos.limpieza, equipos.uso, equipos.novedad, equipos.asignadas, 
            equipos.observaciones, equipos.id_cliente, equipos.created_at, equipos.updated_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_enviar_a_reparacion(
  p_id_equipo INT,
  p_observaciones TEXT
) RETURNS VOID AS $$
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
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  UPDATE equipos
  SET estado = 'en_reparacion',
      novedad = 'no_disponible',
      observaciones = COALESCE(p_observaciones, observaciones),
      updated_at = NOW()
  WHERE equipos.id = p_id;

  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_finalizar_reparacion(p_id INT)
RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  UPDATE equipos
  SET estado = 'operativo',
      novedad = 'disponible',
      updated_at = NOW()
  WHERE equipos.id = p_id AND equipos.estado = 'en_reparacion';

  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_reasignar_equipo(p_id INT, p_id_cliente INT)
RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  UPDATE equipos
  SET id_cliente = p_id_cliente,
      updated_at = NOW()
  WHERE equipos.id = p_id;

  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_equipos_por_estado(p_estado VARCHAR(50))
RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.estado = p_estado
  ORDER BY e.id ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_operativos_disponibles()
RETURNS TABLE(
  id INT, 
  placa VARCHAR, 
  estado VARCHAR, 
  tipo_reparacion VARCHAR, 
  limpieza VARCHAR, 
  uso VARCHAR,
  novedad VARCHAR, 
  asignadas VARCHAR, 
  observaciones TEXT, 
  id_cliente INT, 
  created_at TIMESTAMP,
  updated_at TIMESTAMP, 
  cliente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.estado = 'operativo' AND e.novedad = 'disponible'
  ORDER BY e.id ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_equipo(p_id INT)
RETURNS TABLE(eliminado BOOLEAN) AS $$
BEGIN
  DELETE FROM equipos WHERE id = p_id;
  RETURN QUERY SELECT TRUE;
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

-- ✅ CORREGIDO: Definir columnas explícitas
CREATE OR REPLACE FUNCTION sp_listar_tecnicos()
RETURNS TABLE (
  id INT,
  nombre VARCHAR(150),
  especialidad VARCHAR(100),
  contacto VARCHAR(50),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY 
  SELECT t.id, t.nombre, t.especialidad, t.contacto, t.activo, t.created_at, t.updated_at
  FROM tecnicos t;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_tecnico(p_id INT)
RETURNS TABLE (
  id INT,
  nombre VARCHAR(150),
  especialidad VARCHAR(100),
  contacto VARCHAR(50),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY 
  SELECT t.id, t.nombre, t.especialidad, t.contacto, t.activo, t.created_at, t.updated_at
  FROM tecnicos t
  WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_tecnico(
  p_id INT,
  p_nombre VARCHAR(150),
  p_especialidad VARCHAR(100),
  p_contacto VARCHAR(50)
) RETURNS TABLE (
  id INT,
  nombre VARCHAR(150),
  especialidad VARCHAR(100),
  contacto VARCHAR(50),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  UPDATE tecnicos
  SET nombre = p_nombre,
      especialidad = p_especialidad,
      contacto = p_contacto
  WHERE tecnicos.id = p_id
  RETURNING tecnicos.id, tecnicos.nombre, tecnicos.especialidad, tecnicos.contacto, 
            tecnicos.activo, tecnicos.created_at, tecnicos.updated_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_tecnico(p_id INT)
RETURNS TABLE(eliminado BOOLEAN) AS $$
BEGIN
  DELETE FROM tecnicos WHERE id = p_id;
  RETURN QUERY SELECT TRUE;
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

-- ✅ CORREGIDO: Definir columnas explícitas
CREATE OR REPLACE FUNCTION sp_listar_ordenes()
RETURNS TABLE (
  id INT,
  id_equipo INT,
  id_tecnico INT,
  estado VARCHAR(30),
  tipo VARCHAR(30),
  es_reemplazo BOOLEAN,
  descripcion TEXT,
  observaciones TEXT,
  fecha_inicio TIMESTAMP,
  fecha_fin TIMESTAMP,
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY 
  SELECT o.id, o.id_equipo, o.id_tecnico, o.estado, o.tipo, o.es_reemplazo,
         o.descripcion, o.observaciones, o.fecha_inicio, o.fecha_fin, o.fecha_limite,
         o.created_at, o.updated_at
  FROM ordenes_servicio o;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_orden(p_id INT)
RETURNS TABLE (
  id INT,
  id_equipo INT,
  id_tecnico INT,
  estado VARCHAR(30),
  tipo VARCHAR(30),
  es_reemplazo BOOLEAN,
  descripcion TEXT,
  observaciones TEXT,
  fecha_inicio TIMESTAMP,
  fecha_fin TIMESTAMP,
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY 
  SELECT o.id, o.id_equipo, o.id_tecnico, o.estado, o.tipo, o.es_reemplazo,
         o.descripcion, o.observaciones, o.fecha_inicio, o.fecha_fin, o.fecha_limite,
         o.created_at, o.updated_at
  FROM ordenes_servicio o
  WHERE o.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_actualizar_orden(
  p_id INT,
  p_estado VARCHAR(30),
  p_observaciones TEXT
) RETURNS TABLE (
  id INT,
  id_equipo INT,
  id_tecnico INT,
  estado VARCHAR(30),
  tipo VARCHAR(30),
  es_reemplazo BOOLEAN,
  descripcion TEXT,
  observaciones TEXT,
  fecha_inicio TIMESTAMP,
  fecha_fin TIMESTAMP,
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  UPDATE ordenes_servicio
  SET estado = p_estado,
      observaciones = p_observaciones
  WHERE ordenes_servicio.id = p_id
  RETURNING ordenes_servicio.id, ordenes_servicio.id_equipo, ordenes_servicio.id_tecnico,
            ordenes_servicio.estado, ordenes_servicio.tipo, ordenes_servicio.es_reemplazo,
            ordenes_servicio.descripcion, ordenes_servicio.observaciones, 
            ordenes_servicio.fecha_inicio, ordenes_servicio.fecha_fin, 
            ordenes_servicio.fecha_limite, ordenes_servicio.created_at, ordenes_servicio.updated_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_eliminar_orden(p_id INT)
RETURNS TABLE(eliminado BOOLEAN) AS $$
BEGIN
  DELETE FROM ordenes_servicio WHERE id = p_id;
  RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_asignar_tecnico(p_id_orden INT, p_id_tecnico INT)
RETURNS TABLE(
  id INT, 
  id_equipo INT, 
  id_tecnico INT, 
  estado VARCHAR, 
  tipo VARCHAR, 
  es_reemplazo BOOLEAN,
  descripcion TEXT, 
  observaciones TEXT, 
  fecha_inicio TIMESTAMP, 
  fecha_fin TIMESTAMP, 
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP, 
  updated_at TIMESTAMP, 
  equipo_placa VARCHAR, 
  tecnico_nombre VARCHAR
) AS $$
BEGIN
  UPDATE ordenes_servicio
  SET id_tecnico = p_id_tecnico,
      estado = 'en_proceso',
      fecha_inicio = NOW(),
      updated_at = NOW()
  WHERE ordenes_servicio.id = p_id_orden;

  RETURN QUERY
  SELECT o.id, o.id_equipo, o.id_tecnico, o.estado, o.tipo, o.es_reemplazo,
         o.descripcion, o.observaciones, o.fecha_inicio, o.fecha_fin, o.fecha_limite,
         o.created_at, o.updated_at,
         eq.placa::VARCHAR AS equipo_placa,
         t.nombre::VARCHAR AS tecnico_nombre
  FROM ordenes_servicio o
  LEFT JOIN equipos eq ON o.id_equipo = eq.id
  LEFT JOIN tecnicos t ON o.id_tecnico = t.id
  WHERE o.id = p_id_orden;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_orden_actualizar_estado(
  p_id_orden INT, 
  p_nuevo_estado VARCHAR(50), 
  p_observaciones TEXT
) RETURNS TABLE(
  id INT, 
  id_equipo INT, 
  id_tecnico INT, 
  estado VARCHAR, 
  tipo VARCHAR, 
  es_reemplazo BOOLEAN,
  descripcion TEXT, 
  observaciones TEXT, 
  fecha_inicio TIMESTAMP, 
  fecha_fin TIMESTAMP, 
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP, 
  updated_at TIMESTAMP, 
  equipo_placa VARCHAR, 
  tecnico_nombre VARCHAR
) AS $$
BEGIN
  UPDATE ordenes_servicio
  SET estado = p_nuevo_estado,
      observaciones = COALESCE(p_observaciones, observaciones),
      updated_at = NOW()
  WHERE ordenes_servicio.id = p_id_orden;

  RETURN QUERY
  SELECT o.id, o.id_equipo, o.id_tecnico, o.estado, o.tipo, o.es_reemplazo,
         o.descripcion, o.observaciones, o.fecha_inicio, o.fecha_fin, o.fecha_limite,
         o.created_at, o.updated_at,
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
  id INT, 
  id_equipo INT, 
  id_tecnico INT, 
  estado VARCHAR, 
  tipo VARCHAR, 
  es_reemplazo BOOLEAN,
  descripcion TEXT, 
  observaciones TEXT, 
  fecha_inicio TIMESTAMP, 
  fecha_fin TIMESTAMP, 
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP, 
  updated_at TIMESTAMP, 
  equipo_placa VARCHAR, 
  tecnico_nombre VARCHAR
) AS $$
DECLARE
  v_id_equipo INT;
BEGIN
  -- Obtener el id_equipo antes de actualizar
  SELECT o.id_equipo INTO v_id_equipo
  FROM ordenes_servicio o
  WHERE o.id = p_id_orden;

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
  WHERE equipos.id = v_id_equipo;

  RETURN QUERY
  SELECT o.id, o.id_equipo, o.id_tecnico, o.estado, o.tipo, o.es_reemplazo,
         o.descripcion, o.observaciones, o.fecha_inicio, o.fecha_fin, o.fecha_limite,
         o.created_at, o.updated_at,
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
  id INT, 
  id_equipo INT, 
  id_tecnico INT, 
  estado VARCHAR, 
  tipo VARCHAR, 
  es_reemplazo BOOLEAN,
  descripcion TEXT, 
  observaciones TEXT, 
  fecha_inicio TIMESTAMP, 
  fecha_fin TIMESTAMP, 
  fecha_limite TIMESTAMP,
  created_at TIMESTAMP, 
  updated_at TIMESTAMP, 
  equipo_placa VARCHAR, 
  tecnico_nombre VARCHAR, 
  estado_plazo TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.id, o.id_equipo, o.id_tecnico, o.estado, o.tipo, o.es_reemplazo,
         o.descripcion, o.observaciones, o.fecha_inicio, o.fecha_fin, o.fecha_limite,
         o.created_at, o.updated_at,
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
  RETURN QUERY SELECT 1;
END;
$$ LANGUAGE plpgsql;
