import { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ToastProvider } from './components/Toast';
import { Sidebar } from './components/Sidebar';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ClientesPage from './pages/ClientesPage';
import EquiposPage from './pages/EquiposPage';
import TecnicosPage from './pages/TecnicosPage';
import OrdenesPage from './pages/OrdenesPage';
import HistorialPage from './pages/HistorialPage';
import ReportesPage from './pages/ReportesPage';
import './index.css';

function AppLayout({ children, onLogout }: { children: React.ReactNode; onLogout?: () => void }) {
  return (
    <div className="app-layout">
      <Sidebar onLogout={onLogout} />
      <main className="main-content">
        {children}
      </main>
    </div>
  );
}

export default function App() {
  const [isAuth, setIsAuth] = useState(() => {
    return localStorage.getItem('coolservice_auth') === 'true';
  });

  const handleLogin = () => setIsAuth(true);


  return (
    <BrowserRouter>
      <ToastProvider>
        <Routes>
          {/* Ruta Login */}
          <Route
            path="/login"
            element={
              isAuth
                ? <Navigate to="/dashboard" replace />
                : <LoginPage onLogin={handleLogin} />
            }
          />

          {/* Rutas protegidas */}
          {isAuth ? (
            <>
              <Route path="/dashboard" element={<AppLayout><DashboardPage /></AppLayout>} />
              <Route path="/clientes" element={<AppLayout><ClientesPage /></AppLayout>} />
              <Route path="/equipos" element={<AppLayout><EquiposPage /></AppLayout>} />
              <Route path="/tecnicos" element={<AppLayout><TecnicosPage /></AppLayout>} />
              <Route path="/ordenes" element={<AppLayout><OrdenesPage /></AppLayout>} />
              <Route path="/historial" element={<AppLayout><HistorialPage /></AppLayout>} />
              <Route path="/reportes" element={<AppLayout><ReportesPage /></AppLayout>} />
              <Route path="/" element={<Navigate to="/dashboard" replace />} />
              <Route path="*" element={<Navigate to="/dashboard" replace />} />
            </>
          ) : (
            <Route path="*" element={<Navigate to="/login" replace />} />
          )}
        </Routes>
      </ToastProvider>
    </BrowserRouter>
  );
}
