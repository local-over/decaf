# Cafaine: Anti-Sleep Tool for macOS

<p align="center">
  <a href="https://local-over.github.io/decaf">
    <img src="assets/slider.gif" alt="Cafaine Interactive Slideshow" width="850" style="border-radius: 14px; box-shadow: 0 16px 40px rgba(0,0,0,0.12);">
  </a>
</p>

<p align="center">
  <a href="https://github.com/local-over/decaf/releases/latest"><img src="https://img.shields.io/github/v/release/local-over/decaf?style=flat-square&color=00AEF2" alt="Latest Release"></a>
  <img src="https://img.shields.io/badge/Platform-macOS%2013%2B-blue?style=flat-square" alt="macOS 13+">
  <img src="https://img.shields.io/badge/Architecture-Universal-blue?style=flat-square" alt="Universal">
  <img src="https://img.shields.io/badge/CI-Passing-brightgreen?style=flat-square" alt="CI Status">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License"></a>
</p>

Cafaine is a 100% free and open-source anti-sleep utility for macOS. It prevents your Mac from sleeping, dimming the display, or starting the screensaver, operating directly from your menu bar with zero background overhead.

Created by **Hassan Elkady** ([@local-over](https://github.com/local-over)).

Website and Interactive Showcase: **[local-over.github.io/decaf](https://local-over.github.io/decaf)**

---

## Features

- **Single-Click Activation:** Click the coffee cup in your menu bar to toggle active and inactive states.
- **Custom Durations & Presets:** Quick activation presets for `[ ∞ ]`, `[ 15 ]`, `[ 30 ]`, `[ 45 ]`, `[ 01 ]`, `[ 04 ]`, `[ 08 ]`, or custom duration (`[ ⚙ ]`).
- **Animated Menu Bar Indicator:** Dynamic rising steam vector animation in the macOS menu bar when active.
- **Display Sleep vs. System Sleep:** Configure whether the display stays illuminated or only background tasks and downloads stay active.
- **Power Management Automation:** Auto-activate when connecting to power, or auto-deactivate when disconnecting from charger.
- **Closed-Lid Operation:** Keep your system running when the MacBook lid is closed.
- **Launch at Login:** Native integration with macOS Service Management.
- **Global Keyboard Shortcut:** Toggle sleep prevention with `⌥C` (Option + C).
- **Zero Dependencies:** Built in pure Swift using native Apple IOKit power management APIs. Uses ~15MB RAM and 0% CPU.

---

## Installation

### Pre-built Compiled Release
1. Download **[Cafaine-macos.zip (Latest Release)](https://github.com/local-over/decaf/releases/latest/download/Cafaine-macos.zip)** (Universal binary for Apple Silicon and Intel).
2. Unzip and drag `Cafaine.app` into `/Applications` (this also indexes it for Launchpad).
3. If macOS displays *"Cannot verify developer"*, go to **System Settings → Privacy & Security** and click **"Open Anyway"** (or run `xattr -cr /Applications/Cafaine.app` in Terminal).
4. Launch Cafaine. It runs quietly in your top menu bar with zero Dock clutter. Click the coffee cup or press `⌥C` to activate.

### Build from Source
Requirements: macOS 13.0 or later with Xcode Command Line Tools.

```bash
git clone https://github.com/local-over/decaf.git
cd decaf
make bundle
make run
```

---

## Developer Support & Donations

If Cafaine is helpful to your daily workflow, consider supporting **Hassan Elkady**:

- **PayPal:** [paypal.me/HassanElkady2](https://paypal.me/HassanElkady2)
- **USDT (TON Network / TRC20):** `UQBEJwLa4EGPRmUKw4O1i9d_JjJGmjkJ2myqR5lborzgceT-`
- **Donation Web Page:** [local-over.github.io/decaf/donate.html](https://local-over.github.io/decaf/donate.html)
- **GitHub:** [@local-over](https://github.com/local-over)

---

## License

Cafaine is licensed under the [MIT License](LICENSE).
