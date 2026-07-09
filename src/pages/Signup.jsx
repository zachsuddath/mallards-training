import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'

export default function Signup() {
  const navigate = useNavigate()
  const [locations, setLocations] = useState([])
  const [form, setForm] = useState({ full_name: '', email: '', password: '', location_id: '' })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [done, setDone] = useState(false)

  useEffect(() => {
    supabase.from('locations').select('*').order('name').then(({ data }) => setLocations(data || []))
  }, [])

  async function handleSubmit(e) {
    e.preventDefault()
    setError('')
    if (!form.location_id) { setError('Please select your location.'); return }
    if (form.password.length < 8) { setError('Password must be at least 8 characters.'); return }
    setLoading(true)

    const { data, error: signUpErr } = await supabase.auth.signUp({
      email: form.email,
      password: form.password,
    })

    if (signUpErr) {
      setError(signUpErr.message || 'Sign up failed. Please try again.')
      setLoading(false); return
    }

    const userId = data.user?.id
    if (!userId) {
      setError('Account could not be created. Please try again.')
      setLoading(false); return
    }

    const { error: profileErr } = await supabase.from('profiles').upsert({
      id: userId,
      full_name: form.full_name,
      role: 'employee',
      location_id: form.location_id,
      status: 'pending',
    })
    if (profileErr) {
      setError(profileErr.message || profileErr.code || JSON.stringify(profileErr))
      setLoading(false); return
    }

    // Sign out immediately — they can't use the app until approved
    await supabase.auth.signOut()
    setLoading(false)
    setDone(true)
  }

  if (done) {
    return (
      <div className="login-page">
        <div className="login-card" style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>&#x23F3;</div>
          <div style={{ fontWeight: 700, fontSize: 22, color: '#1B3A6B', marginBottom: 8 }}>Request Submitted!</div>
          <div style={{ color: '#6B7280', fontSize: 14, lineHeight: 1.6 }}>
            Your account is pending approval from your manager.<br />
            They will activate your account shortly &mdash; then you can log in.
          </div>
          <Link to="/login" className="btn btn-primary" style={{ display: 'block', marginTop: 24, textAlign: 'center' }}>
            Back to Login
          </Link>
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
        <div className="login-title">Create Account</div>
        <div className="login-sub">Join your team's training portal</div>

        <form className="login-form" onSubmit={handleSubmit}>
          {error && <div className="error-msg">{error}</div>}

          <div className="form-group">
            <label className="form-label">Full Name</label>
            <input
              type="text"
              className="form-input"
              placeholder="Jane Smith"
              required
              value={form.full_name}
              onChange={e => setForm(f => ({ ...f, full_name: e.target.value }))}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Email</label>
            <input
              type="email"
              className="form-input"
              placeholder="you@example.com"
              required
              value={form.email}
              onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Password</label>
            <input
              type="password"
              className="form-input"
              placeholder="At least 8 characters"
              required
              value={form.password}
              onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
            />
          </div>

          <div className="form-group">
            <label className="form-label">Your Location</label>
            <select
              className="form-input"
              required
              value={form.location_id}
              onChange={e => setForm(f => ({ ...f, location_id: e.target.value }))}
            >
              <option value="">Select your location...</option>
              {locations.map(l => (
                <option key={l.id} value={l.id}>{l.name}</option>
              ))}
            </select>
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
            style={{ marginTop: 8 }}
          >
            {loading ? 'Creating account...' : 'Request Access'}
          </button>
        </form>

        <p style={{ textAlign: 'center', marginTop: 16, fontSize: 13, color: '#6B7280' }}>
          Already have an account?{' '}
          <Link to="/login" style={{ color: '#1B3A6B', fontWeight: 600 }}>Sign in</Link>
        </p>
      </div>
    </div>
  )
}
