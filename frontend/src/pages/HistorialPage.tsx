import { useEffect, useState } from 'react';
import { historialApi } from '../services/api';
import { Spinner, EmptyState } from '../components/UI';
import { useToast } from '../components/Toast';
import { formatDate } from '../hooks/useHelpers';

type HistorialTab = 'completo' | 'equipos' | 'ordenes';

export default function HistorialPage() {
  const toast = useToast();
  const [tab, setTab] = useState<HistorialTab>('completo');
  const [data, setData] = useState<any>({ historial_equipos: [], historial_ordenes: [] });
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    setLoading(true);
    historialApi.getCompleto()
      .then(setData)
      .catch(e => toast(e.message, 'error'))
      .finally(() => setLoading(false));
  }, []);

  const equiposH = tab === 'ordenes' ? [] : (data.historial_equipos ?? []);
  const ordenesH = tab === 'equipos' ? [] : (data.historial_ordenes ?? []);

  const filterSearch = (items: any[], fields: string[]) =>
    search ? items.filter(i => fields.some(f => String(i[f] ?? '').toLowerCase().includes(search.toLowerCase()))) : items;

  const filteredEquipos = filterSearch(equiposH, ['estado_nuevo', 'estado_anterior', 'observaciones']);
  const filteredOrdenes = filterSearch(ordenesH, ['estado_nuevo', 'estado_anterior', 'observaciones']);

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1>🕘 Historial</h1>
          <span className="page-header-subtitle">Registro completo de cambios del sistema</span>
        </div>
        <input
          id="historial-search"
          placeholder="🔍 Buscar en historial..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{ width: 240, padding: '8px 14px', fontSize: 13 }}
        />
      </div>

      <div className="page-body">
        {/* Tabs */}
        <div className="flex gap-2 mb-4">
          {([
            { key: 'completo', label: '📋 Todo', icon: '📋' },
            { key: 'equipos', label: '🧊 Equipos', icon: '🧊' },
            { key: 'ordenes', label: '📄 Órdenes', icon: '📄' },
          ] as const).map(t => (
            <button
              key={t.key}
              className={`btn btn-sm ${tab === t.key ? 'btn-primary' : 'btn-secondary'}`}
              onClick={() => setTab(t.key)}
              id={`historial-tab-${t.key}`}
            >
              {t.label}
            </button>
          ))}
        </div>

        {loading ? <Spinner /> : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {/* Historial de Equipos */}
            {tab !== 'ordenes' && (
              <div className="card">
                <div className="card-header">
                  <h3 className="card-title">🧊 Historial de Equipos ({filteredEquipos.length})</h3>
                </div>
                <div className="table-wrapper">
                  {filteredEquipos.length === 0 ? (
                    <EmptyState icon="🧊" title="Sin historial de equipos" />
                  ) : (
                    <table>
                      <thead>
                        <tr>
                          <th>#</th>
                          <th>Equipo ID</th>
                          <th>Estado Anterior</th>
                          <th>Estado Nuevo</th>
                          <th>Cliente Ant.</th>
                          <th>Cliente Nuevo</th>
                          <th>Observaciones</th>
                          <th>Fecha</th>
                        </tr>
                      </thead>
                      <tbody>
                        {filteredEquipos.map((h: any) => (
                          <tr key={h.id}>
                            <td className="font-mono text-muted">#{h.id}</td>
                            <td className="font-mono" style={{ color: 'var(--color-cyan)' }}>Eq.{h.id_equipo}</td>
                            <td>
                              <span style={{ color: 'var(--color-text-muted)', fontSize: 13 }}>{h.estado_anterior || '—'}</span>
                            </td>
                            <td>
                              <span style={{ fontWeight: 600, color: 'var(--color-primary-hover)', fontSize: 13 }}>{h.estado_nuevo}</span>
                            </td>
                            <td className="text-muted text-sm">{h.id_cliente_anterior ? `Cliente #${h.id_cliente_anterior}` : '—'}</td>
                            <td className="text-sm" style={{ color: 'var(--color-success)' }}>{h.id_cliente_nuevo ? `Cliente #${h.id_cliente_nuevo}` : '—'}</td>
                            <td style={{ fontSize: 12, color: 'var(--color-text-muted)', maxWidth: 220 }}>
                              <span title={h.observaciones}>{h.observaciones?.substring(0, 60)}{(h.observaciones?.length ?? 0) > 60 ? '...' : ''}</span>
                            </td>
                            <td className="text-muted text-sm">{formatDate(h.created_at, true)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            )}

            {/* Historial de Órdenes */}
            {tab !== 'equipos' && (
              <div className="card">
                <div className="card-header">
                  <h3 className="card-title">📄 Historial de Órdenes ({filteredOrdenes.length})</h3>
                </div>
                <div className="table-wrapper">
                  {filteredOrdenes.length === 0 ? (
                    <EmptyState icon="📄" title="Sin historial de órdenes" />
                  ) : (
                    <table>
                      <thead>
                        <tr>
                          <th>#</th>
                          <th>Orden ID</th>
                          <th>Estado Anterior</th>
                          <th>Estado Nuevo</th>
                          <th>Técnico ID</th>
                          <th>Observaciones</th>
                          <th>Fecha</th>
                        </tr>
                      </thead>
                      <tbody>
                        {filteredOrdenes.map((h: any) => (
                          <tr key={h.id}>
                            <td className="font-mono text-muted">#{h.id}</td>
                            <td className="font-mono" style={{ color: 'var(--color-cyan)' }}>Ord.{h.id_orden}</td>
                            <td>
                              <span style={{ color: 'var(--color-text-muted)', fontSize: 13 }}>{h.estado_anterior || '—'}</span>
                            </td>
                            <td>
                              <span
                                className={`badge badge-${h.estado_nuevo}`}
                                style={{ fontSize: 12 }}
                              >
                                {h.estado_nuevo}
                              </span>
                            </td>
                            <td className="text-muted text-sm">{h.id_tecnico ? `Téc.#${h.id_tecnico}` : '—'}</td>
                            <td style={{ fontSize: 12, color: 'var(--color-text-muted)', maxWidth: 220 }}>
                              <span title={h.observaciones}>{h.observaciones?.substring(0, 60)}{(h.observaciones?.length ?? 0) > 60 ? '...' : ''}</span>
                            </td>
                            <td className="text-muted text-sm">{formatDate(h.created_at, true)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </>
  );
}
