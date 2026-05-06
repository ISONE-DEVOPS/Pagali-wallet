// Pagali wallet screens — each is a function that renders the inside of the phone.

// ─── Onboarding ──────────────────────────────────────────────
function OnboardScreen({ onDone }) {
  const [page, setPage] = React.useState(0);
  const pages = [
    { title: 'Fazer Pagamentos', subtitle: 'Pague todas as suas contas em um único local. Sem fila e sem stress.', img: '../../assets/images/onboard1.png' },
    { title: 'Segurança e Confiança', subtitle: 'Monitoriza todas as suas transações.', img: '../../assets/images/onboard2.png' },
    { title: 'Guarde os seus trocos', subtitle: 'Poupa sem perceber, todos os dias.', img: '../../assets/images/onboard3.png' },
    { title: 'Investimentos', subtitle: 'Investe naquilo que acredita e confia.', img: '../../assets/images/onboard4.png' },
    { title: 'Emite Faturas', subtitle: 'Faça faturas para os seus clientes e receba logo.', img: '../../assets/images/onboard5.png' },
  ];
  const p = pages[page];
  const isLast = page === pages.length - 1;
  return (
    <div style={{ background: PAGALI.purple, height: '100%', display: 'flex', flexDirection: 'column', color: '#fff', padding: '16px 24px 28px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <img src="../../assets/images/pagali.png" style={{ height: 28 }} alt="Pagali" />
        {!isLast && <button onClick={onDone} style={{ background: 'transparent', border: 0, color: '#fff', opacity: .7, fontFamily: 'Roboto', fontSize: 14, cursor: 'pointer' }}>Saltar</button>}
      </div>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px 0' }}>
        <img src={p.img} style={{ width: '78%', maxHeight: 280, objectFit: 'contain', filter: 'drop-shadow(0 12px 24px rgba(0,0,0,.18))' }} alt="" />
      </div>
      <div style={{ textAlign: 'center', marginBottom: 18 }}>
        <div style={{ fontSize: 24, fontWeight: 500, lineHeight: 1.1, marginBottom: 12 }}>{p.title}</div>
        <div style={{ fontSize: 15, lineHeight: 1.5, opacity: .9, padding: '0 8px' }}>{p.subtitle}</div>
      </div>
      <div style={{ display: 'flex', gap: 6, justifyContent: 'center', marginBottom: 22 }}>
        {pages.map((_, i) => (
          <span key={i} style={{
            width: i === page ? 22 : 8, height: 8, borderRadius: 6,
            background: i === page ? '#fff' : 'rgba(255,255,255,.35)',
            transition: 'all 200ms ease',
          }} />
        ))}
      </div>
      <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
        <PButton variant="lime" onClick={() => isLast ? onDone() : setPage(page + 1)}>
          {isLast ? 'Iniciar' : 'Próximo'}
        </PButton>
      </div>
    </div>
  );
}

// ─── Login (PIN) ─────────────────────────────────────────────
function LoginScreen({ onDone }) {
  const [pin, setPin] = React.useState('');
  React.useEffect(() => { if (pin.length === 4) setTimeout(onDone, 250); }, [pin]);
  const press = (k) => { if (k === 'del') setPin(pin.slice(0, -1)); else if (pin.length < 4) setPin(pin + k); };
  return (
    <div style={{ background: PAGALI.purple, height: '100%', display: 'flex', flexDirection: 'column', color: '#fff', padding: '24px' }}>
      <img src="../../assets/images/pagali.png" style={{ height: 26, alignSelf: 'flex-start', marginTop: 12 }} alt="Pagali" />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', gap: 24 }}>
        <PAvatar name="Ana Silva" size={72} bg="rgba(255,255,255,.18)" color="#fff" />
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 22, fontWeight: 500 }}>Olá, Ana</div>
          <div style={{ fontSize: 14, opacity: .8, marginTop: 4 }}>Insira o seu PIN para entrar</div>
        </div>
        <div style={{ display: 'flex', gap: 14 }}>
          {[0, 1, 2, 3].map(i => (
            <span key={i} style={{
              width: 14, height: 14, borderRadius: '50%',
              background: pin.length > i ? '#fff' : 'transparent',
              border: '2px solid rgba(255,255,255,.6)',
            }} />
          ))}
        </div>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8 }}>
        {['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'].map((k, i) => (
          k === '' ? <div key={i} /> :
            <button key={i} onClick={() => press(k)} style={{
              background: 'rgba(255,255,255,.12)', border: 0, color: '#fff',
              borderRadius: 16, padding: '16px 0', fontSize: 22, fontWeight: 500,
              cursor: 'pointer', fontFamily: 'Roboto',
            }}>{k === 'del' ? '⌫' : k}</button>
        ))}
      </div>
    </div>
  );
}

// ─── Home ────────────────────────────────────────────────────
function HomeScreen({ onAction, onTx }) {
  const [hide, setHide] = React.useState(false);
  const txs = [
    { type: 'in', name: 'João Monteiro', meta: 'Recebido · há 2 min', amt: 1500 },
    { type: 'qr', name: 'Restaurante Sodade', meta: 'QR · Mindelo', amt: -850 },
    { type: 'out', name: 'Maria Tavares', meta: 'Enviado · ontem', amt: -2000 },
    { type: 'in', name: 'Carlos Évora', meta: 'Recebido · 2 dias', amt: 5000 },
  ];
  return (
    <div style={{ background: PAGALI.bg, height: '100%', overflow: 'auto', paddingBottom: 100 }}>
      {/* Hero */}
      <div style={{ background: PAGALI.purple, padding: '14px 20px 28px', borderBottomLeftRadius: 28, borderBottomRightRadius: 28 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', color: '#fff' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <PAvatar name="Ana Silva" size={36} bg="rgba(255,255,255,.18)" color="#fff" />
            <div>
              <div style={{ fontSize: 12, opacity: .75 }}>Bem-vinda</div>
              <div style={{ fontSize: 15, fontWeight: 500 }}>Ana Silva</div>
            </div>
          </div>
          <button style={{ background: 'rgba(255,255,255,.12)', border: 0, color: '#fff', width: 38, height: 38, borderRadius: '50%', display: 'grid', placeItems: 'center', cursor: 'pointer' }}>
            <Icon name="bell" size={18} />
          </button>
        </div>
        <div style={{ marginTop: 22, color: '#fff' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ fontSize: 12, textTransform: 'uppercase', letterSpacing: '.1em', opacity: .8 }}>Saldo disponível</span>
            <button onClick={() => setHide(!hide)} style={{ background: 'transparent', border: 0, color: '#fff', cursor: 'pointer', padding: 0, opacity: .8 }}>
              <Icon name={hide ? 'eyeOff' : 'eye'} size={16} />
            </button>
          </div>
          <div style={{ fontSize: 36, fontWeight: 700, letterSpacing: '-0.02em', marginTop: 4, fontFeatureSettings: "'tnum'" }}>
            {hide ? '••••••' : fmtCVE(5320)} <span style={{ fontSize: 13, opacity: .8, fontWeight: 500 }}>CVE</span>
          </div>
          <div style={{ fontSize: 12, opacity: .75, marginTop: 2 }}>•••• 8821 · Banco de Cabo Verde</div>
        </div>
      </div>
      {/* Quick actions */}
      <div style={{ padding: '0 20px', marginTop: -22 }}>
        <PCard padding={14}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 6 }}>
            {[
              { i: 'arrowUp', l: 'Enviar', a: 'send' },
              { i: 'arrowDown', l: 'Pedir', a: 'request' },
              { i: 'qr', l: 'Pagar QR', a: 'qr' },
              { i: 'plus', l: 'Carregar', a: 'topup' },
            ].map(b => (
              <button key={b.a} onClick={() => onAction?.(b.a)} style={{
                background: 'transparent', border: 0, cursor: 'pointer',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
                padding: '8px 4px', fontFamily: 'Roboto',
              }}>
                <span style={{ width: 44, height: 44, borderRadius: '50%', background: PAGALI.purple50, color: PAGALI.purple, display: 'grid', placeItems: 'center' }}>
                  <Icon name={b.i} size={20} />
                </span>
                <span style={{ fontSize: 12, color: PAGALI.fgDefault, fontWeight: 500 }}>{b.l}</span>
              </button>
            ))}
          </div>
        </PCard>
      </div>
      {/* Section: Faturas */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{ fontSize: 13, fontWeight: 500, textTransform: 'uppercase', letterSpacing: '.06em', color: PAGALI.fgMuted, marginBottom: 10 }}>Pagar contas</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 10 }}>
          {[
            { l: 'Electra', s: 'Luz', c: '#FFE9B0', t: '#8A6100' },
            { l: 'CV Telecom', s: 'Internet', c: '#DDF2FF', t: '#0169A6' },
            { l: 'IGT', s: 'Impostos', c: '#F1ECF8', t: PAGALI.purple },
          ].map(b => (
            <PCard key={b.l} padding={12} style={{ textAlign: 'center' }}>
              <div style={{ width: 42, height: 42, margin: '0 auto', borderRadius: 12, background: b.c, color: b.t, display: 'grid', placeItems: 'center', fontWeight: 700, fontSize: 16 }}>{b.l[0]}</div>
              <div style={{ fontSize: 13, fontWeight: 500, marginTop: 8, color: PAGALI.fgDefault }}>{b.l}</div>
              <div style={{ fontSize: 11, color: PAGALI.fgLight }}>{b.s}</div>
            </PCard>
          ))}
        </div>
      </div>
      {/* Section: Recent */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
          <div style={{ fontSize: 13, fontWeight: 500, textTransform: 'uppercase', letterSpacing: '.06em', color: PAGALI.fgMuted }}>Movimentos recentes</div>
          <button style={{ background: 'transparent', border: 0, color: PAGALI.purple, fontSize: 13, fontWeight: 500, cursor: 'pointer' }}>Ver tudo</button>
        </div>
        <PCard padding={0}>
          {txs.map((t, i) => {
            const cfg = t.type === 'in'
              ? { bg: '#E0F8EF', fg: '#0E8B66', ic: 'arrowDown' }
              : t.type === 'qr'
                ? { bg: '#FFF1D8', fg: '#A66800', ic: 'qr' }
                : { bg: PAGALI.purple50, fg: PAGALI.purple, ic: 'arrowUp' };
            return (
              <PListRow
                key={i}
                onClick={() => onTx?.(t)}
                leading={<div style={{ width: 42, height: 42, borderRadius: '50%', background: cfg.bg, color: cfg.fg, display: 'grid', placeItems: 'center' }}><Icon name={cfg.ic} size={18} /></div>}
                title={t.name}
                subtitle={t.meta}
                trailing={
                  <div style={{ fontSize: 15, fontWeight: 700, color: t.amt > 0 ? '#0E8B66' : PAGALI.fgDefault, fontFeatureSettings: "'tnum'" }}>
                    {t.amt > 0 ? '+' : '−'}{fmtCVE(Math.abs(t.amt))}
                  </div>
                }
              />
            );
          })}
        </PCard>
      </div>
    </div>
  );
}

// ─── Send (P2P) ──────────────────────────────────────────────
function SendScreen({ onBack, onContinue }) {
  const [step, setStep] = React.useState(0);
  const [phone, setPhone] = React.useState('+238 ');
  const [amount, setAmount] = React.useState('2500');
  const [note, setNote] = React.useState('');
  const recents = [
    { name: 'João Monteiro', phone: '+238 989 0002' },
    { name: 'Maria Tavares', phone: '+238 989 0003' },
    { name: 'Carlos Évora', phone: '+238 989 0004' },
  ];
  return (
    <div style={{ background: PAGALI.bg, height: '100%', display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Enviar dinheiro" onBack={onBack} />
      <div style={{ flex: 1, padding: '8px 20px 20px', overflow: 'auto' }}>
        {step === 0 && (
          <>
            <PField label="Para (número de telemóvel)" value={phone} onChange={setPhone} prefix={<Icon name="phone" size={16} />} />
            <div style={{ fontSize: 12, fontWeight: 500, textTransform: 'uppercase', letterSpacing: '.06em', color: PAGALI.fgMuted, margin: '20px 0 10px' }}>Recentes</div>
            <PCard padding={0}>
              {recents.map(r => (
                <PListRow
                  key={r.phone}
                  onClick={() => { setPhone(r.phone); setStep(1); }}
                  leading={<PAvatar name={r.name} />}
                  title={r.name}
                  subtitle={r.phone}
                  trailing={<Icon name="chevronRight" size={18} stroke={PAGALI.fgLight} />}
                />
              ))}
            </PCard>
            <div style={{ marginTop: 24 }}>
              <PButton full onClick={() => setStep(1)}>Continuar</PButton>
            </div>
          </>
        )}
        {step === 1 && (
          <>
            <PCard style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <PAvatar name="João Monteiro" />
              <div>
                <div style={{ fontWeight: 500 }}>João Monteiro</div>
                <div style={{ fontSize: 12, color: PAGALI.fgLight }}>{phone} · BCVCVCV</div>
              </div>
            </PCard>
            <div style={{ marginTop: 16, background: PAGALI.purple50, borderRadius: 18, padding: '24px 18px', textAlign: 'center' }}>
              <div style={{ fontSize: 12, textTransform: 'uppercase', letterSpacing: '.1em', color: PAGALI.purple, fontWeight: 500 }}>Montante</div>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 10, marginTop: 8 }}>
                <input value={amount} onChange={e => setAmount(e.target.value.replace(/\D/g, ''))}
                  style={{ background: 'transparent', border: 0, outline: 0, fontFamily: 'Roboto', fontSize: 48, fontWeight: 700, color: PAGALI.purple, width: 180, textAlign: 'center', fontFeatureSettings: "'tnum'" }} />
                <span style={{ fontSize: 16, fontWeight: 500, color: PAGALI.purple }}>CVE</span>
              </div>
              <div style={{ fontSize: 12, color: PAGALI.purple, opacity: .7, marginTop: 6 }}>Disponível: {fmtCVE(5320)} CVE</div>
            </div>
            <div style={{ marginTop: 16 }}>
              <PField label="Nota (opcional)" value={note} onChange={setNote} placeholder="Almoço, renda..." />
            </div>
            <div style={{ marginTop: 24 }}>
              <PButton full onClick={() => onContinue?.({ phone, amount: Number(amount), note, name: 'João Monteiro' })}>Confirmar e enviar</PButton>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

// ─── Confirm (Mojaloop "acceptParty / acceptQuote") ──────────
function ConfirmScreen({ tx, onBack, onDone }) {
  return (
    <div style={{ background: PAGALI.bg, height: '100%', display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Confirmar" onBack={onBack} />
      <div style={{ flex: 1, padding: '20px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ textAlign: 'center', padding: '20px 0' }}>
          <PAvatar name={tx.name} size={72} />
          <div style={{ fontSize: 14, color: PAGALI.fgLight, marginTop: 14 }}>A enviar a</div>
          <div style={{ fontSize: 20, fontWeight: 500, marginTop: 4 }}>{tx.name}</div>
          <div style={{ fontSize: 13, color: PAGALI.fgLight, marginTop: 2 }}>{tx.phone}</div>
        </div>
        <PCard>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0' }}>
            <span style={{ color: PAGALI.fgLight, fontSize: 14 }}>Montante</span>
            <span style={{ fontWeight: 500, fontFeatureSettings: "'tnum'" }}>{fmtCVE(tx.amount)} CVE</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0' }}>
            <span style={{ color: PAGALI.fgLight, fontSize: 14 }}>Taxa</span>
            <span style={{ fontWeight: 500 }}>0,00 CVE</span>
          </div>
          <div style={{ height: 1, background: '#00000010', margin: '8px 0' }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0' }}>
            <span style={{ fontSize: 14 }}>Total</span>
            <span style={{ fontWeight: 700, color: PAGALI.purple, fontFeatureSettings: "'tnum'" }}>{fmtCVE(tx.amount)} CVE</span>
          </div>
          {tx.note && <>
            <div style={{ height: 1, background: '#00000010', margin: '8px 0' }} />
            <div style={{ fontSize: 13, color: PAGALI.fgLight }}>Nota</div>
            <div style={{ fontSize: 14, marginTop: 2 }}>{tx.note}</div>
          </>}
        </PCard>
        <div style={{ flex: 1 }} />
        <PButton full onClick={onDone}>Pagar agora</PButton>
        <div style={{ height: 12 }} />
        <PButton full variant="tertiary" onClick={onBack}>Cancelar</PButton>
      </div>
    </div>
  );
}

// ─── Success ─────────────────────────────────────────────────
function SuccessScreen({ tx, onDone }) {
  return (
    <div style={{ background: '#fff', height: '100%', display: 'flex', flexDirection: 'column', padding: 24 }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', gap: 16 }}>
        <div style={{ width: 96, height: 96, borderRadius: '50%', background: '#E0F8EF', display: 'grid', placeItems: 'center', color: '#0E8B66' }}>
          <Icon name="check" size={48} strokeWidth={2.5} />
        </div>
        <div style={{ fontSize: 22, fontWeight: 500, marginTop: 8 }}>Pagamento concluído</div>
        <div style={{ fontSize: 14, color: PAGALI.fgLight, maxWidth: 260 }}>
          {fmtCVE(tx.amount)} CVE enviados a {tx.name}.
        </div>
        <div style={{ fontSize: 11, color: PAGALI.fgLight, fontFamily: 'ui-monospace, Menlo, monospace', marginTop: 6 }}>
          ID: T-{Math.random().toString(36).slice(2, 10).toUpperCase()}
        </div>
      </div>
      <div style={{ display: 'flex', gap: 10 }}>
        <PButton variant="tertiary" full icon={<Icon name="share" size={16} />}>Partilhar</PButton>
        <PButton variant="tertiary" full icon={<Icon name="receipt" size={16} />}>Recibo</PButton>
      </div>
      <div style={{ height: 10 }} />
      <PButton full onClick={onDone}>Voltar ao início</PButton>
    </div>
  );
}

// ─── QR Pay (P2M) ────────────────────────────────────────────
function QRScreen({ onBack, onContinue }) {
  return (
    <div style={{ background: '#000', height: '100%', display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Pagar com QR" dark onBack={onBack} />
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(circle at 50% 45%, rgba(98,51,160,.4), transparent 60%), repeating-linear-gradient(45deg, #1a1a1a 0 8px, #0f0f0f 8px 16px)' }} />
        {/* viewfinder */}
        <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%,-55%)', width: 220, height: 220 }}>
          {[
            { t: 0, l: 0, br: '0 0 0 4px' },
            { t: 0, r: 0, br: '0 0 4px 0' },
            { b: 0, l: 0, br: '0 4px 0 0' },
            { b: 0, r: 0, br: '4px 0 0 0' },
          ].map((c, i) => (
            <span key={i} style={{
              position: 'absolute',
              top: c.t, left: c.l, right: c.r, bottom: c.b,
              width: 36, height: 36,
              borderTop: c.t === 0 ? `4px solid ${PAGALI.lime}` : 'none',
              borderBottom: c.b === 0 ? `4px solid ${PAGALI.lime}` : 'none',
              borderLeft: c.l === 0 ? `4px solid ${PAGALI.lime}` : 'none',
              borderRight: c.r === 0 ? `4px solid ${PAGALI.lime}` : 'none',
            }} />
          ))}
          {/* fake QR */}
          <div style={{ position: 'absolute', inset: 30, background: '#fff', borderRadius: 8, display: 'grid', gridTemplateColumns: 'repeat(11,1fr)', gridTemplateRows: 'repeat(11,1fr)', padding: 8, gap: 1 }}>
            {Array.from({ length: 121 }).map((_, i) => (
              <span key={i} style={{ background: ((i * 7 + ((i / 11) | 0) * 3) % 5 < 2 || [0, 1, 2, 8, 9, 10, 110, 111, 112, 118, 119, 120].includes(i)) ? '#000' : 'transparent' }} />
            ))}
          </div>
        </div>
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, padding: '24px 20px', color: '#fff', textAlign: 'center' }}>
          <div style={{ fontSize: 13, opacity: .7 }}>Aponte para o código do comerciante</div>
          <div style={{ height: 14 }} />
          <PButton variant="lime" onClick={() => onContinue?.({
            merchantId: 'MER002', name: 'Restaurante Sodade', city: 'Mindelo', mcc: '5812', amount: 850,
          })}>Detectado · Restaurante Sodade</PButton>
        </div>
      </div>
    </div>
  );
}

// ─── Merchant pay confirm (P2M) ──────────────────────────────
function MerchantPayScreen({ merchant, onBack, onDone }) {
  const [amount, setAmount] = React.useState(String(merchant.amount || ''));
  return (
    <div style={{ background: PAGALI.bg, height: '100%', display: 'flex', flexDirection: 'column' }}>
      <AppBar title="Pagar comerciante" onBack={onBack} />
      <div style={{ flex: 1, padding: '8px 20px 20px', overflow: 'auto' }}>
        <PCard>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 48, height: 48, borderRadius: 14, background: PAGALI.lime, color: '#1a1a1a', display: 'grid', placeItems: 'center', fontWeight: 700, fontSize: 20 }}>R</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 500 }}>{merchant.name}</div>
              <div style={{ fontSize: 12, color: PAGALI.fgLight }}>{merchant.city} · MCC {merchant.mcc}</div>
            </div>
            <span style={{ fontSize: 11, padding: '4px 8px', borderRadius: 999, background: '#E0F8EF', color: '#0E8B66', fontWeight: 500 }}>
              <Icon name="shield" size={12} /> Verificado
            </span>
          </div>
        </PCard>
        <div style={{ marginTop: 16, background: PAGALI.purple, color: '#fff', borderRadius: 18, padding: '24px 18px', textAlign: 'center' }}>
          <div style={{ fontSize: 12, textTransform: 'uppercase', letterSpacing: '.1em', opacity: .85, fontWeight: 500 }}>Montante</div>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'center', gap: 10, marginTop: 8 }}>
            <input value={amount} onChange={e => setAmount(e.target.value.replace(/\D/g, ''))}
              style={{ background: 'transparent', border: 0, outline: 0, fontFamily: 'Roboto', fontSize: 48, fontWeight: 700, color: '#fff', width: 180, textAlign: 'center', fontFeatureSettings: "'tnum'" }} />
            <span style={{ fontSize: 16, fontWeight: 500, opacity: .85 }}>CVE</span>
          </div>
        </div>
        <div style={{ height: 24 }} />
        <PButton full onClick={() => onDone?.({ name: merchant.name, phone: merchant.city, amount: Number(amount), note: 'Pagali P2M payment' })}>Pagar agora</PButton>
      </div>
    </div>
  );
}

Object.assign(window, {
  OnboardScreen, LoginScreen, HomeScreen, SendScreen, ConfirmScreen, SuccessScreen, QRScreen, MerchantPayScreen,
});
