import { useState } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './contexts/AuthContext'
import { supabase } from './lib/supabase'
import Login from './pages/Login'
import EmployeeDashboard from './pages/EmployeeDashboard'
import TrainingModule from './pages/TrainingModule'
import ManagerDashboard from './pages/ManagerDashboard'
import AdminPanel from './pages/AdminPanel'
import MenuReference from './pages/MenuReference'
import Layout from './components/Layout'

// ── SET PASSWORD PAGE (shown when user arrives via invite/reset link) ──────────
function SetPasswordPage({ onDone }) {
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  async function handleSave() {
    if (password.length < 8) { setError('Password must be at least 8 characters.'); return }
    if (password !== confirm) { setError('Passwords do not match.'); return }
    setSaving(true)
    const { error: err } = await supabase.auth.updateUser({ password })
    setSaving(false)
    if (err) { setError(err.message || JSON.stringify(err)); return }
    onDone()
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#F9FAFB' }}>
      <div style={{ background: 'white', borderRadius: 12, padding: 32, width: 360, maxWidth: '90vw', boxShadow: '0 4px 24px rgba(0,0,0,0.10)' }}>
        <div style={{ textAlign: 'center', marginBottom: 28 }}>
          <div style={{ fontSize: 44, marginBottom: 10 }}>🦆</div>
          <div style={{ fontWeight: 700, fontSize: 22, color: '#1B3A6B' }}>Welcome to Mallards!</div>
          <div style={{ color: '#6B7280', fontSize: 14, marginTop: 6 }}>Set a password to access your training.</div>
        </div>
        {error && <div className="error-msg" style={{ marginBottom: 16 }}>{error}</div>}
        <div className="form-group">
          <label className="form-label">New Password</label>
          <input
            className="form-input"
            type="password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            placeholder="At least 8 characters"
            autoFocus
          />
        </div>
        <div className="form-group">
          <label className="form-label">Confirm Password</label>
          <input
            className="form-input"
            type="password"
            value={confirm}
            onChange={e => setConfirm(e.target.value)}
            placeholder="Repeat your password"
            onKeyDown={e => e.key === 'Enter' && !saving && handleSave()}
          />
        </div>
        <button
          className="btn btn-primary"
          style={{ width: '100%', marginTop: 8 }}
          disabled={saving || !password || !confirm}
          onClick={handleSave}
        >
          {saving ? 'Saving...' : 'Set Password & Get Started →'}
        </button>
      </div>
    </div>
  )
}

// ── ROUTE GUARDS ───────────────────────────────────────────────────────────────
function ProtectedRoute({ children, allowedRoles }) {
  const { user, profile, loading } = useAuth()

  if (loading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{ textAlign: 'center', color: '#6B7280' }}>
          <div style={{ fontSize: 32, marginBottom: 12 }}>🦆</div>
          <div>Loading...</div>
        </div>
      </div>
    )
  }

  if (!user) return <Navigate to="/login" replace />

  if (allowedRoles && profile && !allowedRoles.includes(profile.role)) {
    return <Navigate to="/" replace />
  }

  return children
}

function RootRedirect() {
  const { profile, loading } = useAuth()
  if (loading) return null
  if (!profile) return <Navigate to="/login" replace />
  if (profile.role === 'admin') return <Navigate to="/admin" replace />
  if (profile.role === 'manager') return <Navigate to="/manager" replace />
  return <Navigate to="/training" replace />
}

// ── APP ────────────────────────────────────────────────────────────────────────
export default function App() {
  const { needsPasswordReset, setNeedsPasswordReset } = useAuth()

  // If user arrived via an invite/reset link, show the set-password screen
  if (needsPasswordReset) {
    return <SetPasswordPage onDone={() => setNeedsPasswordReset(false)} />
  }

  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route path="/" element={
        <ProtectedRoute>
          <Layout />
        </ProtectedRoute>
      }>
        <Route index element={<RootRedirect />} />

        <Route path="training" element={
          <ProtectedRoute allowedRoles={['employee', 'manager', 'admin']}>
            <EmployeeDashboard />
          </ProtectedRoute>
        } />

        <Route path="training/module/:moduleId" element={
          <ProtectedRoute allowedRoles={['employee', 'manager', 'admin']}>
            <TrainingModule />
          </ProtectedRoute>
        } />

        <Route path="menu" element={
          <ProtectedRoute allowedRoles={['employee', 'manager', 'admin']}>
            <MenuReference />
          </ProtectedRoute>
        } />

        <Route path="manager" element={
          <ProtectedRoute allowedRoles={['manager', 'admin']}>
            <ManagerDashboard />
          </ProtectedRoute>
        } />

        <Route path="admin" element={
          <ProtectedRoute allowedRoles={['admin']}>
            <AdminPanel />
          </ProtectedRoute>
        } />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
