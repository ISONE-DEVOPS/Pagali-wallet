---
name: pagali-design
description: Use this skill to generate well-branded interfaces and assets for Pagali, the Cape Verde P2P/P2M digital wallet, either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.
If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here to become an expert in designing with this brand.
If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts _or_ production code, depending on the need.

Key files to start from:
- `README.md` — brand context, content rules, visual foundations, iconography, caveats
- `colors_and_type.css` — all design tokens (CSS vars for colors, type, spacing, radii, shadows)
- `assets/` — logo, splash, onboarding illustrations
- `ui_kits/pagali-wallet/` — JSX components for wallet screens; load `index.html` for the interactive demo
- `preview/` — small spec cards documenting individual tokens and components

When designing for Pagali, remember: Portuguese copy, deep purple (#6233A0) + lime (#B4BF09) palette, fully-rounded buttons (25px radius), Roboto type, mobile-first (Flutter target), and no emoji in product UI.
