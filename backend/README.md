# Backend - Sistema de Gestión de Mantenimiento

## Arquitectura Sin ORM

Este backend utiliza **mysql2** con pool de conexiones y **procedimientos almacenados** para toda interacción con la base de datos.

## Estructura del Proyecto

```
backend/
├── src/
│   ├── database/
│   │   ├── database.module.ts      # Módulo global de BD
│   │   ├── database.service.ts     # Servicio con pool de conexiones
│   │   └── index.ts
│   ├── modules/
│   │   ├── clientes/
│   │   ├── equipos/
│   │   ├── tecnicos/
│   │   ├── ordenes/
│   │   ├── historial/
│   │   └── reportes/
│   ├── app.module.ts
│   └── main.ts
├── database/
│   └── procedures.sql              # Todos los procedimientos almacenados
└── package.json
```

## Instalación

```bash
npm install
```

## Configuración

Crear archivo `.env` en la raíz del backend:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=tu_password
DB_DATABASE=inventario
```

## Base de Datos

### 1. Crear tablas

```sql
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    documento VARCHAR(50) UNIQUE NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(30),
    email VARCHAR(150),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE equipos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(50) UNIQUE NOT NULL,
    estado ENUM('operativo', 'en_mantenimiento', 'reemplazado', 'en_reparacion') DEFAULT 'operativo',
    limpieza VARCHAR(255),
    uso VARCHAR(255),
    novedad ENUM('asignada', 'disponible', 'no_disponible') DEFAULT 'disponible',
    asignadas VARCHAR(255),
    observaciones TEXT,
    id_cliente INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE SET NULL
);

CREATE TABLE tecnicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    contacto VARCHAR(50) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE ordenes_servicio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo INT NOT NULL,
    id_tecnico INT,
    estado ENUM('pendiente', 'en_proceso', 'finalizada') DEFAULT 'pendiente',
    tipo ENUM('mantenimiento', 'reparacion', 'reemplazo') DEFAULT 'mantenimiento',
    descripcion TEXT,
    observaciones TEXT,
    es_reemplazo BOOLEAN DEFAULT FALSE,
    id_equipo_reemplazo INT,
    fecha_reemplazo DATETIME,
    fecha_limite DATETIME NOT NULL,
    fecha_inicio DATETIME,
    fecha_fin DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_equipo) REFERENCES equipos(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id) ON DELETE SET NULL,
    FOREIGN KEY (id_equipo_reemplazo) REFERENCES equipos(id) ON DELETE SET NULL
);
```

### 2. Ejecutar procedimientos almacenados

```bash
mysql -u root -p inventario < database/procedures.sql
```

## Uso de DatabaseService

### Inyección en Services

```typescript
import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../../database';

@Injectable()
export class MiService {
  constructor(private readonly db: DatabaseService) {}

  async getData() {
    // Consulta simple
    return this.db.query('SELECT * FROM tabla WHERE id = ?', [id]);

    // Llamar procedimiento almacenado
    return this.db.call('sp_mi_proceso(?, ?)', [param1, param2]);
  }
}
```

### Métodos Disponibles

| Método | Descripción |
|--------|-------------|
| `db.query(sql, params)` | Ejecuta consulta SQL con parámetros |
| `db.call(procedure, params)` | Ejecuta procedimiento almacenado |
| `db.getConnection()` | Obtiene conexión directa del pool |

## Procedimientos Almacenados

### Clientes

| Procedimiento | Descripción |
|--------------|-------------|
| `sp_cliente_create(nombre, documento, direccion, telefono, email)` | Crea cliente |
| `sp_cliente_find_all()` | Lista todos los clientes activos |
| `sp_cliente_find_one(id)` | Busca cliente por ID |
| `sp_cliente_update(id, nombre, documento, direccion, telefono, email)` | Actualiza cliente |
| `sp_cliente_delete(id)` | Elimina lógico (activo = FALSE) |

### Equipos

| Procedimiento | Descripción |
|--------------|-------------|
| `sp_equipo_create(placa, estado, limpieza, uso, novedad, asignadas, observaciones, id_cliente)` | Crea equipo |
| `sp_equipo_find_all()` | Lista todos los equipos con cliente |
| `sp_equipo_find_one(id)` | Busca equipo por ID |
| `sp_equipo_update(id, ...)` | Actualiza equipo |
| `sp_equipo_delete(id)` | Elimina equipo |
| `sp_equipo_find_by_estado(estado)` | Filtra por estado |
| `sp_equipo_find_operativos_disponibles()` | Equipos operativos disponibles |
| `sp_equipo_enviar_reparacion(id, observaciones)` | Envía a reparación |
| `sp_equipo_finalizar_reparacion(id)` | Finaliza reparación |
| `sp_equipo_reasignar(id, id_cliente)` | Reasigna a otro cliente |

### Técnicos

| Procedimiento | Descripción |
|--------------|-------------|
| `sp_tecnico_create(nombre, especialidad, contacto)` | Crea técnico |
| `sp_tecnico_find_all()` | Lista técnicos activos |
| `sp_tecnico_find_one(id)` | Busca técnico por ID |
| `sp_tecnico_update(id, nombre, especialidad, contacto)` | Actualiza técnico |
| `sp_tecnico_delete(id)` | Elimina lógico |

### Órdenes

| Procedimiento | Descripción |
|--------------|-------------|
| `sp_orden_create(id_equipo, tipo, descripcion, id_tecnico)` | Crea orden |
| `sp_orden_find_all()` | Lista todas las órdenes |
| `sp_orden_find_one(id)` | Busca orden por ID |
| `sp_orden_asignar_tecnico(id_orden, id_tecnico)` | Asigna técnico |
| `sp_orden_actualizar_estado(id_orden, estado, observaciones)` | Actualiza estado |
| `sp_orden_cerrar(id_orden, observaciones)` | Cierra orden |
| `sp_orden_verificar_plazos()` | Verifica plazos vencidos |
| `sp_orden_delete(id)` | Elimina orden |

## Ejecutar

```bash
# Desarrollo
npm run start:dev

# Producción
npm run build
npm run start:prod
```

## Migración desde ORM

1. Eliminar entidades (`*.entity.ts`)
2. Eliminar `TypeOrmModule` de los módulos
3. Inyectar `DatabaseService` en los services
4. Reemplazar `repository.save()` por `db.call('sp_create...')`
5. Reemplazar `find()` por `db.call('sp_find_all()')`
