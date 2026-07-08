import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../lib/supabase'

export default function EmployeeDashboard() {
  const { profile } = useAuth()
  const navigate = useNavigate()
  const [modules, setModules] = useState([])
  const [progress, setProgress] = useState({}) // module_id -> { total, completed }
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (profile?.track_id) loadData()
    else setLoading(false)
  }, [profile])

  async function loadData() {
    // Load modules for this track
    const { data: mods } = await supabase
      .from('modules')
      .select('*, module_items(id)')
      .eq('track_id', profile.track_id)
      .order('order_index')

    if (!mods) return setLoading(false)

    // Load all completed item ids for this user
    const allItemIds = mods.flatMap(m => m.module_items.map(i => i.id))

    const { data: prog } = await supabase
      .from('employee_progress')
      .select('module_item_id')
      .eq('user_id', profile.id)
      .in('module_item_id', allItemIds)

    const completedSet = new Set(prog?.map(p => p.module_item_id) || [])

    // Build progress map
    const progressMap = {}
    mods.forEach(m => {
      const total = m.module_items.length
      const completed = m.module_items.filter(i => completedSet.has(i.id)).length
      progressMap[m.id] = { total, completed }
    })

    setModules(mods)
    setProgress(progressMap)
    setLoading(false)
  }

  if (loading) {
    return <div className="empty-state"><div className="empty-state-icon">⏳</div>Loading your training...</div>
  }

  if (!profile?.track_id) {
    return (
      <div>
        <div className="page-header">
          <div className="page-title">Welcome, {profile?.full_name?.split(' ')[0]}! 👋</div>
          <div className="page-subtitle">You haven't been assigned a training track yet.</div>
        </div>
        <div className="card">
          <div className="card-body empty-state">
            <div className="empty-state-icon">📋</div>
            <div className="empty-state-title">No Training Track Assigned</div>
            <p style={{ marginTop: 8, fontSize: 14, color: '#6B7280' }}>
              Ask your manager to assign you to a training track and you'll be ready to go!
            </p>
          </div>
        </div>
      </div>
    )
  }

  const totalItems = Object.values(progress).reduce((sum, p) => sum + p.total, 0)
  const totalCompleted = Object.values(progress).reduce((sum, p) => sum + p.completed, 0)
  const overallPct = totalItems > 0 ? Math.round((totalCompleted / totalItems) * 100) : 0

  // Determine module states
  const moduleStates = modules.map((mod, idx) => {
    const p = progress[mod.id] || { total: 0, completed: 0 }
    const isComplete = p.total > 0 && p.completed === p.total
    // Module is unlocked if it's the first, or the previous is complete
    const prevComplete = idx === 0 || (() => {
      const prev = modules[idx - 1]
      const pp = progress[prev.id] || { total: 0, completed: 0 }
      return pp.total > 0 && pp.completed === pp.total
    })()
    return { ...mod, progress: p, isComplete, isUnlocked: prevComplete }
  })

  const firstName = profile?.full_name?.split(' ')[0] || 'there'

  return (
    <div>
      <div className="page-header">
        <div className="page-title">Hey {firstName}! 👋</div>
        <div className="page-subtitle">{profile?.tracks?.name} Training Track</div>
      </div>

      {/* Overall Progress */}
      <div className="card mb-24">
        <div className="card-body">
          <div className="flex-between mb-16">
            <div>
              <div style={{ fontWeight: 700, fontSize: 16 }}>Overall Progress</div>
              <div style={{ fontSize: 13, color: '#6B7280', marginTop: 4 }}>
                {totalCompleted} of {totalItems} items complete
              </div>
            </div>
            <div style={{ fontSize: 32, fontWeight: 800, color: overallPct === 100 ? '#27AE60' : '#1B3A6B' }}>
              {overallPct}%
            </div>
          </div>
          <div className="progress-wrap" style={{ height: 12 }}>
            <div
              className={`progress-bar ${overallPct === 100 ? 'green' : ''}`}
              style={{ width: `${overallPct}%`, height: 12 }}
            />
          </div>
          {overallPct === 100 && (
            <div style={{ marginTop: 12, color: '#27AE60', fontWeight: 600, fontSize: 14 }}>
              🎉 Training complete! Talk to your manager about your final sign-off.
            </div>
          )}
        </div>
      </div>

      {/* Modules List */}
      <div className="page-header" style={{ marginBottom: 16 }}>
        <div className="page-title" style={{ fontSize: 18 }}>Training Modules</div>
      </div>

      {moduleStates.map((mod, idx) => {
        const pct = mod.progress.total > 0
          ? Math.round((mod.progress.completed / mod.progress.total) * 100)
          : 0

        return (
          <div
            key={mod.id}
            className={`module-card ${!mod.isUnlocked ? 'locked' : ''} ${mod.isComplete ? 'completed' : ''}`}
            onClick={() => mod.isUnlocked && navigate(`/training/module/${mod.id}`)}
          >
            <div className={`module-num ${mod.isComplete ? 'done' : mod.isUnlocked ? 'active' : ''}`}>
              {mod.isComplete ? '✓' : idx + 1}
            </div>

            <div className="module-info">
              <div className="module-name">{mod.title}</div>
              <div className="module-desc">{mod.description}</div>
              {mod.isUnlocked && !mod.isComplete && mod.progress.total > 0 && (
                <div style={{ marginTop: 8 }}>
                  <div className="progress-wrap" style={{ height: 4 }}>
                    <div className="progress-bar" style={{ width: `${pct}%`, height: 4 }} />
                  </div>
                </div>
              )}
            </div>

            <div className="module-status">
              {!mod.isUnlocked && <span>🔒 Locked</span>}
              {mod.isUnlocked && mod.isComplete && <span style={{ color: '#27AE60' }}>✓ Done</span>}
              {mod.isUnlocked && !mod.isComplete && (
                <span>{mod.progress.completed}/{mod.progress.total}</span>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
