# Brand Identity & Design System Specification: Cafaine

This document specifies the exact visual identity, design tokens, typography, component layouts, and animation standards derived from deep analysis of the reference application (*Caffeinated - Anti Sleep App* by Yugen GmbH on the Mac App Store) for the open-source implementation **Cafaine**.

---

## 1. Color Palette & Design Tokens

### Primary Brand Gradient (App Icon & Marketing)
- **Top / Light Accent:** `#00AEF2` (Vibrant Cyan / Electric Sky Blue, RGB: 0, 174, 242)
- **Bottom / Deep Accent:** `#155EDD` (Royal Cobalt Blue, RGB: 21, 94, 221)
- **Gradient Angle:** 135 degrees (top-left to bottom-right)
- **Foreground Glyphs:** `#FFFFFF` (Pure White, 100% opacity)

### Interface Chrome (macOS Native Materials)
- **Light Mode Menu Background:** `NSVisualEffectView.Material.popover` (translucent light material, base `#FFFFFF` with blur)
- **Dark Mode Menu Background:** `NSVisualEffectView.Material.popover` (translucent dark material, base `#1E1E1E` with blur)
- **Primary Text Color (Light):** `#1D1D1F` (macOS Primary Label, 100% opacity)
- **Secondary Text Color (Light):** `#86868B` (macOS Secondary Label, 60% opacity)
- **Primary Text Color (Dark):** `#F5F5F7` (macOS Primary Label, 100% opacity)
- **Secondary Text Color (Dark):** `#A1A1A6` (macOS Secondary Label, 65% opacity)
- **Active State Tint:** `#007AFF` (Apple System Blue) or `#00AEF2` (Brand Cyan)
- **Inactive State Tint:** Standard menu bar template monochrome tint (adapts automatically to desktop wallpaper brightness)

---

## 2. Typography

All typography strictly adheres to Apple Human Interface Guidelines using the system font:

- **Application Title:** SF Pro Display, 15pt, Semi-Bold / Medium
- **Status Subtitle ("Active Until ..."):** SF Pro Text, 11pt, Regular, Secondary Label Color
- **Menu Items & Labels:** SF Pro Text, 13pt, Regular
- **Duration Numbers ("15", "30", "45", "01"):** SF Pro Text, 12pt, Monospaced Digits, Medium
- **Settings Section Headers:** SF Pro Text, 11pt, Bold, Uppercase, Secondary Label Color
- **Settings Toggle Labels:** SF Pro Text, 13pt, Regular

*Strict Rule:* No emoji glyphs are permitted anywhere in application menus, status titles, settings labels, or marketing assets.

---

## 3. Menu Bar Icon & Animation Specifications

### Inactive State
- **Icon:** A minimal 16x16 vector coffee mug outline:
  - Cup body: Rounded rectangle with smooth corner radius.
  - Handle: Clean arc attached to the right side of the mug.
  - Saucer: Thin rounded horizontal ellipse underneath.
  - Fill: Transparent.
  - Rendering Mode: Template (automatic dark/light adaptation).

### Active State & Animation
- **Fill:** Cup body filled solid with dark coffee/espresso tone (`#3C2A21` or accent tinted `#007AFF` when colored icon mode is active).
- **Steam Animation:**
  - 4 discrete animation frames cycling at 120ms intervals.
  - Frame 1: Low steam rising from the center.
  - Frame 2: Steam extending upward with left curvature.
  - Frame 3: Steam dissipating upward with right curvature.
  - Frame 4: Secondary steam curl rising.
  - Loop mode: Continuous while active.

---

## 4. Menu & Popover Architecture

Derived from Screen 1 and Screen 2 of the reference application:

```
+------------------------------------------+
|  Cafaine                                 |
|  Active Until 8:45 AM (or Inactive)      |
+------------------------------------------+
|  Duration                                |
|    [ 15 ] [ 30 ] [ 45 ] [ • 01 ] [ 02 ]  |
|    [ 04 ] [ 08 ] [ 12 ] [  ∞  ]          |
+------------------------------------------+
|  --------------------------------------- |
|  Settings...                             |
|  About Cafaine...                        |
|  Quit Cafaine                            |
+------------------------------------------+
```

### Behavioral Mechanics:
1. **Left-Click Action:** If "Activate with Left Click" is enabled in Settings, single left-click toggles state immediately. Secondary click (right-click or Control-click) opens the menu popover.
2. **Standard Action:** Left-click opens the menu popover.
3. **Selected Duration Indicator:** Indicated by a bullet point (`•`) or highlighted checkmark next to the active preset.

---

## 5. Preferences / Settings Window Architecture

Derived from Screen 3 of the reference application:

- **Window Title:** Settings
- **Window Dimensions:** 420px width, 480px height, fixed or resizable
- **Window Style:** Native macOS Standard Window (`.titled`, `.closable`)

### Setting Toggles:
1. **Launch at Login** (Boolean toggle) — Automatically registers with `SMAppService.mainApp`.
2. **Activate at Launch** (Boolean toggle) — Starts in active caffeinated state upon app launch.
3. **Activate with Left Click** (Boolean toggle) — Toggles with 1 click; right-click reveals menu.
4. **Keyboard Shortcut** (Key combination) — Global hotkey to toggle activation (e.g. Option+C).
5. **Allow Display Sleep** (Boolean toggle) — Only prevents idle system sleep while letting monitors turn off.
6. **Keep Awake with Lid Closed** (Boolean toggle) — Prevents sleep when MacBook lid is closed.
7. **Allow Notifications** (Boolean toggle) — Displays native macOS user notifications when timers expire.
8. **Colored Menu Bar Icon** (Boolean toggle) — Renders the active icon in brand cyan/blue instead of monochrome template.
9. **Activate on Power Connect** (Boolean toggle) — Activates when MagSafe / USB-C charger is attached.
10. **Deactivate on Power Disconnect** (Boolean toggle) — Deactivates when running on battery to conserve charge.

---

## 6. App Store Presentation Standards

Replicating the clean, minimalist App Store promotional aesthetics:

- **Aspect Ratio:** 1286 x 804 (Apple Mac App Store standard).
- **Background:** Clean off-white studio background (`#F5F5F7` to `#FFFFFF`) with subtle soft shadow.
- **Left Column:**
  - Kicker / Category tag in uppercase neutral grey (`#86868B`, 13pt).
  - Main Title in bold black typography (`#1D1D1F`, 42pt, tight line height).
  - Subtitle in neutral grey (`#6E6E73`, 17pt, regular).
- **Right Column:**
  - Pixel-perfect macOS desktop frame, native menu bar, and live Cafaine popover / settings window with authentic drop shadow (`shadowBlur: 40`, `shadowOffset: (0, -15)`, `alpha: 0.25`).
- **Currency & Pricing:** Always formatted in US Dollars ($3.99 / $4.99) vs. $0.00 Free on GitHub. No emojis.
