/**
 * Platform Dashboard Component
 * Author: Antigravity AI
 */

export function renderPlatformDashboard(data) {
  const { components, globalStatus } = data;
  
  const componentList = Object.entries(components).map(([key, info]) => `
    <div class="status-item">
      <div class="status-meta">
        <span class="status-name">${info.service}</span>
        <span class="status-time">${new Date(info.lastCheck).toLocaleTimeString()}</span>
      </div>
      <div class="status-indicator-group">
        ${info.latency ? `<span class="latency">${info.latency}ms</span>` : ''}
        <span class="dot ${info.status === 'healthy' ? 'success' : 'warning'} pulse"></span>
      </div>
    </div>
  `).join('');

  return `
    <section class="card glass-panel platform-dashboard">
      <div class="card-header">
        <h2>
          <span>🛰️ Platform Control</span>
          <span class="badge ${globalStatus === 'online' ? '' : 'badge-warning'}">${globalStatus.toUpperCase()}</span>
        </h2>
        <p class="subtitle">Real-time Cloudflare Infrastructure Status</p>
      </div>
      <div class="status-list">
        ${componentList}
      </div>
      <div class="dashboard-footer">
        <button id="refresh-health" class="text-button">Force Sync</button>
        <span class="version-tag">v1.0.5-stable</span>
      </div>
    </section>
  `;
}

// Styles specific to this component (to be added to styles.css or handled via JS)
export const platformDashboardStyles = `
  .platform-dashboard .status-list {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-md);
    margin-top: var(--spacing-sm);
  }
  .status-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--spacing-sm) var(--spacing-md);
    background: var(--color-bg-accent);
    border-radius: var(--radius-md);
    border: 1px solid rgba(255, 255, 255, 0.02);
  }
  .status-meta {
    display: flex;
    flex-direction: column;
  }
  .status-name {
    font-weight: 600;
    font-size: 0.9rem;
  }
  .status-time {
    font-size: 0.7rem;
    color: var(--color-text-muted);
  }
  .status-indicator-group {
    display: flex;
    align-items: center;
    gap: var(--spacing-sm);
  }
  .latency {
    font-size: 0.75rem;
    font-family: monospace;
    color: var(--color-primary);
  }
  .subtitle {
    font-size: 0.8rem;
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-sm);
  }
  .text-button {
    background: transparent;
    padding: 0;
    font-size: 0.75rem;
    color: var(--color-primary);
    text-decoration: underline;
  }
  .version-tag {
    font-size: 0.65rem;
    color: var(--color-text-muted);
  }
  .dashboard-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--spacing-md);
  }
`;
