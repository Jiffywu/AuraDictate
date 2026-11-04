# Aura Dictate

**The smallest, fastest-feeling dictation app on Mac.**

Hold a key, talk, and let go. Your words appear wherever you're typing. Aura lives in the menu bar and transcribes on your Mac with Apple's built-in speech engine.

<p align="center">
  <a href="https://github.com/Jiffywu/AuraDictate/releases/download/v1.1.0/auradictate-promo.mp4">
    <img src="docs/auradictate-demo.gif" alt="Aura Dictate — On-Device Push-to-Talk Dictation for macOS" width="100%" />
  </a>
  <br />
  <sub><a href="https://github.com/Jiffywu/AuraDictate/releases/download/v1.1.0/auradictate-promo.mp4">▶ Watch full 1080p60 video with sound (MP4)</a> · <a href="https://github.com/Jiffywu/AuraDictate/releases/latest/download/AuraDictate.dmg">⬇ Download AuraDictate.dmg (530 KB)</a></sub>
</p>

## Why it feels fast

Aura transcribes while you talk, so there's very little left to do when you let go of the key. In a repeatable test on an M4 MacBook Air, text was ready to paste a median of 191 ms after release for a 4-second clip and 136 ms for a 27-second clip.

It also keeps the last 380 ms of audio in memory, so your first word doesn't get cut off.

- **Download:** 530 KB
- **Installed:** 760 KB
- **Memory:** about 14 MB when idle and 17 MB after dictating, plus Apple's speech service while you dictate
- **CPU:** under 1% of one core when idle

The Settings window uses about 44 MB while it's open. Aura restarts itself when you close the window to give that memory back.

## How it compares

| | Aura Dictate | [Wispr Flow](https://wisprflow.ai) | [Superwhisper](https://superwhisper.com) | [MacWhisper](https://macwhisper.com) |
|---|---|---|---|---|
| **Price** | Free | Limited free plan, Pro $15/month | Limited free plan, Pro $8.49/month or $249.99 once | Free version, Pro about €59–65 once |
| **Open source** | Yes (MIT) | No | No | No |
| **Where speech is processed** | On your Mac | Cloud | On your Mac or cloud | On your Mac |
| **Speech engine** | Apple | Cloud models | Whisper, Parakeet, cloud models | Whisper, Parakeet |
| **Built mainly for** | Dictation | Dictation | Dictation | Transcribing audio files |
| **Languages** | English (US) | Many | Many | Many |
| **Runs on** | Mac | Mac, Windows, iPhone, Android | Mac, Windows, iPhone | Mac |

Prices were checked in November 2026 and can change.

Aura does one job. Pick Wispr Flow or Superwhisper if you want AI to rewrite your text, or if you need other languages or devices. Pick MacWhisper if you mostly transcribe recordings. Whisper and Parakeet models may also be more accurate on difficult audio.

## Requirements

- Apple silicon Mac with macOS 26 or later
- Microphone access
- Accessibility access, for the global shortcut and auto-paste

macOS may download its English speech model the first time Aura starts.

## Install

**Download:** Open [`AuraDictate.dmg`](https://github.com/Jiffywu/AuraDictate/releases/latest/download/AuraDictate.dmg) and drag Aura Dictate into Applications. This build isn't notarized yet, so macOS may block it the first time. If it does, open System Settings > Privacy & Security and choose **Open Anyway**, or use the Terminal install below.

**Terminal:**

```sh
curl -fsSL https://raw.githubusercontent.com/Jiffywu/AuraDictate/main/install.sh | bash
```

**From source** (needs Xcode or Command Line Tools with the macOS 26 SDK or newer):

```sh
./build.sh /Applications/AuraDictate.app
open /Applications/AuraDictate.app
```

`build.sh` signs the app ad hoc. Set `SIGN_IDENTITY` to use a Developer ID. `scripts/package-release.sh` builds the DMG and ZIP.

## Use

1. Follow the setup guide on first launch. You can reopen it with **Setup Guide** in the menu bar.
2. Hold Right Command and talk. Fn and Right Option also work.
3. Let go. Aura pastes the text into the active app, then restores your clipboard.

Open **Settings & History** from the menu bar to change shortcuts, colors, and shapes, or to see past dictations.

**If access still shows as off:** Open Privacy & Security in System Settings, remove Aura Dictate from the list, and add it again from Applications.

## Privacy

- Aura has no code that uploads your audio or text.
- Pre-roll keeps your microphone open while Aura is idle, so it can save the last moments of audio. That audio stays in memory. Turn off **Pre-roll** to close the microphone between dictations.
- Your last 50 transcripts are saved unencrypted in the app's local preferences until you clear them.
- macOS may download speech assets. Apple's speech settings on your Mac may also apply.

## Source

The whole app is in `AuraDictate.swift`. The logo is `AuraMark.svg`, and `scripts/generate-icon.swift` generates the icon:

```sh
swift scripts/generate-icon.swift /tmp/AuraIcon.iconset
iconutil -c icns /tmp/AuraIcon.iconset -o AppIcon.icns
```

Aura Dictate is released under the [MIT license](LICENSE).
