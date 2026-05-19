import axios from 'axios';
import type {
  Cliente, Equipo, Tecnico, OrdenServicio,
  ResumenReporte, ReporteMensual,
  CreateClienteDto, CreateEquipoDto, CreateTecnicoDto,
  CreateOrdenDto, AsignarTecnicoDto, UpdateEstadoOrdenDto,
  EnviarReparacionDto, ReasignarEquipoDto,
} from '../types';

const BASE_URL = import.meta.env.VITE_API_URL || '/api';

const api = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 10000,
});

// Interceptor para manejo de errores global
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const message = error.response?.data?.message || error.message || 'Error de conexión';
    return Promise.reject(new Error(Array.isArray(message) ? message.join(', ') : message));
  }
);

// ============================================================
// CLIENTES
// ============================================================
export const clientesApi = {
  getAll: () => api.get<Cliente[]>('/clientes').then(r => r.data),
  create: (dto: CreateClienteDto) => api.post<{ id: number }>('/clientes', dto).then(r => r.data),
};

// ============================================================
// EQUIPOS
// ============================================================
export const equiposApi = {
  getAll: () => api.get<Equipo[]>('/equipos').then(r => r.data),
  getOne: (id: number) => api.get<Equipo>(`/equipos/${id}`).then(r => r.data),
  create: (dto: CreateEquipoDto) => api.post<{ id: number }>('/equipos', dto).then(r => r.data),
  update: (id: number, dto: Partial<CreateEquipoDto>) =>
    api.put<{ filas_afectadas: number }>(`/equipos/${id}`, dto).then(r => r.data),
  enviarReparacion: (id: number, dto: EnviarReparacionDto) =>
    api.post(`/equipos/${id}/enviar-reparacion`, dto).then(r => r.data),
  finalizarReparacion: (id: number) =>
    api.put(`/equipos/${id}/finalizar-reparacion`).then(r => r.data),
  reasignar: (id: number, dto: ReasignarEquipoDto) =>
    api.put(`/equipos/${id}/reasignar`, dto).then(r => r.data),
};

// ============================================================
// TÉCNICOS
// ============================================================
export const tecnicosApi = {
  getAll: () => api.get<Tecnico[]>('/tecnicos').then(r => r.data),
  create: (dto: CreateTecnicoDto) => api.post<{ id: number }>('/tecnicos', dto).then(r => r.data),
  update: (id: number, dto: Partial<CreateTecnicoDto>) =>
    api.put<{ filas_afectadas: number }>(`/tecnicos/${id}`, dto).then(r => r.data),
};

// ============================================================
// ÓRDENES DE SERVICIO
// ============================================================
export const ordenesApi = {
  getAll: () => api.get<OrdenServicio[]>('/ordenes').then(r => r.data),
  getOne: (id: number) => api.get<OrdenServicio>(`/ordenes/${id}`).then(r => r.data),
  create: (dto: CreateOrdenDto) => api.post<{ id: number; fecha_limite: string }>('/ordenes', dto).then(r => r.data),
  asignarTecnico: (dto: AsignarTecnicoDto) => api.put('/ordenes/asignar', dto).then(r => r.data),
  actualizarEstado: (dto: UpdateEstadoOrdenDto) => api.put('/ordenes/estado', dto).then(r => r.data),
  cerrarOrden: (id: number, observaciones?: string) =>
    api.put(`/ordenes/${id}/cerrar`, { observaciones }).then(r => r.data),
};

// ============================================================
// HISTORIAL
// ============================================================
export const historialApi = {
  getCompleto: () => api.get('/historial').then(r => r.data),
  getEquipo: (id: number) => api.get(`/historial/equipo/${id}`).then(r => r.data),
  getOrden: (id: number) => api.get(`/historial/orden/${id}`).then(r => r.data),
};

// ============================================================
// REPORTES
// ============================================================
export const reportesApi = {
  getResumen: () => api.get<ResumenReporte>('/reportes/resumen').then(r => r.data),
  getMensual: (year: number, month: number) =>
    api.get<ReporteMensual>('/reportes/mensual', { params: { year, month } }).then(r => r.data),
};
