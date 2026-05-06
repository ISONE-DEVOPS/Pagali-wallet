# Pagali Wallet — Flutter

Implementação Flutter/Dart do design system Pagali, cobrindo os dois fluxos de pagamento da `Pagali-wallet`:

- **P2P** — transferências entre números (MSISDN), via `core-connector` (Mojaloop)
- **P2M** — pagamento ao comerciante por QR EMVCo TLV (`com.pagali.p2m`, moeda CVE)

## Como correr

```bash
cd flutter
flutter pub get
flutter run
```

> Coloca os ficheiros de imagem (`pagali.png`, `splashMain.png`, `onboard1..5.png`) em `flutter/assets/images/` antes de correr — estão na raiz do projecto em `assets/images/`.

## Estrutura

```
lib/
  main.dart                       Ponto de entrada + Splash + navegação entre telas
  theme/
    colors.dart                   PagaliColors — todas as cores da marca
    typography.dart               PagaliText — escala tipográfica (Roboto)
    theme.dart                    buildPagaliTheme() — ThemeData global
  widgets/
    p_button.dart                 Botão com 6 variantes + animação de press
    p_card.dart                   Cartão branco com sombra suave
    p_avatar.dart                 Avatar circular com iniciais
    p_field.dart                  Campo de texto consistente com o DS
    bottom_nav.dart               Nav inferior cinza com FAB lima do QR
  screens/
    onboarding_screen.dart        5 páginas (texto fiel à versão original)
    login_screen.dart             PIN de 4 dígitos sobre fundo roxo
    home_screen.dart              Hero do saldo + ações rápidas + contas + movimentos
    send_screen.dart              P2P — destinatário → montante
    confirm_screen.dart           Resumo (montante + taxa + total + nota)
    success_screen.dart           Confirmação visual + ID da transacção
    qr_scan_screen.dart           Visor QR (placeholder — falta `mobile_scanner`)
    merchant_pay_screen.dart      P2M — comerciante detectado + montante
  models/
    transaction.dart              Modelos Transaction / TxParty / TxKind
  utils/
    format.dart                   Money.cve(...) — formatação CVE pt_CV

assets/
  images/                         Logo, splash, ilustrações de onboarding
```

## Implementado nesta iteração

- **`mobile_scanner`** real ligado ao `QRScanScreen` — TLV é parseado pelo `qr-service` (`POST /qr/parse`).
- **Cliente HTTP** (`services/api_client.dart`) com endpoints para `core-connector` (P2P 3-fase Mojaloop), `merchant-registry`, `qr-service`. Hosts via `--dart-define`.
- **`TransferService`** orquestra `discover → quote → execute` e devolve recibo com `transferId` (UUID v4).
- **`Session`** (`services/session.dart`) — PIN guardado como SHA-256, token + user em `shared_preferences`.
- **Telas novas**: `HistoryScreen` (filtros + agrupamento por dia), `TopUpScreen` (cartão / banco / agente), `RequestScreen` (deep link + QR placeholder), `KycScreen` (4 passos: dados → BI → selfie → revisão), `SettingsScreen`.

## Configurar hosts

```bash
flutter run \
  --dart-define=CORE_CONNECTOR_BASE=https://core-connector.dev.pagali.cv \
  --dart-define=MERCHANT_REGISTRY_BASE=https://merchant-registry.dev.pagali.cv \
  --dart-define=QR_SERVICE_BASE=https://qr.dev.pagali.cv
```

## Permissões a adicionar

- **iOS** `Info.plist` → `NSCameraUsageDescription` ("Para ler códigos QR de pagamento")
- **Android** `AndroidManifest.xml` → `<uses-permission android:name="android.permission.CAMERA" />`

## Ainda em aberto

- Recibo PDF / partilha real (actualmente os botões são no-op)
- Cliente real do `qr_flutter` no `RequestScreen` (placeholder com `Icons.qr_code_2`)
- Push notifications (FCM) e deep-link handler para `pagali://request?...`
- Testes de widget para telas críticas (P2P confirm, P2M pay)

## Mapeamento DS ↔ código

| Token CSS                  | Dart                              |
|----------------------------|-----------------------------------|
| `--pagali-purple`          | `PagaliColors.purple`             |
| `--pagali-lime`            | `PagaliColors.lime`               |
| `--r-pill` (25px)          | `BorderRadius.circular(25)`       |
| `.amount-display`          | `PagaliText.amount`               |
| `--shadow-purple`          | shadow no `PButton.primary`       |

Manter sincronizado com `colors_and_type.css` na raiz do design system.
