import { estadoEquipoLabel, estadoOrdenLabel } from '../hooks/useHelpers';

/** Badge de estado de equipo */
export function EstadoEquipoBadge({ estado }: { estado: string }) {
  return (
    <span className={`badge badge-${estado}`}>
      <span className="badge-dot" />
      {estadoEquipoLabel(estado)}
    </span>
  );
}

/** Badge de estado de orden */
export function EstadoOrdenBadge({ estado }: { estado: string }) {
  return (
    <span className={`badge badge-${estado}`}>
      {estadoOrdenLabel(estado)}
    </span>
  );
}

/** Badge de tipo de orden */
export function TipoOrdenBadge({ tipo, esReemplazo }: { tipo: string; esReemplazo?: boolean }) {
  const map: Record<string, { color: string; icon: string; label: string }> = {
    mantenimiento: { color: '#3b82f6', icon: '🔧', label: 'Mantenimiento' },
    reparacion: { color: '#ef4444', icon: '⚙️', label: 'Reparación' },
    reemplazo: { color: '#8b5cf6', icon: '🔄', label: 'Reemplazo' },
  };
  const cfg = map[tipo] || { color: '#7a9cc4', icon: '📋', label: tipo };
  return (
    <span
      className="badge"
      style={{
        background: `${cfg.color}18`,
        color: cfg.color,
        borderColor: `${cfg.color}30`,
      }}
    >
      {cfg.icon} {cfg.label}
      {esReemplazo && <span style={{ marginLeft: 4, fontSize: 10, opacity: 0.8 }}>AUTO</span>}
    </span>
  );
}

/** Badge activo/inactivo */
export function ActiveBadge({ activo }: { activo: boolean }) {
  return (
    <span className={`badge ${activo ? 'badge-operativo' : 'badge-reemplazado'}`}>
      {activo ? '✓ Activo' : '✗ Inactivo'}
    </span>
  );
}
