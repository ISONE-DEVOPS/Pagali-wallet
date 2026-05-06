// Pagali wallet — small primitives
// All exported to window for cross-script access.

const PAGALI = {
  purple: '#6233A0',
  purple700: '#4F2A82',
  purple300: '#8E6BBF',
  purple50: '#F1ECF8',
  lime: '#B4BF09',
  lime700: '#909808',
  pink: '#FFABAB',
  link: '#0169A6',
  bg: '#E5E5E5',
  surface: '#FFFFFF',
  surfaceDark: '#212020',
  bottomNav: '#424242',
  fgDefault: '#212020',
  fgMuted: '#515565',
  fgSubtle: '#666666',
  fgLight: '#858585',
  success: '#2BD9A8',
  warning: '#FFC857',
  danger: '#E5484D',
};

// ─── Button ─────────────────────────────────────────────────
function PButton({ children, variant = 'primary', icon, onClick, disabled, full, style }) {
  const [pressed, setPressed] = React.useState(false);
  const base = {
    border: 0, cursor: disabled ? 'not-allowed' : 'pointer',
    fontFamily: 'Roboto, sans-serif', fontSize: 16, fontWeight: 500,
    borderRadius: 25, padding: '14px 28px',
    transition: 'all 120ms ease',
    transform: pressed ? 'scale(0.97)' : 'scale(1)',
    opacity: disabled ? 0.45 : 1,
    width: full ? '100%' : 'auto',
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    ...style,
  };
  const variants = {
    primary: { background: PAGALI.purple, color: '#fff', boxShadow: '0 8px 18px rgba(98,51,160,0.32)' },
    lime: { background: PAGALI.lime, color: '#1a1a1a' },
    white: { background: '#fff', color: PAGALI.purple },
    ghost: { background: 'transparent', color: '#fff', border: '2px solid rgba(255,255,255,.6)', padding: '12px 26px' },
    tertiary: { background: PAGALI.purple50, color: PAGALI.purple, boxShadow: 'none' },
    danger: { background: PAGALI.danger, color: '#fff' },
  };
  return (
    <button
      onClick={disabled ? null : onClick}
      onPointerDown={() => !disabled && setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{ ...base, ...variants[variant] }}
    >
      {icon}<span>{children}</span>
    </button>
  );
}

// ─── Field ───────────────────────────────────────────────────
function PField({ label, value, onChange, type = 'text', placeholder, prefix, autoFocus }) {
  const [focus, setFocus] = React.useState(false);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && <label style={{ fontSize: 13, fontWeight: 500, color: PAGALI.fgMuted }}>{label}</label>}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        padding: '14px 16px',
        border: `1.5px solid ${focus ? PAGALI.purple : '#00000018'}`,
        background: '#fff', borderRadius: 14, transition: 'border-color 150ms',
      }}>
        {prefix && <span style={{ color: PAGALI.fgLight, fontSize: 15 }}>{prefix}</span>}
        <input
          type={type} value={value} onChange={e => onChange?.(e.target.value)}
          placeholder={placeholder} autoFocus={autoFocus}
          onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
          style={{
            flex: 1, border: 0, outline: 0, background: 'transparent',
            font: '400 16px Roboto, sans-serif', color: PAGALI.fgDefault, width: '100%',
          }}
        />
      </div>
    </div>
  );
}

// ─── Card ────────────────────────────────────────────────────
function PCard({ children, style, padding = 18 }) {
  return (
    <div style={{
      background: '#fff', borderRadius: 18, padding,
      boxShadow: '0 4px 12px rgba(40,20,80,0.08)',
      ...style,
    }}>{children}</div>
  );
}

// ─── Avatar (initials) ───────────────────────────────────────
function PAvatar({ name, size = 42, bg = PAGALI.purple50, color = PAGALI.purple }) {
  const initials = (name || '?').split(' ').map(s => s[0]).slice(0, 2).join('').toUpperCase();
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%', background: bg, color,
      display: 'grid', placeItems: 'center',
      fontSize: size * 0.4, fontWeight: 700, fontFamily: 'Roboto, sans-serif',
      flexShrink: 0,
    }}>{initials}</div>
  );
}

// ─── Currency formatter (CVE) ────────────────────────────────
function fmtCVE(n) {
  return new Intl.NumberFormat('pt-CV', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    .format(n).replace(',', ',');
}

// ─── Lucide icon helper (CDN SVG path data baked in for the icons we use) ─
const ICONS = {
  home: 'M3 9.5L12 3l9 6.5V20a1 1 0 01-1 1h-5v-7h-6v7H4a1 1 0 01-1-1V9.5z',
  history: 'M3 12a9 9 0 109-9 9 9 0 00-6.36 2.64L3 8M3 3v5h5M12 7v5l3 2',
  qr: 'M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h3M14 17v4M17 14v3M21 14v7M14 21h7',
  cards: 'M2 7h20v12a2 2 0 01-2 2H4a2 2 0 01-2-2V7zM2 7V5a2 2 0 012-2h16a2 2 0 012 2v2M6 16h4',
  more: 'M3 6h18M3 12h18M3 18h18',
  arrowRight: 'M5 12h14M13 5l7 7-7 7',
  arrowLeft: 'M19 12H5M11 5l-7 7 7 7',
  arrowUp: 'M12 19V5M5 12l7-7 7 7',
  arrowDown: 'M12 5v14M19 12l-7 7-7-7',
  arrowSwap: 'M17 3l4 4-4 4M3 7h18M7 21l-4-4 4-4M3 17h18',
  plus: 'M12 5v14M5 12h14',
  receipt: 'M4 4v17l3-2 3 2 3-2 3 2 3-2V4zM8 8h8M8 12h8M8 16h5',
  wallet: 'M3 7h16a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V7zM3 7V6a2 2 0 012-2h11M17 13h2',
  user: 'M20 21a8 8 0 10-16 0M16 7a4 4 0 11-8 0 4 4 0 018 0',
  bell: 'M6 8a6 6 0 1112 0c0 7 3 8 3 8H3s3-1 3-8M14 21a2 2 0 01-4 0',
  eye: 'M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7zM12 15a3 3 0 100-6 3 3 0 000 6z',
  eyeOff: 'M9.88 9.88a3 3 0 004.24 4.24M10.7 5.05A10.5 10.5 0 0112 5c6.5 0 10 7 10 7a13.4 13.4 0 01-1.67 2.68M6.61 6.61A13.5 13.5 0 002 12s3.5 7 10 7a10.5 10.5 0 005.39-1.61M2 2l20 20',
  check: 'M5 12l5 5L20 7',
  close: 'M6 6l12 12M18 6l-12 12',
  copy: 'M9 9h11a2 2 0 012 2v11a2 2 0 01-2 2H9a2 2 0 01-2-2v-1M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1',
  share: 'M4 12v7a2 2 0 002 2h12a2 2 0 002-2v-7M16 6l-4-4-4 4M12 2v13',
  search: 'M11 19a8 8 0 100-16 8 8 0 000 16zM21 21l-4.35-4.35',
  bolt: 'M13 2L3 14h7l-1 8 10-12h-7l1-8z',
  phone: 'M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z',
  zap: 'M13 2L3 14h7l-1 8 10-12h-7l1-8z',
  chevronRight: 'M9 6l6 6-6 6',
  shield: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
};

function Icon({ name, size = 22, stroke = 'currentColor', fill = 'none', strokeWidth = 1.75 }) {
  const d = ICONS[name];
  if (!d) return null;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
      strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round">
      <path d={d} />
    </svg>
  );
}

// ─── ListRow ─────────────────────────────────────────────────
function PListRow({ leading, title, subtitle, trailing, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: 'grid', gridTemplateColumns: 'auto 1fr auto', gap: 14,
      alignItems: 'center', padding: '14px 16px', cursor: onClick ? 'pointer' : 'default',
      borderBottom: '1px solid rgba(0,0,0,.06)',
    }}>
      {leading}
      <div>
        <div style={{ fontSize: 15, fontWeight: 500, color: PAGALI.fgDefault }}>{title}</div>
        {subtitle && <div style={{ fontSize: 12, color: PAGALI.fgLight, marginTop: 2 }}>{subtitle}</div>}
      </div>
      {trailing}
    </div>
  );
}

// ─── Bottom Nav ──────────────────────────────────────────────
function BottomNav({ active, onChange, onQR }) {
  const items = [
    { id: 'home', label: 'Início', icon: 'home' },
    { id: 'history', label: 'Histórico', icon: 'history' },
    { id: 'qr', label: 'QR', icon: 'qr', fab: true },
    { id: 'cards', label: 'Cartões', icon: 'cards' },
    { id: 'more', label: 'Mais', icon: 'more' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      background: PAGALI.bottomNav, padding: '10px 8px 14px',
      display: 'flex', justifyContent: 'space-around', alignItems: 'center',
      borderTopLeftRadius: 20, borderTopRightRadius: 20,
    }}>
      {items.map(it => it.fab ? (
        <button key={it.id} onClick={() => onQR?.()} style={{
          background: PAGALI.lime, color: '#1a1a1a', border: 0,
          width: 56, height: 56, borderRadius: '50%', display: 'grid', placeItems: 'center',
          marginTop: -22, boxShadow: '0 8px 18px rgba(180,191,9,.5)', cursor: 'pointer',
        }}>
          <Icon name="qr" size={26} stroke="#1a1a1a" strokeWidth={2} />
        </button>
      ) : (
        <button key={it.id} onClick={() => onChange?.(it.id)} style={{
          background: 'transparent', border: 0, color: '#fff',
          opacity: active === it.id ? 1 : 0.55,
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
          padding: '6px 12px', cursor: 'pointer',
          fontFamily: 'Roboto, sans-serif', fontSize: 11,
        }}>
          <Icon name={it.icon} size={22} />
          {it.label}
        </button>
      ))}
    </div>
  );
}

// ─── App Bar ─────────────────────────────────────────────────
function AppBar({ title, onBack, action, dark }) {
  const fg = dark ? '#fff' : PAGALI.fgDefault;
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '40px 1fr 40px', alignItems: 'center',
      padding: '10px 12px', minHeight: 52, color: fg,
    }}>
      {onBack ? (
        <button onClick={onBack} style={{ background: 'transparent', border: 0, color: fg, cursor: 'pointer', padding: 6, display: 'grid', placeItems: 'center' }}>
          <Icon name="arrowLeft" size={22} />
        </button>
      ) : <div />}
      <div style={{ textAlign: 'center', fontSize: 17, fontWeight: 500 }}>{title}</div>
      <div style={{ textAlign: 'right' }}>{action}</div>
    </div>
  );
}

Object.assign(window, {
  PAGALI, PButton, PField, PCard, PAvatar, fmtCVE, Icon, PListRow, BottomNav, AppBar,
});
