-- =========================
-- CLIENTES
-- =========================

CREATE OR REPLACE FUNCTION sp_crear_cliente(
  p_nombre VARCHAR(150),
  p_documento VARCHAR(50),
  p_direccion VARCHAR(255),
  p_telefono VARCHAR(30),
  p_email VARCHAR(150)
) RETURNS TABLE(
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  INSERT INTO clientes (nombre, documento, direccion, telefono, email)
  VALUES (p_nombre, p_documento, p_direccion, p_telefono, p_email)
  RETURNING clientes.id, clientes.nombre, clientes.documento, clientes.direccion,
            clientes.telefono, clientes.email, clientes.activo, clientes.created_at, clientes.updated_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_clientes()
RETURNS TABLE(
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.id, c.nombre, c.documento, c.direccion, c.telefono, c.email, c.activo, c.created_at, c.updated_at
  FROM clientes c
  ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_cliente(p_id INT)
RETURNS TABLE(
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.id, c.nombre, c.documento, c.direccion, c.telefono, c.email, c.activo, c.created_at, c.updated_at
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
) RETURNS TABLE(
  id INT,
  nombre VARCHAR(150),
  documento VARCHAR(50),
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  activo BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  UPDATE clientes
  SET nombre = COALESCE(p_nombre, nombre),
      documento = COALESCE(p_documento, documento),
      direccion = COALESCE(p_direccion, direccion),
      telefono = COALESCE(p_telefono, telefono),
      email = COALESCE(p_email, email),
      updated_at = NOW()
  WHERE clientes.id = p_id
  RETURNING clientes.id, clientes.nombre, clientes.documento, clientes.direccion,
            clientes.telefono, clientes.email, clientes.activo, clientes.created_at, clientes.updated_at;
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
) RETURNS TABLE(
  id INT,
  placa VARCHAR(50),
  estado VARCHAR(30),
  tipo_reparacion VARCHAR(255),
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30),
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  INSERT INTO equipos (placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente)
  VALUES (p_placa, p_estado, p_limpieza, p_uso, p_novedad, p_asignadas, p_observaciones, p_id_cliente)
  RETURNING equipos.id, equipos.placa, equipos.estado, equipos.tipo_reparacion, equipos.limpieza,
            equipos.uso, equipos.novedad, equipos.asignadas, equipos.observaciones, equipos.id_cliente,
            equipos.created_at, equipos.updated_at;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_equipos()
RETURNS TABLE(
  id INT,
  placa VARCHAR(50),
  estado VARCHAR(30),
  tipo_reparacion VARCHAR(255),
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30),
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  cliente_nombre VARCHAR(150)
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR(150) AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_equipo(p_id INT)
RETURNS TABLE(
  id INT,
  placa VARCHAR(50),
  estado VARCHAR(30),
  tipo_reparacion VARCHAR(255),
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30),
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  cliente_nombre VARCHAR(150)
) AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e.limpieza, e.uso,
         e.novedad, e.asignadas, e.observaciones, e.id_cliente, e.created_at,
         e.updated_at, c.nombre::VARCHAR(150) AS cliente_nombre
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
  placa VARCHAR(50),
  estado VARCHAR(30),
  tipo_reparacion VARCHAR(255),
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30),
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
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
  WHERE equipos.id = p_id
  RETURNING equipos.id, equipos.placa, equipos.estado, equipos.tipo_reparacion, equipos.limpieza,
            equipos.uso, equipos.novedad, equipos.asignadas, equipos.observaciones, equipos.id_cliente,
            equipos.created_at, equipos.updated_at;
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
  placa VARCHAR(50),
  estado VARCHAR(30),
  tipo_reparacion VARCHAR(255),
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30),
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  cliente_nombre VARCHAR(150)
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
         e.updated_at, c.nombre::VARCHAR(150) AS cliente_nombre
  FROM equipos e
  LEFT JOIN clientes c ON e.id_cliente = c.id
  WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_finalizar_reparacion(p_id INT)
RETURNS TABLE(
  id INT,
  placa VARCHAR(50),
  estado VARCHAR(30),
  tipo_reparacion VARCHAR(255),
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30),
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  cliente_nombre VARCHAR(150)
) AS $$
BEGIN
  UPDATE equipos
  SET estado = 'operativo',
      novedad = 'disponible',
      updated_at = NOW()
  WHERE equipos.id = p_id AND equipos.estado = 'en_reparacion';

  RETURN QUERY
  SELECT e.id, e.placa, e.estado, e.tipo_reparacion, e
