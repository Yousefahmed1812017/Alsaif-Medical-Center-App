---
name: "alsaif-medical-design-system"
description: "AI Skill for building UI with the Alsaif Medical Design System"
---

# Alsaif Medical Design System Guidelines

You are an expert UI/UX Engineer. When generating or modifying UI code (Flutter, Web, etc.) for Alsaif Medical Center, you MUST strictly adhere to the following design system rules:

## 1. Color Palette
Use ONLY the following primary brand colors:
- **Darkest Blue**: `#015C92` (Use for primary text, active states, deep backgrounds)
- **Dark Blue**: `#2D82B5` (Use for hover states, secondary elements)
- **Primary Brand**: `#53A7D8` (Use for primary buttons, active tabs, main accents)
- **Light Blue**: `#88CDF6` (Use for soft highlights, disabled states)
- **Lightest (Surface)**: `#BCE6FF` (Use for very light backgrounds, secondary button backgrounds)

Semantic Colors:
- **Success**: `#22C55E` (Background: `#DCFCE7`)
- **Error/Danger**: `#EF4444` (Background: `#FEE2E2`)
- **Warning**: `#EAB308` (Background: `#FEF9C3`)
- **Info**: `#3B82F6` (Background: `#DBEAFE`)
- **Neutrals**: White `#FFFFFF`, Light Grays `#F8FAFC`, `#E2E8F0`, Dark text `#1E293B`

## 2. Typography
- **English (LTR)**: `Poppins`
- **Arabic (RTL)**: `Cairo`
- **Hierarchy**:
  - H1: 36px Bold
  - H2: 30px Bold
  - H3: 24px Semibold
  - H4: 20px Medium
  - Body Large: 16px Regular
  - Body Normal: 14px Regular
  - Caption: 12px Regular

## 3. Bilingual & RTL Rules
- The UI MUST support both Arabic (RTL) and English (LTR).
- **Icon Placement Rule**: Icons MUST ALWAYS be logically placed before the text depending on the reading direction.
  - In LTR (English), the icon is on the Left of the text.
  - In RTL (Arabic), the icon is on the Right of the text.
  - Always leave an 8px spacing gap between the icon and text.

## 4. UI Components & Shapes
- **Corner Radius**: Use soft, modern rounded corners. 
  - Standard components (buttons, inputs): `8px` to `10px`
  - Large containers (cards, modals): `14px` to `24px`
- **Shadows**: Use clean, subtle elevation shadows. Avoid harsh black shadows.
- **Borders**: Inputs and cards should have light borders (e.g. `#E2E8F0`) and white backgrounds.
- **Buttons**:
  - Primary buttons use the Primary Brand color (`#53A7D8`) with white text.
  - Apply scale-down animation on click.

## 5. Spacing & Layout
- Maintain generous whitespace and padding (e.g., 24px padding inside cards).
- Use flexbox or grid layouts heavily for clean alignment.
- Never use placeholder generic colors outside the approved palette.

## 6. Icons
- Standardize on FontAwesome 6 (Solid/Regular) or Phosphor Icons.
- Keep icon sizes consistent (typically 16px to 24px).

Follow these rules unconditionally to guarantee a premium, professional, and accessible UI.
