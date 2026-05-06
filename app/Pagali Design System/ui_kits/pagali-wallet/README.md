# Pagali Wallet — UI Kit

Click-thru recreation of the Pagali mobile wallet. **This is a projected design**, not a pixel-recreation — the Flutter source (`ISONE-DEVOPS/pagali-app`) only ships a splash + 5-page onboarding. Wallet screens are extrapolated from:

- The **brand tokens** in `lib/Theme/colors.dart` and `style.dart` (purple `#6233A0`, lime `#B4BF09`, Roboto, 25px pill buttons).
- The **onboarding copy** (Portuguese, formal-friendly second person).
- The **backend contracts** in `Pagali-wallet/`:
  - P2P: `core-connector` payer/payee with MSISDN+FSP IDs (`BCVCVCV`, `CAIXACV`)
  - P2M: `merchant-registry` (sample: Mercado Sucupira, Restaurante Sodade) + EMVCo TLV QR (`com.pagali.p2m`, currency CVE / `132`, country CV)
  - 3-phase flow: discovery → acceptParty → acceptQuote

## Files

```
index.html        Interactive demo
components.jsx    PButton / PField / PCard / PAvatar / Icon / PListRow / BottomNav / AppBar
screens.jsx       OnboardScreen, LoginScreen, HomeScreen, SendScreen,
                  ConfirmScreen, SuccessScreen, QRScreen, MerchantPayScreen
android-frame.jsx (unused — kept for future device-frame previews)
```

## Flows demonstrated

1. **Onboarding** (5 pages, lifted from Flutter source)
2. **Login** — 4-digit PIN keypad on purple
3. **Home** — balance hero, quick actions, bill-pay shortcuts (Electra / CV Telecom / IGT), recent movements
4. **P2P send** — phone picker → amount → confirm → success
5. **P2M QR** — scanner viewfinder → merchant detected → amount → success

## Caveats

- Bill-pay merchants (Electra / CV Telecom / IGT) are placeholders — real categories TBD with the team.
- Icons are Lucide-derived SVG paths inlined; substitute with `flutter_svg` assets when the Flutter app ships.
- `topup` and `request` flows route to a placeholder "Em breve" screen.
- Animations are CSS transitions only; final motion design will live in Flutter.
