import { NavLink } from 'react-router-dom';
import { useEffect, useState } from 'react';

const NAV_ITEMS = [
  { path: '/dashboard', icon: '📊', label: 'Dashboard', section: 'Principal' },
  { path: '/equipos', icon: '🧊', label: 'Equipos', section: 'Gestión' },
  { path: '/ordenes', icon: '📋', label: 'Órdenes', section: 'Gestión' },
  { path: '/clientes', icon: '👤', label: 'Clientes', section: 'Gestión' },
  { path: '/tecnicos', icon: '🧑‍🔧', label: 'Técnicos', section: 'Gestión' },
  { path: '/historial', icon: '🕘', label: 'Historial', section: 'Consulta' },
  { path: '/reportes', icon: '📈', label: 'Reportes', section: 'Consulta' },
];

export function Sidebar({ onLogout }: { onLogout?: () => void }) {
  const [time, setTime] = useState(new Date());

  useEffect(() => {
    const interval = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(interval);
  }, []);

  const sections = Array.from(new Set(NAV_ITEMS.map(i => i.section)));

  return (
    <aside className="sidebar">
      <div className="sidebar-logo">
        <div className="sidebar-logo-icon">❄️</div>
        <div className="sidebar-logo-text">
          <span className="sidebar-logo-title">CoolService</span>
          <span className="sidebar-logo-subtitle">Gestión de Neveras</span>
        </div>
      </div>

      <nav className="sidebar-nav" aria-label="Navegación principal">
        {sections.map(section => (
          <div key={section}>
            <div className="sidebar-section-label">{section}</div>
            {NAV_ITEMS.filter(i => i.section === section).map(item => (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                id={`nav-${item.label.toLowerCase().replace(/\s/g, '-')}`}
              >
                <span className="nav-icon">{item.icon}</span>
                <span>{item.label}</span>
              </NavLink>
            ))}
          </div>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="sidebar-time">
          🕐 {time.toLocaleTimeString('es-CO')}
          <br />
          <span style={{ opacity: 0.6, fontSize: '11px' }}>
            {time.toLocaleDateString('es-CO', { weekday: 'short', day: '2-digit', month: 'short' })}
          </span>
        </div>
        {onLogout && (
          <button
            className="btn btn-secondary btn-sm"
            onClick={onLogout}
            id="btn-logout"
            style={{ width: '100%', marginTop: 10 }}
          >
            🚪 Cerrar Sesión
          </button>
        )}
      </div>
    </aside>
  );
}
