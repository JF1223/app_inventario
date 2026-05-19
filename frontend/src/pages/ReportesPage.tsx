import { useEffect, useState } from 'react';
import { reportesApi } from '../services/api';
import type { ReporteMensual } from '../types';
import { EmptyState } from '../components/UI';
import { useToast } from '../components/Toast';
import { EstadoOrdenBadge, TipoOrdenBadge } from '../components/Badges';
import { formatDate, monthName } from '../hooks/useHelpers';

export default function ReportesPage() {
  const toast = useToast();
  const now = new Date();
  const [year, setYear] = useState(now.getFullYear());
  const [month, setMonth] = useState(now.getMonth() + 1);
  const [reporte, setReporte] = useState<ReporteMensual | null>(null);
  const [loading, setLoading] = useState(false);

  const cargarReporte = () => {
    setLoading(true);
    reportesApi.getMensual(year, month)
      .then(setReporte)
      .catch(e => toast(e.message, 'error'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { cargarReporte(); }, []);

  const years = Array.from({ length: 5 }, (_, i) => now.getFullYear() - i);
  const months = Array.from({ length: 12 }, (_, i) => i + 1);

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1>📈 Reportes</h1>
          <span className="page-header-subtitle">Estadísticas y reportes mensuales</span>
        </div>
      </div>

      <div className="page-body">
        {/* Filtros */}
        <div className="card" style={{ marginBottom: 20 }}>
          <div className="card-body">
            <div className="flex items-center gap-3">
              <span style={{ fontSize: 14, color: 'var(--color-text-muted)', fontWeight: 600 }}>Período:</span>
              <select
                id="reporte-year"
                value={year}
                onChange={e => setYear(parseInt(e.target.value))}
                style={{ width: 100 }}
              >
                {years.map(y => <option key={y} value={y}>{y}</option>)}
              </select>
              <select
                id="reporte-month"
                value={month}
                onChange={e => setMonth(parseInt(e.target.value))}
                style={{ width: 140 }}
              >
                {months.map(m => <option key={m} value={m}>{monthName(m)}</option>)}
              </select>
              <button
                className="btn btn-primary"
                onClick={cargarReporte}
                disabled={loading}
                id="btn-generar-reporte"
              >
                {loading ? '⏳ Cargando...' : '📊 Generar Reporte'}
              </button>
            </div>
          </div>
        </div>

        {/* Resumen del mes */}
        {reporte && (
          <>
            <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(4, 1fr)', marginBottom: 20 }}>
              <SummaryCard icon="📋" value={reporte.resumen.total_ordenes} label="Total Órdenes" accent="#3b82f6" />
              <SummaryCard icon="✅" value={reporte.resumen.finalizadas} label="Finalizadas" accent="#10b981" />
              <SummaryCard icon="⏳" value={reporte.resumen.pendientes} label="Pendientes/En Proceso" accent="#f59e0b" />
              <SummaryCard icon="🔄" value={reporte.resumen.reemplazos} label="Reemplazos Auto." accent="#ef4444" />
            </div>

            {/* Título del reporte */}
            <div className="card" style={{ marginBottom: 20 }}>
              <div className="card-header">
                <h3 className="card-title">
                  📄 Reporte de {monthName(reporte.month)} {reporte.year}
                </h3>
                <div style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>
                  {reporte.resumen.total_ordenes} órdenes procesadas en el período
                </div>
              </div>

              <div className="table-wrapper">
                {reporte.ordenes.length === 0 ? (
                  <EmptyState
                    icon="📊"
                    title={`Sin órdenes en ${monthName(month)} ${year}`}
                    subtitle="No se encontraron órdenes de servicio para este período"
                  />
                ) : (
                  <table>
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Equipo</th>
                        <th>Técnico</th>
                        <th>Tipo</th>
                        <th>Estado</th>
                        <th>Reemplazo</th>
                        <th>Creado</th>
                        <th>Cerrado</th>
                      </tr>
                    </thead>
                    <tbody>
                      {reporte.ordenes.map(o => (
                        <tr key={o.id}>
                          <td className="font-mono text-muted">#{o.id}</td>
                          <td>
                            <span className="font-mono" style={{ fontWeight: 700, color: 'var(--color-cyan)', fontSize: 13 }}>
                              {(o as any).placa || `Eq.#${o.id_equipo}`}
                            </span>
                          </td>
                          <td style={{ fontSize: 13 }}>{(o as any).tecnico_nombre || '—'}</td>
                          <td><TipoOrdenBadge tipo={o.tipo} esReemplazo={o.es_reemplazo} /></td>
                          <td><EstadoOrdenBadge estado={o.estado} /></td>
                          <td>
                            {o.es_reemplazo
                              ? <span style={{ fontSize: 12, color: '#8b5cf6', fontWeight: 600 }}>🔄 Sí</span>
                              : <span className="text-muted" style={{ fontSize: 12 }}>No</span>
                            }
                          </td>
                          <td className="text-muted text-sm">{formatDate(o.created_at)}</td>
                          <td className="text-muted text-sm">{formatDate(o.fecha_fin)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>
            </div>

            {/* Análisis adicional */}
            {reporte.resumen.total_ordenes > 0 && (
              <div className="dashboard-grid">
                <div className="card">
                  <div className="card-header">
                    <h3 className="card-title">📊 Análisis del Mes</h3>
                  </div>
                  <div className="card-body">
                    <AnalysisItem
                      label="Tasa de finalización"
                      value={`${Math.round((reporte.resumen.finalizadas / reporte.resumen.total_ordenes) * 100)}%`}
                      color="var(--color-success)"
                    />
                    <AnalysisItem
                      label="Tasa de reemplazo automático"
                      value={`${Math.round((reporte.resumen.reemplazos / reporte.resumen.total_ordenes) * 100)}%`}
                      color={reporte.resumen.reemplazos > 0 ? 'var(--color-danger)' : 'var(--color-success)'}
                    />
                    <AnalysisItem
                      label="Órdenes pendientes/en proceso"
                      value={String(reporte.resumen.pendientes)}
                      color="var(--color-warning)"
                    />
                    <AnalysisItem
                      label="Período analizado"
                      value={`${monthName(reporte.month)} ${reporte.year}`}
                      color="var(--color-primary-hover)"
                    />
                  </div>
                </div>

                <div className="card">
                  <div className="card-header">
                    <h3 className="card-title">🔄 Política de Reemplazos</h3>
                  </div>
                  <div className="card-body">
                    <div style={{ padding: '12px 0', borderBottom: '1px solid var(--color-border)' }}>
                      <div style={{ fontSize: 13, color: 'var(--color-text-muted)', marginBottom: 6 }}>
                        Los equipos que superan el plazo de <strong style={{ color: 'var(--color-warning)' }}>4 días</strong> sin resolución
                        son automáticamente reemplazados por el sistema.
                      </div>
                    </div>
                    {reporte.resumen.reemplazos > 0 ? (
                      <div style={{ marginTop: 12 }}>
                        <div style={{ fontSize: 32, fontWeight: 800, color: 'var(--color-danger)', textAlign: 'center', margin: '16px 0' }}>
                          {reporte.resumen.reemplazos}
                        </div>
                        <div style={{ textAlign: 'center', fontSize: 13, color: 'var(--color-text-muted)' }}>
                          reemplazos automáticos en {monthName(reporte.month)} {reporte.year}
                        </div>
                      </div>
                    ) : (
                      <div style={{ textAlign: 'center', padding: '20px 0' }}>
                        <div style={{ fontSize: 32, marginBottom: 8 }}>✅</div>
                        <div style={{ fontSize: 13, color: 'var(--color-success)' }}>
                          Sin reemplazos automáticos este mes
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}
          </>
        )}

        {!reporte && !loading && (
          <EmptyState icon="📊" title="Selecciona un período" subtitle="Elige año y mes y haz clic en Generar Reporte" />
        )}
      </div>
    </>
  );
}

function SummaryCard({ icon, value, label, accent }: { icon: string; value: number; label: string; accent: string }) {
  return (
    <div className="stat-card" style={{ '--accent-color': accent } as React.CSSProperties}>
      <span className="stat-icon">{icon}</span>
      <div className="stat-value">{value}</div>
      <div className="stat-label">{label}</div>
    </div>
  );
}

function AnalysisItem({ label, value, color }: { label: string; value: string; color: string }) {
  return (
    <div className="flex items-center justify-between" style={{ padding: '10px 0', borderBottom: '1px solid var(--color-border)' }}>
      <span style={{ fontSize: 13, color: 'var(--color-text-muted)' }}>{label}</span>
      <span style={{ fontWeight: 700, color, fontFamily: 'JetBrains Mono, monospace', fontSize: 13 }}>{value}</span>
    </div>
  );
}
