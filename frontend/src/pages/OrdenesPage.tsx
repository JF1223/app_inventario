import { useEffect, useState } from 'react';
import { ordenesApi, equiposApi, tecnicosApi } from '../services/api';
import type { OrdenServicio, Equipo, Tecnico, CreateOrdenDto, AsignarTecnicoDto } from '../types';
import { Modal } from '../components/Modal';
import { Spinner, EmptyState } from '../components/UI';
import { useToast } from '../components/Toast';
import { EstadoOrdenBadge, TipoOrdenBadge } from '../components/Badges';
import { formatDate, diasRestantes, diasClass } from '../hooks/useHelpers';

// ─── Modal Nueva Orden ────────────────────────────────────────
interface NuevaOrdenModalProps {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  equipos: Equipo[];
  tecnicos: Tecnico[];
}

function NuevaOrdenModal({ open, onClose, onSaved, equipos, tecnicos }: NuevaOrdenModalProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState<CreateOrdenDto>({
    id_equipo: 0, tipo: 'mantenimiento', descripcion: '', id_tecnico: undefined,
  });

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement | HTMLTextAreaElement | HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm(prev => ({
      ...prev,
      [name]: name === 'id_equipo' || name === 'id_tecnico' ? (value ? parseInt(value) : undefined) : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.id_equipo) { toast('Selecciona un equipo', 'error'); return; }
    setLoading(true);
    try {
      const result = await ordenesApi.create(form);
      toast(`Orden #${result.id} creada — Límite: ${formatDate(result.fecha_limite)} ✅`, 'success');
      onSaved();
      onClose();
      setForm({ id_equipo: 0, tipo: 'mantenimiento', descripcion: '', id_tecnico: undefined });
    } catch (err: any) {
      toast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const equiposDisponibles = equipos.filter(e => e.estado !== 'en_mantenimiento' || true);

  return (
    <Modal
      open={open}
      onClose={onClose}
      title="Nueva Orden de Servicio"
      
      
      footer={
        <>
          <button className="btn btn-secondary" onClick={onClose} id="orden-modal-cancel">Cancelar</button>
          <button className="btn btn-primary" form="orden-form" type="submit" disabled={loading} id="orden-modal-save">
            {loading ? 'Creando...' : '✅ Crear Orden'}
          </button>
        </>
      }
    >
      <div className="alert-vencido" style={{ borderColor: 'rgba(59,130,246,0.3)', background: 'rgba(59,130,246,0.1)', color: '#60a5fa' }}>
        ⏱️ Se calculará automáticamente un plazo de <strong>4 días naturales</strong> desde la creación.
      </div>
      <form id="orden-form" onSubmit={handleSubmit} className="form-grid">
        <div className="form-group">
          <label htmlFor="o-equipo">Equipo *</label>
          <select id="o-equipo" name="id_equipo" value={form.id_equipo || ''} onChange={handleChange} required>
            <option value="">— Seleccionar equipo —</option>
            {equiposDisponibles.map(e => (
              <option key={e.id} value={e.id}>{e.placa} — {e.estado.replace(/_/g, ' ')}</option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label htmlFor="o-tipo">Tipo de Orden</label>
          <select id="o-tipo" name="tipo" value={form.tipo} onChange={handleChange}>
            <option value="mantenimiento">🔧 Mantenimiento</option>
            <option value="reparacion">⚙️ Reparación</option>
            <option value="reemplazo">🔄 Reemplazo</option>
          </select>
        </div>
        <div className="form-group full-width">
          <label htmlFor="o-tecnico">Técnico Asignado</label>
          <select id="o-tecnico" name="id_tecnico" value={form.id_tecnico || ''} onChange={handleChange}>
            <option value="">— Sin asignar (pendiente) —</option>
            {tecnicos.filter(t => t.activo).map(t => (
              <option key={t.id} value={t.id}>{t.nombre} — {t.especialidad}</option>
            ))}
          </select>
        </div>
        <div className="form-group full-width">
          <label htmlFor="o-descripcion">Descripción</label>
          <textarea id="o-descripcion" name="descripcion" placeholder="Descripción del servicio requerido..." value={form.descripcion} onChange={handleChange} />
        </div>
      </form>
    </Modal>
  );
}

// ─── Modal Gestionar Orden ────────────────────────────────────
interface GestionOrdenModalProps {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  orden: OrdenServicio;
  tecnicos: Tecnico[];
  equipos: Equipo[];
}

function GestionOrdenModal({ open, onClose, onSaved, orden, tecnicos, equipos }: GestionOrdenModalProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [tab, setTab] = useState<'asignar' | 'estado' | 'cerrar'>('asignar');
  const [tecnicoId, setTecnicoId] = useState('');
  const [nuevoEstado, setNuevoEstado] = useState('');
  const [observaciones, setObservaciones] = useState('');

  const equipo = equipos.find(e => e.id === orden.id_equipo);
  const dias = diasRestantes(orden.fecha_limite);

  const asignarTecnico = async () => {
    if (!tecnicoId) { toast('Selecciona un técnico', 'error'); return; }
    setLoading(true);
    try {
      const dto: AsignarTecnicoDto = { id_orden: orden.id, id_tecnico: parseInt(tecnicoId) };
      await ordenesApi.asignarTecnico(dto);
      toast('Técnico asignado ✅', 'success');
      onSaved();
      onClose();
    } catch (err: any) { toast(err.message, 'error'); }
    finally { setLoading(false); }
  };

  const cambiarEstado = async () => {
    if (!nuevoEstado) { toast('Selecciona un estado', 'error'); return; }
    setLoading(true);
    try {
      await ordenesApi.actualizarEstado({ id_orden: orden.id, nuevo_estado: nuevoEstado, observaciones });
      toast('Estado actualizado ✅', 'success');
      onSaved();
      onClose();
    } catch (err: any) { toast(err.message, 'error'); }
    finally { setLoading(false); }
  };

  const cerrarOrden = async () => {
    setLoading(true);
    try {
      await ordenesApi.cerrarOrden(orden.id, observaciones);
      toast('Orden cerrada ✅', 'success');
      onSaved();
      onClose();
    } catch (err: any) { toast(err.message, 'error'); }
    finally { setLoading(false); }
  };

  return (
    <Modal open={open} onClose={onClose} title={`Gestionar Orden #${orden.id}`} icon="⚙️" size="lg">
      {/* Info de la orden */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 20 }}>
        <InfoCard label="Equipo" value={equipo?.placa || `#${orden.id_equipo}`} />
        <InfoCard label="Estado" value={orden.estado.replace(/_/g, ' ')} />
        <InfoCard label="Tipo" value={orden.tipo} />
        <InfoCard
          label="Plazo"
          value={dias <= 0 ? `¡VENCIDO hace ${Math.abs(dias)} días!` : `${dias} días restantes`}
          danger={dias <= 0}
          warning={dias === 1 || dias === 2}
        />
        <InfoCard label="Fecha límite" value={formatDate(orden.fecha_limite, true)} />
        {orden.es_reemplazo && <InfoCard label="Reemplazado" value={`Equipo #${orden.id_equipo_reemplazo}`} />}
      </div>

      {/* Tabs */}
      {orden.estado !== 'finalizada' && (
        <>
          <div className="flex gap-2 mb-4">
            {(['asignar', 'estado', 'cerrar'] as const).map(t => (
              <button
                key={t}
                className={`btn ${tab === t ? 'btn-primary' : 'btn-secondary'} btn-sm`}
                onClick={() => setTab(t)}
                id={`orden-tab-${t}`}
              >
                {t === 'asignar' ? '👷 Asignar' : t === 'estado' ? '🔄 Estado' : '✅ Cerrar'}
              </button>
            ))}
          </div>

          {tab === 'asignar' && (
            <div className="form-grid">
              <div className="form-group full-width">
                <label htmlFor="g-tecnico">Técnico</label>
                <select id="g-tecnico" value={tecnicoId} onChange={e => setTecnicoId(e.target.value)}>
                  <option value="">— Seleccionar técnico —</option>
                  {tecnicos.filter(t => t.activo).map(t => (
                    <option key={t.id} value={t.id}>{t.nombre} — {t.especialidad}</option>
                  ))}
                </select>
              </div>
              <div className="form-group full-width">
                <button className="btn btn-primary" onClick={asignarTecnico} disabled={loading} id="btn-asignar-tecnico">
                  {loading ? 'Asignando...' : '👷 Asignar Técnico'}
                </button>
              </div>
            </div>
          )}

          {tab === 'estado' && (
            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="g-estado">Nuevo Estado</label>
                <select id="g-estado" value={nuevoEstado} onChange={e => setNuevoEstado(e.target.value)}>
                  <option value="">— Seleccionar estado —</option>
                  <option value="pendiente">⏳ Pendiente</option>
                  <option value="en_proceso">⚙️ En Proceso</option>
                  <option value="finalizada">✅ Finalizada</option>
                </select>
              </div>
              <div className="form-group full-width">
                <label htmlFor="g-obs-estado">Observaciones</label>
                <textarea id="g-obs-estado" placeholder="Motivo del cambio..." value={observaciones} onChange={e => setObservaciones(e.target.value)} />
              </div>
              <div className="form-group full-width">
                <button className="btn btn-primary" onClick={cambiarEstado} disabled={loading} id="btn-cambiar-estado">
                  {loading ? 'Actualizando...' : '🔄 Actualizar Estado'}
                </button>
              </div>
            </div>
          )}

          {tab === 'cerrar' && (
            <div className="form-grid">
              <div className="form-group full-width">
                <label htmlFor="g-obs-cierre">Observaciones de cierre</label>
                <textarea id="g-obs-cierre" placeholder="Descripción del trabajo realizado..." value={observaciones} onChange={e => setObservaciones(e.target.value)} />
              </div>
              <div className="form-group full-width">
                <button className="btn btn-success" onClick={cerrarOrden} disabled={loading} id="btn-cerrar-orden">
                  {loading ? 'Cerrando...' : '✅ Cerrar Orden'}
                </button>
              </div>
            </div>
          )}
        </>
      )}

      {orden.estado === 'finalizada' && (
        <div style={{ textAlign: 'center', padding: 20 }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>✅</div>
          <div style={{ fontWeight: 700, color: 'var(--color-success)', fontSize: 16 }}>
            Orden Finalizada
          </div>
          {orden.fecha_fin && (
            <div className="text-muted mt-4">Cerrada el: {formatDate(orden.fecha_fin, true)}</div>
          )}
        </div>
      )}
    </Modal>
  );
}

function InfoCard({ label, value, danger = false, warning = false }: { label: string; value: string; danger?: boolean; warning?: boolean }) {
  return (
    <div style={{
      background: 'var(--color-bg-3)',
      border: `1px solid ${danger ? 'rgba(239,68,68,0.25)' : warning ? 'rgba(245,158,11,0.25)' : 'var(--color-border)'}`,
      borderRadius: 'var(--radius-md)',
      padding: '10px 14px',
    }}>
      <div style={{ fontSize: 11, color: 'var(--color-text-subtle)', marginBottom: 4, textTransform: 'uppercase', letterSpacing: '0.05em' }}>{label}</div>
      <div style={{ fontWeight: 700, fontSize: 13, color: danger ? 'var(--color-danger)' : warning ? 'var(--color-warning)' : 'var(--color-text)' }}>{value}</div>
    </div>
  );
}

// ─── Página Principal ─────────────────────────────────────────
export default function OrdenesPage() {
  const toast = useToast();
  const [ordenes, setOrdenes] = useState<OrdenServicio[]>([]);
  const [equipos, setEquipos] = useState<Equipo[]>([]);
  const [tecnicos, setTecnicos] = useState<Tecnico[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalNueva, setModalNueva] = useState(false);
  const [modalGestion, setModalGestion] = useState(false);
  const [ordenSeleccionada, setOrdenSeleccionada] = useState<OrdenServicio | undefined>();
  const [filterEstado, setFilterEstado] = useState('');

  const load = () => {
    setLoading(true);
    Promise.all([ordenesApi.getAll(), equiposApi.getAll(), tecnicosApi.getAll()])
      .then(([o, e, t]) => { setOrdenes(o); setEquipos(e); setTecnicos(t); })
      .catch(e => toast(e.message, 'error'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const abrirGestion = (o: OrdenServicio) => { setOrdenSeleccionada(o); setModalGestion(true); };

  const filtered = filterEstado ? ordenes.filter(o => o.estado === filterEstado) : ordenes;

  const plazosVencidos = ordenes.filter(o => o.estado === 'en_proceso' && diasRestantes(o.fecha_limite) <= 0).length;

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1>Órdenes de Servicio</h1>
          <span className="page-header-subtitle">{ordenes.length} órdenes totales</span>
        </div>
        <button className="btn btn-primary" onClick={() => setModalNueva(true)} id="btn-nueva-orden">
          + Nueva Orden
        </button>
      </div>

      <div className="page-body">
        {plazosVencidos > 0 && (
          <div className="alert-vencido mb-4">
            🚨 <strong>{plazosVencidos} orden(es)</strong> con plazo vencido — El cron job ejecutará el reemplazo automático
          </div>
        )}

        {/* Filtros rápidos */}
        <div className="flex gap-2 mb-4">
          {['', 'pendiente', 'en_proceso', 'finalizada'].map(estado => (
            <button
              key={estado || 'all'}
              className={`btn btn-sm ${filterEstado === estado ? 'btn-primary' : 'btn-secondary'}`}
              onClick={() => setFilterEstado(estado)}
              id={`filter-ordenes-${estado || 'all'}`}
            >
              {estado === '' ? 'Todas' : estado.replace(/_/g, ' ')}
              <span style={{ marginLeft: 4, fontSize: 11, opacity: 0.7 }}>
                ({ordenes.filter(o => estado ? o.estado === estado : true).length})
              </span>
            </button>
          ))}
        </div>

        <div className="card">
          <div className="card-header">
            <h3 className="card-title">
              Órdenes {filterEstado && `— ${filterEstado.replace(/_/g, ' ')}`}
            </h3>
          </div>
          <div className="table-wrapper">
            {loading ? (
              <Spinner />
            ) : filtered.length === 0 ? (
              <EmptyState title="No hay órdenes" subtitle="Crea la primera orden de servicio" />
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Equipo</th>
                    <th>Tipo</th>
                    <th>Estado</th>
                    <th>Técnico</th>
                    <th>Plazo</th>
                    <th>Reemplazo</th>
                    <th>Creado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map(o => {
                    const equipo = equipos.find(e => e.id === o.id_equipo);
                    const tecnico = tecnicos.find(t => t.id === o.id_tecnico);
                    const dias = diasRestantes(o.fecha_limite);
                    const isPending = o.estado !== 'finalizada';
                    return (
                      <tr key={o.id}>
                        <td className="font-mono text-muted">#{o.id}</td>
                        <td>
                          <span className="font-mono" style={{ fontWeight: 700, color: 'var(--color-cyan)', fontSize: 13 }}>
                            {equipo?.placa || `Equipo #${o.id_equipo}`}
                          </span>
                        </td>
                        <td><TipoOrdenBadge tipo={o.tipo} esReemplazo={o.es_reemplazo} /></td>
                        <td><EstadoOrdenBadge estado={o.estado} /></td>
                        <td style={{ fontSize: 13 }}>{tecnico?.nombre || o.tecnico_nombre || '—'}</td>
                        <td>
                          {isPending ? (
                            <span className={`days-counter ${diasClass(dias)}`}>
                              {dias <= 0 ? `⚠️ ${Math.abs(dias)}d vencido` : `${dias}d restantes`}
                            </span>
                          ) : (
                            <span className="text-muted text-sm">{formatDate(o.fecha_fin)}</span>
                          )}
                        </td>
                        <td>
                          {o.es_reemplazo
                            ? <span style={{ fontSize: 12, color: '#8b5cf6' }}>🔄 #{o.id_equipo_reemplazo}</span>
                            : <span className="text-muted" style={{ fontSize: 12 }}>—</span>
                          }
                        </td>
                        <td className="text-muted text-sm">{formatDate(o.created_at)}</td>
                        <td>
                          <button
                            className="btn btn-secondary btn-sm"
                            onClick={() => abrirGestion(o)}
                            id={`btn-gestionar-orden-${o.id}`}
                          >
                            ⚙️ Gestionar
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>

      <NuevaOrdenModal
        open={modalNueva}
        onClose={() => setModalNueva(false)}
        onSaved={load}
        equipos={equipos}
        tecnicos={tecnicos}
      />

      {ordenSeleccionada && (
        <GestionOrdenModal
          open={modalGestion}
          onClose={() => { setModalGestion(false); setOrdenSeleccionada(undefined); }}
          onSaved={load}
          orden={ordenSeleccionada}
          tecnicos={tecnicos}
          equipos={equipos}
        />
      )}
    </>
  );
}
