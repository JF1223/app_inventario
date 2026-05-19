import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useToast } from '../components/Toast';

interface LoginPageProps {
  onLogin: () => void;
}

// Credenciales de demo (en producción esto sería autenticación real)
const DEMO_USER = 'admin';
const DEMO_PASS = 'admin123';

export default function LoginPage({ onLogin }: LoginPageProps) {
  const [usuario, setUsuario] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const toast = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    // Simulamos un delay de auth
    await new Promise(r => setTimeout(r, 800));

    if (usuario === DEMO_USER && password === DEMO_PASS) {
      localStorage.setItem('coolservice_auth', 'true');
      localStorage.setItem('coolservice_user', usuario);
      toast('¡Bienvenido al sistema CoolService! ❄️', 'success');
      onLogin();
      navigate('/dashboard');
    } else {
      setError('Usuario o contraseña incorrectos');
      toast('Credenciales inválidas', 'error');
    }

    setLoading(false);
  };

  return (
    <div className="login-page">
      <div className="login-bg-blur login-bg-1" />
      <div className="login-bg-blur login-bg-2" />

      <div className="login-card">
        <div className="login-header">
          <div className="login-logo-wrap">❄️</div>
          <h1 className="login-title">CoolService</h1>
          <p className="login-subtitle">
            Sistema de Gestión de<br />Mantenimiento de Neveras
          </p>
        </div>

        <form className="login-form" onSubmit={handleSubmit} id="login-form">
          <div className="form-group">
            <label htmlFor="login-usuario">Usuario</label>
            <input
              id="login-usuario"
              type="text"
              placeholder="Ingresa tu usuario"
              value={usuario}
              onChange={e => setUsuario(e.target.value)}
              required
              autoComplete="username"
              autoFocus
            />
          </div>

          <div className="form-group">
            <label htmlFor="login-password">Contraseña</label>
            <input
              id="login-password"
              type="password"
              placeholder="Ingresa tu contraseña"
              value={password}
              onChange={e => setPassword(e.target.value)}
              required
              autoComplete="current-password"
            />
          </div>

          {error && (
            <div className="alert-vencido">
              <span>⚠️</span>
              {error}
            </div>
          )}

          <button
            type="submit"
            className="btn btn-primary login-btn"
            disabled={loading}
            id="login-submit-btn"
          >
            {loading ? (
              <>
                <div className="spinner" style={{ width: 16, height: 16, borderWidth: 2 }} />
                Verificando...
              </>
            ) : (
              <>🔐 Iniciar Sesión</>
            )}
          </button>
        </form>

        <div className="login-demo-hint">
          <strong>🔑 Acceso de demostración</strong><br />
          Usuario: <strong>admin</strong><br />
          Contraseña: <strong>admin123</strong>
        </div>
      </div>
    </div>
  );
}
