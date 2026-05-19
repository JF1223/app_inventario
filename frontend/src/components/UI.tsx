export function Spinner({ text = 'Cargando...' }: { text?: string }) {
  return (
    <div className="loading-overlay">
      <div className="spinner" />
      <span className="loading-text">{text}</span>
    </div>
  );
}

export function EmptyState({
  icon = '📭',
  title,
  subtitle,
}: {
  icon?: string;
  title: string;
  subtitle?: string;
}) {
  return (
    <div className="empty-state">
      <div className="empty-icon">{icon}</div>
      <div className="empty-title">{title}</div>
      {subtitle && <div className="empty-subtitle">{subtitle}</div>}
    </div>
  );
}
