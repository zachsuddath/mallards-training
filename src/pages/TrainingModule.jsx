import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../lib/supabase'

// Custom PIN pad — no <input>, so browsers can't save or autofill the manager PIN
function PinPad({ onSubmit, error, loading }) {
  const [digits, setDigits] = useState([])

  // Reset digits when an error comes back
  useEffect(() => { if (error) setDigits([]) }, [error])

  function tap(d) {
    if (loading || digits.length >= 4) return
    const next = [...digits, d]
    setDigits(next)
    if (next.length === 4) onSubmit(next.join(''))
  }
  function del() { if (!loading) setDigits(d => d.slice(0, -1)) }

  const btn = (label, action, extra = {}) => (
    <button
      onClick={action}
      disabled={loading}
      style={{
        width: 64, height: 64, borderRadius: 12, fontSize: 20, fontWeight: 600,
        background: '#F3F4F6', border: '1px solid #E5E7EB', cursor: loading ? 'not-allowed' : 'pointer',
        color: '#1B3A6B', display: 'flex', alignItems: 'center', justifyContent: 'center',
        userSelect: 'none', ...extra
      }}
    >{label}</button>
  )

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
      <div style={{ display: 'flex', gap: 14 }}>
        {[0, 1, 2, 3].map(i => (
          <div key={i} style={{
            width: 14, height: 14, borderRadius: '50%',
            background: i < digits.length ? '#1B3A6B' : '#D1D5DB',
            transition: 'background 0.15s'
          }} />
        ))}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 64px)', gap: 8 }}>
        {[1, 2, 3, 4, 5, 6, 7, 8, 9].map(n => btn(n, () => tap(String(n))))}
        <div />
        {btn('0', () => tap('0'))}
        {btn('⌫', del, { fontSize: 16, color: '#6B7280' })}
      </div>
      {loading && <div style={{ fontSize: 13, color: '#6B7280' }}>Checking…</div>}
      {error && <div style={{ fontSize: 13, color: '#C0392B' }}>{error}</div>}
    </div>
  )
}

export default function TrainingModule() {
  const { moduleId } = useParams()
  const { profile } = useAuth()
  const navigate = useNavigate()
  const [module, setModule] = useState(null)
  const [items, setItems] = useState([])
  const [completedIds, setCompletedIds] = useState(new Set())
  const [allModules, setAllModules] = useState([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [quizAnswers, setQuizAnswers] = useState({})
  const [quizSubmitted, setQuizSubmitted] = useState({})
  const [quizScores, setQuizScores] = useState({})
  const [pinUnlocked, setPinUnlocked] = useState(new Set())
  const [pinError, setPinError] = useState({})
  const [pinLoading, setPinLoading] = useState({})

  useEffect(() => { loadModule() }, [moduleId])

  async function loadModule() {
    setLoading(true)
    const { data: mod } = await supabase.from('modules').select('*').eq('id', moduleId).single()
    if (!mod) { navigate('/training'); return }
    setModule(mod)
    const { data: itms } = await supabase.from('module_items').select('*').eq('module_id', moduleId).order('order_index')
    setItems(itms || [])
    const itemIds = (itms || []).map(i => i.id)
    if (itemIds.length) {
      const { data: prog } = await supabase.from('employee_progress').select('module_item_id').eq('user_id', profile.id).in('module_item_id', itemIds)
      setCompletedIds(new Set(prog?.map(p => p.module_item_id) || []))
    }
    const { data: allMods } = await supabase.from('modules').select('id, title, order_index').eq('track_id', mod.track_id).order('order_index')
    setAllModules(allMods || [])
    setLoading(false)
  }

  async function toggleItem(itemId) {
    if (saving) return
    setSaving(true)
    if (completedIds.has(itemId)) {
      await supabase.from('employee_progress').delete().eq('user_id', profile.id).eq('module_item_id', itemId)
      setCompletedIds(prev => { const s = new Set(prev); s.delete(itemId); return s })
    } else {
      await supabase.from('employee_progress').upsert({ user_id: profile.id, module_item_id: itemId })
      setCompletedIds(prev => new Set([...prev, itemId]))
    }
    setSaving(false)
  }

  async function submitQuiz(item) {
    let questions = []
    try { questions = JSON.parse(item.content).questions || [] } catch {}
    const answers = quizAnswers[item.id] || {}
    let correct = 0
    questions.forEach((q, idx) => { if (answers[idx] === q.correctIndex) correct++ })
    const total = questions.length
    const pct = total > 0 ? Math.round((correct / total) * 100) : 0
    const passed = pct >= 80
    setQuizScores(s => ({ ...s, [item.id]: { correct, total, pct, passed } }))
    setQuizSubmitted(s => ({ ...s, [item.id]: true }))
    if (passed && !completedIds.has(item.id)) {
      await supabase.from('employee_progress').upsert({ user_id: profile.id, module_item_id: item.id })
      setCompletedIds(prev => new Set([...prev, item.id]))
    }
    await supabase.from('quiz_attempts').insert({ user_id: profile.id, module_item_id: item.id, score: correct, total, passed })
  }

  function retakeQuiz(itemId) {
    setQuizAnswers(a => ({ ...a, [itemId]: {} }))
    setQuizSubmitted(s => ({ ...s, [itemId]: false }))
    setQuizScores(sc => ({ ...sc, [itemId]: null }))
    setPinUnlocked(s => { const n = new Set(s); n.delete(itemId); return n })
  }

  async function verifyPin(itemId, pin) {
    setPinLoading(l => ({ ...l, [itemId]: true }))
    setPinError(e => ({ ...e, [itemId]: '' }))
    const { data, error } = await supabase.rpc('verify_manager_pin', {
      p_location_id: profile.location_id,
      p_pin: pin,
    })
    setPinLoading(l => ({ ...l, [itemId]: false }))
    if (error || !data) {
      setPinError(e => ({ ...e, [itemId]: 'Incorrect PIN. Ask your manager to try again.' }))
    } else {
      setPinUnlocked(s => new Set([...s, itemId]))
    }
  }

  async function signOffValidation(itemId, pin) {
    setPinLoading(l => ({ ...l, [itemId]: true }))
    setPinError(e => ({ ...e, [itemId]: '' }))
    const { data, error } = await supabase.rpc('sign_off_validation', {
      p_location_id: profile.location_id,
      p_pin: pin,
      p_employee_id: profile.id,
      p_item_id: itemId,
    })
    setPinLoading(l => ({ ...l, [itemId]: false }))
    if (error || !data?.success) {
      setPinError(e => ({ ...e, [itemId]: 'Incorrect PIN. Ask your manager to try again.' }))
    } else {
      setCompletedIds(prev => new Set([...prev, itemId]))
    }
  }

  // Replace any PDF iframes/embeds in info content with a safe "View PDF" button.
  // Without this, embedded PDFs take over the screen and block employees from continuing.
  function sanitizeInfoContent(html) {
    if (!html) return ''
    const el = document.createElement('div')
    el.innerHTML = html
    el.querySelectorAll('iframe, embed, object').forEach(node => {
      const src = node.getAttribute('src') || node.getAttribute('data') || ''
      if (src.toLowerCase().includes('.pdf') || node.getAttribute('type') === 'application/pdf') {
        const a = document.createElement('a')
        a.href = src
        a.target = '_blank'
        a.rel = 'noopener noreferrer'
        a.style.cssText = 'display:inline-flex;align-items:center;gap:8px;padding:10px 18px;background:#1B3A6B;color:white;border-radius:8px;text-decoration:none;font-weight:600;font-size:14px;'
        a.textContent = '📄 View PDF'
        node.replaceWith(a)
      }
    })
    // Make any raw PDF links open in a new tab
    el.querySelectorAll('a[href]').forEach(a => {
      if ((a.getAttribute('href') || '').toLowerCase().endsWith('.pdf')) {
        a.setAttribute('target', '_blank')
        a.setAttribute('rel', 'noopener noreferrer')
      }
    })
    return el.innerHTML
  }

  if (loading) return <div className="empty-state"><div className="empty-state-icon">&#x23F3;</div>Loading module...</div>

  const currentIdx = allModules.findIndex(m => m.id === moduleId)
  const prevModule = currentIdx > 0 ? allModules[currentIdx - 1] : null
  const nextModule = currentIdx < allModules.length - 1 ? allModules[currentIdx + 1] : null
  const checklistItems = items.filter(i => i.type === 'checklist')
  const completableItems = items.filter(i => ['checklist', 'quiz', 'validation'].includes(i.type))
  const completedChecklist = checklistItems.filter(i => completedIds.has(i.id)).length
  const completedAll = completableItems.filter(i => completedIds.has(i.id)).length
  const moduleComplete = completableItems.length > 0 && completedAll === completableItems.length
  const pct = checklistItems.length > 0 ? Math.round((completedChecklist / checklistItems.length) * 100) : 0
  const videoItems = items.filter(i => i.type === 'video')
  const infoItems = items.filter(i => i.type === 'info')
  const quizItems = items.filter(i => i.type === 'quiz')
  const validationItems = items.filter(i => i.type === 'validation')
  const needsPin = profile?.role === 'employee' && !!profile?.location_id

  return (
    <div>
      <button className="btn btn-secondary btn-sm mb-24" onClick={() => navigate('/training')}>Back to Training</button>
      <div className="page-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ background: moduleComplete ? '#27AE60' : '#1B3A6B', color: 'white', borderRadius: 8, width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: 14, flexShrink: 0 }}>
            {moduleComplete ? '&#x2713;' : currentIdx + 1}
          </div>
          <div>
            <div className="page-title">{module?.title}</div>
            <div className="page-subtitle">{module?.description}</div>
          </div>
        </div>
      </div>

      {videoItems.length > 0 && (
        <div className="mb-24">
          <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 12 }}>Videos</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {videoItems.map(item => (
              <div key={item.id} className="card">
                <div className="card-header">
                  <div className="card-title">{item.title}</div>
                  {!completedIds.has(item.id)
                    ? <button className="btn btn-sm btn-secondary" onClick={() => toggleItem(item.id)}>Mark Watched</button>
                    : <span className="badge badge-green">Watched</span>}
                </div>
                <div className="card-body">
                  <div className="video-wrapper">
                    {item.content && !item.content.includes('PLACEHOLDER') ? (
                      <iframe src={item.content} title={item.title} allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowFullScreen />
                    ) : (
                      <div className="video-placeholder">
                        <div className="video-placeholder-icon">&#x25BA;</div>
                        <div className="video-placeholder-text">Video coming soon</div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {infoItems.length > 0 && (
        <div className="mb-24">
          <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 12 }}>Key Info</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {infoItems.map(item => (
              <div key={item.id} className="card">
                <div className="card-header"><div className="card-title">{item.title}</div></div>
                <div className="card-body">
                  <div className="info-block ql-content" dangerouslySetInnerHTML={{ __html: sanitizeInfoContent(item.content) }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {quizItems.map(item => {
        let questions = []
        try { questions = JSON.parse(item.content).questions || [] } catch {}
        const answers = quizAnswers[item.id] || {}
        const submitted = quizSubmitted[item.id] || false
        const score = quizScores[item.id] || null
        const isComplete = completedIds.has(item.id)
        const allAnswered = questions.length > 0 && questions.every((_, i) => answers[i] !== undefined)
        const unlocked = !needsPin || pinUnlocked.has(item.id) || isComplete

        return (
          <div key={item.id} className="mb-24">
            <div className="card">
              <div className="card-header">
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{ fontSize: 20 }}>&#x1F9E0;</span>
                  <div>
                    <div className="card-title">{item.title}</div>
                    <div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>{questions.length} questions &middot; 80% to pass</div>
                  </div>
                </div>
                {isComplete && <span className="badge badge-green">Passed</span>}
              </div>

              {!unlocked && (
                <div style={{ padding: '24px', textAlign: 'center', borderTop: '1px solid #E5E7EB' }}>
                  <div style={{ fontSize: 32, marginBottom: 8 }}>&#x1F512;</div>
                  <div style={{ fontWeight: 600, fontSize: 15, color: '#1B3A6B', marginBottom: 4 }}>Manager PIN Required</div>
                  <div style={{ fontSize: 13, color: '#6B7280', marginBottom: 20 }}>
                    Hand the device to your manager — they tap their PIN below.
                  </div>
                  <PinPad
                    onSubmit={pin => verifyPin(item.id, pin)}
                    error={pinError[item.id]}
                    loading={pinLoading[item.id]}
                  />
                </div>
              )}

              {unlocked && !submitted && (
                <div style={{ padding: '8px 24px 24px' }}>
                  {questions.map((q, qIdx) => (
                    <div key={qIdx} className="quiz-question">
                      <div className="quiz-question-text"><span style={{ color: '#6B7280', marginRight: 6 }}>{qIdx + 1}.</span>{q.question}</div>
                      <div className="quiz-options">
                        {q.options.map((opt, oIdx) => (
                          <label key={oIdx} className={`quiz-option ${answers[qIdx] === oIdx ? 'selected' : ''}`}>
                            <input type="radio" name={`q-${item.id}-${qIdx}`} checked={answers[qIdx] === oIdx}
                              onChange={() => setQuizAnswers(a => ({ ...a, [item.id]: { ...(a[item.id] || {}), [qIdx]: oIdx } }))} />
                            <span>{opt}</span>
                          </label>
                        ))}
                      </div>
                    </div>
                  ))}
                  <button className="btn btn-primary" disabled={!allAnswered} onClick={() => submitQuiz(item)} style={{ marginTop: 8, opacity: allAnswered ? 1 : 0.5 }}>Submit Quiz</button>
                  {!allAnswered && <span style={{ fontSize: 13, color: '#6B7280', marginLeft: 12 }}>Answer all questions to submit</span>}
                </div>
              )}

              {unlocked && submitted && (
                <div style={{ padding: '8px 24px 24px' }}>
                  <div className={`quiz-result ${score?.passed ? 'quiz-result-pass' : 'quiz-result-fail'}`}>
                    <div style={{ fontSize: 22, marginBottom: 6 }}>{score?.passed ? '&#x1F389;' : '&#x1F4DA;'}</div>
                    <div style={{ fontWeight: 700, fontSize: 16 }}>{score?.passed ? 'You passed!' : 'Not quite — keep studying'}</div>
                    <div style={{ fontSize: 14, marginTop: 4 }}>Score: {score?.correct}/{score?.total} &middot; {score?.pct}%{!score?.passed && <span style={{ color: '#C0392B' }}> (80% required)</span>}</div>
                  </div>
                  {questions.map((q, qIdx) => {
                    const selected = answers[qIdx]
                    const correct = q.correctIndex
                    const isRight = selected === correct
                    return (
                      <div key={qIdx} className={`quiz-review-item ${isRight ? 'correct' : 'incorrect'}`}>
                        <div style={{ fontWeight: 600, fontSize: 13, marginBottom: 4 }}>{isRight ? '&#x2713;' : '&#x2717;'} {q.question}</div>
                        {!isRight && <div style={{ fontSize: 13, color: '#27AE60' }}>Correct: <strong>{q.options[correct]}</strong></div>}
                        {!isRight && selected !== undefined && <div style={{ fontSize: 13, color: '#C0392B' }}>Your answer: {q.options[selected]}</div>}
                      </div>
                    )
                  })}
                  {!score?.passed && <button className="btn btn-secondary" onClick={() => retakeQuiz(item.id)} style={{ marginTop: 12 }}>Retake Quiz</button>}
                </div>
              )}
            </div>
          </div>
        )
      })}

      {validationItems.length > 0 && (
        <div className="mb-24">
          <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 12 }}>Manager Sign-offs</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {validationItems.map(item => {
              const done = completedIds.has(item.id)
              return (
                <div key={item.id} className="card">
                  <div className="card-header">
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <span style={{ fontSize: 20 }}>✍️</span>
                      <div>
                        <div className="card-title">{item.title}</div>
                        {item.content && <div style={{ fontSize: 13, color: '#6B7280', marginTop: 2 }}>{item.content}</div>}
                      </div>
                    </div>
                    {done && <span className="badge badge-green">Signed off ✓</span>}
                  </div>
                  {!done && (
                    <div style={{ padding: '24px', textAlign: 'center', borderTop: '1px solid #E5E7EB' }}>
                      <div style={{ fontSize: 32, marginBottom: 8 }}>✍️</div>
                      <div style={{ fontWeight: 600, fontSize: 15, color: '#1B3A6B', marginBottom: 4 }}>Manager Sign-off Required</div>
                      <div style={{ fontSize: 13, color: '#6B7280', marginBottom: 20 }}>
                        Hand the device to your manager — they tap their PIN to confirm you've completed this.
                      </div>
                      <PinPad
                        onSubmit={pin => signOffValidation(item.id, pin)}
                        error={pinError[item.id]}
                        loading={pinLoading[item.id]}
                      />
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      )}

      {checklistItems.length > 0 && (
        <div>
          <div className="card">
            <div className="card-header">
              <div className="card-title">Checklist</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <span style={{ fontSize: 13, color: '#6B7280' }}>{completedChecklist}/{checklistItems.length} complete</span>
                {moduleComplete && <span className="badge badge-green">Module Complete!</span>}
              </div>
            </div>
            <div style={{ padding: '0 24px' }}>
              <div className="progress-wrap mt-12 mb-16" style={{ height: 6 }}>
                <div className={`progress-bar ${moduleComplete ? 'green' : ''}`} style={{ width: `${pct}%`, height: 6 }} />
              </div>
              {checklistItems.map(item => (
                <div key={item.id} className="checklist-item">
                  <div className={`check-box ${completedIds.has(item.id) ? 'checked' : ''}`} onClick={() => toggleItem(item.id)}>
                    {completedIds.has(item.id) && '&#x2713;'}
                  </div>
                  <div className={`checklist-text ${completedIds.has(item.id) ? 'done' : ''}`}>{item.title}</div>
                </div>
              ))}
            </div>
            {moduleComplete && (
              <div style={{ padding: '16px 24px', borderTop: '1px solid #E5E7EB' }}>
                <div style={{ background: 'rgba(39,174,96,0.08)', border: '1px solid rgba(39,174,96,0.3)', borderRadius: 8, padding: '14px 16px', color: '#27AE60', fontWeight: 600, fontSize: 14 }}>
                  Nice work! You have completed this module.{nextModule && ' Move on to the next one when you are ready.'}
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      <div className="flex-between mt-24">
        <div>{prevModule && <button className="btn btn-secondary" onClick={() => navigate(`/training/module/${prevModule.id}`)}>&#x2190; {prevModule.title}</button>}</div>
        <div>
          {nextModule && <button className="btn btn-primary" onClick={() => navigate(`/training/module/${nextModule.id}`)}>{nextModule.title} &#x2192;</button>}
          {!nextModule && moduleComplete && <button className="btn btn-success" onClick={() => navigate('/training')}>Back to Dashboard</button>}
        </div>
      </div>
    </div>
  )
}
