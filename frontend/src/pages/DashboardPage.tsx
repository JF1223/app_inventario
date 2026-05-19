import { useEffect, useState } from 'react';
import { reportesApi } from '../services/api';
import type { ResumenReporte } from '../types';
import { Spinner } from '../components/UI';

const ESTADO_COLORS: Record<string, string> = {
  operativo: '#10b981',
  en_mantenimiento: '#f59e0b',
  reemplazado: '#8b5cf6',
  en_reparacion: '#ef4444',
  pendiente: '#f59e0b',
  en_proceso: '#3b82f6',
  finalizada: '#10b981',
  mantenimiento: '#3b82f6',
  reparacion: '#ef4444',
  reemplazo: '#8b5cf6',
};

function ChartBar({ label, value, total, color }: { label: string; value: number; total: number; color: string }) {
  const pct = total > 0 ? Math.round((value / total) * 100) : 0;
  return (
    <div className="chart-bar-item">
      <div className="chart-bar-header">
        <span className="chart-bar-label">{label.replace('_', ' ')}</span>
        <span className="chart-bar-value">{value} <span className="text-muted">({pct}%)</span></span>
      </div>
      <div className="progress-bar-wrap">
        <div
          className="progress-bar-fill"
          style={{ width: `${pct}%`, background: color }}
        />
      </div>
    </div>
  );
}

export default function DashboardPage() {
  const [resumen, setResumen] = useState<ResumenReporte | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    reportesApi.getResumen()
      .then(setResumen)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1> Dashboard</h1>
          <span className="page-header-subtitle">Resumen general del sistema</span>
        </div>
      </div>
      <div className="page-body"><Spinner text="Cargando estadísticas..." /></div>
    </>
  );

  if (error) return (
    <>
      <div className="page-header"><div className="page-header-left"><h1>Dashboard</h1></div></div>
      <div className="page-body">
        <div className="alert-vencido">⚠️ Error al cargar estadísticas: {error}</div>
      </div>
    </>
  );

  const totalEquipos = Number(resumen?.total_equipos ?? 0);
  const totalClientes = Number(resumen?.total_clientes ?? 0);
  const totalTecnicos = Number(resumen?.total_tecnicos ?? 0);
  const totalReemplazos = Number(resumen?.total_reemplazos ?? 0);

  const equiposPorEstado = resumen?.equipos_por_estado ?? [];
  const ordenesPorEstado = resumen?.ordenes_por_estado ?? [];
  const ordenesPorTipo = resumen?.ordenes_por_tipo ?? [];

  const totalOrdenes = ordenesPorEstado.reduce((a, o) => a + parseInt(String(o.cantidad)), 0);
  const totalEquiposGraf = equiposPorEstado.reduce((a, e) => a + parseInt(String(e.cantidad)), 0);
  const totalOrdenesTipo = ordenesPorTipo.reduce((a, t) => a + parseInt(String(t.cantidad)), 0);

  const equiposOperativos = equiposPorEstado.find(e => e.estado === 'operativo');
  const equiposMantenimiento = equiposPorEstado.find(e => e.estado === 'en_mantenimiento');
  const ordenesPendientes = ordenesPorEstado.find(o => o.estado === 'pendiente');
  const ordenesEnProceso = ordenesPorEstado.find(o => o.estado === 'en_proceso');

  const STATS = [
    { label: 'Total Equipos', value: totalEquipos},
    { label: 'Clientes Activos', value: totalClientes},
    { label: 'Técnicos Activos', value: totalTecnicos},
    { label: 'Reemplazos Auto.', value: totalReemplazos},
    { label: 'Operativos', value: parseInt(String(equiposOperativos?.cantidad ?? 0))},
    { label: 'En Mantenimiento', value: parseInt(String(equiposMantenimiento?.cantidad ?? 0))},
    { label: 'Órdenes Pendientes', value: parseInt(String(ordenesPendientes?.cantidad ?? 0))},
    { label: 'Órdenes En Proceso', value: parseInt(String(ordenesEnProceso?.cantidad ?? 0)) },
  ];

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1> Dashboard</h1>
          <span className="page-header-subtitle">Resumen general del sistema</span>
        </div>
        <button
          className="btn btn-secondary btn-sm"
          onClick={() => { setLoading(true); reportesApi.getResumen().then(setResumen).finally(() => setLoading(false)); }}
          id="dashboard-refresh-btn"
        >
          🔄 Actualizar
        </button>
      </div>

      <div className="page-body">
        {/* Stats Grid */}
        <div className="stats-grid">
          {STATS.map((s) => (
            <div
              key={s.label}
              className="stat-card"
              
            >
              
              <div className="stat-value">{s.value.toLocaleString('es-CO')}</div>
              <div className="stat-label">{s.label}</div>
            </div>
          ))}
        </div>

        {/* Charts Grid */}
        <div className="dashboard-grid">
          {/* Estado de Equipos */}
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">Estado de Equipos</h3>
            </div>
            <div className="card-body">
              {equiposPorEstado.length === 0 ? (
                <p className="text-muted">Sin datos de equipos</p>
              ) : equiposPorEstado.map(e => (
                <ChartBar
                  key={e.estado}
                  label={e.estado.replace(/_/g, ' ')}
                  value={parseInt(String(e.cantidad))}
                  total={totalEquiposGraf}
                  color={ESTADO_COLORS[e.estado] || '#7a9cc4'}
                />
              ))}
            </div>
          </div>

          {/* Estado de Órdenes */}
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">Estado de Órdenes</h3>
            </div>
            <div className="card-body">
              {ordenesPorEstado.length === 0 ? (
                <p className="text-muted">Sin órdenes registradas</p>
              ) : ordenesPorEstado.map(o => (
                <ChartBar
                  key={o.estado}
                  label={o.estado.replace(/_/g, ' ')}
                  value={parseInt(String(o.cantidad))}
                  total={totalOrdenes}
                  color={ESTADO_COLORS[o.estado] || '#7a9cc4'}
                />
              ))}
            </div>
          </div>

          {/* Tipo de Órdenes */}
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">🔧 Tipo de Órdenes</h3>
            </div>
            <div className="card-body">
              {ordenesPorTipo.length === 0 ? (
                <p className="text-muted">Sin órdenes registradas</p>
              ) : ordenesPorTipo.map(t => (
                <ChartBar
                  key={t.tipo}
                  label={t.tipo}
                  value={parseInt(String(t.cantidad))}
                  total={totalOrdenesTipo}
                  color={ESTADO_COLORS[t.tipo] || '#7a9cc4'}
                />
              ))}
            </div>
          </div>

          {/* Alertas críticas */}
          <div className="card">
            <div className="card-header">
              <h3 className="card-title">⚡ Información del Sistema</h3>
            </div>
            <div className="card-body">
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>                            
                <InfoRow icon="📦" label="Equipos en reparación" value={String(parseInt(String(equiposPorEstado.find(e => e.estado === 'en_reparacion')?.cantidad ?? 0)))} />
                <InfoRow icon="🔁" label="Total reemplazos automáticos" value={String(totalReemplazos)} highlight />
                {parseInt(String(equiposPorEstado.find(e => e.estado === 'en_reparacion')?.cantidad ?? 0)) > 0 && (
                  <div className="alert-vencido">
                    ⚠️ Hay equipos en reparación que podrían asignarse a clientes
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

function InfoRow({ icon, label, value, highlight = false }: { icon: string; label: string; value: string; highlight?: boolean }) {
  return (
    <div className="flex items-center justify-between" style={{ padding: '8px 0', borderBottom: '1px solid var(--color-border)' }}>
      <span className="text-muted">{icon} {label}</span>
      <span style={{ fontWeight: 700, color: highlight ? 'var(--color-primary-hover)' : 'var(--color-text)', fontFamily: 'JetBrains Mono, monospace', fontSize: 13 }}>
        {value}
      </span>
    </div>
  );
}
