# Aura Dictate

Aura Dictate is a macOS menu bar app for push-to-talk dictation. It uses Apple's `SpeechAnalyzer` and `SpeechTranscriber` to transcribe speech on device with an original voice-wave mark, a 380ms pre-roll ring buffer, and a live customizable industrial chassis.

<p align="center">
  <a href="https://github.com/Jiffywu/AuraDictate/releases/download/v1.1.0/auradictate-promo.mp4">
    <img src="docs/auradictate-demo.gif" alt="Aura Dictate — On-Device Push-to-Talk Dictation for macOS" width="100%" />
  </a>
  <br />
  <sub><a href="https://github.com/Jiffywu/AuraDictate/releases/download/v1.1.0/auradictate-promo.mp4">▶ Watch full 1080p60 video with sound (MP4)</a> · <a href="https://github.com/Jiffywu/AuraDictate/releases/latest/download/AuraDictate.dmg">⬇ Download AuraDictate.dmg (1.1 MB)</a></sub>
</p>

## Principles

- Keep dictation close at hand with a menu bar app and a push-to-talk shortcut.
- Use Apple's on-device speech tools and keep the audio pre-roll in memory.
- Give people control over the app's appearance, shortcuts, and clipboard behavior.
- Keep the source small enough to read and modify.

## Requirements

- An Apple silicon Mac running macOS 26 or later.
- Xcode or Command Line Tools with the macOS 26 SDK or newer.
- Microphone access. Accessibility access is required for the global shortcut and automatic paste.
- The English (United States) speech model. macOS may download speech assets when the app starts.

The app currently uses `en_US` and does not offer a language picker.

## Install

### Option 1: Download `.dmg` (Recommended for most users)
1. Download **[`AuraDictate.dmg`](https://github.com/Jiffywu/AuraDictate/releases/latest/download/AuraDictate.dmg)** from the [latest GitHub Release](https://github.com/Jiffywu/AuraDictate/releases/latest).
2. Open `AuraDictate.dmg` and drag **AuraDictate** into **Applications**.

### Option 2: One-Line Terminal Installer
Installs the pre-built release directly into `/Applications/AuraDictate.app`, clears quarantine attributes, and launches it in your menu bar:

```sh
curl -fsSL https://raw.githubusercontent.com/Jiffywu/AuraDictate/main/install.sh | bash
```

### Option 3: Build from Source
```sh
./build.sh /Applications/AuraDictate.app
open /Applications/AuraDictate.app
```

The default `./build.sh` is ad hoc signed and outputs to `build/AuraDictate.app` unless a destination path is passed. A Developer ID signature can be supplied with `SIGN_IDENTITY`, and `./scripts/package-release.sh` builds both `dist/AuraDictate.dmg` and `dist/AuraDictate-macos-arm64.zip`.

## Use

On first launch, the setup guide walks you through microphone and Accessibility access. You can open it again with **Setup Guide** in the menu bar. If macOS does not show a permission prompt, open Privacy & Security in System Settings and enable Aura Dictate under Microphone and Accessibility. On macOS versions that show Device Control and Data Access, use that page for Accessibility access. If Aura still reports that access is off, remove its old entry and add the app from Applications again.

Open **Settings & History** from the menu bar icon. Hold the configured shortcut to dictate, then release it to finish. The default shortcut is Right Command. Fn and Right Option are also available. You can start and stop recording in the main window.

Use **Appearance** in the main window to change the background, panel, accent, logo color, outline color, logo shape, box shape, and outline width. These preferences also apply to the floating transcription display. Choose **Reset appearance** to restore the defaults.

Pre-roll is enabled by default. When microphone access is granted, this keeps audio capture running so the app can retain a short in-memory buffer before the shortcut is pressed. Turn off Pre-roll in the main window to stop capture while idle. Auto-paste uses the clipboard and attempts to restore its previous contents after pasting.

## Privacy

The app stores up to 50 transcripts in local user defaults until you clear history. They are not encrypted by the app. Audio pre-roll is kept in memory. The app does not implement a network upload for audio or transcripts, but macOS may download speech assets. Review Apple's speech feature behavior for your macOS version and configuration before relying on this description for a privacy policy.

## Source and license

`AuraDictate.swift` contains the app, capture pipeline, and UI. `AuraMark.svg` is the editable logo and `scripts/generate-icon.swift` generates the app icon. To regenerate it, run `swift scripts/generate-icon.swift /tmp/AuraIcon.iconset` followed by `iconutil -c icns /tmp/AuraIcon.iconset -o AppIcon.icns`.

The source is offered under the MIT license in `LICENSE`. Verify that you have the rights to release the original source and any contributions before publishing.
