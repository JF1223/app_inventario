import { useEffect, useState } from 'react';
import { equiposApi, clientesApi } from '../services/api';
import type { Equipo, Cliente, CreateEquipoDto } from '../types';
import { Modal } from '../components/Modal';
import { Spinner, EmptyState } from '../components/UI';
import { useToast } from '../components/Toast';
import { EstadoEquipoBadge } from '../components/Badges';
import { formatDate } from '../hooks/useHelpers';
import { historialApi } from '../services/api';

// ─── Modal Crear/Editar Equipo ────────────────────────────────
interface EquipoModalProps {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  equipo?: Equipo;
  clientes: Cliente[];
}

function EquipoModal({ open, onClose, onSaved, equipo, clientes }: EquipoModalProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState<CreateEquipoDto>({
    placa: '', estado: 'operativo', limpieza: '', uso: '',
    novedad: 'disponible', asignadas: '', observaciones: '', id_cliente: undefined,
  });

  useEffect(() => {
    if (equipo) {
      setForm({
        placa: equipo.placa, estado: equipo.estado, limpieza: equipo.limpieza || '',
        uso: equipo.uso || '', novedad: equipo.novedad, asignadas: equipo.asignadas || '',
        observaciones: equipo.observaciones || '', id_cliente: equipo.id_cliente,
      });
    } else {
      setForm({ placa: '', estado: 'operativo', limpieza: '', uso: '', novedad: 'disponible', asignadas: '', observaciones: '', id_cliente: undefined });
    }
  }, [equipo, open]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setForm(prev => ({ ...prev, [name]: name === 'id_cliente' ? (value ? parseInt(value) : undefined) : value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      if (equipo) {
        await equiposApi.update(equipo.id, form);
        toast('Equipo actualizado ✅', 'success');
      } else {
        await equiposApi.create(form);
        toast('Equipo registrado ✅', 'success');
      }
      onSaved();
      onClose();
    } catch (err: any) {

      console.log(err);

      toast('El número de placa ya existe', 'error');

    } finally {

      setLoading(false);

    }
  };

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={equipo ? 'Editar Equipo' : 'Registrar Equipo'}


      footer={
        <>
          <button className="btn btn-secondary" onClick={onClose} id="equipo-modal-cancel">Cancelar</button>
          <button className="btn btn-primary" form="equipo-form" type="submit" disabled={loading} id="equipo-modal-save">
            {loading ? 'Guardando...' : `✅ ${equipo ? 'Actualizar' : 'Guardar'}`}
          </button>
        </>
      }
    >
      <form id="equipo-form" onSubmit={handleSubmit} className="form-grid">
        <div className="form-group">
          <label htmlFor="e-placa">Placa / Código *</label>
          <input id="e-placa" name="placa" placeholder="EJ: NEV-001" value={form.placa} onChange={handleChange} required />
        </div>
        <div className="form-group">
          <label htmlFor="e-estado">Estado</label>
          <select id="e-estado" name="estado" value={form.estado} onChange={handleChange}>
            <option value="operativo">Operativo</option>
            <option value="en_mantenimiento"> En Mantenimiento</option>
            <option value="reemplazado">Reemplazado</option>
            <option value="en_reparacion"> En Reparación</option>
          </select>
        </div>
        <div className="form-group">
          <label htmlFor="e-novedad">Novedad</label>
          <select id="e-novedad" name="novedad" value={form.novedad} onChange={handleChange}>
            <option value="asignada">Asignada</option>
            <option value="disponible">Disponible</option>
            <option value="no_disponible">No Disponible</option>
          </select>
        </div>
        <div className="form-group">
          <label htmlFor="e-cliente">Cliente Asignado</label>
          <select id="e-cliente" name="id_cliente" value={form.id_cliente ?? ''} onChange={handleChange}>
            <option value="">— Sin cliente —</option>
            {clientes.map(c => (
              <option key={c.id} value={c.id}>{c.nombre} ({c.documento})</option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label htmlFor="e-limpieza">Limpieza</label>
          <input id="e-limpieza" name="limpieza" placeholder="Estado de limpieza" value={form.limpieza} onChange={handleChange} />
        </div>
        <div className="form-group">
          <label htmlFor="e-uso">Uso</label>
          <input id="e-uso" name="uso" placeholder="Tipo de uso" value={form.uso} onChange={handleChange} />
        </div>
        <div className="form-group">
          <label htmlFor="e-asignadas">Asignadas</label>
          <input id="e-asignadas" name="asignadas" placeholder="Info adicional de asignación" value={form.asignadas} onChange={handleChange} />
        </div>
        <div className="form-group full-width">
          <label htmlFor="e-observaciones">Observaciones</label>
          <textarea id="e-observaciones" name="observaciones" placeholder="Observaciones del equipo..." value={form.observaciones} onChange={handleChange} />
        </div>
      </form>
    </Modal>
  );
}

// ─── Modal Enviar a Reparación ────────────────────────────────
interface ReparacionModalProps {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  equipo: Equipo | undefined;
}

function ReparacionModal({ open, onClose, onSaved, equipo }: ReparacionModalProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [tipoReparacion, setTipoReparacion] = useState<'piezas' | 'arreglo'>('arreglo');

  useEffect(() => {
    if (open) setTipoReparacion('arreglo');
  }, [open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!equipo) return;
    setLoading(true);
    try {
      await equiposApi.enviarReparacion(equipo.id, { tipo_reparacion: tipoReparacion });
      toast('Equipo enviado a reparación 🔧', 'success');
      onSaved();
      onClose();
    } catch (err: any) {
      toast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={`Enviar a reparación: ${equipo?.placa || ''}`}
      icon="🔧"
      size="sm"
      footer={
        <>
          <button className="btn btn-secondary" onClick={onClose}>Cancelar</button>
          <button className="btn btn-primary" form="reparacion-form" type="submit" disabled={loading}>
            {loading ? 'Enviando...' : '🔧 Enviar a reparación'}
          </button>
        </>
      }
    >
      <form id="reparacion-form" onSubmit={handleSubmit}>
        <p style={{ marginBottom: 16, fontSize: 13, color: 'var(--color-text-muted)' }}>
          El equipo se desasignará del cliente actual y quedará en reparación.
          Seleccione el motivo de la reparación:
        </p>
        <div className="form-group">
          <label>Tipo de reparación *</label>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 4 }}>
            <label style={{
              display: 'flex', alignItems: 'center', gap: 10, padding: '12px 16px',
              border: `2px solid ${tipoReparacion === 'piezas' ? 'var(--color-primary)' : 'var(--color-border)'}`,
              borderRadius: 8, cursor: 'pointer', transition: 'all 0.15s',
              background: tipoReparacion === 'piezas' ? 'var(--color-primary-hover)' : 'transparent',
            }}>
              <input
                type="radio" name="tipo_reparacion" value="piezas"
                checked={tipoReparacion === 'piezas'}
                onChange={() => setTipoReparacion('piezas')}
                style={{ accentColor: 'var(--color-primary)' }}
              />
              <div>
                <div style={{ fontWeight: 600, fontSize: 14 }}>🔩 Piezas</div>
                <div style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>Se necesitan repuestos o piezas de reemplazo</div>
              </div>
            </label>
            <label style={{
              display: 'flex', alignItems: 'center', gap: 10, padding: '12px 16px',
              border: `2px solid ${tipoReparacion === 'arreglo' ? 'var(--color-primary)' : 'var(--color-border)'}`,
              borderRadius: 8, cursor: 'pointer', transition: 'all 0.15s',
              background: tipoReparacion === 'arreglo' ? 'var(--color-primary-hover)' : 'transparent',
            }}>
              <input
                type="radio" name="tipo_reparacion" value="arreglo"
                checked={tipoReparacion === 'arreglo'}
                onChange={() => setTipoReparacion('arreglo')}
                style={{ accentColor: 'var(--color-primary)' }}
              />
              <div>
                <div style={{ fontWeight: 600, fontSize: 14 }}>🔧 Arreglo</div>
                <div style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>Reparación o ajuste sin reemplazo de piezas</div>
              </div>
            </label>
          </div>
        </div>
      </form>
    </Modal>
  );
}

// ─── Modal Reasignar Equipo ──────────────────────────────────
interface ReasignarModalProps {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  equipo: Equipo | undefined;
  clientes: Cliente[];
}

function ReasignarModal({ open, onClose, onSaved, equipo, clientes }: ReasignarModalProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [idCliente, setIdCliente] = useState<number | undefined>();

  useEffect(() => {
    if (open) setIdCliente(undefined);
  }, [open]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!equipo || !idCliente) return;
    setLoading(true);
    try {
      await equiposApi.reasignar(equipo.id, { id_cliente: idCliente });
      toast('Equipo reasignado correctamente ✅', 'success');
      onSaved();
      onClose();
    } catch (err: any) {
      toast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      open={open}
      onClose={onClose}
      title={`Reasignar: ${equipo?.placa || ''}`}


      footer={
        <>
          <button className="btn btn-secondary" onClick={onClose}>Cancelar</button>
          <button className="btn btn-primary" form="reasignar-form" type="submit" disabled={loading || !idCliente}>
            {loading ? 'Asignando...' : ' Reasignar'}
          </button>
        </>
      }
    >
      <form id="reasignar-form" onSubmit={handleSubmit}>
        <p style={{ marginBottom: 16, fontSize: 13, color: 'var(--color-text-muted)' }}>
          Seleccione el cliente al que se le asignará este equipo:
        </p>
        <div className="form-group">
          <label htmlFor="r-cliente">Cliente *</label>
          <select
            id="r-cliente"
            value={idCliente ?? ''}
            onChange={e => setIdCliente(e.target.value ? parseInt(e.target.value) : undefined)}
            required
          >
            <option value="">— Seleccione un cliente —</option>
            {clientes.map(c => (
              <option key={c.id} value={c.id}>{c.nombre} ({c.documento})</option>
            ))}
          </select>
        </div>
      </form>
    </Modal>
  );
}

// ─── Modal Historial Equipo ────────────────────────────────────
function HistorialModal({ open, onClose, equipoId, equipoPlaca }: { open: boolean; onClose: () => void; equipoId: number; equipoPlaca: string }) {
  const [historial, setHistorial] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (open && equipoId) {
      setLoading(true);
      historialApi.getEquipo(equipoId)
        .then(setHistorial)
        .finally(() => setLoading(false));
    }
  }, [open, equipoId]);

  return (
    <Modal open={open} onClose={onClose} title={`Historial: ${equipoPlaca}`} icon="🕘" size="lg">
      {loading ? <Spinner /> : historial.length === 0 ? (
        <EmptyState icon="🕘" title="Sin historial" subtitle="Este equipo no tiene cambios registrados" />
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
          {historial.map((h: any) => (
            <div key={h.id} style={{
              display: 'flex', gap: 12, padding: '12px 0',
              borderBottom: '1px solid var(--color-border)', alignItems: 'flex-start'
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: '50%',
                background: 'var(--color-surface-2)', border: '1px solid var(--color-border)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 14, flexShrink: 0
              }}>🔄</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 2 }}>
                  <span style={{ color: 'var(--color-text-muted)' }}>{h.estado_anterior || 'inicio'}</span>
                  {' → '}
                  <span style={{ color: 'var(--color-primary-hover)' }}>{h.estado_nuevo}</span>
                </div>
                {h.observaciones && <div style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>{h.observaciones}</div>}
              </div>
              <div style={{ fontSize: 11, color: 'var(--color-text-subtle)', whiteSpace: 'nowrap' }}>
                {formatDate(h.created_at, true)}
              </div>
            </div>
          ))}
        </div>
      )}
    </Modal>
  );
}

// ─── Página Principal ─────────────────────────────────────────
export default function EquiposPage() {
  const toast = useToast();
  const [equipos, setEquipos] = useState<Equipo[]>([]);
  const [clientes, setClientes] = useState<Cliente[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [historialOpen, setHistorialOpen] = useState(false);
  const [reparacionOpen, setReparacionOpen] = useState(false);
  const [reasignarOpen, setReasignarOpen] = useState(false);
  const [editTarget, setEditTarget] = useState<Equipo | undefined>();
  const [historialTarget, setHistorialTarget] = useState<Equipo | undefined>();
  const [reparacionTarget, setReparacionTarget] = useState<Equipo | undefined>();
  const [reasignarTarget, setReasignarTarget] = useState<Equipo | undefined>();
  const [search, setSearch] = useState('');
  const [filterEstado, setFilterEstado] = useState('');

  const load = () => {
    setLoading(true);
    Promise.all([equiposApi.getAll(), clientesApi.getAll()])
      .then(([e, c]) => { setEquipos(e); setClientes(c); })
      .catch(e => toast(e.message, 'error'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const openEdit = (e: Equipo) => { setEditTarget(e); setModalOpen(true); };
  const openNew = () => { setEditTarget(undefined); setModalOpen(true); };
  const onClose = () => { setModalOpen(false); setEditTarget(undefined); };

  const openHistorial = (e: Equipo) => { setHistorialTarget(e); setHistorialOpen(true); };
  const openReparacion = (e: Equipo) => { setReparacionTarget(e); setReparacionOpen(true); };
  const openReasignar = (e: Equipo) => { setReasignarTarget(e); setReasignarOpen(true); };

  const handleFinalizarReparacion = async (e: Equipo) => {
    if (!confirm(`¿Finalizar reparación de ${e.placa}? El equipo quedará disponible para reasignar.`)) return;
    try {
      await equiposApi.finalizarReparacion(e.id);
      toast('Reparación finalizada ✅', 'success');
      load();
    } catch (err: any) {
      toast(err.message, 'error');
    }
  };

  const filtered = equipos.filter(e => {
    const matchSearch = e.placa.toLowerCase().includes(search.toLowerCase()) ||
      (e.observaciones?.toLowerCase().includes(search.toLowerCase()) ?? false);
    const matchEstado = filterEstado ? e.estado === filterEstado : true;
    return matchSearch && matchEstado;
  });

  const clienteNombre = (id?: number) => clientes.find(c => c.id === id)?.nombre || '—';

  const tipoReparacionLabel = (tr?: string) => {
    if (!tr) return null;
    const labels: Record<string, string> = { piezas: '🔩 Piezas', arreglo: '🔧 Arreglo' };
    return labels[tr] || tr;
  };

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1>🧊 Equipos</h1>
          <span className="page-header-subtitle">{equipos.length} equipos registrados</span>
        </div>
        <button className="btn btn-primary" onClick={openNew} id="btn-nuevo-equipo">
          + Nuevo Equipo
        </button>
      </div>

      <div className="page-body">
        {/* Resumen rápido */}
        <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(4, 1fr)', marginBottom: 20 }}>
          {['operativo', 'en_mantenimiento', 'reemplazado', 'en_reparacion'].map(estado => {
            const count = equipos.filter(e => e.estado === estado).length;
            const icons: Record<string, string> = { operativo: '✅', en_mantenimiento: '⚠️', reemplazado: '🔁', en_reparacion: '🔴' };
            const colors: Record<string, string> = { operativo: '#10b981', en_mantenimiento: '#f59e0b', reemplazado: '#8b5cf6', en_reparacion: '#ef4444' };
            return (
              <div
                key={estado}
                className="stat-card"
                style={{ '--accent-color': colors[estado], cursor: 'pointer' } as React.CSSProperties}
                onClick={() => setFilterEstado(filterEstado === estado ? '' : estado)}
              >
                <span className="stat-icon">{icons[estado]}</span>
                <div className="stat-value">{count}</div>
                <div className="stat-label">{estado.replace(/_/g, ' ')}</div>
                {filterEstado === estado && (
                  <div className="stat-badge" style={{ background: `${colors[estado]}22`, color: colors[estado] }}>
                    Filtrando ✓
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <div className="card">
          <div className="card-header">
            <h3 className="card-title">📋 Lista de Equipos {filterEstado && `— ${filterEstado.replace(/_/g, ' ')}`}</h3>
            <div className="flex gap-2">
              {filterEstado && (
                <button className="btn btn-secondary btn-sm" onClick={() => setFilterEstado('')} id="btn-clear-filter">
                  ✕ Quitar filtro
                </button>
              )}
              <input
                id="equipos-search"
                placeholder="🔍 Buscar placa..."
                value={search}
                onChange={e => setSearch(e.target.value)}
                style={{ width: 200, padding: '7px 12px', fontSize: 13 }}
              />
            </div>
          </div>
          <div className="table-wrapper">
            {loading ? (
              <Spinner />
            ) : filtered.length === 0 ? (
              <EmptyState icon="🧊" title="No hay equipos" subtitle="Registra el primer equipo con el botón superior" />
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>Placa</th>
                    <th>Estado</th>
                    <th>Cliente</th>
                    <th>Novedad</th>
                    <th>Reparación</th>
                    <th>Registro</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map(eq => (
                    <tr key={eq.id}>
                      <td>
                        <span className="font-mono" style={{ fontWeight: 700, color: 'var(--color-cyan)', fontSize: 13 }}>
                          {eq.placa}
                        </span>
                      </td>
                      <td><EstadoEquipoBadge estado={eq.estado} /></td>
                      <td style={{ fontSize: 13 }}>{clienteNombre(eq.id_cliente)}</td>
                      <td>
                        <span style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>
                          {eq.novedad.replace(/_/g, ' ')}
                        </span>
                      </td>
                      <td style={{ fontSize: 12 }}>
                        {eq.tipo_reparacion ? tipoReparacionLabel(eq.tipo_reparacion) : '—'}
                      </td>
                      <td className="text-muted text-sm">{formatDate(eq.created_at)}</td>
                      <td>
                        <div className="flex gap-2">
                          {eq.estado !== 'en_reparacion' && (
                            <button
                              className="btn btn-secondary btn-sm"
                              onClick={() => openReparacion(eq)}
                              title="Enviar a reparación"
                            >
                              🔧
                            </button>
                          )}
                          {eq.estado === 'en_reparacion' && (
                            <button
                              className="btn btn-secondary btn-sm"
                              onClick={() => handleFinalizarReparacion(eq)}
                              title="Finalizar reparación"
                              style={{ color: '#10b981' }}
                            >
                              ✅
                            </button>
                          )}
                          {eq.estado !== 'en_reparacion' && eq.novedad === 'disponible' && !eq.id_cliente && (
                            <button
                              className="btn btn-secondary btn-sm"
                              onClick={() => openReasignar(eq)}
                              title="Reasignar a cliente"
                            >
                              🔄
                            </button>
                          )}
                          <button className="btn btn-secondary btn-sm" onClick={() => openEdit(eq)} id={`btn-edit-equipo-${eq.id}`}>
                            ✏️
                          </button>
                          <button className="btn btn-secondary btn-sm" onClick={() => openHistorial(eq)} id={`btn-hist-equipo-${eq.id}`}>
                            🕘
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>

      <EquipoModal open={modalOpen} onClose={onClose} onSaved={load} equipo={editTarget} clientes={clientes} />
      <ReparacionModal
        open={reparacionOpen}
        onClose={() => { setReparacionOpen(false); setReparacionTarget(undefined); }}
        onSaved={load}
        equipo={reparacionTarget}
      />
      <ReasignarModal
        open={reasignarOpen}
        onClose={() => { setReasignarOpen(false); setReasignarTarget(undefined); }}
        onSaved={load}
        equipo={reasignarTarget}
        clientes={clientes}
      />
      {historialTarget && (
        <HistorialModal
          open={historialOpen}
          onClose={() => { setHistorialOpen(false); setHistorialTarget(undefined); }}
          equipoId={historialTarget.id}
          equipoPlaca={historialTarget.placa}
        />
      )}
    </>
  );
}