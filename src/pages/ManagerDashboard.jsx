import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'

const TRACK_COLORS = {
  foh_server: '#1B3A6B',
  foh_support: '#2E6DA4',
  bar: '#1B3A6B',
  kitchen: '#C0392B',
  management: '#27AE60',
}

export default function ManagerDashboard() {
  const navigate = useNavigate()
  const [employees, setEmployees] = useState([])
  const [tracks, setTracks] = useState([])
  const [loading, setLoading] = useState(true)
  const [filterTrack, setFilterTrack] = useState('all')
  const [selected, setSelected] = useState(null) // employee detail modal

  useEffect(() => {
    loadData()
  }, [])

  async function loadData() {
    // Load all tracks
    const { data: trackData } = await supabase
      .from('tracks')
      .select('*')
      .order('name')

    setTracks(trackData || [])

    // Load all employee profiles (non-admin users)
    const { data: profiles } = await supabase
      .from('profiles')
      .select('*, tracks(id, name, position_key, color)')
      .in('role', ['employee', 'manager'])
      .order('full_name')

    if (!profiles) { setLoading(false); return }

    // For each employee, calculate their progress
    const enriched = await Promise.all(profiles.map(async emp => {
      if (!emp.track_id) return { ...emp, pct: 0, completed: 0, total: 0, modules: [] }

      // Get all module items for their track
      const { data: mods } = await supabase
        .from('modules')
        .select('id, title, order_index, module_items(id)')
        .eq('track_id', emp.track_id)
        .order('order_index')

      const allItems = (mods || []).flatMap(m => m.module_items.map(i => i.id))
      const total = allItems.length

      if (total === 0) return { ...emp, pct: 0, completed: 0, total: 0, modules: mods || [] }

      const { data: prog } = await supabase
        .from('employee_progress')
        .select('module_item_id')
        .eq('user_id', emp.id)
        .in('module_item_id', allItems)

      const completedSet = new Set(prog?.map(p => p.module_item_id) || [])
      const completed = completedSet.size
      const pct = Math.round((completed / total) * 100)

      // Module-level progress
      const modulesWithProg = (mods || []).map(m => {
        const mTotal = m.module_items.length
        const mDone = m.module_items.filter(i => completedSet.has(i.id)).length
        return { ...m, total: mTotal, completed: mDone, done: mTotal > 0 && mDone === mTotal }
      })

      return { ...emp, pct, completed, total, modules: modulesWithProg }
    }))

    setEmployees(enriched)
    setLoading(false)
  }

  const filtered = filterTrack === 'all'
    ? employees
    : employees.filter(e => e.track_id === filterTrack)

  const stats = {
    total: employees.length,
    complete: employees.filter(e => e.pct === 100).length,
    inProgress: employees.filter(e => e.pct > 0 && e.pct < 100).length,
    notStarted: employees.filter(e => e.pct === 0).length,
  }

  if (loading) {
    return <div className="empty-state"><div className="empty-state-icon">⏳</div>Loading team data...</div>
  }

  return (
    <div>
      <div className="page-header">
        <div className="page-title">Team Training Progress</div>
        <div className="page-subtitle">See where your team is and who needs a nudge.</div>
      </div>

      {/* Stats */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-label">Total Employees</div>
          <div className="stat-value">{stats.total}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Training Complete</div>
          <div className="stat-value" style={{ color: '#27AE60' }}>{stats.complete}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">In Progress</div>
          <div className="stat-value" style={{ color: '#C9A227' }}>{stats.inProgress}</div>
        </div>
        <div className="stat-card">
          <div className="stat-label">Not Started</div>
          <div className="stat-value" style={{ color: '#C0392B' }}>{stats.notStarted}</div>
        </div>
      </div>

      {/* Filter */}
      <div className="flex gap-8 mb-16" style={{ flexWrap: 'wrap' }}>
        <button
          className={`btn btn-sm ${filterTrack === 'all' ? 'btn-primary' : 'btn-secondary'}`}
          onClick={() => setFilterTrack('all')}
        >
          All Tracks
        </button>
        {tracks.map(t => (
          <button
            key={t.id}
            className={`btn btn-sm ${filterTrack === t.id ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setFilterTrack(t.id)}
          >
            {t.name}
          </button>
        ))}
      </div>

      {/* Employee Table */}
      <div className="card">
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Employee</th>
                <th>Track</th>
                <th>Progress</th>
                <th>Status</th>
                <th>Details</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', color: '#6B7280', padding: 40 }}>
                    No employees found.
                  </td>
                </tr>
              )}
              {filtered.map(emp => {
                const statusBadge = emp.pct === 100
                  ? <span className="badge badge-green">✓ Complete</span>
                  : emp.pct > 0
                  ? <span className="badge badge-amber">In Progress</span>
                  : <span className="badge badge-red">Not Started</span>

                return (
                  <tr key={emp.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{
                          width: 32, height: 32, borderRadius: '50%',
                          background: '#E5E7EB', display: 'flex', alignItems: 'center',
                          justifyContent: 'center', fontWeight: 700, fontSize: 13, flexShrink: 0
                        }}>
                          {emp.full_name?.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                        </div>
                        <div>
                          <div style={{ fontWeight: 600, fontSize: 14 }}>{emp.full_name}</div>
                          <div style={{ fontSize: 12, color: '#6B7280', textTransform: 'capitalize' }}>{emp.role}</div>
                        </div>
                      </div>
                    </td>
                    <td>
                      {emp.tracks ? (
                        <span className="badge badge-navy">{emp.tracks.name}</span>
                      ) : (
                        <span style={{ color: '#6B7280', fontSize: 13 }}>No track</span>
                      )}
                    </td>
                    <td style={{ minWidth: 160 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div className="progress-wrap" style={{ height: 8, flex: 1 }}>
                          <div
                            className={`progress-bar ${emp.pct === 100 ? 'green' : ''}`}
                            style={{ width: `${emp.pct}%`, height: 8 }}
                          />
                        </div>
                        <span style={{ fontSize: 13, fontWeight: 600, color: '#1B3A6B', minWidth: 36 }}>
                          {emp.pct}%
                        </span>
                      </div>
                      <div style={{ fontSize: 12, color: '#6B7280', marginTop: 4 }}>
                        {emp.completed}/{emp.total} items
                      </div>
                    </td>
                    <td>{statusBadge}</td>
                    <td>
                      <button
                        className="btn btn-secondary btn-sm"
                        onClick={() => setSelected(emp)}
                      >
                        View →
                      </button>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Employee Detail Modal */}
      {selected && (
        <div className="modal-overlay" onClick={() => setSelected(null)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <div>
                <div className="modal-title">{selected.full_name}</div>
                <div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>
                  {selected.tracks?.name || 'No track'} · {selected.pct}% complete
                </div>
              </div>
              <button className="close-btn" onClick={() => setSelected(null)}>✕</button>
            </div>
            <div className="modal-body">
              <div className="progress-wrap" style={{ height: 8 }}>
                <div
                  className={`progress-bar ${selected.pct === 100 ? 'green' : ''}`}
                  style={{ width: `${selected.pct}%`, height: 8 }}
                />
              </div>

              <div style={{ fontWeight: 700, fontSize: 14, marginTop: 4 }}>Module Breakdown</div>
              {selected.modules?.length === 0 && (
                <div style={{ color: '#6B7280', fontSize: 14 }}>No modules assigned.</div>
              )}
              {selected.modules?.map((mod, idx) => (
                <div key={mod.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0', borderBottom: '1px solid #E5E7EB' }}>
                  <div style={{
                    width: 28, height: 28, borderRadius: '50%',
                    background: mod.done ? '#27AE60' : mod.completed > 0 ? '#1B3A6B' : '#E5E7EB',
                    color: mod.done || mod.completed > 0 ? 'white' : '#6B7280',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: 12, fontWeight: 700, flexShrink: 0
                  }}>
                    {mod.done ? '✓' : idx + 1}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 14, fontWeight: 500 }}>{mod.title}</div>
                    <div style={{ fontSize: 12, color: '#6B7280' }}>{mod.completed}/{mod.total} items</div>
                  </div>
                  <span className={`badge ${mod.done ? 'badge-green' : mod.completed > 0 ? 'badge-amber' : 'badge-red'}`}>
                    {mod.done ? 'Done' : mod.completed > 0 ? 'In Progress' : 'Not Started'}
                  </span>
                </div>
              ))}
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setSelected(null)}>Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
