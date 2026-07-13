import { useEffect, useState, useRef, useCallback } from 'react'
import ReactQuill from 'react-quill'
import 'react-quill/dist/quill.snow.css'
import { supabase } from '../lib/supabase'
import { useSettings } from '../contexts/SettingsContext'
import { useAuth } from '../contexts/AuthContext'

// Shared PIN pad (no <input> = no browser autofill)
function PinPad({ onSubmit, error, loading }) {
  const [digits, setDigits] = useState([])
  useEffect(() => { if (error) setDigits([]) }, [error])
  function tap(d) {
    if (loading || digits.length >= 4) return
    const next = [...digits, d]
    setDigits(next)
    if (next.length === 4) onSubmit(next.join(''))
  }
  function del() { if (!loading) setDigits(d => d.slice(0, -1)) }
  const btn = (label, action, extra = {}) => (
    <button onClick={action} disabled={loading}
      style={{ width: 64, height: 64, borderRadius: 12, fontSize: 20, fontWeight: 600, background: '#F3F4F6', border: '1px solid #E5E7EB', cursor: loading ? 'not-allowed' : 'pointer', color: '#1B3A6B', display: 'flex', alignItems: 'center', justifyContent: 'center', userSelect: 'none', ...extra }}>
      {label}
    </button>
  )
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
      <div style={{ display: 'flex', gap: 14 }}>
        {[0,1,2,3].map(i => <div key={i} style={{ width: 14, height: 14, borderRadius: '50%', background: i < digits.length ? '#1B3A6B' : '#D1D5DB', transition: 'background 0.15s' }} />)}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 64px)', gap: 8 }}>
        {[1,2,3,4,5,6,7,8,9].map(n => btn(n, () => tap(String(n))))}
        <div />{btn('0', () => tap('0'))}{btn('⌫', del, { fontSize: 16, color: '#6B7280' })}
      </div>
      {loading && <div style={{ fontSize: 13, color: '#6B7280' }}>Checking…</div>}
      {error && <div style={{ fontSize: 13, color: '#C0392B' }}>{error}</div>}
    </div>
  )
}

// SETTINGS TAB
function SettingsTab() {
  const { settings, updateSetting, uploadLogo } = useSettings()
  const [form, setForm] = useState({
    company_name: settings.company_name,
    tagline: settings.tagline,
    primary_color: settings.primary_color,
    accent_color: settings.accent_color,
  })
  const [saving, setSaving] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [saved, setSaved] = useState(false)
  const fileRef = useRef(null)

  useEffect(() => {
    setForm({
      company_name: settings.company_name,
      tagline: settings.tagline,
      primary_color: settings.primary_color,
      accent_color: settings.accent_color,
    })
  }, [settings.company_name])

  async function handleSave() {
    setSaving(true); setSaved(false)
    for (const [key, value] of Object.entries(form)) {
      await updateSetting(key, value)
    }
    setSaving(false); setSaved(true)
    setTimeout(() => setSaved(false), 3000)
  }

  async function handleLogoUpload(e) {
    const file = e.target.files?.[0]
    if (!file) return
    setUploading(true)
    try { await uploadLogo(file) } catch (err) { alert('Logo upload failed: ' + err.message) }
    setUploading(false)
  }

  async function handleRemoveLogo() {
    await updateSetting('logo_url', '')
  }

  return (
    <div style={{ maxWidth: 560 }}>
      <div className="card mb-16">
        <div className="card-header"><div className="card-title">Branding</div></div>
        <div className="card-body" style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: 20 }}>

          <div>
            <div className="form-label" style={{ marginBottom: 10 }}>Logo</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
              <div style={{ width: 80, height: 80, border: '2px dashed #D1D5DB', borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#F9FAFB', overflow: 'hidden' }}>
                {settings.logo_url
                  ? <img src={settings.logo_url} alt="logo" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
                  : <span style={{ fontSize: 32 }}>🦆</span>
                }
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <input ref={fileRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={handleLogoUpload} />
                <button className="btn btn-secondary btn-sm" onClick={() => fileRef.current?.click()} disabled={uploading}>
                  {uploading ? 'Uploading...' : 'Upload Logo'}
                </button>
                {settings.logo_url && (
                  <button className="btn btn-sm" style={{ background: '#FEE2E2', color: '#C0392B', border: 'none' }} onClick={handleRemoveLogo}>
                    Remove
                  </button>
                )}
                <div style={{ fontSize: 12, color: '#6B7280' }}>PNG or SVG, square works best</div>
              </div>
            </div>
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Company Name</label>
            <input className="form-input" value={form.company_name}
              onChange={e => setForm(f => ({ ...f, company_name: e.target.value }))}
              placeholder="e.g. Mallards" />
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Tagline (shows under name in sidebar)</label>
            <input className="form-input" value={form.tagline}
              onChange={e => setForm(f => ({ ...f, tagline: e.target.value }))}
              placeholder="e.g. Training Portal" />
          </div>

          <div style={{ display: 'flex', gap: 20 }}>
            <div className="form-group" style={{ marginBottom: 0, flex: 1 }}>
              <label className="form-label">Primary Color (sidebar, buttons)</label>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <input type="color" value={form.primary_color}
                  onChange={e => setForm(f => ({ ...f, primary_color: e.target.value }))}
                  style={{ width: 48, height: 40, padding: 2, border: '1px solid #D1D5DB', borderRadius: 8, cursor: 'pointer' }} />
                <input className="form-input" value={form.primary_color}
                  onChange={e => setForm(f => ({ ...f, primary_color: e.target.value }))}
                  style={{ fontFamily: 'monospace', marginBottom: 0 }} placeholder="#1B3A6B" />
              </div>
            </div>
            <div className="form-group" style={{ marginBottom: 0, flex: 1 }}>
              <label className="form-label">Accent Color (highlights)</label>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <input type="color" value={form.accent_color}
                  onChange={e => setForm(f => ({ ...f, accent_color: e.target.value }))}
                  style={{ width: 48, height: 40, padding: 2, border: '1px solid #D1D5DB', borderRadius: 8, cursor: 'pointer' }} />
                <input className="form-input" value={form.accent_color}
                  onChange={e => setForm(f => ({ ...f, accent_color: e.target.value }))}
                  style={{ fontFamily: 'monospace', marginBottom: 0 }} placeholder="#C9A227" />
              </div>
            </div>
          </div>

          <div style={{ background: form.primary_color, borderRadius: 10, padding: '14px 18px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ color: 'white', fontWeight: 700 }}>{form.company_name || 'Company Name'}</div>
            <div style={{ background: form.accent_color, color: '#fff', borderRadius: 6, padding: '4px 14px', fontSize: 13, fontWeight: 600 }}>Preview</div>
          </div>

          <button className="btn btn-primary" onClick={handleSave} disabled={saving} style={{ alignSelf: 'flex-start' }}>
            {saving ? 'Saving...' : saved ? 'Saved!' : 'Save Branding'}
          </button>
        </div>
      </div>
    </div>
  )
}

// INVITE MODAL
function InviteModal({ tracks, locations, onClose, onSave }) {
  const [form, setForm] = useState({ full_name: '', email: '', role: 'employee', track_id: '', location_id: '' })
  const [preComplete, setPreComplete] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)

  function fmtErr(err) {
    if (!err) return 'Unknown error'
    const msg = err.message || err.msg || ''
    if (!msg || msg === '{}') return 'Email rate limit hit — Supabase only allows 2 invite emails per hour on the free plan. Wait ~1 hour and try again.'
    if (msg.toLowerCase().includes('rate') || msg.toLowerCase().includes('429')) return 'Email rate limit hit — wait ~1 hour and try again.'
    return msg
  }

  async function handleInvite() {
    if (!form.full_name.trim() || !form.email.trim()) { setError('Name and email are required.'); return }
    setSaving(true); setError('')
    const { data, error: signUpError } = await supabase.auth.signUp({
      email: form.email.trim(), password: crypto.randomUUID(),
      options: { data: { full_name: form.full_name.trim(), role: form.role } },
    })
    if (signUpError) { setSaving(false); setError(fmtErr(signUpError)); return }
    if (data.user) {
      const profileUpdate = { status: 'active' }
      if (form.track_id) profileUpdate.track_id = form.track_id
      if (form.location_id) profileUpdate.location_id = form.location_id
      await supabase.from('profiles').update(profileUpdate).eq('id', data.user.id)
      if (preComplete && form.track_id) {
        await supabase.rpc('pre_complete_track', { p_employee_id: data.user.id, p_track_id: form.track_id })
      }
    }
    const { error: resetError } = await supabase.auth.resetPasswordForEmail(form.email.trim(), { redirectTo: window.location.origin })
    setSaving(false)
    if (resetError) setError('Account created but invite email failed: ' + fmtErr(resetError))
    else setSuccess(true)
  }

  if (success) return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header"><div className="modal-title">Invite Sent</div><button className="close-btn" onClick={onClose}>✕</button></div>
        <div className="modal-body" style={{ textAlign: 'center', padding: '32px 24px' }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>✉️</div>
          <div style={{ fontWeight: 600, fontSize: 16, marginBottom: 8 }}>{form.full_name} has been invited</div>
          <div style={{ color: '#6B7280', fontSize: 14 }}>An email was sent to <strong>{form.email}</strong> with a link to set their password.</div>
        </div>
        <div className="modal-footer"><button className="btn btn-primary" onClick={() => { onSave(); onClose() }}>Done</button></div>
      </div>
    </div>
  )

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header"><div className="modal-title">Invite New Employee</div><button className="close-btn" onClick={onClose}>✕</button></div>
        <div className="modal-body">
          {error && <div className="error-msg">{error}</div>}
          <div className="form-group"><label className="form-label">Full Name</label><input className="form-input" value={form.full_name} onChange={e => setForm(f => ({ ...f, full_name: e.target.value }))} placeholder="e.g. Jane Smith" /></div>
          <div className="form-group"><label className="form-label">Email</label><input className="form-input" type="email" value={form.email} onChange={e => setForm(f => ({ ...f, email: e.target.value }))} placeholder="jane@email.com" /></div>
          <div className="form-group"><label className="form-label">Location</label>
            <select className="form-select" value={form.location_id} onChange={e => setForm(f => ({ ...f, location_id: e.target.value }))}>
              <option value="">-- Select Location --</option>
              {locations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
            </select>
          </div>
          <div className="form-group"><label className="form-label">Role</label>
            <select className="form-select" value={form.role} onChange={e => setForm(f => ({ ...f, role: e.target.value }))}>
              <option value="employee">Employee</option><option value="manager">Manager</option><option value="admin">Admin</option>
            </select>
          </div>
          <div className="form-group"><label className="form-label">Training Track</label>
            <select className="form-select" value={form.track_id} onChange={e => setForm(f => ({ ...f, track_id: e.target.value }))}>
              <option value="">-- Assign Later --</option>
              {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
            </select>
          </div>
          {form.track_id && (
            <div className="form-group">
              <label style={{ display: 'flex', alignItems: 'flex-start', gap: 8, cursor: 'pointer' }}>
                <input type="checkbox" checked={preComplete} onChange={e => setPreComplete(e.target.checked)} style={{ marginTop: 2, accentColor: '#1B3A6B', flexShrink: 0 }} />
                <span>
                  <span className="form-label" style={{ margin: 0, display: 'block' }}>Mark as already trained</span>
                  <span style={{ fontSize: 12, color: '#6B7280' }}>Pre-completes all current track items. Use for existing staff who are already trained.</span>
                </span>
              </label>
            </div>
          )}
          <div style={{ background: '#F0F9FF', border: '1px solid #BAE6FD', borderRadius: 8, padding: '10px 14px', fontSize: 13, color: '#0369A1' }}>
            They will get an email with a link to set their password and log in for the first time.
          </div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={handleInvite} disabled={saving}>{saving ? 'Sending...' : 'Send Invite'}</button>
        </div>
      </div>
    </div>
  )
}

// EMPLOYEE MODAL
function EmployeeModal({ employee, tracks, locations, onClose, onSave }) {
  const [form, setForm] = useState({
    full_name: employee?.full_name || '',
    role: employee?.role || 'employee',
    track_id: employee?.track_id || '',
    location_id: employee?.location_id || '',
    status: employee?.status || 'active',
    manager_pin: '',
  })
  const [preComplete, setPreComplete] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  // Only offer pre-complete when assigning a NEW track (or changing track)
  const trackChanged = form.track_id && form.track_id !== (employee?.track_id || '')

  async function handleSave() {
    if (form.role === 'manager' && form.manager_pin && (form.manager_pin.length !== 4 || !/^\d{4}$/.test(form.manager_pin))) {
      setError('PIN must be exactly 4 digits.'); return
    }
    setSaving(true); setError('')
    const payload = {
      full_name: form.full_name,
      role: form.role,
      track_id: form.track_id || null,
      location_id: form.location_id || null,
      status: form.status,
    }
    if (form.role === 'manager' && form.manager_pin) payload.manager_pin = form.manager_pin
    const { error: saveErr } = await supabase.from('profiles').update(payload).eq('id', employee.id)
    if (saveErr) { setSaving(false); setError(saveErr.message); return }
    if (preComplete && form.track_id) {
      await supabase.rpc('pre_complete_track', { p_employee_id: employee.id, p_track_id: form.track_id })
    }
    setSaving(false)
    onSave(); onClose()
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header"><div className="modal-title">Edit Employee</div><button className="close-btn" onClick={onClose}>✕</button></div>
        <div className="modal-body">
          {error && <div className="error-msg">{error}</div>}
          <div className="form-group"><label className="form-label">Full Name</label><input className="form-input" value={form.full_name} onChange={e => setForm(f => ({ ...f, full_name: e.target.value }))} /></div>
          <div className="form-group"><label className="form-label">Location</label>
            <select className="form-select" value={form.location_id} onChange={e => setForm(f => ({ ...f, location_id: e.target.value }))}>
              <option value="">-- No Location --</option>
              {locations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
            </select>
          </div>
          <div className="form-group"><label className="form-label">Role</label>
            <select className="form-select" value={form.role} onChange={e => setForm(f => ({ ...f, role: e.target.value }))}>
              <option value="employee">Employee</option><option value="manager">Manager</option><option value="admin">Admin</option>
            </select>
          </div>
          <div className="form-group"><label className="form-label">Status</label>
            <select className="form-select" value={form.status} onChange={e => setForm(f => ({ ...f, status: e.target.value }))}>
              <option value="active">Active</option>
              <option value="pending">Pending</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">Training Track</label>
            <select className="form-select" value={form.track_id} onChange={e => setForm(f => ({ ...f, track_id: e.target.value }))}>
              <option value="">-- No Track --</option>
              {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
            </select>
          </div>
          {trackChanged && (
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label style={{ display: 'flex', alignItems: 'flex-start', gap: 8, cursor: 'pointer' }}>
                <input type="checkbox" checked={preComplete} onChange={e => setPreComplete(e.target.checked)} style={{ marginTop: 2, accentColor: '#1B3A6B', flexShrink: 0 }} />
                <span>
                  <span className="form-label" style={{ margin: 0, display: 'block' }}>Mark as already trained</span>
                  <span style={{ fontSize: 12, color: '#6B7280' }}>Pre-completes all current track items. Use for employees who already completed this training before this system was set up.</span>
                </span>
              </label>
            </div>
          )}
          {form.role === 'manager' && (
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label">Manager PIN (4 digits)</label>
              <input
                className="form-input"
                type="text"
                inputMode="numeric"
                maxLength={4}
                autoComplete="off"
                value={form.manager_pin}
                onChange={e => setForm(f => ({ ...f, manager_pin: e.target.value.replace(/\D/g, '').slice(0, 4) }))}
                placeholder={employee?.manager_pin ? 'Enter new PIN to change' : 'Set a 4-digit PIN'}
              />
              <div style={{ fontSize: 12, color: '#6B7280', marginTop: 4 }}>
                Managers use this PIN to unlock employee quizzes. Leave blank to keep the current PIN.
              </div>
            </div>
          )}
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={handleSave} disabled={saving}>{saving ? 'Saving...' : 'Save Changes'}</button>
        </div>
      </div>
    </div>
  )
}

// ITEM MODAL
function ItemModal({ item, moduleId, onClose, onSave }) {
  const quillRef = useRef(null)
  const [form, setForm] = useState({ type: item?.type || 'checklist', title: item?.title || '', content: item?.content || '', order_index: item?.order_index || 99 })
  const [quizQuestions, setQuizQuestions] = useState(() => {
    if (item?.type === 'quiz' && item?.content) { try { return JSON.parse(item.content).questions || [newQuestion()] } catch {} }
    return [newQuestion()]
  })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  function newQuestion() { return { question: '', options: ['', '', '', ''], correctIndex: 0 } }

  const imageHandler = useCallback(() => {
    const input = document.createElement('input')
    input.setAttribute('type', 'file'); input.setAttribute('accept', 'image/*'); input.click()
    input.onchange = async () => {
      const file = input.files?.[0]; if (!file) return
      const ext = file.name.split('.').pop()
      const fileName = `${Date.now()}.${ext}`
      const { error: uploadError } = await supabase.storage.from('training-images').upload(fileName, file)
      if (uploadError) { alert('Image upload failed: ' + uploadError.message); return }
      const { data: { publicUrl } } = supabase.storage.from('training-images').getPublicUrl(fileName)
      const editor = quillRef.current?.getEditor()
      const range = editor?.getSelection(true)
      editor?.insertEmbed(range?.index || 0, 'image', publicUrl)
      editor?.setSelection((range?.index || 0) + 1)
    }
  }, [])

  const quillModules = { toolbar: { container: [[{ header: [2, 3, false] }],['bold', 'italic', 'underline'],[{ list: 'ordered' }, { list: 'bullet' }],['image'],['clean']], handlers: { image: imageHandler } } }

  async function handleSave() {
    if (!form.title.trim()) { setError('Title is required.'); return }
    if (form.type === 'quiz' && quizQuestions.some(q => !q.question.trim())) { setError('All questions must have text.'); return }
    setSaving(true); setError('')
    let content = form.content
    if (form.type === 'quiz') content = JSON.stringify({ questions: quizQuestions, pass_threshold: 80 })
    const payload = { ...form, content, module_id: moduleId }
    const { error } = item?.id ? await supabase.from('module_items').update(payload).eq('id', item.id) : await supabase.from('module_items').insert(payload)
    setSaving(false)
    if (error) setError(error.message)
    else { onSave(); onClose() }
  }

  function updateQuestion(idx, field, value) { setQuizQuestions(qs => qs.map((q, i) => i === idx ? { ...q, [field]: value } : q)) }
  function updateOption(qIdx, oIdx, value) {
    setQuizQuestions(qs => qs.map((q, i) => { if (i !== qIdx) return q; const opts = [...q.options]; opts[oIdx] = value; return { ...q, options: opts } }))
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" style={{ maxWidth: 640, maxHeight: '88vh', overflowY: 'auto' }} onClick={e => e.stopPropagation()}>
        <div className="modal-header"><div className="modal-title">{item?.id ? 'Edit' : 'Add'} Item</div><button className="close-btn" onClick={onClose}>✕</button></div>
        <div className="modal-body">
          {error && <div className="error-msg">{error}</div>}
          <div className="form-group"><label className="form-label">Type</label>
            <select className="form-select" value={form.type} onChange={e => setForm(f => ({ ...f, type: e.target.value }))}>
              <option value="checklist">Checklist Item</option>
              <option value="video">Video</option>
              <option value="info">Study Guide / Info</option>
              <option value="quiz">Quiz</option>
              <option value="validation">Validation Sign-off</option>
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">{form.type === 'checklist' ? 'Task Description' : 'Title'}</label>
            <input className="form-input" value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
              placeholder={form.type === 'quiz' ? 'e.g. Bar Knowledge Quiz' : form.type === 'video' ? 'e.g. Welcome Video' : 'e.g. Read the Employee Handbook'} />
          </div>
          {form.type === 'video' && (
            <div className="form-group"><label className="form-label">YouTube Embed URL</label>
              <input className="form-input" value={form.content} onChange={e => setForm(f => ({ ...f, content: e.target.value }))} placeholder="https://www.youtube.com/embed/VIDEO_ID" />
              <div style={{ fontSize: 12, color: '#6B7280', marginTop: 4 }}>From YouTube: Share then Embed then copy the src URL</div>
            </div>
          )}
          {form.type === 'info' && (
            <div className="form-group"><label className="form-label">Content</label>
              <div style={{ border: '1px solid #D1D5DB', borderRadius: 8, overflow: 'hidden' }}>
                <ReactQuill ref={quillRef} theme="snow" value={form.content} onChange={val => setForm(f => ({ ...f, content: val }))} modules={quillModules} style={{ minHeight: 240 }} placeholder="Write content here." />
              </div>
              <div style={{ fontSize: 12, color: '#6B7280', marginTop: 4 }}>Click the image icon in the toolbar to upload a photo.</div>
            </div>
          )}
          {form.type === 'quiz' && (
            <div className="form-group">
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
                <label className="form-label" style={{ margin: 0 }}>Questions</label>
                <span style={{ fontSize: 12, color: '#6B7280' }}>Pass score: 80% — employees can retake until they pass</span>
              </div>
              {quizQuestions.map((q, qIdx) => (
                <div key={qIdx} className="quiz-builder-question">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                    <span style={{ fontWeight: 600, fontSize: 13, color: '#374151' }}>Question {qIdx + 1}</span>
                    {quizQuestions.length > 1 && <button onClick={() => setQuizQuestions(qs => qs.filter((_, i) => i !== qIdx))} style={{ background: '#FEE2E2', color: '#C0392B', border: 'none', borderRadius: 6, padding: '3px 10px', cursor: 'pointer', fontSize: 12 }}>Remove</button>}
                  </div>
                  <input className="form-input" style={{ marginBottom: 10 }} value={q.question} onChange={e => updateQuestion(qIdx, 'question', e.target.value)} placeholder="Type your question here..." />
                  <div style={{ fontSize: 12, color: '#6B7280', marginBottom: 6 }}>Click the circle next to the correct answer:</div>
                  {q.options.map((opt, oIdx) => (
                    <div key={oIdx} style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
                      <input type="radio" name={`correct-${qIdx}`} checked={q.correctIndex === oIdx} onChange={() => updateQuestion(qIdx, 'correctIndex', oIdx)} style={{ cursor: 'pointer', accentColor: '#27AE60', width: 16, height: 16, flexShrink: 0 }} />
                      <input className="form-input" style={{ marginBottom: 0 }} value={opt} onChange={e => updateOption(qIdx, oIdx, e.target.value)} placeholder={`Option ${oIdx + 1}`} />
                    </div>
                  ))}
                </div>
              ))}
              <button className="btn btn-secondary" onClick={() => setQuizQuestions(qs => [...qs, newQuestion()])} style={{ width: '100%', textAlign: 'center', marginTop: 4 }}>+ Add Question</button>
            </div>
          )}
          {form.type === 'validation' && (
            <div className="form-group">
              <label className="form-label">What the manager must observe / sign off on</label>
              <textarea
                className="form-input"
                rows={3}
                value={form.content}
                onChange={e => setForm(f => ({ ...f, content: e.target.value }))}
                placeholder="e.g. Employee demonstrates proper technique for the new seasonal cocktail from build to garnish."
                style={{ resize: 'vertical' }}
              />
              <div style={{ fontSize: 12, color: '#6B7280', marginTop: 4 }}>
                This description shows on the employee's training screen and on the printed validation sheet.
              </div>
            </div>
          )}
          {form.type !== 'quiz' && (
            <div className="form-group"><label className="form-label">Order (lower = first)</label>
              <input className="form-input" type="number" value={form.order_index} onChange={e => setForm(f => ({ ...f, order_index: parseInt(e.target.value) || 1 }))} />
            </div>
          )}
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={handleSave} disabled={saving}>{saving ? 'Saving...' : item?.id ? 'Save Changes' : 'Add Item'}</button>
        </div>
      </div>
    </div>
  )
}

// MODULE MODAL
function ModuleModal({ module, trackId, onClose, onSave }) {
  const [form, setForm] = useState({ title: module?.title || '', description: module?.description || '', order_index: module?.order_index || 99 })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  async function handleSave() {
    if (!form.title.trim()) { setError('Title is required.'); return }
    setSaving(true)
    const payload = { ...form, track_id: trackId }
    const { error } = module?.id ? await supabase.from('modules').update(payload).eq('id', module.id) : await supabase.from('modules').insert(payload)
    setSaving(false)
    if (error) setError(error.message)
    else { onSave(); onClose() }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header"><div className="modal-title">{module?.id ? 'Edit' : 'Add'} Module</div><button className="close-btn" onClick={onClose}>✕</button></div>
        <div className="modal-body">
          {error && <div className="error-msg">{error}</div>}
          <div className="form-group"><label className="form-label">Module Title</label><input className="form-input" value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} placeholder="e.g. Server Training" /></div>
          <div className="form-group"><label className="form-label">Description</label><input className="form-input" value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} placeholder="Brief description..." /></div>
          <div className="form-group"><label className="form-label">Order (lower = first)</label><input className="form-input" type="number" value={form.order_index} onChange={e => setForm(f => ({ ...f, order_index: parseInt(e.target.value) || 1 }))} /></div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={handleSave} disabled={saving}>{saving ? 'Saving...' : module?.id ? 'Save Changes' : 'Add Module'}</button>
        </div>
      </div>
    </div>
  )
}

// VALIDATION TAB
function ValidationTab({ isAdmin, isManager, profile }) {
  const [tracks, setTracks] = useState([])
  const [locations, setLocations] = useState([])
  const [selectedTrackId, setSelectedTrackId] = useState('')
  const [selectedLocationId, setSelectedLocationId] = useState(profile?.location_id || '')
  const [validationItems, setValidationItems] = useState([])
  const [employees, setEmployees] = useState([])
  const [signoffs, setSignoffs] = useState({}) // key: `${empId}:${itemId}`
  const [signingItem, setSigningItem] = useState(null) // itemId currently being signed off
  const [selectedEmpIds, setSelectedEmpIds] = useState(new Set())
  const [pinError, setPinError] = useState('')
  const [pinLoading, setPinLoading] = useState(false)
  const [loading, setLoading] = useState(false)
  const [signedCount, setSignedCount] = useState(null)

  useEffect(() => {
    supabase.from('tracks').select('*').order('name').then(({ data }) => {
      setTracks(data || [])
      if (data?.length && !selectedTrackId) setSelectedTrackId(data[0].id)
    })
    if (isAdmin) {
      supabase.from('locations').select('*').order('name').then(({ data }) => setLocations(data || []))
    }
  }, [])

  useEffect(() => {
    if (selectedTrackId && selectedLocationId) loadData()
  }, [selectedTrackId, selectedLocationId])

  async function loadData() {
    setLoading(true); setSigningItem(null); setSelectedEmpIds(new Set())

    // Get validation items for this track (through modules)
    const { data: mods } = await supabase.from('modules').select('id, title').eq('track_id', selectedTrackId)
    const modIds = (mods || []).map(m => m.id)
    const modTitleMap = {}
    ;(mods || []).forEach(m => { modTitleMap[m.id] = m.title })

    const { data: items } = modIds.length
      ? await supabase.from('module_items').select('id, title, content, module_id').in('module_id', modIds).eq('type', 'validation').order('order_index')
      : { data: [] }
    const enriched = (items || []).map(i => ({ ...i, moduleName: modTitleMap[i.module_id] }))
    setValidationItems(enriched)

    // Get active non-admin employees at this location on this track
    const { data: emps } = await supabase.from('profiles')
      .select('id, full_name')
      .eq('location_id', selectedLocationId)
      .eq('track_id', selectedTrackId)
      .eq('status', 'active')
      .neq('role', 'admin')
      .order('full_name')
    setEmployees(emps || [])

    // Get existing sign-offs
    if (items?.length && emps?.length) {
      const { data: soffs } = await supabase.from('validation_signoffs')
        .select('employee_id, item_id, signed_at, signer:signed_off_by(full_name)')
        .in('employee_id', (emps || []).map(e => e.id))
        .in('item_id', (items || []).map(i => i.id))
      const map = {}
      ;(soffs || []).forEach(s => { map[`${s.employee_id}:${s.item_id}`] = s })
      setSignoffs(map)
    } else {
      setSignoffs({})
    }
    setLoading(false)
  }

  async function handleSignOff(pin) {
    if (!signingItem || selectedEmpIds.size === 0) return
    setPinLoading(true); setPinError('')

    const { data, error } = await supabase.rpc('batch_sign_off_validation', {
      p_location_id: selectedLocationId,
      p_pin: pin,
      p_employee_ids: [...selectedEmpIds],
      p_item_id: signingItem,
    })

    setPinLoading(false)
    if (error || !data?.success) {
      setPinError('Incorrect PIN. Try again.')
    } else {
      setSignedCount(data.signed_count)
      setSigningItem(null)
      setSelectedEmpIds(new Set())
      setPinError('')
      await loadData()
    }
  }

  function openSignOff(itemId) {
    setSigningItem(itemId)
    // Pre-select employees who haven't been signed off yet
    const unsigned = employees.filter(e => !signoffs[`${e.id}:${itemId}`]).map(e => e.id)
    setSelectedEmpIds(new Set(unsigned))
    setPinError('')
    setSignedCount(null)
  }

  function printSheet() {
    const locName = locations.find(l => l.id === selectedLocationId)?.name || (isManager ? 'Your Location' : 'Location')
    const trackName = tracks.find(t => t.id === selectedTrackId)?.name || 'Track'
    const date = new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })

    const html = `<!DOCTYPE html><html><head><title>${locName} — ${trackName} Validation Sheet</title>
<style>
  body { font-family: Arial, sans-serif; font-size: 11px; margin: 24px; color: #111; }
  h1 { font-size: 18px; margin: 0 0 4px; }
  .sub { color: #555; margin-bottom: 20px; font-size: 12px; }
  table { border-collapse: collapse; width: 100%; table-layout: fixed; }
  th, td { border: 1px solid #bbb; padding: 7px 8px; vertical-align: top; word-wrap: break-word; }
  th { background: #f4f4f4; font-weight: 700; text-align: center; font-size: 10px; }
  th:first-child { text-align: left; }
  td:first-child { text-align: left; font-weight: 600; }
  .mod { font-size: 9px; color: #777; font-weight: 400; display: block; }
  .desc { font-size: 9px; color: #555; font-weight: 400; margin-top: 2px; }
  .signed { text-align: center; color: #27ae60; font-size: 13px; }
  .signed-date { font-size: 8px; color: #888; display: block; }
  .signed-by { font-size: 8px; color: #555; display: block; }
  @media print { body { margin: 12px; } }
</style></head><body>
<h1>🦆 ${locName} — ${trackName}</h1>
<div class="sub">Validation Sheet &nbsp;·&nbsp; ${date}</div>
<table>
  <thead><tr>
    <th style="width:28%">Training Item</th>
    ${employees.map(e => `<th>${e.full_name}</th>`).join('')}
  </tr></thead>
  <tbody>
    ${validationItems.map(item => `<tr>
      <td>
        ${item.moduleName ? `<span class="mod">${item.moduleName}</span>` : ''}
        ${item.title}
        ${item.content ? `<div class="desc">${item.content}</div>` : ''}
      </td>
      ${employees.map(emp => {
        const s = signoffs[`${emp.id}:${item.id}`]
        if (s) {
          const d = new Date(s.signed_at).toLocaleDateString()
          const by = s.signer?.full_name || ''
          return `<td class="signed">✓<span class="signed-date">${d}</span>${by ? `<span class="signed-by">${by}</span>` : ''}</td>`
        }
        return `<td></td>`
      }).join('')}
    </tr>`).join('')}
  </tbody>
</table>
<script>window.onload = () => { window.print(); }</script>
</body></html>`

    const w = window.open('', '_blank')
    w.document.write(html)
    w.document.close()
  }

  const trackName = tracks.find(t => t.id === selectedTrackId)?.name || ''

  return (
    <div>
      {/* Selectors */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 20, flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="form-group" style={{ marginBottom: 0, minWidth: 180 }}>
          <label className="form-label">Track</label>
          <select className="form-select" value={selectedTrackId} onChange={e => setSelectedTrackId(e.target.value)}>
            <option value="">-- Select Track --</option>
            {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
          </select>
        </div>
        {isAdmin && (
          <div className="form-group" style={{ marginBottom: 0, minWidth: 180 }}>
            <label className="form-label">Location</label>
            <select className="form-select" value={selectedLocationId} onChange={e => setSelectedLocationId(e.target.value)}>
              <option value="">-- Select Location --</option>
              {locations.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
            </select>
          </div>
        )}
        {selectedTrackId && selectedLocationId && validationItems.length > 0 && (
          <button className="btn btn-secondary" onClick={printSheet} style={{ marginBottom: 0 }}>🖨️ Print Sheet</button>
        )}
      </div>

      {loading && <div className="empty-state"><div className="empty-state-icon">⏳</div>Loading…</div>}

      {!loading && selectedTrackId && selectedLocationId && validationItems.length === 0 && (
        <div className="card"><div className="card-body empty-state">
          <div className="empty-state-title">No validation items in {trackName}</div>
          <p style={{ fontSize: 14, color: '#6B7280', marginTop: 8 }}>Add "Validation Sign-off" items to modules in this track via Training Content.</p>
        </div></div>
      )}

      {!loading && selectedTrackId && selectedLocationId && employees.length === 0 && validationItems.length > 0 && (
        <div className="card"><div className="card-body empty-state">
          <div className="empty-state-title">No employees assigned to {trackName} at this location</div>
        </div></div>
      )}

      {signedCount !== null && (
        <div style={{ background: '#D1FAE5', border: '1px solid #6EE7B7', borderRadius: 8, padding: '12px 16px', marginBottom: 16, color: '#065F46', fontWeight: 600, fontSize: 14 }}>
          ✓ Signed off {signedCount} employee{signedCount !== 1 ? 's' : ''} successfully.
        </div>
      )}

      {/* Validation items list */}
      {!loading && validationItems.map(item => {
        const totalEmps = employees.length
        const signedEmps = employees.filter(e => signoffs[`${e.id}:${item.id}`]).length
        const isOpen = signingItem === item.id

        return (
          <div key={item.id} className="card mb-16">
            <div className="card-header">
              <div>
                {item.moduleName && <div style={{ fontSize: 11, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 2 }}>{item.moduleName}</div>}
                <div className="card-title" style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  ✍️ {item.title}
                </div>
                {item.content && <div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>{item.content}</div>}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexShrink: 0 }}>
                <span style={{ fontSize: 13, color: signedEmps === totalEmps && totalEmps > 0 ? '#27AE60' : '#6B7280', fontWeight: 600 }}>
                  {signedEmps}/{totalEmps} signed off
                </span>
                {!isOpen && employees.length > 0 && (
                  <button className="btn btn-primary btn-sm" onClick={() => openSignOff(item.id)}>Sign off employees →</button>
                )}
                {isOpen && (
                  <button className="btn btn-secondary btn-sm" onClick={() => { setSigningItem(null); setPinError('') }}>Cancel</button>
                )}
              </div>
            </div>

            {/* Employee status grid */}
            <div className="table-wrap">
              <table>
                <thead><tr><th>Employee</th><th>Status</th><th>Signed by</th><th>Date</th></tr></thead>
                <tbody>
                  {employees.map(emp => {
                    const s = signoffs[`${emp.id}:${item.id}`]
                    return (
                      <tr key={emp.id}>
                        <td style={{ fontWeight: 600 }}>{emp.full_name}</td>
                        <td>{s ? <span className="badge badge-green">Signed off ✓</span> : <span className="badge" style={{ background: '#F3F4F6', color: '#6B7280' }}>Pending</span>}</td>
                        <td style={{ fontSize: 13, color: '#6B7280' }}>{s?.signer?.full_name || '—'}</td>
                        <td style={{ fontSize: 13, color: '#6B7280' }}>{s ? new Date(s.signed_at).toLocaleDateString() : '—'}</td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>

            {/* Sign-off panel */}
            {isOpen && (
              <div style={{ borderTop: '2px solid #1B3A6B', padding: 24, background: '#F8FAFF' }}>
                <div style={{ fontWeight: 700, fontSize: 15, color: '#1B3A6B', marginBottom: 4 }}>Sign off employees on: {item.title}</div>
                <div style={{ fontSize: 13, color: '#6B7280', marginBottom: 16 }}>Select who completed this, then have a manager tap their PIN.</div>
                <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexWrap: 'wrap' }}>
                  <button className="btn btn-secondary btn-sm" onClick={() => setSelectedEmpIds(new Set(employees.filter(e => !signoffs[`${e.id}:${item.id}`]).map(e => e.id)))}>Select unsigned</button>
                  <button className="btn btn-secondary btn-sm" onClick={() => setSelectedEmpIds(new Set(employees.map(e => e.id)))}>Select all</button>
                  <button className="btn btn-secondary btn-sm" onClick={() => setSelectedEmpIds(new Set())}>Clear</button>
                </div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 20 }}>
                  {employees.map(emp => {
                    const checked = selectedEmpIds.has(emp.id)
                    const alreadySigned = !!signoffs[`${emp.id}:${item.id}`]
                    return (
                      <label key={emp.id} style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '6px 12px', borderRadius: 8, border: `2px solid ${checked ? '#1B3A6B' : '#E5E7EB'}`, background: checked ? '#EEF2FF' : 'white', cursor: 'pointer', fontSize: 13, fontWeight: checked ? 600 : 400 }}>
                        <input type="checkbox" checked={checked} style={{ accentColor: '#1B3A6B' }}
                          onChange={e => setSelectedEmpIds(prev => { const n = new Set(prev); e.target.checked ? n.add(emp.id) : n.delete(emp.id); return n })} />
                        {emp.full_name}
                        {alreadySigned && <span style={{ fontSize: 11, color: '#27AE60' }}>✓</span>}
                      </label>
                    )
                  })}
                </div>
                {selectedEmpIds.size > 0 && (
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontWeight: 600, fontSize: 14, color: '#1B3A6B', marginBottom: 12 }}>
                      Manager PIN — signing off {selectedEmpIds.size} employee{selectedEmpIds.size !== 1 ? 's' : ''}
                    </div>
                    <PinPad onSubmit={handleSignOff} error={pinError} loading={pinLoading} />
                  </div>
                )}
                {selectedEmpIds.size === 0 && <div style={{ textAlign: 'center', fontSize: 13, color: '#9CA3AF' }}>Select at least one employee above.</div>}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

// REPORTS TAB
function ReportsTab({ isAdmin, isManager, profile }) {
  const [reportData, setReportData] = useState([])
  const [loading, setLoading] = useState(true)
  const [locationFilter, setLocationFilter] = useState('all')
  const [allLocations, setAllLocations] = useState([])

  useEffect(() => { loadReport() }, [])

  async function loadReport() {
    setLoading(true)

    // 1. Fetch active employees (exclude admins from the report)
    let empQuery = supabase.from('profiles')
      .select('id, full_name, location_id, track_id, status, locations(id, name), tracks(name)')
      .eq('status', 'active')
      .neq('role', 'admin')
      .order('full_name')
    if (isManager && profile?.location_id) empQuery = empQuery.eq('location_id', profile.location_id)
    const { data: employees } = await empQuery
    if (!employees?.length) { setReportData([]); setLoading(false); return }

    const locs = [...new Map(employees.filter(e => e.locations).map(e => [e.locations.id, e.locations])).values()]
    setAllLocations(locs)

    // 2. Fetch modules for each track employees are on
    const trackIds = [...new Set(employees.filter(e => e.track_id).map(e => e.track_id))]
    if (!trackIds.length) {
      setReportData(employees.map(e => ({ ...e, total: 0, completed: 0, pct: null, quizzesTotal: 0, quizzesPassed: 0 })))
      setLoading(false); return
    }
    const { data: modules } = await supabase.from('modules').select('id, track_id').in('track_id', trackIds)
    const moduleIds = (modules || []).map(m => m.id)
    const moduleTrackMap = {}
    ;(modules || []).forEach(m => { moduleTrackMap[m.id] = m.track_id })

    // 3. Fetch completable items (checklist + quiz) in those modules
    const { data: items } = moduleIds.length
      ? await supabase.from('module_items').select('id, module_id, type').in('module_id', moduleIds).in('type', ['checklist', 'quiz'])
      : { data: [] }

    // Build trackId → { all itemIds, quizIds }
    const trackItems = {}
    ;(items || []).forEach(item => {
      const tid = moduleTrackMap[item.module_id]
      if (!trackItems[tid]) trackItems[tid] = { all: [], quizIds: [] }
      trackItems[tid].all.push(item.id)
      if (item.type === 'quiz') trackItems[tid].quizIds.push(item.id)
    })

    // 4. Fetch progress and quiz attempts for all employees
    const empIds = employees.map(e => e.id)
    const [{ data: progress }, { data: attempts }] = await Promise.all([
      supabase.from('employee_progress').select('user_id, module_item_id').in('user_id', empIds),
      supabase.from('quiz_attempts').select('user_id, module_item_id, score, total, passed').in('user_id', empIds),
    ])

    // Build userId → completed item Set
    const progressMap = {}
    ;(progress || []).forEach(p => {
      if (!progressMap[p.user_id]) progressMap[p.user_id] = new Set()
      progressMap[p.user_id].add(p.module_item_id)
    })

    // Build best quiz score per user+item
    const bestScores = {}
    ;(attempts || []).forEach(a => {
      const key = `${a.user_id}:${a.module_item_id}`
      if (!bestScores[key] || a.score > bestScores[key].score) bestScores[key] = a
    })

    // 5. Assemble report rows
    const report = employees.map(emp => {
      const ti = emp.track_id ? trackItems[emp.track_id] : null
      const total = ti?.all.length || 0
      const done = ti ? ti.all.filter(id => (progressMap[emp.id] || new Set()).has(id)).length : 0
      const pct = total > 0 ? Math.round((done / total) * 100) : (emp.track_id ? 0 : null)
      const quizzesTotal = ti?.quizIds.length || 0
      const quizzesPassed = ti ? ti.quizIds.filter(qid => bestScores[`${emp.id}:${qid}`]?.passed).length : 0
      return { ...emp, total, completed: done, pct, quizzesTotal, quizzesPassed }
    })

    setReportData(report)
    setLoading(false)
  }

  const filtered = locationFilter === 'all' ? reportData : reportData.filter(e => e.location_id === locationFilter)
  const withTrack = filtered.filter(e => e.pct !== null)
  const avgPct = withTrack.length ? Math.round(withTrack.reduce((s, e) => s + e.pct, 0) / withTrack.length) : 0
  const notStartedCount = withTrack.filter(e => e.pct === 0).length
  const completeCount = withTrack.filter(e => e.pct === 100).length

  // Group by location name
  const grouped = {}
  filtered.forEach(emp => {
    const loc = emp.locations?.name || 'No Location'
    if (!grouped[loc]) grouped[loc] = []
    grouped[loc].push(emp)
  })

  if (loading) return <div className="empty-state"><div className="empty-state-icon">⏳</div>Loading report…</div>

  return (
    <div>
      {/* Summary cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginBottom: 24 }}>
        {[
          { label: 'Active Employees', value: filtered.length, color: '#1B3A6B' },
          { label: 'Avg Completion', value: withTrack.length ? `${avgPct}%` : '—', color: '#1B3A6B' },
          { label: 'Not Started', value: notStartedCount, color: notStartedCount > 0 ? '#C0392B' : '#6B7280' },
          { label: 'Fully Complete', value: completeCount, color: completeCount > 0 ? '#27AE60' : '#6B7280' },
        ].map(s => (
          <div key={s.label} className="card" style={{ padding: 16, textAlign: 'center' }}>
            <div style={{ fontSize: 28, fontWeight: 700, color: s.color }}>{s.value}</div>
            <div style={{ fontSize: 12, color: '#6B7280', marginTop: 4 }}>{s.label}</div>
          </div>
        ))}
      </div>

      {/* Location filter tabs (admin only, multiple locations) */}
      {isAdmin && allLocations.length > 1 && (
        <div style={{ display: 'flex', gap: 8, marginBottom: 16, flexWrap: 'wrap' }}>
          <button className={`btn btn-sm ${locationFilter === 'all' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setLocationFilter('all')}>All Locations</button>
          {allLocations.map(loc => (
            <button key={loc.id} className={`btn btn-sm ${locationFilter === loc.id ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setLocationFilter(loc.id)}>{loc.name}</button>
          ))}
        </div>
      )}

      {/* Per-location employee tables */}
      {Object.entries(grouped).map(([locName, emps]) => {
        const locWithTrack = emps.filter(e => e.pct !== null)
        const locAvg = locWithTrack.length ? Math.round(locWithTrack.reduce((s, e) => s + e.pct, 0) / locWithTrack.length) : null
        return (
          <div key={locName} className="card mb-16">
            <div className="card-header">
              <div>
                <div className="card-title">📍 {locName}</div>
                <div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>
                  {emps.length} employee{emps.length !== 1 ? 's' : ''}
                  {locAvg !== null ? ` · ${locAvg}% avg completion` : ''}
                </div>
              </div>
              <button className="btn btn-secondary btn-sm" onClick={loadReport}>Refresh</button>
            </div>
            <div className="table-wrap">
              <table>
                <thead>
                  <tr><th>Employee</th><th>Track</th><th style={{ minWidth: 160 }}>Progress</th><th>Quizzes</th><th>Status</th></tr>
                </thead>
                <tbody>
                  {emps.map(emp => (
                    <tr key={emp.id}>
                      <td style={{ fontWeight: 600 }}>{emp.full_name}</td>
                      <td style={{ color: emp.tracks?.name ? '#374151' : '#9CA3AF' }}>{emp.tracks?.name || 'No track'}</td>
                      <td>
                        {emp.pct === null ? (
                          <span style={{ color: '#9CA3AF', fontSize: 13 }}>No track assigned</span>
                        ) : (
                          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                            <div style={{ flex: 1, height: 6, background: '#E5E7EB', borderRadius: 99, overflow: 'hidden', minWidth: 80 }}>
                              <div style={{ height: '100%', width: `${emp.pct}%`, background: emp.pct === 100 ? '#27AE60' : '#1B3A6B', borderRadius: 99 }} />
                            </div>
                            <span style={{ fontSize: 13, fontWeight: 600, color: emp.pct === 100 ? '#27AE60' : '#374151', minWidth: 36 }}>{emp.pct}%</span>
                          </div>
                        )}
                      </td>
                      <td>
                        {emp.quizzesTotal === 0 ? (
                          <span style={{ color: '#9CA3AF', fontSize: 13 }}>—</span>
                        ) : (
                          <span style={{ fontSize: 13, fontWeight: 600, color: emp.quizzesPassed === emp.quizzesTotal ? '#27AE60' : emp.quizzesPassed > 0 ? '#D97706' : '#C0392B' }}>
                            {emp.quizzesPassed}/{emp.quizzesTotal} passed
                          </span>
                        )}
                      </td>
                      <td>
                        {emp.pct === null && <span style={{ fontSize: 12, color: '#9CA3AF' }}>—</span>}
                        {emp.pct === 0 && <span className="badge badge-red">Not started</span>}
                        {emp.pct > 0 && emp.pct < 100 && <span className="badge badge-amber">In progress</span>}
                        {emp.pct === 100 && <span className="badge badge-green">Complete ✓</span>}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )
      })}

      {filtered.length === 0 && (
        <div className="card"><div className="card-body empty-state"><div className="empty-state-title">No employees to report on yet.</div></div></div>
      )}
    </div>
  )
}

// MAIN ADMIN PANEL
export default function AdminPanel() {
  const { profile } = useAuth()
  const isAdmin = profile?.role === 'admin'
  const isManager = profile?.role === 'manager'

  const [tab, setTab] = useState('content')
  const [tracks, setTracks] = useState([])
  const [locations, setLocations] = useState([])
  const [selectedTrack, setSelectedTrack] = useState(null)
  const [modules, setModules] = useState([])
  const [selectedModule, setSelectedModule] = useState(null)
  const [moduleItems, setModuleItems] = useState([])
  const [employees, setEmployees] = useState([])
  const [loading, setLoading] = useState(true)
  const [modal, setModal] = useState(null)
  const [editTarget, setEditTarget] = useState(null)

  useEffect(() => { loadTracks(); loadLocations() }, [])
  useEffect(() => { if (selectedTrack) loadModules(selectedTrack.id) }, [selectedTrack])
  useEffect(() => { if (selectedModule) loadItems(selectedModule.id) }, [selectedModule])
  useEffect(() => { if (tab === 'employees') loadEmployees() }, [tab])

  async function loadLocations() {
    const { data } = await supabase.from('locations').select('*').order('name')
    setLocations(data || [])
  }

  async function loadTracks() {
    const { data } = await supabase.from('tracks').select('*').order('name')
    setTracks(data || [])
    if (data?.length && !selectedTrack) setSelectedTrack(data[0])
    setLoading(false)
  }
  async function loadModules(trackId) {
    const { data } = await supabase.from('modules').select('*').eq('track_id', trackId).order('order_index')
    setModules(data || []); setSelectedModule(null); setModuleItems([])
  }
  async function loadItems(moduleId) {
    const { data } = await supabase.from('module_items').select('*').eq('module_id', moduleId).order('order_index')
    setModuleItems(data || [])
  }
  async function loadEmployees() {
    let query = supabase.from('profiles').select('*, tracks(name), locations(name), manager_pin').order('full_name')
    // Managers only see their own location
    if (isManager && profile?.location_id) {
      query = query.eq('location_id', profile.location_id)
    }
    const { data } = await query
    setEmployees(data || [])
  }
  async function approveEmployee(id, trackId) {
    const update = { status: 'active' }
    if (trackId) update.track_id = trackId
    await supabase.from('profiles').update(update).eq('id', id)
    loadEmployees()
  }
  async function deleteItem(id) {
    if (!confirm('Delete this item?')) return
    await supabase.from('module_items').delete().eq('id', id)
    loadItems(selectedModule.id)
  }
  async function deleteModule(id) {
    if (!confirm('Delete this module and all its items?')) return
    await supabase.from('modules').delete().eq('id', id)
    loadModules(selectedTrack.id)
  }

  const typeLabel = { video: 'video', checklist: 'checklist', info: 'info', quiz: 'quiz', validation: '✍️ sign-off' }
  if (loading) return <div className="empty-state"><div className="empty-state-icon">Loading...</div></div>

  const pendingEmployees = employees.filter(e => e.status === 'pending')
  const activeEmployees = employees.filter(e => e.status !== 'pending')

  return (
    <div>
      <div className="page-header">
        <div className="page-title">Admin Panel</div>
        <div className="page-subtitle">Manage training content, employees, and branding.</div>
      </div>
      <div className="flex gap-8 mb-24">
        <button className={`btn ${tab === 'content' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTab('content')}>Training Content</button>
        <button className={`btn ${tab === 'employees' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTab('employees')}>
          Employees {pendingEmployees.length > 0 && tab !== 'employees' ? `(${pendingEmployees.length} pending)` : ''}
        </button>
        <button className={`btn ${tab === 'validations' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTab('validations')}>✍️ Validations</button>
        <button className={`btn ${tab === 'reports' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTab('reports')}>Reports</button>
        {isAdmin && <button className={`btn ${tab === 'settings' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTab('settings')}>Branding</button>}
      </div>

      {tab === 'settings' && <SettingsTab />}
      {tab === 'validations' && <ValidationTab isAdmin={isAdmin} isManager={isManager} profile={profile} />}
      {tab === 'reports' && <ReportsTab isAdmin={isAdmin} isManager={isManager} profile={profile} />}

      {tab === 'content' && (
        <div className="grid-2" style={{ alignItems: 'start', gap: 20 }}>
          <div>
            <div className="card mb-16">
              <div className="card-header"><div className="card-title">Training Tracks</div></div>
              <div style={{ padding: '8px 12px' }}>
                {tracks.map(t => (
                  <button key={t.id} className={`nav-item ${selectedTrack?.id === t.id ? 'active' : ''}`}
                    style={{ color: selectedTrack?.id === t.id ? 'white' : '#1A1A2E', background: selectedTrack?.id === t.id ? t.color || 'var(--navy)' : 'transparent' }}
                    onClick={() => setSelectedTrack(t)}>{t.name}</button>
                ))}
              </div>
            </div>
            {selectedTrack && (
              <div className="card">
                <div className="card-header">
                  <div className="card-title">Modules</div>
                  <button className="btn btn-primary btn-sm" onClick={() => { setEditTarget(null); setModal('module') }}>+ Add Module</button>
                </div>
                <div style={{ padding: '8px 12px' }}>
                  {modules.length === 0 && <div style={{ padding: '16px 8px', color: '#6B7280', fontSize: 14 }}>No modules yet.</div>}
                  {modules.map((mod, idx) => (
                    <div key={mod.id} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 8px', borderRadius: 8, cursor: 'pointer', background: selectedModule?.id === mod.id ? 'rgba(27,58,107,0.08)' : 'transparent', marginBottom: 2 }} onClick={() => setSelectedModule(mod)}>
                      <div style={{ width: 24, height: 24, borderRadius: '50%', background: '#E5E7EB', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, flexShrink: 0 }}>{idx + 1}</div>
                      <div style={{ flex: 1, fontSize: 14, fontWeight: selectedModule?.id === mod.id ? 600 : 400 }}>{mod.title}</div>
                      <div style={{ display: 'flex', gap: 4 }}>
                        <button className="btn btn-secondary btn-sm" onClick={e => { e.stopPropagation(); setEditTarget(mod); setModal('module') }}>Edit</button>
                        <button className="btn btn-sm" style={{ background: '#FEE2E2', color: '#C0392B', border: 'none' }} onClick={e => { e.stopPropagation(); deleteModule(mod.id) }}>✕</button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
          <div>
            {selectedModule ? (
              <div className="card">
                <div className="card-header">
                  <div><div className="card-title">{selectedModule.title}</div><div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>{moduleItems.length} items</div></div>
                  <button className="btn btn-primary btn-sm" onClick={() => { setEditTarget(null); setModal('item') }}>+ Add Item</button>
                </div>
                <div style={{ padding: '8px 16px' }}>
                  {moduleItems.length === 0 && <div style={{ padding: '20px 0', color: '#6B7280', fontSize: 14, textAlign: 'center' }}>No items yet.</div>}
                  {moduleItems.map(item => (
                    <div key={item.id} className="item-row">
                      <div className="item-row-label">
                        <div style={{ fontSize: 14, fontWeight: 500 }}>{item.title}</div>
                      </div>
                      <span className="item-row-type">{typeLabel[item.type] || item.type}</span>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-secondary btn-sm" onClick={() => { setEditTarget(item); setModal('item') }}>Edit</button>
                        <button className="btn btn-sm" style={{ background: '#FEE2E2', color: '#C0392B', border: 'none' }} onClick={() => deleteItem(item.id)}>✕</button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : (
              <div className="card"><div className="card-body empty-state"><div className="empty-state-title">Select a Module</div><p style={{ marginTop: 8, fontSize: 14, color: '#6B7280' }}>Click a module on the left to manage its content.</p></div></div>
            )}
          </div>
        </div>
      )}

      {tab === 'employees' && (
        <div>
          {/* PENDING APPROVALS */}
          {pendingEmployees.length > 0 && (
            <div className="card mb-16" style={{ border: '1px solid #FCD34D', background: '#FFFBEB' }}>
              <div className="card-header" style={{ borderBottom: '1px solid #FCD34D' }}>
                <div>
                  <div className="card-title" style={{ color: '#92400E' }}>⏳ Pending Approvals ({pendingEmployees.length})</div>
                  <div style={{ fontSize: 13, color: '#92400E', marginTop: 2 }}>These employees signed up and are waiting to access training.</div>
                </div>
              </div>
              <div className="table-wrap">
                <table>
                  <thead><tr><th>Name</th><th>Location</th><th>Assign Track</th><th>Actions</th></tr></thead>
                  <tbody>
                    {pendingEmployees.map(emp => (
                      <PendingRow key={emp.id} emp={emp} tracks={tracks} onApprove={approveEmployee} onEdit={() => { setEditTarget(emp); setModal('employee') }} />
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ACTIVE EMPLOYEES */}
          <div className="card">
            <div className="card-header">
              <div className="card-title">
                {isManager ? 'Your Location\'s Employees' : 'All Employees'}
                <span style={{ fontWeight: 400, fontSize: 13, color: '#6B7280', marginLeft: 8 }}>({activeEmployees.length})</span>
              </div>
              <button className="btn btn-primary btn-sm" onClick={() => { setEditTarget(null); setModal('invite') }}>+ Invite Employee</button>
            </div>
            <div className="table-wrap">
              <table>
                <thead><tr><th>Name</th><th>Location</th><th>Role</th><th>Track</th><th>Actions</th></tr></thead>
                <tbody>
                  {activeEmployees.length === 0 && <tr><td colSpan={5} style={{ textAlign: 'center', color: '#6B7280', padding: 40 }}>No active employees yet.</td></tr>}
                  {activeEmployees.map(emp => (
                    <tr key={emp.id}>
                      <td style={{ fontWeight: 600 }}>{emp.full_name}</td>
                      <td>{emp.locations?.name || <span style={{ color: '#9CA3AF' }}>—</span>}</td>
                      <td>
                        <span className={`badge ${emp.role === 'admin' ? 'badge-red' : emp.role === 'manager' ? 'badge-amber' : 'badge-navy'}`}>{emp.role}</span>
                        {emp.role === 'manager' && (
                          <span style={{ fontSize: 11, marginLeft: 6, color: emp.manager_pin ? '#27AE60' : '#9CA3AF' }}>
                            {emp.manager_pin ? '🔐 PIN set' : '⚠️ No PIN'}
                          </span>
                        )}
                      </td>
                      <td>{emp.tracks?.name || <span style={{ color: '#9CA3AF' }}>Not assigned</span>}</td>
                      <td><button className="btn btn-secondary btn-sm" onClick={() => { setEditTarget(emp); setModal('employee') }}>Edit</button></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {modal === 'module' && <ModuleModal module={editTarget} trackId={selectedTrack?.id} onClose={() => { setModal(null); setEditTarget(null) }} onSave={() => loadModules(selectedTrack.id)} />}
      {modal === 'item' && <ItemModal item={editTarget} moduleId={selectedModule?.id} onClose={() => { setModal(null); setEditTarget(null) }} onSave={() => loadItems(selectedModule.id)} />}
      {modal === 'employee' && <EmployeeModal employee={editTarget} tracks={tracks} locations={locations} onClose={() => { setModal(null); setEditTarget(null) }} onSave={loadEmployees} />}
      {modal === 'invite' && <InviteModal tracks={tracks} locations={locations} onClose={() => setModal(null)} onSave={loadEmployees} />}
    </div>
  )
}

// Inline row component for pending approval with track selector
function PendingRow({ emp, tracks, onApprove, onEdit }) {
  const [trackId, setTrackId] = useState('')
  const [approving, setApproving] = useState(false)

  async function handleApprove() {
    setApproving(true)
    await onApprove(emp.id, trackId)
    setApproving(false)
  }

  return (
    <tr>
      <td style={{ fontWeight: 600 }}>{emp.full_name}<div style={{ fontSize: 12, color: '#6B7280', fontWeight: 400 }}>{emp.email}</div></td>
      <td>{emp.locations?.name || <span style={{ color: '#9CA3AF' }}>—</span>}</td>
      <td>
        <select className="form-select" style={{ fontSize: 13, padding: '4px 8px', marginBottom: 0 }} value={trackId} onChange={e => setTrackId(e.target.value)}>
          <option value="">-- Assign Track --</option>
          {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
        </select>
      </td>
      <td>
        <div style={{ display: 'flex', gap: 6 }}>
          <button
            className="btn btn-sm"
            style={{ background: '#D1FAE5', color: '#065F46', border: 'none', fontWeight: 600 }}
            onClick={handleApprove}
            disabled={approving}
          >
            {approving ? '...' : '✓ Approve'}
          </button>
          <button className="btn btn-secondary btn-sm" onClick={onEdit}>Edit</button>
        </div>
      </td>
    </tr>
  )
}
