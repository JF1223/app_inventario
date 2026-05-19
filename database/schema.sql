-- ============================================================
-- Sistema de Gestión de Mantenimiento de Equipos Refrigerados
-- Esquema de Base de Datos MySQL 8
-- ============================================================

CREATE DATABASE IF NOT EXISTS neveras_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE neveras_db;

-- ============================================================
-- TABLAS
-- ============================================================

-- Clientes
CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  documento VARCHAR(50) NOT NULL UNIQUE,
  direccion VARCHAR(255),
  telefono VARCHAR(30),
  email VARCHAR(150),
  activo BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_documento (documento),
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Equipos (Neveras)
CREATE TABLE IF NOT EXISTS equipos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  placa VARCHAR(50) NOT NULL UNIQUE,
  estado ENUM('operativo', 'en_mantenimiento', 'reemplazado', 'en_reparacion') NOT NULL DEFAULT 'operativo',
  tipo_reparacion ENUM('piezas', 'arreglo') NULL,
  limpieza VARCHAR(255),
  uso VARCHAR(255),
  novedad ENUM('asignada', 'disponible', 'no_disponible') NOT NULL DEFAULT 'disponible',
  asignadas VARCHAR(255),
  observaciones TEXT,
  id_cliente INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE SET NULL,
  INDEX idx_placa (placa),
  INDEX idx_estado (estado),
  INDEX idx_cliente (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Técnicos
CREATE TABLE IF NOT EXISTS tecnicos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  especialidad VARCHAR(100) NOT NULL,
  contacto VARCHAR(50) NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Órdenes de Servicio
CREATE TABLE IF NOT EXISTS ordenes_servicio (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_equipo INT NOT NULL,
  id_tecnico INT,
  estado ENUM('pendiente', 'en_proceso', 'finalizada') NOT NULL DEFAULT 'pendiente',
  tipo ENUM('mantenimiento', 'reparacion', 'reemplazo') NOT NULL DEFAULT 'mantenimiento',
  es_reemplazo TINYINT(1) DEFAULT 0,
  descripcion TEXT,
  observaciones TEXT,
  fecha_inicio DATETIME NULL,
  fecha_fin DATETIME NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_equipo) REFERENCES equipos(id) ON DELETE RESTRICT,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id) ON DELETE SET NULL,
  INDEX idx_estado (estado),
  INDEX idx_equipo (id_equipo),
  INDEX idx_tecnico (id_tecnico)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Historial de cambios de estado de órdenes
CREATE TABLE IF NOT EXISTS historial_ordenes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_orden INT NOT NULL,
  estado_anterior VARCHAR(30),
  estado_nuevo VARCHAR(30) NOT NULL,
  id_tecnico INT,
  observaciones TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_orden) REFERENCES ordenes_servicio(id) ON DELETE CASCADE,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id) ON DELETE SET NULL,
  INDEX idx_orden (id_orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci  ;

-- Historial de cambios de estado de equipos
CREATE TABLE IF NOT EXISTS historial_equipos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_equipo INT NOT NULL,
  estado_anterior VARCHAR(30),
  estado_nuevo VARCHAR(30) NOT NULL,
  id_cliente_anterior INT,
  id_cliente_nuevo INT,
  observaciones TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_equipo) REFERENCES equipos(id) ON DELETE CASCADE,
  FOREIGN KEY (id_cliente_anterior) REFERENCES clientes(id) ON DELETE SET NULL,
  FOREIGN KEY (id_cliente_nuevo) REFERENCES clientes(id) ON DELETE SET NULL,
  INDEX idx_equipo (id_equipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 