-- ============================================================
-- Datos de Prueba (Seed Data)
-- ============================================================

USE neveras_db;

-- Clientes
INSERT INTO clientes (nombre, documento, direccion, telefono, email) VALUES
('Restaurante El Sabor', '900123456', 'Calle 10 #20-30', '3001111111', 'sabor@email.com'),
('Supermercado La Economía', '900654321', 'Av. Principal #50-60', '3002222222', 'economia@email.com'),
('Hotel Paraíso', '900111222', 'Carrera 5 #15-25', '3003333333', 'paraiso@email.com'),
('Café La Montaña', '900333444', 'Calle 8 #12-40', '3004444444', 'montana@email.com'),
('Minimarket El Sol', '900555666', 'Barrio Centro Local 5', '3005555555', 'sol@email.com');

-- Técnicos
INSERT INTO tecnicos (nombre, especialidad, contacto, activo) VALUES
('Carlos Pérez', 'Refrigeración Comercial', '3101111111', TRUE),
('María López', 'Refrigeración Industrial', '3102222222', TRUE),
('Juan Rodríguez', 'Compresores', '3103333333', TRUE),
('Ana Martínez', 'Sistemas de Frío', '3104444444', TRUE);

-- Equipos (Neveras Coca-Cola y Colombina)
INSERT INTO equipos (placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente) VALUES
('CC-001', 'operativo', 'Limpia', 'Normal', 'asignada', 'Restaurante El Sabor', 'Nevera Coca-Cola refrescos', 1),
('CC-002', 'operativo', 'Limpia', 'Normal', 'asignada', 'Supermercado La Economía', 'Nevera Coca-Cola refrescos', 2),
('CC-003', 'operativo', 'Limpia', 'Intenso', 'asignada', 'Hotel Paraíso', 'Nevera Coca-Cola refrescos', 3),
('COL-001', 'operativo', 'Limpia', 'Normal', 'asignada', 'Café La Montaña', 'Nevera Colombina helados', 4),
('COL-002', 'operativo', 'Limpia', 'Normal', 'asignada', 'Minimarket El Sol', 'Nevera Colombina helados', 5),
('CC-004', 'operativo', 'Limpia', 'Bajo', 'disponible', 'Sin asignar', 'Nevera Coca-Cola reserva', NULL),
('COL-003', 'operativo', 'Limpia', 'Bajo', 'disponible', 'Sin asignar', 'Nevera Colombina reserva', NULL);