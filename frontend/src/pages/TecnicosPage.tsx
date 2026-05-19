import { useEffect, useState } from 'react';
import { tecnicosApi } from '../services/api';
import type { Tecnico, CreateTecnicoDto } from '../types';
import { Modal } from '../components/Modal';
import { Spinner, EmptyState } from '../components/UI';
import { useToast } from '../components/Toast';
import { ActiveBadge } from '../components/Badges';
import { formatDate } from '../hooks/useHelpers';

interface TecnicoModalProps {
  open: boolean;
  onClose: () => void;
  onSaved: () => void;
  tecnico?: Tecnico;
}

function TecnicoModal({ open, onClose, onSaved, tecnico }: TecnicoModalProps) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState<CreateTecnicoDto>({
    nombre: '', especialidad: '', contacto: '', activo: true,
  });

  useEffect(() => {
    if (tecnico) {
      setForm({ nombre: tecnico.nombre, especialidad: tecnico.especialidad, contacto: tecnico.contacto, activo: tecnico.activo });
    } else {
      setForm({ nombre: '', especialidad: '', contacto: '', activo: true });
    }
  }, [tecnico, open]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    setForm(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      if (tecnico) {
        await tecnicosApi.update(tecnico.id, form);
        toast('Técnico actualizado ✅', 'success');
      } else {
        await tecnicosApi.create(form);
        toast('Técnico registrado ✅', 'success');
      }
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
      title={tecnico ? 'Editar Técnico' : 'Registrar Técnico'}
      icon="🧑‍🔧"
      footer={
        <>
          <button className="btn btn-secondary" onClick={onClose} id="tecnico-modal-cancel">Cancelar</button>
          <button className="btn btn-primary" form="tecnico-form" type="submit" disabled={loading} id="tecnico-modal-save">
            {loading ? 'Guardando...' : `✅ ${tecnico ? 'Actualizar' : 'Guardar'}`}
          </button>
        </>
      }
    >
      <form id="tecnico-form" onSubmit={handleSubmit} className="form-grid">
        <div className="form-group">
          <label htmlFor="t-nombre">Nombre completo *</label>
          <input id="t-nombre" name="nombre" placeholder="Nombre del técnico" value={form.nombre} onChange={handleChange} required />
        </div>
        <div className="form-group">
          <label htmlFor="t-especialidad">Especialidad *</label>
          <input id="t-especialidad" name="especialidad" placeholder="Ej: Refrigeración, Electricidad" value={form.especialidad} onChange={handleChange} required />
        </div>
        <div className="form-group">
          <label htmlFor="t-contacto">Contacto *</label>
          <input id="t-contacto" name="contacto" placeholder="Teléfono o email" value={form.contacto} onChange={handleChange} required />
        </div>
        <div className="form-group">
          <label htmlFor="t-activo">Estado</label>
          <select id="t-activo" name="activo" value={form.activo ? 'true' : 'false'} onChange={e => setForm(p => ({ ...p, activo: e.target.value === 'true' }))}>
            <option value="true">✓ Activo</option>
            <option value="false">✗ Inactivo</option>
          </select>
        </div>
      </form>
    </Modal>
  );
}

export default function TecnicosPage() {
  const toast = useToast();
  const [tecnicos, setTecnicos] = useState<Tecnico[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editTarget, setEditTarget] = useState<Tecnico | undefined>();
  const [search, setSearch] = useState('');

  const load = () => {
    setLoading(true);
    tecnicosApi.getAll()
      .then(setTecnicos)
      .catch(e => toast(e.message, 'error'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const openEdit = (t: Tecnico) => { setEditTarget(t); setModalOpen(true); };
  const openNew = () => { setEditTarget(undefined); setModalOpen(true); };
  const onClose = () => { setModalOpen(false); setEditTarget(undefined); };

  const filtered = tecnicos.filter(t =>
    t.nombre.toLowerCase().includes(search.toLowerCase()) ||
    t.especialidad.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1>🧑‍🔧 Técnicos</h1>
          <span className="page-header-subtitle">{tecnicos.filter(t => t.activo).length} activos de {tecnicos.length} registrados</span>
        </div>
        <button className="btn btn-primary" onClick={openNew} id="btn-nuevo-tecnico">
          + Nuevo Técnico
        </button>
      </div>

      <div className="page-body">
        <div className="card">
          <div className="card-header">
            <h3 className="card-title">📋 Lista de Técnicos</h3>
            <input
              id="tecnicos-search"
              placeholder="🔍 Buscar técnico..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              style={{ width: 220, padding: '7px 12px', fontSize: 13 }}
            />
          </div>
          <div className="table-wrapper">
            {loading ? (
              <Spinner />
            ) : filtered.length === 0 ? (
              <EmptyState icon="🧑‍🔧" title="No hay técnicos" subtitle="Registra el primer técnico con el botón superior" />
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Especialidad</th>
                    <th>Contacto</th>
                    <th>Estado</th>
                    <th>Registro</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map(t => (
                    <tr key={t.id}>
                      <td className="font-mono text-muted">#{t.id}</td>
                      <td><strong>{t.nombre}</strong></td>
                      <td>
                        <span style={{ background: 'var(--color-primary-dim)', color: 'var(--color-primary-hover)', padding: '3px 8px', borderRadius: 20, fontSize: 12 }}>
                          {t.especialidad}
                        </span>
                      </td>
                      <td className="font-mono" style={{ fontSize: 13 }}>{t.contacto}</td>
                      <td><ActiveBadge activo={t.activo} /></td>
                      <td className="text-muted text-sm">{formatDate(t.created_at)}</td>
                      <td>
                        <button
                          className="btn btn-secondary btn-sm"
                          onClick={() => openEdit(t)}
                          id={`btn-edit-tecnico-${t.id}`}
                        >
                          ✏️ Editar
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>

      <TecnicoModal open={modalOpen} onClose={onClose} onSaved={load} tecnico={editTarget} />
    </>
  );
}
