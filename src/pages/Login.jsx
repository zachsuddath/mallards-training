import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../lib/supabase'

export default function Login() {
  const { signIn } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [forgotMode, setForgotMode] = useState(false)
  const [resetSent, setResetSent] = useState(false)
  const [resetLoading, setResetLoading] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    setError('')
    setLoading(true)
    const { error } = await signIn(email, password)
    setLoading(false)
    if (error) {
      setError('Invalid email or password. Please try again.')
    } else {
      navigate('/')
    }
  }

  async function handleReset(e) {
    e.preventDefault()
    if (!email.trim()) { setError('Enter your email address above.'); return }
    setError('')
    setResetLoading(true)
    await supabase.auth.resetPasswordForEmail(email.trim(), { redirectTo: window.location.origin })
    setResetLoading(false)
    setResetSent(true)
  }

  if (resetSent) {
    return (
      <div className="login-page">
        <div className="login-card" style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>📧</div>
          <div style={{ fontWeight: 700, fontSize: 20, color: '#1B3A6B', marginBottom: 8 }}>Check your email</div>
          <div style={{ color: '#6B7280', fontSize: 14, lineHeight: 1.6 }}>
            We sent a password reset link to <strong>{email}</strong>.<br />
            Click the link in that email to set a new password.
          </div>
          <button className="btn btn-secondary" style={{ marginTop: 24, width: '100%' }} onClick={() => { setForgotMode(false); setResetSent(false) }}>
            Back to Sign In
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-logo">
          <div style={{ fontSize: 48 }}>&#x1F986;</div>
        </div>
        <div className="login-title">Mallards Training</div>
        <div className="login-sub">{forgotMode ? 'Reset your password' : 'Sign in to access your training portal'}</div>

        <form className="login-form" onSubmit={forgotMode ? handleReset : handleSubmit}>
          {error && <div className="error-msg">{error}</div>}

          <div className="form-group">
            <label className="form-label">Email</label>
            <input
              type="email"
              className="form-input"
              placeholder="you@example.com"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
              autoFocus
            />
          </div>

          {!forgotMode && (
            <div className="form-group">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                <label className="form-label" style={{ marginBottom: 0 }}>Password</label>
                <button type="button" onClick={() => { setForgotMode(true); setError('') }}
                  style={{ fontSize: 12, color: '#1B3A6B', background: 'none', border: 'none', cursor: 'pointer', padding: 0, fontWeight: 600 }}>
                  Forgot password?
                </button>
              </div>
              <input
                type="password"
                className="form-input"
                placeholder="&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;&#x2022;"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
              />
            </div>
          )}

          <button type="submit" className="btn btn-primary" disabled={loading || resetLoading} style={{ marginTop: 8 }}>
            {forgotMode
              ? (resetLoading ? 'Sending…' : 'Send Reset Link')
              : (loading ? 'Signing in...' : 'Sign In')}
          </button>

          {forgotMode && (
            <button type="button" className="btn btn-secondary" onClick={() => { setForgotMode(false); setError('') }} style={{ marginTop: 8 }}>
              Back to Sign In
            </button>
          )}
        </form>

        {!forgotMode && (
          <p style={{ textAlign: 'center', marginTop: 20, fontSize: 13, color: '#6B7280' }}>
            New employee?{' '}
            <Link to="/signup" style={{ color: '#1B3A6B', fontWeight: 600 }}>Request access</Link>
          </p>
        )}
      </div>
    </div>
  )
}
