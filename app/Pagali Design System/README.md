# Pagali Design System

> Design system for **Pagali** — a P2P + P2M digital wallet for Cabo Verde (Cape Verde). Pagali ("pay there", from Crioulo) is positioned as a financial services gateway that lets people pay bills, transfer money to friends, and pay merchants by QR — all in one app.

## Sources

This system was reverse-engineered from two repos provided by the user:

| Source | Role | Notes |
|---|---|---|
| `ISONE-DEVOPS/Pagali-wallet` | **Backend** | Mojaloop-style core: `core-connector` (P2P/P2M payer/payee + transfer phases), `merchant-registry`, `qr-service` (EMVCo-style TLV QR generator, scheme GUID `com.pagali.p2m`, currency CVE / ISO 4217 `132`, country `CV`). No UI here. |
| `ISONE-DEVOPS/pagali-app` | **Mobile app (Flutter)** | The visual reference. Contains `lib/Theme/colors.dart`, `lib/Theme/style.dart`, onboarding screens, and `assets/images/*` (logo + illustrations). Currently only a splash + 5-page onboarding flow are implemented — wallet screens have NOT been built yet. |

The user's brief: **"create the UI/UX in Flutter for the P2P and P2M wallet."** This design system is the visual + interaction foundation for that work, mocked here in HTML/React for review before Flutter implementation.

## Product context

Pagali is a **wallet** that supports two transaction patterns, both wired up server-side:

- **P2P** — person-to-person transfers between MSISDN-identified accounts (e.g. Cape Verdean mobile numbers, FSP IDs like `BCVCVCV`, `CAIXACV` — the Banco de Cabo Verde and Caixa Económica swift codes).
- **P2M** — person-to-merchant payment via QR code. Merchants are identified by `merchantId` + `fspId` and have an MCC. Sample merchants in code: *Mercado Sucupira* (Praia), *Restaurante Sodade* (Mindelo).

Currency is **Cape Verdean Escudo (CVE / 132)**. Transfer flow is the Mojaloop 3-phase: discovery → agreement (quote) → transfer (debit + credit).

The brand also lives in a wider ISONE-DEVOPS portfolio (Pagali Events, Pagali Tickets, Pagali Shop, Pagali Delivery, Pagali Scanner) — this system focuses on the **wallet** specifically, but is compatible with the wider Pagali brand.

---

## Index — what's in this folder

```
README.md                  ← you are here
SKILL.md                   ← agent skill manifest (cross-compatible with Claude Code)
colors_and_type.css        ← all CSS variables: colors, type, spacing, radii, shadows
fonts/                     ← (Roboto loaded from Google Fonts CDN — see CSS)
assets/                    ← logo, splash backgrounds, onboarding illustrations
preview/                   ← design-system tab cards (one HTML per swatch/specimen)
ui_kits/
  pagali-wallet/           ← React+JSX recreation of the mobile wallet
    index.html             ← interactive click-thru: onboarding → home → P2P → P2M QR
    components/*.jsx       ← Screen, Button, Field, Card, BottomNav, etc.
slides/                    ← (none — no sample deck was provided)
```

---

## Content fundamentals

**Language: Portuguese (Cape Verdean).** All in-product copy is European Portuguese with Cape Verdean conventions. Examples lifted directly from the onboarding flow:

- "Fazer Pagamentos" — make payments
- "Pague todas as suas contas em um único local. Sem fila e sem Stress." — pay all your bills in one place, no queue and no stress
- "Segurança e Confiança" — security and trust
- "Monitoriza todas as suas transações" — monitor all your transactions
- "Guarde os seus trocos" — save your spare change
- "Investimentos — Investe naquilo que acredita e confia" — invest in what you believe in and trust
- "Emite Faturas — Faça faturas para os seus clientes e receba logo" — issue invoices, get paid right away
- Buttons: **Saltar** (skip), **Próximo** (next), **Iniciar** (start)

**Tone.**
- **Formal-friendly second person.** Uses *o seu / a sua* (formal "your"), occasionally drops to imperative for actions (*Pague*, *Faça*, *Investe*). Never English; never overly casual or slangy.
- **Short, declarative.** Two- or three-word headers + one supporting sentence. No marketing fluff, no exclamation points except in moments of confirmation.
- **Confidence + reassurance.** The recurring promise is *no friction* — "sem fila e sem Stress" — and *control* — "monitoriza todas as suas transações". Money apps in this market live or die on trust; copy should always reinforce that the user is in control.
- **Casing.** Title Case for screen titles ("Fazer Pagamentos"), Sentence case for body. Buttons are Title Case too.
- **No emoji** in product copy. The brand carries warmth through illustration, not emoji.

---

## Visual foundations

### Color
The brand is anchored on **deep purple `#6233A0`** (`mainColor` in `colors.dart`). It's used as full-bleed brand backgrounds (splash, onboarding) and as the primary accent. The secondary CTA color is an unexpected, high-energy **lime `#B4BF09`** — used on rounded pill buttons on top of purple. A soft **pink `#FFABAB`** (`subscribeColor`) appears as a tertiary tint. Neutrals are a warm light-gray scaffold `#E5E5E5` with white surfaces and a dark text well at `#212020`.

The lime/purple pairing is the brand's signature — it reads as confident and a bit playful, distinct from the navy-blue conservatism of every other African fintech.

### Type
**Roboto.** That's the only family declared in the Flutter source (`fontFamily: 'Roboto'`), and it's free + ubiquitous. We use it everywhere — headings, body, numerals — at weights 400 / 500 / 700. Onboarding titles are 24px regular with `height: 1` (very tight), subtitles 16px regular. Letter-spacing stays at 0; we don't track headers wide.

> **Font note:** Roboto is loaded from Google Fonts CDN in `colors_and_type.css`. If the team wants a more distinctive type system later, the obvious upgrade path is a custom display face for amounts/headlines while keeping Roboto for body — flag this with the user.

### Spacing & layout
4-point grid. Onboarding uses generous vertical rhythm with the illustration anchored mid-screen. Screen padding is 24px (`s-6`). Bottom-nav-style action rows sit fixed at the bottom edge.

### Backgrounds
- **Full-bleed solid purple** (`#6233A0`) for splash, onboarding, and primary marketing surfaces.
- **Light gray** (`#E5E5E5`) for scaffolded "app" surfaces (post-login). White cards on top.
- **Vector illustrations** — the brand has 5 onboarding scenes (door/coins, delivery+map, piggybank, growth chart, invoice printer) in a flat, friendly, slightly-corporate style with generous whitespace. They're imported from a stock illustration set (mixed palettes — some lime+navy, some teal+yellow, some indigo). They are NOT brand-cohesive in palette and should be redrawn or curated when the wallet ships.

> **Caveat:** The current illustration set is visually inconsistent (different artists/palettes). Documented for the user — should be replaced with a unified set.

### Animation
The Flutter onboarding uses the standard `introduction_screen` package — horizontal page transitions with active-dot animations. No custom motion was authored. Recommendation for the wallet:
- **Page transitions:** 300ms `cubic-bezier(0.2, 0.8, 0.2, 1)` ease-out.
- **Tap feedback:** 120ms scale-down to 0.97 on press, opacity drop to 0.85.
- **Numeric counters / balance reveals:** 600ms ease-out tween — money apps benefit from a subtle reveal here.
- **Success states:** 1.0 → 1.15 → 1.0 bounce with checkmark stroke draw.
- **Avoid** spring physics, parallax, and long hero animations — speed and trust matter more than delight.

### Hover / press states
This is a mobile app, so press > hover. Press = scale(0.97) + opacity 0.85 + 120ms. Web hover (in marketing/preview): brightness(0.95) on solid fills; opacity(0.85) on outlined.

### Borders, corners, shadows
- **Corner radii.** The brand vocabulary is **round**. Buttons are full pills (`borderRadius.circular(25)`). Cards round at 14–20px. Avatars and icon chips at full-circle.
- **Borders.** Almost no hairline borders. Surfaces are differentiated by background color and shadow, not strokes. When a border is needed, 1px at 8% black.
- **Shadows.** Soft, purple-tinted (`rgba(98, 51, 160, 0.10–0.35)`) — see `--shadow-1/2/3` and `--shadow-purple`. Inner shadows are not used.

### Cards
Rounded (14–20px), white surface, soft shadow (`--shadow-2`), 16–20px internal padding, no border. Section headers within cards use `--label` (14px / uppercase / muted). Amounts get the dedicated `.amount-display` class with tabular numerals.

### Transparency, blur, gradients
- **Transparency.** Used sparingly on overlays (modal scrim at 50% black) and on inactive page-dots (`rgba(0,0,0,0.26)`).
- **Blur.** Not used in the source app. Avoid frosted-glass effects — they don't render well on low-end Android, which is the dominant target hardware in Cabo Verde.
- **Gradients.** Avoid. The brand expresses energy through the lime-on-purple contrast, not gradients.

### Imagery vibe
Bright, illustrative, optimistic. Cool-leaning when on light backgrounds. NO photography in the current asset set. NO grain, no duotones, no AI-art looks. Vectorial only.

### Layout rules (fixed elements)
- **Status bar:** transparent, dark icons on light surfaces, white icons on purple.
- **App bar:** transparent (`elevation: 0`) — the source `style.dart` sets this explicitly.
- **Bottom nav (when present):** `Colors.grey.shade800` background, white icons. White surface preferred when not on a purple screen.

---

## Iconography

The Flutter source declares `cupertino_icons` and `flutter_svg` but no custom icon font. There are NO custom SVG icons committed in `pagali-app/assets/`. The pin glyph in the logo is the only piece of custom mark-making.

**System decision:**
- For UI icons we use **[Lucide](https://lucide.dev/)** (CDN) as the primary set — lightweight stroke icons at 1.75px weight, matching the modernist feel of the lime+purple palette. **Flagged as a substitution** — when the Flutter app ships, swap to `flutter_svg` + matching SVGs from the same Lucide set, or commission a custom set.
- Emoji are **NOT** used in product UI.
- Unicode chars are not used as icons (no `→`, no bullet glyphs in iconographic role — they are fine as text).
- For category/transaction icons (transfer, QR, receipt, wallet, top-up), use Lucide: `arrow-right-left`, `qr-code`, `receipt`, `wallet`, `plus-circle`.

> **Action item for the user:** confirm Lucide is acceptable, or provide a preferred icon set (we can swap to Phosphor, Material Symbols, Heroicons, or a custom set easily).

The **logo wordmark** (`assets/pagali.png`) uses a custom geometric typeface — slab/techno cuts on the P, A, G, L, I — paired with a small map-pin glyph (a circle inside a teardrop, top-right of the wordmark). The pin is a hint at the location-based, "pay-there" naming. **Always use the logo as a raster from `assets/`** — do not redraw it; we don't have the source vector.

---

## Caveats & open questions

1. **Wallet UI doesn't exist yet** in the Flutter source — only splash + onboarding. Everything in `ui_kits/pagali-wallet/` is *projected design*, not a pixel-recreation. The user should review and confirm direction before we build out further.
2. **Illustration palette inconsistency** — see Backgrounds above.
3. **Roboto** is the only declared font; we kept it. If a more distinctive face is wanted, flag.
4. **Lucide icons** are a substitution for the missing custom set — confirm or replace.
5. **No design tokens for dark mode** were found. We've not authored one. If the wallet will support it, we need direction.

---

## Bold ask

**Tell us where to push next.** Options on the table:
- Build out more wallet screens (transaction history, receipts, settings, KYC onboarding, top-up, bill-pay merchant picker).
- Expand into the broader Pagali brand (Events / Tickets / Shop / Delivery share the wordmark).
- Lock down the icon system with a formal substitution or a custom set.
- Replace the illustration set with a unified one (commission, or curate from a single source).
