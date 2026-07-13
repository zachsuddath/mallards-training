import { useEffect, useState, useRef, useCallback } from 'react'
import ReactQuill from 'react-quill'
import 'react-quill/dist/quill.snow.css'
import { supabase } from '../lib/supabase'
import { useSettings } from '../contexts/SettingsContext'
import { useAuth } from '../contexts/AuthContext'

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
  })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  async function handleSave() {
    setSaving(true); setError('')
    const { error } = await supabase.from('profiles').update({
      full_name: form.full_name,
      role: form.role,
      track_id: form.track_id || null,
      location_id: form.location_id || null,
      status: form.status,
    }).eq('id', employee.id)
    setSaving(false)
    if (error) setError(error.message)
    else { onSave(); onClose() }
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
          <div className="form-group"><label className="form-label">Training Track</label>
            <select className="form-select" value={form.track_id} onChange={e => setForm(f => ({ ...f, track_id: e.target.value }))}>
              <option value="">-- No Track --</option>
              {tracks.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
            </select>
          </div>
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
              <option value="checklist">Checklist Item</option><option value="video">Video</option>
              <option value="info">Study Guide / Info</option><option value="quiz">Quiz</option>
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
    let query = supabase.from('profiles').select('*, tracks(name), locations(name)').order('full_name')
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

  const typeLabel = { video: 'video', checklist: 'checklist', info: 'info', quiz: 'quiz' }
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
        {isAdmin && <button className={`btn ${tab === 'settings' ? 'btn-primary' : 'btn-secondary'}`} onClick={() => setTab('settings')}>Branding</button>}
      </div>

      {tab === 'settings' && <SettingsTab />}

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
                      <td><span className={`badge ${emp.role === 'admin' ? 'badge-red' : emp.role === 'manager' ? 'badge-amber' : 'badge-navy'}`}>{emp.role}</span></td>
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
