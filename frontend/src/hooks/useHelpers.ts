// ============================================================
// Helpers de formato y utilidades para el frontend
// ============================================================

/** Formato legible de fechas */
export function formatDate(date: string | null | undefined, withTime = false): string {
  if (!date) return '—';
  const d = new Date(date);
  if (isNaN(d.getTime())) return '—';
  return d.toLocaleString('es-CO', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    ...(withTime ? { hour: '2-digit', minute: '2-digit' } : {}),
  });
}

/** Calcula días restantes hasta fecha_limite */
export function diasRestantes(fechaLimite: string): number {
  const now = new Date();
  const limite = new Date(fechaLimite);
  const diff = limite.getTime() - now.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

/** CSS class según días restantes */
export function diasClass(dias: number): string {
  if (dias > 2) return 'days-ok';
  if (dias > 0) return 'days-warning';
  return 'days-danger';
}

/** Texto legible del estado de equipo */
export function estadoEquipoLabel(estado: string): string {
  const map: Record<string, string> = {
    operativo: 'Operativo',
    en_mantenimiento: 'En Mantenimiento',
    reemplazado: 'Reemplazado',
    en_reparacion: 'En Reparación',
  };
  return map[estado] ?? estado;
}

/** Texto legible del estado de orden */
export function estadoOrdenLabel(estado: string): string {
  const map: Record<string, string> = {
    pendiente: 'Pendiente',
    en_proceso: 'En Proceso',
    finalizada: 'Finalizada',
  };
  return map[estado] ?? estado;
}

/** Texto legible del tipo de orden */
export function tipoOrdenLabel(tipo: string): string {
  const map: Record<string, string> = {
    mantenimiento: 'Mantenimiento',
    reparacion: 'Reparación',
    reemplazo: 'Reemplazo',
  };
  return map[tipo] ?? tipo;
}

/** Nombre del mes en español */
export function monthName(month: number): string {
  const months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return months[month - 1] || '';
}
