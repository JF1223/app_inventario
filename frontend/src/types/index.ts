// ============================================================
// Tipos TypeScript del Sistema de Gestión de Neveras
// ============================================================

export interface Cliente {
  id: number;
  nombre: string;
  documento: string;
  direccion?: string;
  telefono?: string;
  email?: string;
  activo: boolean;
  created_at: string;
  updated_at: string;
}

export interface Equipo {
  id: number;
  placa: string;
  estado: 'operativo' | 'en_mantenimiento' | 'reemplazado' | 'en_reparacion';
  limpieza?: string;
  uso?: string;
  novedad: 'asignada' | 'disponible' | 'no_disponible';
  asignadas?: string;
  observaciones?: string;
  tipo_reparacion?: 'piezas' | 'arreglo';
  id_cliente?: number;
  cliente?: Cliente;
  created_at: string;
  updated_at: string;
}

export interface Tecnico {
  id: number;
  nombre: string;
  especialidad: string;
  contacto: string;
  activo: boolean;
  created_at: string;
  updated_at: string;
}

export interface OrdenServicio {
  id: number;
  id_equipo: number;
  id_tecnico?: number;
  estado: 'pendiente' | 'en_proceso' | 'finalizada';
  tipo: 'mantenimiento' | 'reparacion' | 'reemplazo';
  descripcion?: string;
  observaciones?: string;
  es_reemplazo: boolean;
  id_equipo_reemplazo?: number;
  fecha_reemplazo?: string;
  fecha_limite: string;
  fecha_inicio?: string;
  fecha_fin?: string;
  created_at: string;
  updated_at: string;
  equipo?: Equipo;
  tecnico?: Tecnico;
  tecnico_nombre?: string;
}

export interface HistorialOrden {
  id: number;
  id_orden: number;
  estado_anterior?: string;
  estado_nuevo: string;
  id_tecnico?: number;
  observaciones?: string;
  created_at: string;
}

export interface HistorialEquipo {
  id: number;
  id_equipo: number;
  estado_anterior?: string;
  estado_nuevo: string;
  id_cliente_anterior?: number;
  id_cliente_nuevo?: number;
  observaciones?: string;
  created_at: string;
}

export interface ResumenReporte {
  equipos_por_estado: { estado: string; cantidad: number }[];
  ordenes_por_estado: { estado: string; cantidad: number }[];
  ordenes_por_tipo: { tipo: string; cantidad: number }[];
  total_reemplazos: number;
  total_equipos: number;
  total_clientes: number;
  total_tecnicos: number;
}

export interface ReporteMensual {
  year: number;
  month: number;
  ordenes: OrdenServicio[];
  resumen: {
    total_ordenes: number;
    finalizadas: number;
    reemplazos: number;
    pendientes: number;
  };
}

export interface CreateClienteDto {
  nombre: string;
  documento: string;
  direccion?: string;
  telefono?: string;
  email?: string;
}

export interface CreateEquipoDto {
  placa: string;
  estado?: string;
  limpieza?: string;
  uso?: string;
  novedad?: string;
  asignadas?: string;
  observaciones?: string;
  id_cliente?: number;
}

export interface CreateTecnicoDto {
  nombre: string;
  especialidad: string;
  contacto: string;
  activo?: boolean;
}

export interface CreateOrdenDto {
  id_equipo: number;
  tipo: string;
  descripcion?: string;
  id_tecnico?: number;
}

export interface AsignarTecnicoDto {
  id_orden: number;
  id_tecnico: number;
}

export interface UpdateEstadoOrdenDto {
  id_orden: number;
  nuevo_estado: string;
  observaciones?: string;
}

export interface EnviarReparacionDto {
  tipo_reparacion: 'piezas' | 'arreglo';
}

export interface ReasignarEquipoDto {
  id_cliente: number;
}
