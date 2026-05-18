---
version: alpha
name: Jagjaguwar
description: Indie folk LP: oatmeal sleeve, letterpress ink, amber glow.
colors:
  primary: "#1E1A13"
  secondary: "#877C68"
  tertiary: "#C27C38"
  neutral: "#EFE6D0"
  surface: "#F7EDD6"
  on-primary: "#F7EDD6"
typography:
  display:
    fontFamily: Fraunces
    fontSize: 4.75rem
    fontWeight: 400
    letterSpacing: "-0.02em"
  h1:
    fontFamily: Fraunces
    fontSize: 2.4rem
    fontWeight: 400
  body:
    fontFamily: Lora
    fontSize: 1.02rem
    lineHeight: 1.75
  label:
    fontFamily: Lora
    fontSize: 0.76rem
    letterSpacing: "0.18em"
rounded:
  sm: 2px
  md: 4px
  lg: 6px
spacing:
  sm: 8px
  md: 16px
  lg: 32px
components:
  button-primary:
    backgroundColor: "{colors.tertiary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.md}"
    padding: 12px 20px
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    rounded: "{rounded.lg}"
    padding: 24px
---
## Overview

An indie-folk LP sleeve: oatmeal sleeve, letterpress ink, soft amber glow.

## Colors

The palette is built around high-contrast neutrals and a single accent that drives interaction.

- **Primary (`#1E1A13`):** Headlines and core text.
- **Secondary (`#877C68`):** Borders, captions, and metadata.
- **Tertiary (`#C27C38`):** The sole driver for interaction. Reserve it.
- **Neutral (`#EFE6D0`):** The page foundation.

## Typography

- **display:** Fraunces 4.75rem
- **h1:** Fraunces 2.4rem
- **body:** Lora 1.02rem
- **label:** Lora 0.76rem

## Do's and Don'ts

- **Do** use Tertiary for exactly one action per screen.
- **Do** let Neutral carry the composition — negative space is a feature.
- **Don't** introduce gradients. This system is flat on purpose.
- **Don't** mix Tertiary with alternate accents; the single-accent rule is load-bearing.
