
# ❄️ CoolService — Sistema de Gestión de Mantenimiento de Neveras

Sistema web completo para la gestión de mantenimiento y reparación de equipos refrigerados.

## 🏗️ Arquitectura

```
app_inventario/
├── database/         # SQL: esquema + procedimientos + seed
│   ├── schema.sql
│   ├── procedures.sql
│   └── seed.sql
├── backend/          # NestJS + TypeORM + MySQL
│   └── src/
│       └── modules/  # clientes, equipos, tecnicos, ordenes, historial, reportes
├── frontend/         # React + Vite + TypeScript
│   └── src/
│       ├── pages/    # Login, Dashboard, Equipos, Ordenes, Clientes, Tecnicos, Historial, Reportes
│       ├── components/
│       └── services/ # API layer (Axios)
├── nginx/            # Reverse proxy
│   └── nginx.conf
├── docker-compose.yml
└── .env
```

## 🚀 Inicio Rápido

### Con Docker (recomendado)

```bash
# 1. Clona el proyecto
cd app_inventario

# 2. Levanta todos los servicios
docker-compose up --build -d

# 3. Espera ~30 segundos para que MySQL inicialice
# 4. Abre: http://localhost
```

### Desarrollo Local (sin Docker)

**Backend:**
```bash
cd backend
npm install
# Ejecutar procedimientos almacenados en MySQL
mysql -u root -p inventario < database/procedures.sql
npm run start:dev
# Puerto: 3000
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
# Puerto: 5173
```

> Asegúrate de que MySQL esté corriendo localmente con las credenciales del `backend/.env`

## 🔐 Credenciales del Sistema

| Campo | Valor |
|-------|-------|
| Usuario | `admin` |
| Contraseña | `admin123` |

## 🌐 URLs

| Servicio | URL |
|---------|-----|
| Frontend (via Nginx) | http://localhost |
| Backend API | http://localhost/api o http://localhost:3000 |
| Health check | http://localhost/health |

## 🔌 API Endpoints

### Clientes
- `POST /clientes` — Crear cliente
- `GET /clientes` — Listar clientes
- `GET /clientes/:id` — Obtener cliente por ID
- `PUT /clientes/:id` — Actualizar cliente
- `DELETE /clientes/:id` — Eliminar cliente

### Equipos
- `POST /equipos` — Crear equipo
- `GET /equipos` — Listar equipos
- `GET /equipos/:id` — Obtener equipo
- `PUT /equipos/:id` — Actualizar equipo
- `DELETE /equipos/:id` — Eliminar equipo
- `POST /equipos/:id/enviar-reparacion` — Enviar a reparación
- `PUT /equipos/:id/finalizar-reparacion` — Finalizar reparación
- `PUT /equipos/:id/reasignar` — Reasignar equipo

### Técnicos
- `POST /tecnicos` — Crear técnico
- `GET /tecnicos` — Listar técnicos
- `GET /tecnicos/:id` — Obtener técnico
- `PUT /tecnicos/:id` — Actualizar técnico
- `DELETE /tecnicos/:id` — Eliminar técnico

### Órdenes de Servicio
- `POST /ordenes` — Crear orden
- `GET /ordenes` — Listar órdenes
- `GET /ordenes/:id` — Obtener orden
- `PUT /ordenes/asignar` — Asignar técnico
- `PUT /ordenes/estado` — Actualizar estado
- `PUT /ordenes/:id/cerrar` — Cerrar orden
- `DELETE /ordenes/:id` — Eliminar orden

### Historial
- `GET /historial/equipo/:id` — Historial de equipo
- `GET /historial/orden/:id` — Historial de orden
- `GET /historial` — Historial completo

### Reportes
- `GET /reportes/resumen` — Estadísticas generales
- `GET /reportes/mensual?year=2025&month=1` — Reporte mensual

## ⚙️ Lógica de Negocio Crítica

### Reemplazo Automático (4 días)

1. Al crear una orden, se calcula `fecha_limite = NOW() + 4 días`
2. El **cron job** (`verificar_plazos`) se ejecuta diariamente a las 8:00 AM
3. Para cada orden `en_proceso` con `fecha_limite < NOW()`:
   - El equipo dañado cambia a estado `reemplazado`
   - Se busca un equipo `operativo` disponible
   - Se asigna el equipo de reemplazo al cliente
   - La orden se marca como `finalizada` con `es_reemplazo = TRUE`
   - Se crea una nueva orden de `reparacion` para el equipo dañado
4. Al finalizar la reparación, el equipo queda `operativo` disponible para otro cliente

### Procedimientos Almacenados
- `registrar_cliente` — Registra nuevo cliente
- `registrar_equipo` — Registra nuevo equipo
- `registrar_tecnico` — Registra nuevo técnico
- `crear_orden` — Crea orden + calcula fecha_limite (4 días)
- `asignar_tecnico` — Asigna técnico a orden
- `actualizar_estado_orden` — Cambia estado de orden
- `cerrar_orden` — Cierra orden y actualiza estado del equipo
- `verificar_plazos` — **Lógica de reemplazo automático**

## 🐳 Comandos Docker Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs del backend
docker-compose logs -f backend

# Ver logs del frontend
docker-compose logs -f frontend

# Reiniciar un servicio
docker-compose restart backend

# Parar todo
docker-compose down

# Parar y eliminar volúmenes (BORRA datos de MySQL)
docker-compose down -v

# Ejecutar verificar_plazos manualmente vía API
curl -X GET http://localhost/api/reportes/resumen
```

## 📊 Pantallas del Sistema

| Pantalla | Ruta | Descripción |
|---------|------|-------------|
| Login | `/login` | Autenticación |
| Dashboard | `/dashboard` | Estadísticas globales y gráficas |
| Equipos | `/equipos` | Gestión de neveras con filtro por estado |
| Órdenes | `/ordenes` | Crear/gestionar órdenes, ver contadores de plazo |
| Clientes | `/clientes` | CRUD de clientes |
| Técnicos | `/tecnicos` | CRUD de técnicos |
| Historial | `/historial` | Log de todos los cambios |
| Reportes | `/reportes` | Reportes mensuales y análisis |

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend | React 18 + Vite + TypeScript |
| Backend | NestJS 10 + TypeScript + mysql2 |
| Base de datos | MySQL 8 (procedimientos almacenados) |
| Proxy | Nginx Alpine |
| Contenedores | Docker + Docker Compose |
| HTTP Client | Axios |
| Routing | React Router v6 |
| Cron Jobs | @nestjs/schedule |
