import { useState } from 'react'
import { Outlet, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { useSettings } from '../contexts/SettingsContext'

export default function Layout() {
  const { profile, signOut } = useAuth()
  const { settings } = useSettings()
  const navigate = useNavigate()
  const location = useLocation()
  const [menuOpen, setMenuOpen] = useState(false)

  const isActive = (path) => location.pathname.startsWith(path)

  const navItems = []
  navItems.push({ icon: 'train', label: 'My Training', path: '/training' })
  navItems.push({ icon: 'menu', label: 'Menu', path: '/menu' })
  if (profile?.role === 'manager' || profile?.role === 'admin') {
    navItems.push({ icon: 'team', label: 'Manager Dashboard', path: '/manager' })
  }
  if (profile?.role === 'admin') {
    navItems.push({ icon: 'admin', label: 'Manage Content', path: '/admin' })
  }

  const initials = profile?.full_name
    ? profile.full_name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    : '?'

  const roleLabel = {
    employee: 'Team Member',
    manager: 'Manager',
    admin: 'Admin',
  }[profile?.role] || 'Team Member'

  const handleNav = (path) => {
    navigate(path)
    setMenuOpen(false)
  }

  const logoEl = settings.logo_url
    ? <img src={settings.logo_url} alt={settings.company_name} style={{ height: 32, width: 'auto', objectFit: 'contain' }} />
    : <span style={{ fontSize: 22 }}>🦆</span>

  const navIcons = { train: '📚', menu: '🍽️', team: '👥', admin: '⚙️' }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="sidebar-logo">
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            {logoEl}
            <div style={{ fontSize: 18, fontWeight: 800, color: 'white', letterSpacing: '-0.02em' }}>
              {settings.company_name}
            </div>
          </div>
          <div className="sidebar-logo-text">{settings.tagline}</div>
        </div>

        <nav className="sidebar-nav">
          {navItems.map(item => (
            <button
              key={item.path}
              className={`nav-item ${isActive(item.path) ? 'active' : ''}`}
              onClick={() => handleNav(item.path)}
            >
              <span className="nav-icon">{navIcons[item.icon] || item.icon}</span>
              {item.label}
            </button>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="user-pill">
            <div className="user-avatar">{initials}</div>
            <div className="user-info">
              <div className="user-name">{profile?.full_name || 'Loading...'}</div>
              <div className="user-role">{roleLabel}</div>
            </div>
          </div>
          <button className="sign-out-btn" onClick={signOut}>Sign out</button>
        </div>
      </aside>

      <header className="mobile-header">
        <div className="mobile-header-title">
          {settings.logo_url
            ? <img src={settings.logo_url} alt={settings.company_name} style={{ height: 24, width: 'auto', verticalAlign: 'middle', marginRight: 8 }} />
            : '🦆 '
          }
          {settings.company_name} Training
        </div>
        <button className="hamburger" onClick={() => setMenuOpen(o => !o)} aria-label="Menu">
          {menuOpen ? 'X' : '='}
        </button>
      </header>

      {menuOpen && (
        <div className="mobile-menu">
          <div className="mobile-menu-user">
            <div className="user-avatar" style={{ background: 'rgba(255,255,255,0.2)' }}>{initials}</div>
            <div className="user-info">
              <div className="user-name">{profile?.full_name || ''}</div>
              <div className="user-role">{roleLabel}</div>
            </div>
          </div>
          {navItems.map(item => (
            <button
              key={item.path}
              className={`mobile-nav-item ${isActive(item.path) ? 'active' : ''}`}
              onClick={() => handleNav(item.path)}
            >
              <span>{navIcons[item.icon] || item.icon}</span> {item.label}
            </button>
          ))}
          <button className="mobile-nav-item" style={{ color: 'rgba(255,255,255,0.6)', marginTop: 8 }} onClick={signOut}>
            Sign out
          </button>
        </div>
      )}

      <main className="main-content">
        <Outlet />
      </main>

      <nav className="bottom-nav">
        {navItems.map(item => (
          <button
            key={item.path}
            className={`bottom-nav-item ${isActive(item.path) ? 'active' : ''}`}
            onClick={() => handleNav(item.path)}
          >
            <span className="bottom-nav-icon">{navIcons[item.icon] || item.icon}</span>
            <span className="bottom-nav-label">{item.label}</span>
          </button>
        ))}
      </nav>
    </div>
  )
}
