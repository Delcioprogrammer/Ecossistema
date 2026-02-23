import { useState, useRef, useCallback, useEffect } from 'react'

// ─── API base URL (env var from Vercel) ─────────────────────────────────────
const API = import.meta.env.VITE_API_URL || ''

// ════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ════════════════════════════════════════════════════════════════════════════

function Spinner() {
  return (
    <span style={{
      display:'inline-block',
      width:16, height:16,
      border:'2px solid rgba(245,158,11,0.3)',
      borderTopColor:'#f59e0b',
      borderRadius:'50%',
      animation:'spin 0.8s linear infinite',
      flexShrink:0,
    }}/>
  )
}

function ProgressBar({ value, label }) {
  return (
    <div style={{ marginTop:12 }}>
      <div style={{ display:'flex', justifyContent:'space-between', marginBottom:6 }}>
        <span style={{ color:'#888', fontSize:12 }}>{label}</span>
        <span style={{ color:'#f59e0b', fontSize:12, fontWeight:600 }}>{Math.round(value)}%</span>
      </div>
      <div style={{
        background:'#1a1a1a', borderRadius:99, height:6, overflow:'hidden',
        border:'1px solid #2a2a2a'
      }}>
        <div style={{
          height:'100%', width:`${value}%`,
          background:'linear-gradient(90deg, #d97706, #f59e0b)',
          borderRadius:99,
          transition:'width 0.4s ease',
          boxShadow:'0 0 8px rgba(245,158,11,0.4)',
        }}/>
      </div>
    </div>
  )
}

function DropZone({ label, accept, file, onChange, icon }) {
  const ref = useRef()
  const [drag, setDrag] = useState(false)

  const onDrop = e => {
    e.preventDefault(); setDrag(false)
    const f = e.dataTransfer.files[0]
    if (f) onChange(f)
  }

  return (
    <div
      onClick={() => ref.current.click()}
      onDragOver={e => { e.preventDefault(); setDrag(true) }}
      onDragLeave={() => setDrag(false)}
      onDrop={onDrop}
      style={{
        border:`1.5px dashed ${drag ? '#f59e0b' : file ? '#10b981' : '#333'}`,
        borderRadius:10, padding:'22px 20px',
        cursor:'pointer', transition:'all 200ms',
        background: drag ? 'rgba(245,158,11,0.06)' : file ? 'rgba(16,185,129,0.05)' : '#111',
        display:'flex', alignItems:'center', gap:12,
      }}
    >
      <span style={{ fontSize:28 }}>{file ? '✅' : icon}</span>
      <div>
        <div style={{ fontWeight:500, color: file ? '#10b981' : '#ccc' }}>
          {file ? file.name : label}
        </div>
        <div style={{ fontSize:12, color:'#555', marginTop:2 }}>
          {file ? `${(file.size / 1024 / 1024).toFixed(1)} MB` : 'Clica ou arrasta o ficheiro aqui'}
        </div>
      </div>
      <input ref={ref} type="file" accept={accept} style={{ display:'none' }}
             onChange={e => onChange(e.target.files[0])} />
    </div>
  )
}

function StatusBadge({ status }) {
  const map = {
    queued:      { color:'#888',    bg:'#1a1a1a', label:'Na fila' },
    uploading:   { color:'#3b82f6', bg:'rgba(59,130,246,0.1)', label:'Enviando' },
    analyzing:   { color:'#8b5cf6', bg:'rgba(139,92,246,0.1)', label:'Analisando' },
    transcribing:{ color:'#8b5cf6', bg:'rgba(139,92,246,0.1)', label:'Transcrevendo' },
    translating: { color:'#f59e0b', bg:'rgba(245,158,11,0.1)', label:'Traduzindo' },
    cutting:     { color:'#f59e0b', bg:'rgba(245,158,11,0.1)', label:'Cortando' },
    rendering:   { color:'#f59e0b', bg:'rgba(245,158,11,0.1)', label:'Renderizando' },
    writing:     { color:'#3b82f6', bg:'rgba(59,130,246,0.1)', label:'Escrevendo' },
    embedding:   { color:'#3b82f6', bg:'rgba(59,130,246,0.1)', label:'Embutindo' },
    done:        { color:'#10b981', bg:'rgba(16,185,129,0.1)', label:'Concluído ✓' },
    error:       { color:'#ef4444', bg:'rgba(239,68,68,0.1)',  label:'Erro' },
  }
  const s = map[status] || map.queued
  return (
    <span style={{
      fontSize:11, fontWeight:600, letterSpacing:'0.05em',
      padding:'3px 10px', borderRadius:99,
      color:s.color, background:s.bg,
    }}>{s.label.toUpperCase()}</span>
  )
}

function PrimaryBtn({ onClick, loading, disabled, children, color='#f59e0b' }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled || loading}
      style={{
        background: disabled || loading
          ? '#1a1a1a'
          : `linear-gradient(135deg, ${color}, ${color}dd)`,
        color: disabled || loading ? '#444' : '#000',
        fontFamily:'var(--font-display)',
        fontWeight:700, fontSize:13, letterSpacing:'0.05em',
        padding:'12px 24px', borderRadius:8,
        width:'100%', marginTop:16,
        cursor: disabled || loading ? 'not-allowed' : 'pointer',
        display:'flex', alignItems:'center', justifyContent:'center', gap:8,
        border:'none',
        boxShadow: disabled || loading ? 'none' : `0 4px 20px rgba(245,158,11,0.25)`,
        transition:'all 200ms',
      }}
    >
      {loading && <Spinner />}
      {children}
    </button>
  )
}

function DownloadBtn({ href, label }) {
  return (
    <a
      href={href}
      download
      style={{
        display:'flex', alignItems:'center', gap:8,
        background:'#10b981', color:'#000',
        fontWeight:700, fontSize:13, letterSpacing:'0.04em',
        padding:'11px 20px', borderRadius:8,
        textDecoration:'none', marginTop:10,
        boxShadow:'0 4px 16px rgba(16,185,129,0.2)',
        transition:'all 200ms',
      }}
    >
      ⬇️ {label}
    </a>
  )
}

// ── API Key input shared ────────────────────────────────────────────────────
function ApiKeyNotice({ apiKey }) {
  if (apiKey) return null
  return (
    <div style={{
      background:'rgba(245,158,11,0.08)', border:'1px solid rgba(245,158,11,0.2)',
      borderRadius:8, padding:'12px 16px', marginBottom:16,
      display:'flex', alignItems:'center', gap:10, fontSize:13,
    }}>
      <span>⚠️</span>
      <span style={{ color:'#f59e0b' }}>Vai a <b>Configurações</b> e insere a tua Gemini API Key para usar as funcionalidades de IA.</span>
    </div>
  )
}

// ─── Polling hook ────────────────────────────────────────────────────────────
function usePoll(url, interval = 2000) {
  const [data, setData] = useState(null)
  const timer = useRef(null)

  const start = useCallback((u) => {
    const poll = async () => {
      try {
        const r = await fetch(u || url)
        const d = await r.json()
        setData(d)
        if (d.status !== 'done' && d.status !== 'error') {
          timer.current = setTimeout(poll, interval)
        }
      } catch { timer.current = setTimeout(poll, interval) }
    }
    poll()
  }, [url, interval])

  const stop = useCallback(() => {
    if (timer.current) clearTimeout(timer.current)
  }, [])

  useEffect(() => () => stop(), [stop])

  return { data, start, stop, setData }
}


// ════════════════════════════════════════════════════════════════════════════
// TAB: CORTES
// ════════════════════════════════════════════════════════════════════════════
function TabCortes({ apiKey }) {
  const [video, setVideo]       = useState(null)
  const [instr, setInstr]       = useState('Momentos emocionantes, reações e ação intensa.')
  const [speed, setSpeed]       = useState(1.1)
  const [loading, setLoading]   = useState(false)
  const [jobId, setJobId]       = useState(null)
  const { data: job, start, setData: setJob } = usePoll()

  const submit = async () => {
    if (!apiKey || !video) return
    setLoading(true)
    setJobId(null)
    setJob(null)
    const fd = new FormData()
    fd.append('video', video)
    fd.append('instructions', instr)
    fd.append('speed', speed)
    fd.append('api_key', apiKey)
    try {
      const r = await fetch(`${API}/api/cuts/analyze`, { method:'POST', body:fd })
      const { job_id } = await r.json()
      setJobId(job_id)
      start(`${API}/api/cuts/status/${job_id}`)
    } catch (e) {
      alert('Erro: ' + e.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fade-up">
      <TabHeader icon="✂️" title="Cortes com IA" subtitle="O Gemini analisa o vídeo visualmente e gera cortes automáticos impactantes." />
      <ApiKeyNotice apiKey={apiKey} />

      <DropZone label="Vídeo para cortar" accept="video/*" file={video} onChange={setVideo} icon="🎬" />

      <div style={{ marginTop:16 }}>
        <Label>Instruções para a IA</Label>
        <textarea
          rows={3}
          value={instr}
          onChange={e => setInstr(e.target.value)}
          placeholder="Ex: Cortes com reações exageradas, momentos de tensão..."
          style={{ resize:'vertical', marginTop:6 }}
        />
      </div>

      <div style={{ marginTop:14 }}>
        <Label>Velocidade do vídeo: <span style={{ color:'#f59e0b' }}>{speed.toFixed(1)}×</span></Label>
        <input type="range" min={1.0} max={2.0} step={0.1} value={speed}
               onChange={e => setSpeed(parseFloat(e.target.value))}
               style={{ width:'100%', marginTop:8 }} />
      </div>

      <PrimaryBtn onClick={submit} loading={loading} disabled={!apiKey || !video}>
        🚀 PROCESSAR CORTES COM IA
      </PrimaryBtn>

      {job && (
        <div style={{ marginTop:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:8 }}>
            {job.status !== 'done' && job.status !== 'error' && <Spinner />}
            <StatusBadge status={job.status} />
            <span style={{ color:'#888', fontSize:13 }}>{job.message}</span>
          </div>
          <ProgressBar value={job.progress || 0} label={job.message} />

          {job.status === 'done' && (
            <div style={{ marginTop:16 }}>
              <SuccessBox>
                🎉 {job.count} cortes gerados com sucesso!
              </SuccessBox>
              <DownloadBtn href={`${API}/api/cuts/download/${jobId}`} label={`Baixar ${job.count} cortes (.zip)`} />
              {job.cuts && (
                <div style={{ marginTop:14 }}>
                  <Label>Cortes gerados:</Label>
                  <div style={{ display:'flex', flexDirection:'column', gap:6, marginTop:8 }}>
                    {job.cuts.map((c, i) => (
                      <div key={i} style={{
                        background:'#111', border:'1px solid #2a2a2a', borderRadius:8,
                        padding:'10px 14px', display:'flex', gap:12, alignItems:'center'
                      }}>
                        <span style={{ color:'#f59e0b', fontWeight:700, fontSize:12 }}>#{i+1}</span>
                        <span style={{ color:'#888', fontSize:12 }}>{c.inicio} → {c.fim}</span>
                        <span style={{ color:'#ccc', fontSize:13 }}>{c.titulo}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {job.status === 'error' && (
            <ErrorBox>{job.message}</ErrorBox>
          )}
        </div>
      )}
    </div>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// TAB: LEGENDAS
// ════════════════════════════════════════════════════════════════════════════
function TabLegendas({ apiKey }) {
  const [video, setVideo]     = useState(null)
  const [lang, setLang]       = useState('Portuguese')
  const [embed, setEmbed]     = useState(true)
  const [loading, setLoading] = useState(false)
  const [jobId, setJobId]     = useState(null)
  const { data: job, start, setData: setJob } = usePoll()

  const LANGS = ['Portuguese','English','Spanish','French','German','Italian','Japanese','Chinese','Korean','Arabic']

  const submit = async () => {
    if (!apiKey || !video) return
    setLoading(true); setJobId(null); setJob(null)
    const fd = new FormData()
    fd.append('video', video)
    fd.append('language', lang)
    fd.append('embed', embed)
    fd.append('api_key', apiKey)
    try {
      const r = await fetch(`${API}/api/subtitles/generate`, { method:'POST', body:fd })
      const { job_id } = await r.json()
      setJobId(job_id)
      start(`${API}/api/subtitles/status/${job_id}`)
    } catch (e) { alert(e.message) }
    finally { setLoading(false) }
  }

  return (
    <div className="fade-up">
      <TabHeader icon="📝" title="Legendas Automáticas" subtitle="O Gemini transcreve o áudio e gera um ficheiro SRT com timestamps precisos." />
      <ApiKeyNotice apiKey={apiKey} />

      <DropZone label="Vídeo para legendar" accept="video/*" file={video} onChange={setVideo} icon="🎬" />

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:14, marginTop:16 }}>
        <div>
          <Label>Idioma do vídeo</Label>
          <select value={lang} onChange={e => setLang(e.target.value)} style={{ marginTop:6 }}>
            {LANGS.map(l => <option key={l}>{l}</option>)}
          </select>
        </div>
        <div>
          <Label>Opções</Label>
          <label style={{ display:'flex', alignItems:'center', gap:10, marginTop:14, cursor:'pointer' }}>
            <input type="checkbox" checked={embed} onChange={e => setEmbed(e.target.checked)}
                   style={{ width:16, height:16, accentColor:'#f59e0b' }} />
            <span style={{ color:'#ccc' }}>Embutir no vídeo</span>
          </label>
        </div>
      </div>

      <PrimaryBtn onClick={submit} loading={loading} disabled={!apiKey || !video} color="#8b5cf6">
        📝 GERAR LEGENDAS
      </PrimaryBtn>

      {job && (
        <div style={{ marginTop:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:8 }}>
            {job.status !== 'done' && job.status !== 'error' && <Spinner />}
            <StatusBadge status={job.status} />
            <span style={{ color:'#888', fontSize:13 }}>{job.message}</span>
          </div>
          <ProgressBar value={job.progress || 0} label={job.message} />

          {job.status === 'done' && (
            <div style={{ marginTop:16 }}>
              <SuccessBox>✅ {job.segments} legendas geradas!</SuccessBox>
              <div style={{ display:'flex', flexDirection:'column', gap:8, marginTop:12 }}>
                <DownloadBtn href={`${API}/api/subtitles/download/srt/${jobId}`} label="Baixar ficheiro SRT" />
                {embed && <DownloadBtn href={`${API}/api/subtitles/download/video/${jobId}`} label="Baixar vídeo legendado" />}
              </div>
            </div>
          )}
          {job.status === 'error' && <ErrorBox>{job.message}</ErrorBox>}
        </div>
      )}
    </div>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// TAB: TRADUÇÃO
// ════════════════════════════════════════════════════════════════════════════
function TabTraducao({ apiKey }) {
  const [video, setVideo]       = useState(null)
  const [langFrom, setLangFrom] = useState('en')
  const [langTo, setLangTo]     = useState('pt')
  const [mode, setMode]         = useState('srt')
  const [loading, setLoading]   = useState(false)
  const [jobId, setJobId]       = useState(null)
  const { data: job, start, setData: setJob } = usePoll()

  const LANGS = [
    {code:'pt',label:'Português'},{code:'en',label:'English'},{code:'es',label:'Español'},
    {code:'fr',label:'Français'},{code:'de',label:'Deutsch'},{code:'it',label:'Italiano'},
    {code:'ja',label:'日本語'},{code:'zh',label:'中文'},{code:'ko',label:'한국어'},
  ]

  const submit = async () => {
    if (!apiKey || !video) return
    setLoading(true); setJobId(null); setJob(null)
    const fd = new FormData()
    fd.append('video', video)
    fd.append('lang_from', langFrom)
    fd.append('lang_to', langTo)
    fd.append('mode', mode)
    fd.append('api_key', apiKey)
    try {
      const r = await fetch(`${API}/api/translation/translate`, { method:'POST', body:fd })
      const { job_id } = await r.json()
      setJobId(job_id)
      start(`${API}/api/translation/status/${job_id}`)
    } catch (e) { alert(e.message) }
    finally { setLoading(false) }
  }

  return (
    <div className="fade-up">
      <TabHeader icon="🌍" title="Tradução de Áudio" subtitle="Transcreve o áudio, traduz com IA e gera legendas ou dublagem." />
      <ApiKeyNotice apiKey={apiKey} />

      <DropZone label="Vídeo para traduzir" accept="video/*" file={video} onChange={setVideo} icon="🎬" />

      <div style={{ display:'grid', gridTemplateColumns:'1fr auto 1fr', gap:12, marginTop:16, alignItems:'end' }}>
        <div>
          <Label>De</Label>
          <select value={langFrom} onChange={e => setLangFrom(e.target.value)} style={{ marginTop:6 }}>
            {LANGS.map(l => <option key={l.code} value={l.code}>{l.label}</option>)}
          </select>
        </div>
        <div style={{ color:'#555', paddingBottom:12, fontSize:18 }}>→</div>
        <div>
          <Label>Para</Label>
          <select value={langTo} onChange={e => setLangTo(e.target.value)} style={{ marginTop:6 }}>
            {LANGS.map(l => <option key={l.code} value={l.code}>{l.label}</option>)}
          </select>
        </div>
      </div>

      <div style={{ marginTop:14 }}>
        <Label>Modo de saída</Label>
        <div style={{ display:'flex', gap:10, marginTop:8 }}>
          {[
            {val:'srt', icon:'📄', label:'Legendas SRT'},
            {val:'tts', icon:'🔊', label:'Áudio dublado'},
            {val:'dubbed_video', icon:'🎬', label:'Vídeo dublado'},
          ].map(m => (
            <button
              key={m.val}
              onClick={() => setMode(m.val)}
              style={{
                flex:1, padding:'10px 8px',
                background: mode===m.val ? 'rgba(245,158,11,0.12)' : '#111',
                border:`1.5px solid ${mode===m.val ? '#f59e0b' : '#2a2a2a'}`,
                borderRadius:8, color: mode===m.val ? '#f59e0b' : '#888',
                fontWeight: mode===m.val ? 600 : 400, fontSize:12,
                transition:'all 200ms',
              }}
            >
              {m.icon} {m.label}
            </button>
          ))}
        </div>
      </div>

      <PrimaryBtn onClick={submit} loading={loading} disabled={!apiKey || !video} color="#f59e0b">
        🌍 TRADUZIR COM IA
      </PrimaryBtn>

      {job && (
        <div style={{ marginTop:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:8 }}>
            {job.status !== 'done' && job.status !== 'error' && <Spinner />}
            <StatusBadge status={job.status} />
            <span style={{ color:'#888', fontSize:13 }}>{job.message}</span>
          </div>
          <ProgressBar value={job.progress || 0} label={job.message} />

          {job.status === 'done' && (
            <div style={{ marginTop:16 }}>
              <SuccessBox>✅ {job.segments} segmentos traduzidos!</SuccessBox>
              <div style={{ display:'flex', flexDirection:'column', gap:8, marginTop:12 }}>
                {job.srt && <DownloadBtn href={`${API}/api/translation/download/srt/${jobId}`} label="Baixar SRT traduzido" />}
                {job.video && <DownloadBtn href={`${API}/api/translation/download/video/${jobId}`} label="Baixar vídeo dublado" />}
              </div>
            </div>
          )}
          {job.status === 'error' && <ErrorBox>{job.message}</ErrorBox>}
        </div>
      )}
    </div>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// TAB: TEMPLATE
// ════════════════════════════════════════════════════════════════════════════
function TabTemplate() {
  const [video, setVideo]       = useState(null)
  const [template, setTemplate] = useState(null)
  const [yPos, setYPos]         = useState(600)
  const [autocrop, setAutocrop] = useState(true)
  const [loading, setLoading]   = useState(false)
  const [jobId, setJobId]       = useState(null)
  const { data: job, start, setData: setJob } = usePoll()

  const submit = async () => {
    if (!video || !template) return
    setLoading(true); setJobId(null); setJob(null)
    const fd = new FormData()
    fd.append('video', video)
    fd.append('template', template)
    fd.append('y_pos', yPos)
    fd.append('autocrop', autocrop)
    try {
      const r = await fetch(`${API}/api/template/render`, { method:'POST', body:fd })
      const { job_id } = await r.json()
      setJobId(job_id)
      start(`${API}/api/template/status/${job_id}`)
    } catch (e) { alert(e.message) }
    finally { setLoading(false) }
  }

  return (
    <div className="fade-up">
      <TabHeader icon="🎨" title="Template / Overlay" subtitle="Sobrepõe um template animado ao teu vídeo com posicionamento preciso." />

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <DropZone label="Vídeo principal" accept="video/*" file={video} onChange={setVideo} icon="🎬" />
        <DropZone label="Template/Overlay" accept="video/*" file={template} onChange={setTemplate} icon="🎭" />
      </div>

      <div style={{ marginTop:16, background:'#111', border:'1px solid #222', borderRadius:10, padding:16 }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:12 }}>
          <Label>Posição vertical (Y): <span style={{ color:'#f59e0b' }}>{yPos}px</span></Label>
          <div style={{ display:'flex', gap:8 }}>
            {[['⬆️ Subir', -50], ['⬇️ Descer', 50], ['Reset', 600]].map(([label, val]) => (
              <button key={label} onClick={() => setYPos(val === 600 ? 600 : yPos + val)}
                style={{
                  background:'#1a1a1a', border:'1px solid #333', borderRadius:6,
                  color:'#ccc', padding:'6px 12px', fontSize:12,
                  transition:'all 200ms',
                }}>
                {label}
              </button>
            ))}
          </div>
        </div>
        <input type="range" min={0} max={1920} value={yPos}
               onChange={e => setYPos(parseInt(e.target.value))}
               style={{ width:'100%' }} />
      </div>

      <label style={{ display:'flex', alignItems:'center', gap:10, marginTop:14, cursor:'pointer' }}>
        <input type="checkbox" checked={autocrop} onChange={e => setAutocrop(e.target.checked)}
               style={{ width:16, height:16, accentColor:'#f59e0b' }} />
        <span style={{ color:'#ccc' }}>🔍 Auto-Crop (remover bordas pretas automaticamente)</span>
      </label>

      <PrimaryBtn onClick={submit} loading={loading} disabled={!video || !template} color="#10b981">
        ✨ RENDERIZAR VÍDEO FINAL
      </PrimaryBtn>

      {job && (
        <div style={{ marginTop:20 }}>
          <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:8 }}>
            {job.status !== 'done' && job.status !== 'error' && <Spinner />}
            <StatusBadge status={job.status} />
            <span style={{ color:'#888', fontSize:13 }}>{job.message}</span>
          </div>
          <ProgressBar value={job.progress || 0} label={job.message} />
          {job.status === 'done' && (
            <div style={{ marginTop:16 }}>
              <SuccessBox>✅ Vídeo renderizado!</SuccessBox>
              <DownloadBtn href={`${API}/api/template/download/${jobId}`} label="Baixar vídeo com template" />
            </div>
          )}
          {job.status === 'error' && <ErrorBox>{job.message}</ErrorBox>}
        </div>
      )}
    </div>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// TAB: CONFIGURAÇÕES
// ════════════════════════════════════════════════════════════════════════════
function TabConfigs({ apiKey, setApiKey }) {
  const [val, setVal] = useState(apiKey)
  const save = () => {
    setApiKey(val)
    localStorage.setItem('gemini_key', val)
    alert('✅ API Key guardada!')
  }

  return (
    <div className="fade-up">
      <TabHeader icon="⚙️" title="Configurações" subtitle="Configura a tua chave de API para usar as funcionalidades de IA." />

      <div style={{ background:'#111', border:'1px solid #2a2a2a', borderRadius:12, padding:24, marginBottom:20 }}>
        <Label>🔑 Gemini API Key</Label>
        <div style={{ position:'relative', marginTop:8 }}>
          <input
            type="password"
            placeholder="AIza..."
            value={val}
            onChange={e => setVal(e.target.value)}
          />
        </div>
        <p style={{ color:'#555', fontSize:12, marginTop:8 }}>
          Obtém a tua key gratuita em{' '}
          <a href="https://aistudio.google.com" target="_blank" rel="noreferrer"
             style={{ color:'#f59e0b', textDecoration:'none' }}>
            aistudio.google.com
          </a>
        </p>
        <PrimaryBtn onClick={save} color="#f59e0b">💾 Guardar</PrimaryBtn>
      </div>

      <div style={{ background:'#111', border:'1px solid #2a2a2a', borderRadius:12, padding:24 }}>
        <Label>📋 Requisitos do sistema</Label>
        <div style={{ marginTop:12, display:'flex', flexDirection:'column', gap:8 }}>
          {[
            ['Python 3.9+', 'Backend FastAPI'],
            ['FFmpeg', 'Necessário no servidor para processamento de vídeo'],
            ['Gemini API', 'Plano gratuito disponível — gemini-1.5-pro'],
            ['Railway', 'Deploy gratuito do backend'],
            ['Vercel', 'Deploy gratuito do frontend'],
          ].map(([name, desc]) => (
            <div key={name} style={{ display:'flex', gap:12, padding:'8px 0', borderBottom:'1px solid #1a1a1a' }}>
              <span style={{ color:'#f59e0b', fontWeight:600, minWidth:100, fontSize:13 }}>{name}</span>
              <span style={{ color:'#666', fontSize:13 }}>{desc}</span>
            </div>
          ))}
        </div>
      </div>

      <div style={{ background:'rgba(245,158,11,0.06)', border:'1px solid rgba(245,158,11,0.15)',
                    borderRadius:12, padding:20, marginTop:20 }}>
        <Label>🚀 Deploy rápido</Label>
        <div style={{ marginTop:10, display:'flex', flexDirection:'column', gap:8 }}>
          <div style={{ color:'#888', fontSize:13 }}>
            <span style={{ color:'#f59e0b' }}>Frontend (Vercel):</span>{' '}
            Importa o repositório → pasta <code style={{ color:'#ccc' }}>frontend/</code>
          </div>
          <div style={{ color:'#888', fontSize:13 }}>
            <span style={{ color:'#f59e0b' }}>Backend (Railway):</span>{' '}
            Importa o repositório → pasta <code style={{ color:'#ccc' }}>backend/</code> → adiciona env var <code style={{ color:'#ccc' }}>FRONTEND_URL</code>
          </div>
          <div style={{ color:'#888', fontSize:13 }}>
            <span style={{ color:'#f59e0b' }}>Vercel env vars:</span>{' '}
            <code style={{ color:'#ccc' }}>VITE_API_URL=https://your-app.railway.app</code>
          </div>
        </div>
      </div>
    </div>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// LAYOUT COMPONENTS
// ════════════════════════════════════════════════════════════════════════════

function TabHeader({ icon, title, subtitle }) {
  return (
    <div style={{ marginBottom:24 }}>
      <h2 style={{
        fontFamily:'var(--font-display)', fontWeight:700, fontSize:22,
        color:'#f0f0f0', display:'flex', alignItems:'center', gap:10, marginBottom:4
      }}>
        <span>{icon}</span>{title}
      </h2>
      <p style={{ color:'#555', fontSize:13 }}>{subtitle}</p>
    </div>
  )
}

function Label({ children, style={} }) {
  return (
    <label style={{ display:'block', fontSize:12, fontWeight:600, letterSpacing:'0.06em',
                    color:'#666', textTransform:'uppercase', ...style }}>
      {children}
    </label>
  )
}

function SuccessBox({ children }) {
  return (
    <div style={{
      background:'rgba(16,185,129,0.08)', border:'1px solid rgba(16,185,129,0.2)',
      borderRadius:8, padding:'12px 16px', color:'#10b981', fontSize:14,
    }}>{children}</div>
  )
}

function ErrorBox({ children }) {
  return (
    <div style={{
      background:'rgba(239,68,68,0.08)', border:'1px solid rgba(239,68,68,0.2)',
      borderRadius:8, padding:'12px 16px', color:'#ef4444', fontSize:14, marginTop:10,
    }}>❌ {children}</div>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// SIDEBAR NAV
// ════════════════════════════════════════════════════════════════════════════

const NAV_ITEMS = [
  { id:'cortes',   icon:'✂️',  label:'Cortes com IA',    color:'#f59e0b' },
  { id:'legendas', icon:'📝',  label:'Legendas Auto',    color:'#8b5cf6' },
  { id:'traducao', icon:'🌍',  label:'Tradução de Áudio',color:'#f59e0b' },
  { id:'template', icon:'🎨',  label:'Template/Overlay', color:'#10b981' },
]

function Sidebar({ active, setActive }) {
  return (
    <aside style={{
      width:220, flexShrink:0,
      background:'#0d0d0d',
      borderRight:'1px solid #1a1a1a',
      display:'flex', flexDirection:'column',
      padding:'24px 12px',
    }}>
      {/* Logo */}
      <div style={{ padding:'0 8px 24px', borderBottom:'1px solid #1a1a1a', marginBottom:20 }}>
        <div style={{ fontSize:28, marginBottom:4 }}>🎬</div>
        <div style={{
          fontFamily:'var(--font-display)', fontWeight:800, fontSize:16,
          color:'#f0f0f0', lineHeight:1.2
        }}>
          Estúdio<br/>
          <span style={{ color:'#f59e0b' }}>Viral Pro</span>
        </div>
        <div style={{ color:'#333', fontSize:11, marginTop:4 }}>Powered by Gemini AI</div>
      </div>

      {/* Nav */}
      <nav style={{ flex:1, display:'flex', flexDirection:'column', gap:4 }}>
        {NAV_ITEMS.map(item => {
          const isActive = active === item.id
          return (
            <button
              key={item.id}
              onClick={() => setActive(item.id)}
              style={{
                display:'flex', alignItems:'center', gap:10,
                padding:'11px 14px', borderRadius:8, width:'100%',
                background: isActive ? `rgba(245,158,11,0.1)` : 'transparent',
                border: isActive ? '1px solid rgba(245,158,11,0.2)' : '1px solid transparent',
                color: isActive ? '#f0f0f0' : '#555',
                fontSize:13, fontWeight: isActive ? 600 : 400,
                textAlign:'left', cursor:'pointer',
                transition:'all 200ms',
              }}
            >
              <span style={{ fontSize:16 }}>{item.icon}</span>
              {item.label}
              {isActive && (
                <div style={{
                  marginLeft:'auto', width:4, height:4, borderRadius:'50%',
                  background:'#f59e0b',
                }}/>
              )}
            </button>
          )
        })}
      </nav>

      {/* Settings */}
      <button
        onClick={() => setActive('configs')}
        style={{
          display:'flex', alignItems:'center', gap:10,
          padding:'11px 14px', borderRadius:8, width:'100%',
          background: active==='configs' ? 'rgba(255,255,255,0.05)' : 'transparent',
          border:'1px solid transparent',
          color: active==='configs' ? '#f0f0f0' : '#444',
          fontSize:13, textAlign:'left', cursor:'pointer',
          transition:'all 200ms',
          marginTop:8, borderTop:'1px solid #1a1a1a', paddingTop:14,
        }}
      >
        <span>⚙️</span> Configurações
      </button>
    </aside>
  )
}


// ════════════════════════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════════════════════════

export default function App() {
  const [active, setActive]   = useState('cortes')
  const [apiKey, setApiKey]   = useState(() => localStorage.getItem('gemini_key') || '')

  const tabContent = {
    cortes:   <TabCortes   apiKey={apiKey} />,
    legendas: <TabLegendas apiKey={apiKey} />,
    traducao: <TabTraducao apiKey={apiKey} />,
    template: <TabTemplate />,
    configs:  <TabConfigs  apiKey={apiKey} setApiKey={setApiKey} />,
  }

  return (
    <div style={{
      display:'flex', height:'100vh', overflow:'hidden',
      background:'var(--bg-base)',
    }}>
      <Sidebar active={active} setActive={setActive} />

      {/* Main content */}
      <main style={{
        flex:1, overflowY:'auto',
        padding:'32px 40px',
        background:'#0d0d0d',
      }}>
        <div style={{ maxWidth:740, margin:'0 auto' }}>
          {tabContent[active]}
        </div>
      </main>
    </div>
  )
}
