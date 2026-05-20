-- ============================================================
-- Sistema de Gestión de Mantenimiento de Equipos Refrigerados
-- Esquema de Base de Datos PostgreSQL
-- ============================================================

-- Clientes
CREATE TABLE IF NOT EXISTS clientes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  documento VARCHAR(50) NOT NULL UNIQUE,
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_documento ON clientes (documento);
CREATE INDEX IF NOT EXISTS idx_activo_clientes ON clientes (activo);

-- Equipos (Neveras)
CREATE TABLE IF NOT EXISTS equipos (
  id SERIAL PRIMARY KEY,
  placa VARCHAR(50) NOT NULL UNIQUE,
  estado VARCHAR(30) NOT NULL DEFAULT 'operativo',
  tipo_reparacion VARCHAR(30) NULL,
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad VARCHAR(30) NOT NULL DEFAULT 'disponible',
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_placa ON equipos (placa);
CREATE INDEX IF NOT EXISTS idx_estado_equipos ON equipos (estado);
CREATE INDEX IF NOT EXISTS idx_cliente_equipos ON equipos (id_cliente);

-- Técnicos
CREATE TABLE IF NOT EXISTS tecnicos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  especialidad VARCHAR(100) NOT NULL,
  contacto VARCHAR(50) NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_activo_tecnicos ON tecnicos (activo);

-- Órdenes de Servicio
CREATE TABLE IF NOT EXISTS ordenes_servicio (
  id SERIAL PRIMARY KEY,
  id_equipo INT NOT NULL,
  id_tecnico INT,
  estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
  tipo VARCHAR(30) NOT NULL DEFAULT 'mantenimiento',
  es_reemplazo BOOLEAN DEFAULT FALSE,
  descripcion TEXT,
  observaciones TEXT,
  fecha_inicio TIMESTAMP NULL,
  fecha_fin TIMESTAMP NULL,
  fecha_limite TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_equipo) REFERENCES equipos(id) ON DELETE RESTRICT,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_estado_ordenes ON ordenes_servicio (estado);
CREATE INDEX IF NOT EXISTS idx_equipo_ordenes ON ordenes_servicio (id_equipo);
CREATE INDEX IF NOT EXISTS idx_tecnico_ordenes ON ordenes_servicio (id_tecnico);

-- Historial de cambios de estado de órdenes
CREATE TABLE IF NOT EXISTS historial_ordenes (
  id SERIAL PRIMARY KEY,
  id_orden INT NOT NULL,
  estado_anterior VARCHAR(30),
  estado_nuevo VARCHAR(30) NOT NULL,
  id_tecnico INT,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_orden) REFERENCES ordenes_servicio(id) ON DELETE CASCADE,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_orden_historial ON historial_ordenes (id_orden);

-- Historial de cambios de estado de equipos
CREATE TABLE IF NOT EXISTS historial_equipos (
  id SERIAL PRIMARY KEY,
  id_equipo INT NOT NULL,
  estado_anterior VARCHAR(30),
  estado_nuevo VARCHAR(30) NOT NULL,
  id_cliente_anterior INT,
  id_cliente_nuevo INT,
  observaciones TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_equipo) REFERENCES equipos(id) ON DELETE CASCADE,
  FOREIGN KEY (id_cliente_anterior) REFERENCES clientes(id) ON DELETE SET NULL,
  FOREIGN KEY (id_cliente_nuevo) REFERENCES clientes(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_equipo_historial ON historial_equipos (id_equipo);