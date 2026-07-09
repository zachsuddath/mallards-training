import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../contexts/AuthContext'

// ─── helpers ──────────────────────────────────────────────────────────────────
function Avatar({ name, size = 32 }) {
  const initials = (name || '?').split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', background: '#E5E7EB',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontWeight: 700, fontSize: size * 0.38, flexShrink: 0, color: '#374151'
    }}>{initials}</div>
  )
}

function StatusBadge({ pct }) {
  if (pct === 100) return <span className="badge badge-green">Complete</span>
  if (pct > 0)    return <span className="badge badge-amber">In Progress</span>
  return <span className="badge badge-red">Not Started</span>
}

// ─── main component ────────────────────────────────────────────────────────────
export default function ManagerDashboard() {
  const { profile } = useAuth()
  const [tab, setTab] = useState('team')
  const [employees, setEmployees] = useState([])
  const [pending, setPending] = useState([])
  const [tracks, setTracks] = useState([])
  const [locations, setLocations] = useState([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState(null)

  // Add employee form
  const [addForm, setAddForm] = useState({ full_name: '', email: '', track_id: '', role: 'employee' })
  const [addError, setAddError] = useState('')
  const [addLoading, setAddLoading] = useState(false)
  const [addDone, setAddDone] = useState('')
  const [csvText, setCsvText] = useState('')
  const [csvResults, setCsvResults] = useState([])
  const [csvLoading, setCsvLoading] = useState(false)

  // Settings
  const [pin, setPin] = useState('')
  const [pinConfirm, setPinConfirm] = useState('')
  const [reportEmail, setReportEmail] = useState('')
  const [settingsSaving, setSettingsSaving] = useState(false)
  const [settingsMsg, setSettingsMsg] = useState('')

  const isAdmin = profile?.role === 'admin'
  const myLocationId = profile?.location_id

  useEffect(() => { loadAll() }, [profile])

  async function loadAll() {
    if (!profile) return
    setLoading(true)

    const [{ data: trackData }, { data: locData }] = await Promise.all([
      supabase.from('tracks').select('*').order('name'),
      supabase.from('locations').select('*').order('name'),
    ])
    setTracks(trackData || [])
    setLocations(locData || [])

    // Load existing manager PIN + report email
    setPin(profile.manager_pin || '')
    setReportEmail(profile.report_email || '')

    // Build profile query scoped by location (unless admin)
    let q = supabase.from('profiles').select('*, tracks(id, name)').order('full_name')
    if (!isAdmin && myLocationId) q = q.eq('location_id', myLocationId)

    const { data: allProfiles } = await q

    const active = (allProfiles || []).filter(p => p.status === 'active' && p.role !== 'admin')
    const pend   = (allProfiles || []).filter(p => p.status === 'pending')

    // Enrich active employees with progress %
    const enriched = await Promise.all(active.map(async emp => {
      if (!emp.track_id) return { ...emp, pct: 0 }
      const { data: mods } = await supabase.from('modules')
        .select('id, module_items(id)').eq('track_id', emp.track_id)
      const allItems = (mods || []).flatMap(m => m.module_items.map(i => i.id))
      if (!allItems.length) return { ...emp, pct: 0 }
      const { data: prog } = await supabase.from('employee_progress')
        .select('module_item_id').eq('user_id', emp.id).in('module_item_id', allItems)
      const pct = Math.round(((prog?.length || 0) / allItems.length) * 100)
      return { ...emp, pct }
    }))

    setEmployees(enriched)
    setPending(pend)
    setLoading(false)
  }

  // ─── Approve / reject pending ────────────────────────────────────────────────
  async function approveEmployee(userId) {
    await supabase.rpc('approve_employee', { p_user_id: userId })
    setPending(p => p.filter(e => e.id !== userId))
    loadAll()
  }

  async function rejectEmployee(userId) {
    if (!confirm('Remove this pending request? This cannot be undone.')) return
    await supabase.from('profiles').delete().eq('id', userId)
    setPending(p => p.filter(e => e.id !== userId))
  }

  // ─── Archive employee ─────────────────────────────────────────────────────────
  async function archiveEmployee(userId) {
    if (!confirm('Archive this employee? They will be hidden from reports but their data is preserved.')) return
    await supabase.from('profiles').update({ status: 'archived' }).eq('id', userId)
    setEmployees(e => e.filter(emp => emp.id !== userId))
    setSelected(null)
  }

  // ─── Add single employee (invite email) ──────────────────────────────────────
  async function handleAddEmployee(e) {
    e.preventDefault()
    setAddError(''); setAddDone(''); setAddLoading(true)
    const locationId = isAdmin ? addForm.location_id : myLocationId
    if (!locationId) { setAddError('Select a location.'); setAddLoading(false); return }

    // Use admin invite
    const { data, error } = await supabase.auth.admin.inviteUserByEmail(addForm.email, {
      data: { full_name: addForm.full_name }
    })
    if (error) {
      const msg = error.message || ''
      if (msg.toLowerCase().includes('rate') || msg.includes('429'))
        setAddError('Email rate limit hit — wait ~1 hour or have the employee sign up at /signup')
      else
        setAddError(msg || 'Failed to send invite')
      setAddLoading(false); return
    }
    await supabase.from('profiles').update({
      full_name: addForm.full_name,
      role: addForm.role,
      track_id: addForm.track_id || null,
      location_id: locationId,
      status: 'active',
    }).eq('id', data.user.id)

    setAddDone(`Invite sent to ${addForm.email}`)
    setAddForm({ full_name: '', email: '', track_id: '', role: 'employee' })
    setAddLoading(false)
    loadAll()
  }

  // ─── CSV bulk import ──────────────────────────────────────────────────────────
  async function handleCsvImport() {
    const locationId = isAdmin ? addForm.location_id : myLocationId
    if (!locationId) { setAddError('Select a location first.'); return }
    const lines = csvText.trim().split('\n').filter(Boolean)
    setCsvLoading(true); setCsvResults([])
    const results = []
    for (const line of lines) {
      const [name, email] = line.split(',').map(s => s.trim())
      if (!email || !name) { results.push({ name, email, status: 'skipped — missing name or email' }); continue }
      const { data, error } = await supabase.auth.admin.inviteUserByEmail(email, { data: { full_name: name } })
      if (error) {
        results.push({ name, email, status: `error: ${error.message}` }); continue
      }
      await supabase.from('profiles').update({
        full_name: name, role: 'employee', location_id: locationId, status: 'active'
      }).eq('id', data.user.id)
      results.push({ name, email, status: 'invited' })
    }
    setCsvResults(results)
    setCsvLoading(false)
    loadAll()
  }

  // ─── Save settings ────────────────────────────────────────────────────────────
  async function saveSettings(e) {
    e.preventDefault()
    setSettingsMsg('')
    if (pin && pin.length !== 4) { setSettingsMsg('PIN must be exactly 4 digits.'); return }
    if (pin && !/^\d{4}$/.test(pin)) { setSettingsMsg('PIN must be 4 numbers only.'); return }
    if (pin && pin !== pinConfirm) { setSettingsMsg('PINs do not match.'); return }
    setSettingsSaving(true)
    const updates = { report_email: reportEmail || null }
    if (pin) updates.manager_pin = pin
    const { error } = await supabase.from('profiles').update(updates).eq('id', profile.id)
    setSettingsSaving(false)
    setSettingsMsg(error ? `Error: ${error.message}` : 'Saved!')
    if (!error) { setPinConfirm('') }
  }

  // ─── stats ────────────────────────────────────────────────────────────────────
  const stats = {
    total: employees.length,
    complete: employees.filter(e => e.pct === 100).length,
    inProgress: employees.filter(e => e.pct > 0 && e.pct < 100).length,
    notStarted: employees.filter(e => e.pct === 0).length,
  }

  // ─── location name helper ──────────────────────────────────────────────────────
  function locationName(lid) {
    return locations.find(l => l.id === lid)?.name || '—'
  }

  const tabs = [
    { key: 'team',     label: 'My Team' },
    { key: 'pending',  label: pending.length ? 'Pending (' + pending.length + ')' : 'Pending' },
    { key: 'add',      label: 'Add Employee' },
    { key: 'settings', label: 'Settings' },
  ]

  if (loading) return <div className="empty-state"><div className="empty-state-icon">&#x23F3;</div>Loading team data...</div>

  return (
    <div>
      <div className="page-header">
        <div className="page-title">Manager Dashboard</div>
        <div className="page-subtitle">
          {isAdmin ? 'All locations' : locationName(myLocationId)} &nbsp;&middot;&nbsp; {employees.length} active employees
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 24, flexWrap: 'wrap' }}>
        {tabs.map(t => (
          <button key={t.key}
            className={`btn btn-sm ${tab === t.key ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setTab(t.key)}>
            {t.label}
          </button>
        ))}
      </div>

      {/* ── MY TEAM ── */}
      {tab === 'team' && (
        <div>
          <div className="stats-grid">
            <div className="stat-card"><div className="stat-label">Total</div><div className="stat-value">{stats.total}</div></div>
            <div className="stat-card"><div className="stat-label">Complete</div><div className="stat-value" style={{ color: '#27AE60' }}>{stats.complete}</div></div>
            <div className="stat-card"><div className="stat-label">In Progress</div><div className="stat-value" style={{ color: '#C9A227' }}>{stats.inProgress}</div></div>
            <div className="stat-card"><div className="stat-label">Not Started</div><div className="stat-value" style={{ color: '#C0392B' }}>{stats.notStarted}</div></div>
          </div>

          <div className="card">
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Employee</th>
                    {isAdmin && <th>Location</th>}
                    <th>Track</th>
                    <th>Progress</th>
                    <th>Status</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  {employees.length === 0 && (
                    <tr><td colSpan={isAdmin ? 6 : 5} style={{ textAlign: 'center', color: '#6B7280', padding: 40 }}>No active employees yet.</td></tr>
                  )}
                  {employees.map(emp => (
                    <tr key={emp.id}>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                          <Avatar name={emp.full_name} />
                          <div>
                            <div style={{ fontWeight: 600, fontSize: 14 }}>{emp.full_name}</div>
                            <div style={{ fontSize: 12, color: '#6B7280' }}>{emp.email || emp.role}</div>
                          </div>
                        </div>
                      </td>
                      {isAdmin && <td style={{ fontSize: 13, color: '#374151' }}>{locationName(emp.location_id)}</td>}
                      <td>
                        {emp.tracks
                          ? <span className="badge badge-navy">{emp.tracks.name}</span>
                          : <span style={{ color: '#6B7280', fontSize: 13 }}>No track</span>}
                      </td>
                      <td style={{ minWidth: 140 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                          <div className="progress-wrap" style={{ height: 7, flex: 1 }}>
                            <div className={`progress-bar ${emp.pct === 100 ? 'green' : ''}`} style={{ width: `${emp.pct}%`, height: 7 }} />
                          </div>
                          <span style={{ fontSize: 12, fontWeight: 600, color: '#1B3A6B', minWidth: 32 }}>{emp.pct}%</span>
                        </div>
                      </td>
                      <td><StatusBadge pct={emp.pct} /></td>
                      <td>
                        <button className="btn btn-secondary btn-sm" onClick={() => setSelected(emp)}>View</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ── PENDING ── */}
      {tab === 'pending' && (
        <div className="card">
          {pending.length === 0 ? (
            <div style={{ padding: 40, textAlign: 'center', color: '#6B7280' }}>No pending requests.</div>
          ) : (
            <div className="table-wrap">
              <table>
                <thead><tr><th>Name</th><th>Location</th><th>Requested</th><th>Action</th></tr></thead>
                <tbody>
                  {pending.map(emp => (
                    <tr key={emp.id}>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                          <Avatar name={emp.full_name} />
                          <div>
                            <div style={{ fontWeight: 600, fontSize: 14 }}>{emp.full_name}</div>
                            <div style={{ fontSize: 12, color: '#6B7280' }}>{emp.email}</div>
                          </div>
                        </div>
                      </td>
                      <td style={{ fontSize: 13 }}>{locationName(emp.location_id)}</td>
                      <td style={{ fontSize: 13, color: '#6B7280' }}>{new Date(emp.created_at || Date.now()).toLocaleDateString()}</td>
                      <td>
                        <div style={{ display: 'flex', gap: 8 }}>
                          <button className="btn btn-primary btn-sm" onClick={() => approveEmployee(emp.id)}>Approve</button>
                          <button className="btn btn-sm" style={{ background: '#FEE2E2', color: '#C0392B', border: 'none', cursor: 'pointer', padding: '6px 12px', borderRadius: 6, fontSize: 13, fontWeight: 600 }} onClick={() => rejectEmployee(emp.id)}>Reject</button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* ── ADD EMPLOYEE ── */}
      {tab === 'add' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          {/* Share signup link */}
          <div className="card">
            <div className="card-header"><div className="card-title">Share Signup Link</div></div>
            <div className="card-body" style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <div style={{ fontSize: 14, color: '#374151' }}>
                The fastest way to onboard employees &mdash; no email limits. Share this link and they sign up themselves. You approve them in the Pending tab.
              </div>
              <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
                <input
                  className="form-input"
                  readOnly
                  value={`${window.location.origin}/signup`}
                  style={{ background: '#F9FAFB', color: '#374151', flex: 1 }}
                />
                <button className="btn btn-secondary" onClick={() => { navigator.clipboard.writeText(`${window.location.origin}/signup`); alert('Link copied!') }}>
                  Copy
                </button>
              </div>
            </div>
          </div>

          {/* Individual invite */}
          <div className="card">
            <div className="card-header"><div className="card-title">Invite by Email</div></div>
            <div className="card-body">
              <form onSubmit={handleAddEmployee} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                {addError && <div className="error-msg">{addError}</div>}
                {addDone && <div style={{ background: 'rgba(39,174,96,0.1)', border: '1px solid rgba(39,174,96,0.3)', borderRadius: 8, padding: '10px 14px', color: '#27AE60', fontSize: 14 }}>{addDone}</div>}
                <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                  <div className="form-group" style={{ flex: 1, minWidth: 180 }}>
                    <label className="form-label">Full Name</label>
                    <input className="form-input" required value={addForm.full_name} onChange={e => setAddForm(f => ({ ...f, full_name: e.target.value }))} placeholder="Jane Smith" />
                  </div>
                  <div className="form-group" style={{ flex: 1, minWidth: 180 }}>
                    <label className="form-label">Email</label>
                    <input className="form-input" type="email" required value={addForm.email} onChange={e => setAddForm(f => ({ ...f, email: e.target.value }))} placeholder="jane@example.com" />
                  </div>
                </div>
                <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                  {isAdmin && (
                    <div className="form-group" style={{ flex: 1, minWidth: 180 }}>
                      <label className="form-label">Location</label>
                      <select className="form-input" value={addForm.location_id || ''} onChange={e => setAddForm(f => ({ ...f, location_id: e.target.value }))}>
                        <option value="">Select location...</option>
                        {locations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
                      </select>
                    </div>
                  )}
                  <div className="form-group" style={{ flex: 1, minWidth: 180 }}>
                    <label className="form-label">Role</label>
                    <select className="form-input" value={addForm.role} onChange={e => setAddForm(f => ({ ...f, role: e.target.value }))}>
                      <option value="employee">Employee</option>
                      <option value="manager">Manager</option>
                    </select>
                  </div>
                  <div className="form-group" style={{ flex: 1, minWidth: 180 }}>
                    <label className="form-label">Training Track</label>
                    <select className="form-input" value={addForm.track_id} onChange={e => setAddForm(f => ({ ...f, track_id: e.target.value }))}>
                      <option value="">Assign later...</option>
                      {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                    </select>
                  </div>
                </div>
                <button className="btn btn-primary" type="submit" disabled={addLoading} style={{ alignSelf: 'flex-start' }}>
                  {addLoading ? 'Sending...' : 'Send Invite'}
                </button>
              </form>
            </div>
          </div>

          {/* CSV import */}
          <div className="card">
            <div className="card-header"><div className="card-title">CSV Bulk Import</div></div>
            <div className="card-body" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              <div style={{ fontSize: 13, color: '#6B7280' }}>One employee per line: <code style={{ background: '#F3F4F6', padding: '2px 6px', borderRadius: 4 }}>Full Name, email@example.com</code></div>
              {isAdmin && (
                <div className="form-group">
                  <label className="form-label">Location</label>
                  <select className="form-input" value={addForm.location_id || ''} style={{ maxWidth: 280 }} onChange={e => setAddForm(f => ({ ...f, location_id: e.target.value }))}>
                    <option value="">Select location...</option>
                    {locations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
                  </select>
                </div>
              )}
              <textarea
                className="form-input"
                rows={6}
                placeholder={"Jane Smith, jane@example.com\nJohn Doe, john@example.com"}
                value={csvText}
                onChange={e => setCsvText(e.target.value)}
                style={{ fontFamily: 'monospace', fontSize: 13 }}
              />
              <button className="btn btn-secondary" onClick={handleCsvImport} disabled={csvLoading || !csvText.trim()} style={{ alignSelf: 'flex-start' }}>
                {csvLoading ? 'Importing...' : 'Import'}
              </button>
              {csvResults.length > 0 && (
                <div style={{ fontSize: 13, display: 'flex', flexDirection: 'column', gap: 4 }}>
                  {csvResults.map((r, i) => (
                    <div key={i} style={{ color: r.status === 'invited' ? '#27AE60' : '#C0392B' }}>
                      {r.name} ({r.email}) &mdash; {r.status}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ── SETTINGS ── */}
      {tab === 'settings' && (
        <div className="card" style={{ maxWidth: 480 }}>
          <div className="card-header"><div className="card-title">Manager Settings</div></div>
          <div className="card-body">
            <form onSubmit={saveSettings} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
              {settingsMsg && (
                <div style={{ background: settingsMsg === 'Saved!' ? 'rgba(39,174,96,0.1)' : 'rgba(192,57,43,0.1)', border: `1px solid ${settingsMsg === 'Saved!' ? 'rgba(39,174,96,0.3)' : 'rgba(192,57,43,0.3)'}`, borderRadius: 8, padding: '10px 14px', color: settingsMsg === 'Saved!' ? '#27AE60' : '#C0392B', fontSize: 14 }}>
                  {settingsMsg}
                </div>
              )}

              <div>
                <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 12, color: '#1B3A6B' }}>Test Unlock PIN</div>
                <div style={{ fontSize: 13, color: '#6B7280', marginBottom: 12 }}>
                  Employees must enter this 4-digit PIN before taking any quiz. You enter it on their screen to unlock the test.
                </div>
                <div style={{ display: 'flex', gap: 12 }}>
                  <div className="form-group" style={{ flex: 1 }}>
                    <label className="form-label">New PIN (4 digits)</label>
                    <input
                      className="form-input"
                      type="password"
                      inputMode="numeric"
                      maxLength={4}
                      pattern="\d{4}"
                      placeholder="&bull;&bull;&bull;&bull;"
                      value={pin}
                      onChange={e => setPin(e.target.value.replace(/\D/g, '').slice(0, 4))}
                    />
                  </div>
                  <div className="form-group" style={{ flex: 1 }}>
                    <label className="form-label">Confirm PIN</label>
                    <input
                      className="form-input"
                      type="password"
                      inputMode="numeric"
                      maxLength={4}
                      pattern="\d{4}"
                      placeholder="&bull;&bull;&bull;&bull;"
                      value={pinConfirm}
                      onChange={e => setPinConfirm(e.target.value.replace(/\D/g, '').slice(0, 4))}
                    />
                  </div>
                </div>
                {profile?.manager_pin && <div style={{ fontSize: 12, color: '#27AE60' }}>PIN is currently set.</div>}
              </div>

              <div>
                <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 12, color: '#1B3A6B' }}>Weekly Report Email</div>
                <div style={{ fontSize: 13, color: '#6B7280', marginBottom: 8 }}>
                  Automated weekly reports will be sent here (requires Resend setup).
                </div>
                <div className="form-group">
                  <label className="form-label">Email Address</label>
                  <input
                    className="form-input"
                    type="email"
                    placeholder="manager@mallardsmn.com"
                    value={reportEmail}
                    onChange={e => setReportEmail(e.target.value)}
                  />
                </div>
              </div>

              <button className="btn btn-primary" type="submit" disabled={settingsSaving} style={{ alignSelf: 'flex-start' }}>
                {settingsSaving ? 'Saving...' : 'Save Settings'}
              </button>
            </form>
          </div>
        </div>
      )}

      {/* ── EMPLOYEE DETAIL MODAL ── */}
      {selected && (
        <div className="modal-overlay" onClick={() => setSelected(null)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <div>
                <div className="modal-title">{selected.full_name}</div>
                <div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>
                  {selected.tracks?.name || 'No track'} &nbsp;&middot;&nbsp; {selected.pct}% complete &nbsp;&middot;&nbsp; {locationName(selected.location_id)}
                </div>
              </div>
              <button className="close-btn" onClick={() => setSelected(null)}>X</button>
            </div>
            <div className="modal-body">
              <div className="progress-wrap" style={{ height: 8 }}>
                <div className={`progress-bar ${selected.pct === 100 ? 'green' : ''}`} style={{ width: `${selected.pct}%`, height: 8 }} />
              </div>

              {/* Quick edit — track and location */}
              <EmpEditForm emp={selected} tracks={tracks} locations={locations} isAdmin={isAdmin}
                onSaved={(updates) => {
                  setEmployees(emps => emps.map(e => e.id === selected.id ? { ...e, ...updates } : e))
                  setSelected(s => ({ ...s, ...updates }))
                }} />
            </div>
            <div className="modal-footer" style={{ display: 'flex', justifyContent: 'space-between' }}>
              <button
                className="btn btn-sm"
                style={{ background: '#FEE2E2', color: '#C0392B', border: 'none', cursor: 'pointer', padding: '6px 14px', borderRadius: 6, fontSize: 13, fontWeight: 600 }}
                onClick={() => archiveEmployee(selected.id)}
              >
                Archive Employee
              </button>
              <button className="btn btn-secondary" onClick={() => setSelected(null)}>Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// ─── Employee edit sub-form ────────────────────────────────────────────────────
function EmpEditForm({ emp, tracks, locations, isAdmin, onSaved }) {
  const [trackId, setTrackId] = useState(emp.track_id || '')
  const [locationId, setLocationId] = useState(emp.location_id || '')
  const [saving, setSaving] = useState(false)
  const [msg, setMsg] = useState('')

  async function save() {
    setSaving(true); setMsg('')
    const { error } = await supabase.from('profiles').update({
      track_id: trackId || null,
      ...(isAdmin ? { location_id: locationId || null } : {}),
    }).eq('id', emp.id)
    setSaving(false)
    if (error) { setMsg('Save failed: ' + error.message); return }
    setMsg('Saved!')
    onSaved({ track_id: trackId || null, ...(isAdmin ? { location_id: locationId || null } : {}) })
  }

  return (
    <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{ fontWeight: 700, fontSize: 14, color: '#1B3A6B' }}>Edit Assignment</div>
      {msg && <div style={{ fontSize: 13, color: msg === 'Saved!' ? '#27AE60' : '#C0392B' }}>{msg}</div>}
      <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
        <div className="form-group" style={{ flex: 1, minWidth: 160 }}>
          <label className="form-label">Training Track</label>
          <select className="form-input" value={trackId} onChange={e => setTrackId(e.target.value)}>
            <option value="">No track</option>
            {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
          </select>
        </div>
        {isAdmin && (
          <div className="form-group" style={{ flex: 1, minWidth: 160 }}>
            <label className="form-label">Location</label>
            <select className="form-input" value={locationId} onChange={e => setLocationId(e.target.value)}>
              <option value="">No location</option>
              {locations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
            </select>
          </div>
        )}
      </div>
      <button className="btn btn-primary btn-sm" onClick={save} disabled={saving} style={{ alignSelf: 'flex-start' }}>
        {saving ? 'Saving...' : 'Save Changes'}
      </button>
    </div>
  )
}
