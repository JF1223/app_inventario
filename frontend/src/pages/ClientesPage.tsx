import { useEffect, useState } from 'react';
import { clientesApi } from '../services/api';
import type { Cliente, CreateClienteDto } from '../types';
import { Modal } from '../components/Modal';
import { Spinner, EmptyState } from '../components/UI';
import { useToast } from '../components/Toast';
import { ActiveBadge } from '../components/Badges';
import { formatDate } from '../hooks/useHelpers';

function ClienteModal({ open, onClose, onSaved }: { open: boolean; onClose: () => void; onSaved: () => void }) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState<CreateClienteDto>({
    nombre: '', documento: '', direccion: '', telefono: '', email: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await clientesApi.create(form);
      toast('Cliente registrado exitosamente ✅', 'success');
      onSaved();
      onClose();
      setForm({ nombre: '', documento: '', direccion: '', telefono: '', email: '' });
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
      title="Registrar Cliente"
      icon="👤"
      footer={
        <>
          <button className="btn btn-secondary" onClick={onClose} id="cliente-modal-cancel">Cancelar</button>
          <button className="btn btn-primary" form="cliente-form" type="submit" disabled={loading} id="cliente-modal-save">
            {loading ? 'Guardando...' : '✅ Guardar'}
          </button>
        </>
      }
    >
      <form id="cliente-form" onSubmit={handleSubmit} className="form-grid">
        <div className="form-group">
          <label htmlFor="c-nombre">Nombre completo *</label>
          <input id="c-nombre" name="nombre" placeholder="Nombre del cliente" value={form.nombre} onChange={handleChange} required />
        </div>
        <div className="form-group">
          <label htmlFor="c-documento">Documento / NIT *</label>
          <input id="c-documento" name="documento" placeholder="Cédula o NIT" value={form.documento} onChange={handleChange} required />
        </div>
        <div className="form-group">
          <label htmlFor="c-telefono">Teléfono</label>
          <input id="c-telefono" name="telefono" placeholder="Número de contacto" value={form.telefono} onChange={handleChange} />
        </div>
        <div className="form-group">
          <label htmlFor="c-email">Email</label>
          <input id="c-email" name="email" type="email" placeholder="correo@ejemplo.com" value={form.email} onChange={handleChange} />
        </div>
        <div className="form-group full-width">
          <label htmlFor="c-direccion">Dirección</label>
          <input id="c-direccion" name="direccion" placeholder="Dirección completa" value={form.direccion} onChange={handleChange} />
        </div>
      </form>
    </Modal>
  );
}

export default function ClientesPage() {
  const toast = useToast();
  const [clientes, setClientes] = useState<Cliente[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [search, setSearch] = useState('');

  const load = () => {
    setLoading(true);
    clientesApi.getAll()
      .then(setClientes)
      .catch(e => toast(e.message, 'error'))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const filtered = clientes.filter(c =>
    c.nombre.toLowerCase().includes(search.toLowerCase()) ||
    c.documento.toLowerCase().includes(search.toLowerCase()) ||
    (c.email?.toLowerCase().includes(search.toLowerCase()) ?? false)
  );

  return (
    <>
      <div className="page-header">
        <div className="page-header-left">
          <h1>👤 Clientes</h1>
          <span className="page-header-subtitle">{clientes.length} clientes registrados</span>
        </div>
        <div className="flex gap-2">
          <button className="btn btn-primary" onClick={() => setModalOpen(true)} id="btn-nuevo-cliente">
            + Nuevo Cliente
          </button>
        </div>
      </div>

      <div className="page-body">
        <div className="card">
          <div className="card-header">
            <h3 className="card-title">📋 Lista de Clientes</h3>
            <input
              id="clientes-search"
              placeholder="🔍 Buscar cliente..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              style={{ width: 240, padding: '7px 12px', fontSize: 13 }}
            />
          </div>
          <div className="table-wrapper">
            {loading ? (
              <Spinner />
            ) : filtered.length === 0 ? (
              <EmptyState icon="👤" title="No hay clientes" subtitle="Registra el primer cliente con el botón superior" />
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Documento</th>
                    <th>Teléfono</th>
                    <th>Email</th>
                    <th>Dirección</th>
                    <th>Estado</th>
                    <th>Registro</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map(c => (
                    <tr key={c.id}>
                      <td className="font-mono text-muted">#{c.id}</td>
                      <td><strong>{c.nombre}</strong></td>
                      <td className="font-mono">{c.documento}</td>
                      <td>{c.telefono || '—'}</td>
                      <td style={{ color: 'var(--color-primary-hover)', fontSize: 13 }}>{c.email || '—'}</td>
                      <td style={{ fontSize: 13 }}>{c.direccion || '—'}</td>
                      <td><ActiveBadge activo={c.activo} /></td>
                      <td className="text-muted text-sm">{formatDate(c.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>

      <ClienteModal open={modalOpen} onClose={() => setModalOpen(false)} onSaved={load} />
    </>
  );
}
