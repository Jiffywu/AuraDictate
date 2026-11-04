import AppKit
import SwiftUI
import AVFoundation
import CoreMedia
import Speech
import CoreText
import Carbon.HIToolbox

// MARK: - Appearance & Industrial Typography

struct AuraPreset: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let backgroundHex: String
    let surfaceHex: String
    let accentHex: String
    let logoHex: String
    let outlineHex: String
    let boxShape: String
    let pattern: String
}

enum AuraStyle {
    static let surface = Color(red: 0.25, green: 0.28, blue: 0.34)
    static let grayscale60 = Color(red: 0.65, green: 0.69, blue: 0.75)
    static let grayscale70 = Color(red: 0.72, green: 0.76, blue: 0.82)
    static let grayscale90 = Color(red: 0.88, green: 0.90, blue: 0.94)
    static let grayscale100 = Color.white
    static let error = Color(red: 0.94, green: 0.27, blue: 0.29)
    static let warning = Color(red: 0.90, green: 0.66, blue: 0.27)
    static let success = Color(red: 0.19, green: 0.82, blue: 0.35)

    static let gold400 = Color(red: 0xf2 / 255.0, green: 0xd8 / 255.0, blue: 0xa6 / 255.0)
    static let gold500 = Color(red: 0xff / 255.0, green: 0xda / 255.0, blue: 0x85 / 255.0)
    static let gold600 = Color(red: 0xae / 255.0, green: 0x87 / 255.0, blue: 0x33 / 255.0)

    static let presets: [AuraPreset] = [
        AuraPreset(
            id: "crimson",
            name: "CRIMSON DECK",
            subtitle: "OBSIDIAN // CRIMSON",
            backgroundHex: "0E1118",
            surfaceHex: "171B24",
            accentHex: "E04755",
            logoHex: "E04755",
            outlineHex: "383E4E",
            boxShape: "rounded",
            pattern: "grid"
        ),
        AuraPreset(
            id: "studio",
            name: "STUDIO 1000",
            subtitle: "CHARCOAL // AMBER GOLD",
            backgroundHex: "1C1B1C",
            surfaceHex: "272626",
            accentHex: "C24E00",
            logoHex: "ED1C24",
            outlineHex: "3F3F3F",
            boxShape: "square",
            pattern: "mesh"
        ),
        AuraPreset(
            id: "phosphor",
            name: "P31 SCOPE",
            subtitle: "CRT BLACK // PHOSPHOR",
            backgroundHex: "09110D",
            surfaceHex: "101E17",
            accentHex: "10B981",
            logoHex: "34D399",
            outlineHex: "1F3A2C",
            boxShape: "square",
            pattern: "scanline"
        ),
        AuraPreset(
            id: "cobalt",
            name: "FIELD UNIT",
            subtitle: "SLATE // SIGNAL COBALT",
            backgroundHex: "121519",
            surfaceHex: "1C2128",
            accentHex: "2F81F7",
            logoHex: "FF6A1A",
            outlineHex: "343C47",
            boxShape: "rounded",
            pattern: "mesh"
        )
    ]

    private static var fontsRegistered = false

    static func registerBundledFonts() {
        guard !fontsRegistered else { return }
        fontsRegistered = true
        guard let fontsDir = Bundle.main.resourceURL?.appendingPathComponent("Fonts") else { return }
        if let files = try? FileManager.default.contentsOfDirectory(at: fontsDir, includingPropertiesForKeys: nil) {
            for url in files where url.pathExtension.lowercased() == "otf" || url.pathExtension.lowercased() == "ttf" {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    static func color(_ hex: String, fallback: UInt32) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt32(cleaned, radix: 16) ?? fallback
        return Color(red: Double((value >> 16) & 255) / 255,
                     green: Double((value >> 8) & 255) / 255,
                     blue: Double(value & 255) / 255)
    }

    static func hex(_ color: Color) -> String {
        let rgb = NSColor(color).usingColorSpace(.sRGB) ?? .white
        return String(format: "%02X%02X%02X", Int((rgb.redComponent * 255).rounded()),
                      Int((rgb.greenComponent * 255).rounded()), Int((rgb.blueComponent * 255).rounded()))
    }

    static func meterGradient(accent: Color) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: accent.opacity(0.75), location: 0.0),
                .init(color: accent, location: 0.62),
                .init(color: gold400, location: 1.0)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    static func displayFont(size: CGFloat) -> Font {
        if NSFont(name: "BasementGrotesque-Black", size: size) != nil {
            return .custom("BasementGrotesque-Black", size: size)
        }
        return .system(size: size, weight: .black)
    }

    static func bodyRegular(size: CGFloat = 17) -> Font {
        if NSFont(name: "RedHatText-Regular", size: size) != nil {
            return .custom("RedHatText-Regular", size: size)
        }
        return .system(size: size, weight: .regular)
    }

    static func bodyMedium(size: CGFloat = 15) -> Font {
        if NSFont(name: "RedHatText-Medium", size: size) != nil {
            return .custom("RedHatText-Medium", size: size)
        }
        return .system(size: size, weight: .medium)
    }

    static func bodyBold(size: CGFloat = 12) -> Font {
        if NSFont(name: "RedHatText-Bold", size: size) != nil {
            return .custom("RedHatText-Bold", size: size)
        }
        return .system(size: size, weight: size <= 12 ? .bold : .semibold)
    }

    static func mono(size: CGFloat = 11, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct ChassisPatternOverlay: View {
    let pattern: String
    let tint: Color

    var body: some View {
        Canvas { context, size in
            guard pattern != "none" else { return }
            if pattern == "mesh" {
                let step: CGFloat = 8
                for x in stride(from: 4, to: size.width, by: step) {
                    for y in stride(from: 4, to: size.height, by: step) {
                        let rect = CGRect(x: x, y: y, width: 1.2, height: 1.2)
                        context.fill(Path(ellipseIn: rect), with: .color(tint.opacity(0.14)))
                    }
                }
            } else if pattern == "grid" {
                let step: CGFloat = 20
                var path = Path()
                for x in stride(from: 0, through: size.width, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(tint.opacity(0.10)), lineWidth: 0.6)
            } else if pattern == "scanline" {
                let step: CGFloat = 4
                var path = Path()
                for y in stride(from: 0, through: size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(tint.opacity(0.12)), lineWidth: 0.8)
            }
        }
        .allowsHitTesting(false)
    }
}

struct AuraMark: View {
    let shape: String
    let color: Color
    var size: CGFloat = 26

    var body: some View {
        Group {
            if shape == "waveform" {
                GeometryReader { geo in
                    let unit = min(geo.size.width, geo.size.height) / 100
                    let origin = CGPoint(x: (geo.size.width - 100 * unit) / 2, y: (geo.size.height - 100 * unit) / 2)
                    Path { path in
                        path.move(to: CGPoint(x: origin.x + 12 * unit, y: origin.y + 55 * unit))
                        path.addCurve(to: CGPoint(x: origin.x + 88 * unit, y: origin.y + 55 * unit),
                                      control1: CGPoint(x: origin.x + 12 * unit, y: origin.y + 4 * unit),
                                      control2: CGPoint(x: origin.x + 88 * unit, y: origin.y + 4 * unit))
                    }.stroke(color, style: StrokeStyle(lineWidth: 8 * unit, lineCap: .round))
                    ForEach(0..<5, id: \.self) { index in
                        let heights: [CGFloat] = [18, 30, 45, 30, 18]
                        RoundedRectangle(cornerRadius: 4 * unit)
                            .fill(color)
                            .frame(width: 8 * unit, height: heights[index] * unit)
                            .position(x: origin.x + (22 + CGFloat(index) * 14) * unit,
                                      y: origin.y + (72 - heights[index] / 2) * unit)
                    }
                }
            } else {
                Image(systemName: shape == "circle" ? "waveform.circle.fill" : "mic.circle.fill")
                    .font(.system(size: size * 0.82, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Aura Dictate")
    }
}

// MARK: - Data Models

struct TranscriptRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
    let durationSeconds: Double
    let latencyMs: Double
    let usedPreRoll: Bool
}

enum TriggerKeyOption: String, CaseIterable, Identifiable {
    case rightCommand = "Right ⌘"
    case fnKey = "Fn"
    case rightOption = "Right ⌥"

    var id: String { rawValue }

    var keyCode: UInt16 {
        switch self {
        case .rightCommand: return 54
        case .fnKey: return 63
        case .rightOption: return 61
        }
    }

    /// Checks the exact physical modifier bitmask from an NSEvent's modifierFlags
    func isPressed(in flags: NSEvent.ModifierFlags) -> Bool {
        let raw = flags.rawValue
        switch self {
        case .rightCommand:
            let deviceRightCmd = UInt(NX_DEVICERCMDKEYMASK)
            if (raw & (deviceRightCmd | UInt(NX_DEVICELCMDKEYMASK))) != 0 {
                return (raw & deviceRightCmd) != 0
            }
            return flags.contains(.command)
        case .rightOption:
            let deviceRightAlt = UInt(NX_DEVICERALTKEYMASK)
            if (raw & (deviceRightAlt | UInt(NX_DEVICELALTKEYMASK))) != 0 {
                return (raw & deviceRightAlt) != 0
            }
            return flags.contains(.option)
        case .fnKey:
            return flags.contains(.function)
        }
    }

    /// Checks the exact physical modifier bitmask from a CGEvent's flags
    func isPressed(in cgFlags: CGEventFlags) -> Bool {
        let raw = cgFlags.rawValue
        switch self {
        case .rightCommand:
            let deviceRightCmd = UInt64(NX_DEVICERCMDKEYMASK)
            if (raw & (deviceRightCmd | UInt64(NX_DEVICELCMDKEYMASK))) != 0 {
                return (raw & deviceRightCmd) != 0
            }
            return cgFlags.contains(.maskCommand)
        case .rightOption:
            let deviceRightAlt = UInt64(NX_DEVICERALTKEYMASK)
            if (raw & (deviceRightAlt | UInt64(NX_DEVICELALTKEYMASK))) != 0 {
                return (raw & deviceRightAlt) != 0
            }
            return cgFlags.contains(.maskAlternate)
        case .fnKey:
            return cgFlags.contains(.maskSecondaryFn)
        }
    }
}

// MARK: - Serialized Capture & Frame/PTS Pre-Roll Pipeline

/// Runs exclusively on `captureQueue`.
final class CapturePipelineState: @unchecked Sendable {
    let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)!

    private var preRollBuffers: [(endTime: Double, buffer: AVAudioPCMBuffer)] = []
    private var totalBufferedFrames: Int = 0
    private var maxPreRollFrames: Int = 6080 // 380ms @ 16kHz
    private var activeContinuation: AsyncStream<AnalyzerInput>.Continuation?

    func setPreRollMilliseconds(_ ms: Double) {
        let clampedMs = max(100.0, min(1000.0, ms))
        maxPreRollFrames = Int((clampedMs / 1000.0) * 16000.0)
        trimPreRollToLimit()
    }

    func clearPreRoll() {
        preRollBuffers.removeAll(keepingCapacity: true)
        totalBufferedFrames = 0
    }

    func beginStreaming(
        continuation: AsyncStream<AnalyzerInput>.Continuation,
        includePreRoll: Bool
    ) {
        activeContinuation?.finish()
        if includePreRoll {
            let now = CACurrentMediaTime()
            preRollBuffers.removeAll { now - $0.endTime > 1.2 }
            totalBufferedFrames = preRollBuffers.reduce(0) { $0 + Int($1.buffer.frameLength) }
            trimPreRollToLimit()
            for item in preRollBuffers {
                continuation.yield(AnalyzerInput(buffer: item.buffer))
            }
        }
        preRollBuffers.removeAll(keepingCapacity: true)
        totalBufferedFrames = 0
        activeContinuation = continuation
    }

    func endStreaming() {
        let cont = activeContinuation
        activeContinuation = nil
        cont?.finish()
    }

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> CGFloat? {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { return nil }
        let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)
        guard numSamples > 0,
              let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer),
              let asbdPtr = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else {
            return nil
        }

        let asbd = asbdPtr.pointee
        let isSignedInt = (asbd.mFormatFlags & kAudioFormatFlagIsSignedInteger) != 0
        let isBigEndian = (asbd.mFormatFlags & kAudioFormatFlagIsBigEndian) != 0
        let isNonInterleaved = (asbd.mFormatFlags & kAudioFormatFlagIsNonInterleaved) != 0
        guard asbd.mFormatID == kAudioFormatLinearPCM,
              abs(asbd.mSampleRate - 16000.0) < 1.0,
              asbd.mBitsPerChannel == 16,
              asbd.mChannelsPerFrame >= 1,
              isSignedInt,
              !isBigEndian else {
            return nil
        }

        var blockBuffer: CMBlockBuffer?
        var audioBufferList = AudioBufferList()
        let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: 0,
            blockBufferOut: &blockBuffer
        )
        guard status == noErr,
              audioBufferList.mNumberBuffers >= 1,
              let rawPtr = audioBufferList.mBuffers.mData else {
            return nil
        }

        let channels = isNonInterleaved ? 1 : Int(max(1, asbd.mChannelsPerFrame))
        let availableInt16Count = Int(audioBufferList.mBuffers.mDataByteSize) / MemoryLayout<Int16>.size
        let frameCount = min(numSamples, availableInt16Count / channels)
        guard frameCount > 0,
              let pcmBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: AVAudioFrameCount(frameCount)),
              let dstChannel = pcmBuffer.int16ChannelData?[0] else {
            return nil
        }
        pcmBuffer.frameLength = AVAudioFrameCount(frameCount)

        let srcSamples = rawPtr.assumingMemoryBound(to: Int16.self)
        if channels == 1 {
            memcpy(dstChannel, srcSamples, frameCount * MemoryLayout<Int16>.size)
        } else {
            for i in 0..<frameCount {
                dstChannel[i] = srcSamples[i * channels]
            }
        }

        if let continuation = activeContinuation {
            continuation.yield(AnalyzerInput(buffer: pcmBuffer))

            var sumSquares: Float = 0
            for i in 0..<frameCount {
                let norm = Float(dstChannel[i]) / 32768.0
                sumSquares += norm * norm
            }
            let rms = sqrt(sumSquares / Float(frameCount))
            return CGFloat(min(1.0, max(0.06, pow(rms * 6.5, 0.65))))
        } else {
            appendToPreRoll(pcmBuffer)
            return nil
        }
    }

    private func appendToPreRoll(_ buffer: AVAudioPCMBuffer) {
        let frames = Int(buffer.frameLength)
        guard frames > 0, maxPreRollFrames > 0 else { return }
        preRollBuffers.append((CACurrentMediaTime(), buffer))
        totalBufferedFrames += frames
        trimPreRollToLimit()
    }

    private func trimPreRollToLimit() {
        while totalBufferedFrames > maxPreRollFrames, let first = preRollBuffers.first {
            let firstFrames = Int(first.buffer.frameLength)
            let excessFrames = totalBufferedFrames - maxPreRollFrames
            if excessFrames >= firstFrames {
                preRollBuffers.removeFirst()
                totalBufferedFrames -= firstFrames
            } else if let trimmed = Self.sliceBuffer(first.buffer, startFrame: excessFrames, frameCount: firstFrames - excessFrames) {
                preRollBuffers[0] = (first.endTime, trimmed)
                totalBufferedFrames -= excessFrames
            } else {
                break
            }
        }
    }

    private static func sliceBuffer(_ source: AVAudioPCMBuffer, startFrame: Int, frameCount: Int) -> AVAudioPCMBuffer? {
        guard frameCount > 0,
              startFrame >= 0,
              startFrame + frameCount <= Int(source.frameLength),
              let srcData = source.int16ChannelData?[0],
              let sliced = AVAudioPCMBuffer(pcmFormat: source.format, frameCapacity: AVAudioFrameCount(frameCount)),
              let dstData = sliced.int16ChannelData?[0] else {
            return nil
        }
        sliced.frameLength = AVAudioFrameCount(frameCount)
        memcpy(dstData, srcData.advanced(by: startFrame), frameCount * MemoryLayout<Int16>.size)
        return sliced
    }
}

// MARK: - Core Audio Capture & Apple Native Speech Engine

@MainActor
final class DictationController: NSObject, ObservableObject {
    enum State: Equatable {
        case idle
        case recording
        case finalizing
    }

    @Published var showAppearance = false
    @Published var showOnboarding = !UserDefaults.standard.bool(forKey: "completedOnboarding")
    @Published var onboardingStep = 0
    @Published var state: State = .idle
    @Published var volatileTranscript: String = ""
    @Published var finalizedTranscript: String = ""
    @Published var audioLevels: [CGFloat] = Array(repeating: 0.08, count: 28)
    @Published var history: [TranscriptRecord] = []
    @Published var accessibilityGranted: Bool = false
    @Published var microphoneGranted: Bool = false
    @Published var captureReady: Bool = false
    @Published var errorMessage: String? = nil

    // User Settings
    private var isLoadingSettings: Bool = false

    @Published var instantPreRollEnabled: Bool = true {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(instantPreRollEnabled, forKey: "instantPreRollEnabled")
            syncCaptureSessionState()
        }
    }
    @Published var preRollMs: Double = 380 {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(preRollMs, forKey: "preRollMs")
            let ms = preRollMs
            captureQueue.async { [pipeline] in
                pipeline.setPreRollMilliseconds(ms)
            }
        }
    }
    @Published var autoPasteEnabled: Bool = true {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(autoPasteEnabled, forKey: "autoPasteEnabled")
        }
    }
    @Published var soundEffectsEnabled: Bool = true {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(soundEffectsEnabled, forKey: "soundEffectsEnabled")
        }
    }
    @Published var triggerKey: TriggerKeyOption = .rightCommand {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(triggerKey.rawValue, forKey: "triggerKey")
            if isTriggerPhysicallyDown {
                isTriggerPhysicallyDown = false
                if state == .recording {
                    stopDictation()
                }
            }
        }
    }

    // Serialized Capture & Pipeline Internals
    nonisolated let captureSession = AVCaptureSession()
    nonisolated let audioOutput = AVCaptureAudioDataOutput()
    nonisolated let captureQueue = DispatchQueue(label: "app.auradictate.public.capture", qos: .userInteractive)
    nonisolated let pipeline = CapturePipelineState()
    nonisolated(unsafe) private var isSessionConfigured: Bool = false

    // SpeechAnalyzer State
    private var preparedAnalyzer: SpeechAnalyzer?
    private var preparedTranscriber: SpeechTranscriber?
    private var warmUpTask: Task<Void, Never>?

    private var activeAnalyzer: SpeechAnalyzer?
    private var activeTranscriber: SpeechTranscriber?
    private var activeStartupTask: Task<Bool, Never>?
    private var activeResultsTask: Task<Void, Never>?
    private var activeFinalizationTasks: [UUID: Task<Void, Never>] = [:]
    private var recordingStartTime: CFAbsoluteTime = 0
    private var targetPasteAppPID: pid_t? = nil

    // Pasteboard Serialization
    private struct PasteboardItemSnapshot {
        let representations: [(NSPasteboard.PasteboardType, Data)]
    }
    private var savedUserClipboard: [PasteboardItemSnapshot]? = nil
    private var lastDictationChangeCount: Int? = nil
    private var clipboardRestoreWorkItem: DispatchWorkItem? = nil

    // Physical Key Tracking
    private var isTriggerPhysicallyDown: Bool = false

    // Monitors, CGEventTap & Observers
    private var globalFlagsMonitor: Any?
    private var localFlagsMonitor: Any?
    private var eventTap: CFMachPort?
    private var eventTapSource: CFRunLoopSource?
    private var permissionTimer: Timer?
    private var deviceObservers: [NSObjectProtocol] = []
    private var isShutDown: Bool = false

    var onHUDVisibilityChange: ((Bool) -> Void)?

    override init() {
        super.init()
        loadSettings()
        installDeviceObservers()
        installKeyboardMonitors()
        refreshPermissionsAndConfigureIfNeeded()
        warmUpTask = Task { [weak self] in
            await self?.ensureSpeechAssetsAndWarmUp()
        }
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.refreshPermissionsAndConfigureIfNeeded()
            }
        }
    }

    private func loadSettings() {
        isLoadingSettings = true
        defer { isLoadingSettings = false }

        let defaults = UserDefaults.standard
        if defaults.object(forKey: "instantPreRollEnabled") != nil {
            instantPreRollEnabled = defaults.bool(forKey: "instantPreRollEnabled")
        }
        if defaults.object(forKey: "preRollMs") != nil {
            preRollMs = defaults.double(forKey: "preRollMs")
        }
        if defaults.object(forKey: "autoPasteEnabled") != nil {
            autoPasteEnabled = defaults.bool(forKey: "autoPasteEnabled")
        }
        if defaults.object(forKey: "soundEffectsEnabled") != nil {
            soundEffectsEnabled = defaults.bool(forKey: "soundEffectsEnabled")
        }
        if let rawTrigger = defaults.string(forKey: "triggerKey") {
            if let opt = TriggerKeyOption(rawValue: rawTrigger) {
                triggerKey = opt
            } else if rawTrigger.lowercased().contains("command") {
                triggerKey = .rightCommand
            } else if rawTrigger.lowercased().contains("fn") {
                triggerKey = .fnKey
            } else if rawTrigger.lowercased().contains("option") {
                triggerKey = .rightOption
            }
        }

        let initialMs = preRollMs
        captureQueue.async { [pipeline] in
            pipeline.setPreRollMilliseconds(initialMs)
        }

        if let data = defaults.data(forKey: "dictationHistory"),
           let decoded = try? JSONDecoder().decode([TranscriptRecord].self, from: data) {
            history = decoded
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(Array(history.prefix(50))) {
            UserDefaults.standard.set(data, forKey: "dictationHistory")
        }
    }

    // MARK: - Permissions & Device Hot-Plug Recovery

    func refreshPermissionsAndConfigureIfNeeded() {
        let trusted = AXIsProcessTrusted()
        if trusted && !accessibilityGranted {
            installCGEventTapIfNeeded()
        }
        accessibilityGranted = trusted

        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let wasGranted = microphoneGranted
        microphoneGranted = (micStatus == .authorized)

        if micStatus == .authorized {
            if errorMessage == "Microphone permission required" { errorMessage = nil }
            if !wasGranted || !captureReady {
                rebuildCaptureSessionInput()
            } else {
                syncCaptureSessionState()
            }
        } else {
            captureReady = false
            if micStatus == .denied || micStatus == .restricted {
                errorMessage = "Microphone permission required"
            }
        }
    }

    func promptMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
                Task { @MainActor in self?.refreshPermissionsAndConfigureIfNeeded() }
            }
        case .authorized:
            refreshPermissionsAndConfigureIfNeeded()
        default:
            openPrivacySettings("Privacy_Microphone")
        }
    }

    func promptAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        accessibilityGranted = AXIsProcessTrustedWithOptions(options)
        if accessibilityGranted {
            installCGEventTapIfNeeded()
        } else {
            openPrivacySettings("Privacy_Accessibility")
        }
    }

    private func openPrivacySettings(_ pane: String) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(pane)") {
            NSWorkspace.shared.open(url)
        }
    }

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "completedOnboarding")
        showOnboarding = false
    }

    private func installDeviceObservers() {
        let nc = NotificationCenter.default
        let connected = nc.addObserver(forName: AVCaptureDevice.wasConnectedNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.rebuildCaptureSessionInput() }
        }
        let disconnected = nc.addObserver(forName: AVCaptureDevice.wasDisconnectedNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.rebuildCaptureSessionInput() }
        }
        let runtimeErr = nc.addObserver(forName: AVCaptureSession.runtimeErrorNotification, object: captureSession, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.rebuildCaptureSessionInput() }
        }
        deviceObservers = [connected, disconnected, runtimeErr]
    }

    private func rebuildCaptureSessionInput() {
        guard microphoneGranted else { return }
        let shouldRun = instantPreRollEnabled || state != .idle
        captureQueue.async { [weak self] in
            guard let self else { return }
            self.pipeline.clearPreRoll()

            guard let device = AVCaptureDevice.default(for: .audio),
                  let newInput = try? AVCaptureDeviceInput(device: device) else {
                self.isSessionConfigured = false
                Task { @MainActor [weak self] in
                    self?.captureReady = false
                    self?.errorMessage = "No microphone available"
                }
                return
            }

            self.captureSession.beginConfiguration()
            for oldInput in self.captureSession.inputs {
                self.captureSession.removeInput(oldInput)
            }

            self.audioOutput.audioSettings = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            self.audioOutput.setSampleBufferDelegate(self, queue: self.captureQueue)

            var outputOK = self.captureSession.outputs.contains(self.audioOutput)
            if !outputOK && self.captureSession.canAddOutput(self.audioOutput) {
                self.captureSession.addOutput(self.audioOutput)
                outputOK = true
            }

            var inputOK = false
            if self.captureSession.canAddInput(newInput) {
                self.captureSession.addInput(newInput)
                inputOK = true
            }
            self.captureSession.commitConfiguration()

            let configuredOK = outputOK && inputOK
            self.isSessionConfigured = configuredOK

            if configuredOK && shouldRun {
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            } else if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.captureReady = configuredOK
                if configuredOK && self.errorMessage == "No microphone available" {
                    self.errorMessage = nil
                } else if !configuredOK {
                    self.errorMessage = "Audio capture configuration failed"
                }
            }
        }
    }

    private func syncCaptureSessionState() {
        guard microphoneGranted else { return }
        let shouldRun = instantPreRollEnabled || state != .idle
        captureQueue.async { [weak self] in
            guard let self else { return }
            guard self.isSessionConfigured else {
                Task { @MainActor [weak self] in self?.rebuildCaptureSessionInput() }
                return
            }
            if shouldRun {
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            } else {
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                }
                self.pipeline.clearPreRoll()
            }
        }
    }

    // MARK: - SpeechTranscriber Asset Verification & Pre-Warming

    private func ensureSpeechAssetsAndWarmUp() async {
        guard !Task.isCancelled else { return }
        guard SpeechTranscriber.isAvailable else {
            errorMessage = "Apple SpeechTranscriber unavailable"
            return
        }

        let targetLocale = Locale(identifier: "en_US")
        let transcriber = SpeechTranscriber(locale: targetLocale, preset: .progressiveTranscription)
        if let installReq = try? await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try? await installReq.downloadAndInstall()
        }
        await warmUpNextAnalyzer()
    }

    private func warmUpNextAnalyzer() async {
        guard !Task.isCancelled, !isShutDown, preparedAnalyzer == nil else { return }
        do {
            let locale = Locale(identifier: "en_US")
            let transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)
            let analyzer = SpeechAnalyzer(modules: [transcriber])
            try await analyzer.prepareToAnalyze(in: pipeline.targetFormat)
            guard !Task.isCancelled, !isShutDown else {
                await analyzer.cancelAndFinishNow()
                return
            }
            self.preparedTranscriber = transcriber
            self.preparedAnalyzer = analyzer
        } catch {
            if !Task.isCancelled {
                self.errorMessage = "Speech engine warm-up failed"
            }
        }
    }

    // MARK: - Global & Local Push-To-Talk Monitors (NSEvent + CGEventTap)

    private func installKeyboardMonitors() {
        globalFlagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleNSEventFlagsChanged(event)
            }
        }
        localFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleNSEventFlagsChanged(event)
            }
            return event
        }
        installCGEventTapIfNeeded()
    }

    private func installCGEventTapIfNeeded() {
        guard eventTap == nil else { return }
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let refcon = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo -> Unmanaged<CGEvent>? in
                guard let userInfo else { return Unmanaged.passUnretained(event) }
                let controller = Unmanaged<DictationController>.fromOpaque(userInfo).takeUnretainedValue()
                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    Task { @MainActor in
                        if let tap = controller.eventTap {
                            CGEvent.tapEnable(tap: tap, enable: true)
                        }
                    }
                    return Unmanaged.passUnretained(event)
                }
                guard type == .flagsChanged else { return Unmanaged.passUnretained(event) }
                let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                let flags = event.flags
                Task { @MainActor in
                    controller.handleRawFlagsEvent(keyCode: keyCode, cgFlags: flags)
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: refcon
        ) else {
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.eventTap = tap
        self.eventTapSource = source
    }

    private func handleNSEventFlagsChanged(_ event: NSEvent) {
        let target = triggerKey
        if event.keyCode == target.keyCode {
            applyTriggerTransition(physicallyPressed: target.isPressed(in: event.modifierFlags))
        } else if isTriggerPhysicallyDown && !target.isPressed(in: event.modifierFlags) {
            applyTriggerTransition(physicallyPressed: false)
        }
    }

    private func handleRawFlagsEvent(keyCode: UInt16, cgFlags: CGEventFlags) {
        let target = triggerKey
        if keyCode == target.keyCode {
            applyTriggerTransition(physicallyPressed: target.isPressed(in: cgFlags))
        } else if isTriggerPhysicallyDown && !target.isPressed(in: cgFlags) {
            applyTriggerTransition(physicallyPressed: false)
        }
    }

    private func applyTriggerTransition(physicallyPressed: Bool) {
        guard physicallyPressed != isTriggerPhysicallyDown else { return }
        isTriggerPhysicallyDown = physicallyPressed

        if physicallyPressed {
            startDictation()
        } else if state == .recording {
            stopDictation()
        }
    }

    // MARK: - Start / Stop Live Dictation

    func startDictation() {
        guard state != .recording else { return }
        guard microphoneGranted && captureReady else {
            errorMessage = microphoneGranted ? "Microphone unavailable" : "Grant microphone access first"
            refreshPermissionsAndConfigureIfNeeded()
            return
        }

        errorMessage = nil
        state = .recording
        volatileTranscript = ""
        finalizedTranscript = ""
        recordingStartTime = CFAbsoluteTimeGetCurrent()
        targetPasteAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
        onHUDVisibilityChange?(true)

        if soundEffectsEnabled {
            NSSound(named: "Tink")?.play()
        }

        let (stream, continuation) = AsyncStream<AnalyzerInput>.makeStream(
            bufferingPolicy: .bufferingNewest(512)
        )
        let usePreRoll = instantPreRollEnabled

        captureQueue.async { [weak self] in
            guard let self else {
                continuation.finish()
                return
            }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            self.pipeline.beginStreaming(continuation: continuation, includePreRoll: usePreRoll)
        }

        let transcriber: SpeechTranscriber
        let analyzer: SpeechAnalyzer
        if let prepT = preparedTranscriber, let prepA = preparedAnalyzer {
            transcriber = prepT
            analyzer = prepA
            preparedTranscriber = nil
            preparedAnalyzer = nil
        } else {
            let locale = Locale(identifier: "en_US")
            transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)
            analyzer = SpeechAnalyzer(modules: [transcriber])
        }

        activeTranscriber = transcriber
        activeAnalyzer = analyzer

        warmUpTask = Task { [weak self] in
            await self?.warmUpNextAnalyzer()
        }

        activeResultsTask = Task { [weak self] in
            do {
                for try await result in transcriber.results {
                    guard let self else { break }
                    let piece = String(result.text.characters).trimmingCharacters(in: .whitespacesAndNewlines)
                    if result.isFinal {
                        if !piece.isEmpty {
                            self.finalizedTranscript = Self.appendSegment(existing: self.finalizedTranscript, next: piece)
                        }
                        self.volatileTranscript = ""
                    } else {
                        self.volatileTranscript = piece
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self?.errorMessage = "Transcription interrupted"
                }
            }
        }

        activeStartupTask = Task { [weak self] in
            do {
                try await analyzer.start(inputSequence: stream)
                return true
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self?.errorMessage = "Speech analyzer failed to start"
                    }
                }
                return false
            }
        }
    }

    func stopDictation() {
        guard state == .recording else { return }
        state = .finalizing
        let releaseTime = CFAbsoluteTimeGetCurrent()
        let duration = max(0.1, releaseTime - recordingStartTime)
        let capturedTargetPID = targetPasteAppPID

        let sessionAnalyzer = activeAnalyzer
        let sessionStartupTask = activeStartupTask
        let sessionResultsTask = activeResultsTask
        activeAnalyzer = nil
        activeTranscriber = nil
        activeStartupTask = nil
        activeResultsTask = nil

        let taskID = UUID()
        let finalizeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.activeFinalizationTasks.removeValue(forKey: taskID) }

            try? await Task.sleep(nanoseconds: 50_000_000)

            if self.state == .finalizing {
                let pipe = self.pipeline
                await withCheckedContinuation { (done: CheckedContinuation<Void, Never>) in
                    self.captureQueue.async {
                        pipe.endStreaming()
                        done.resume()
                    }
                }
            }

            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    let startedOK = await (sessionStartupTask?.value ?? false)
                    if startedOK, let sessionAnalyzer {
                        try? await sessionAnalyzer.finalizeAndFinishThroughEndOfInput()
                    } else if let sessionAnalyzer {
                        await sessionAnalyzer.cancelAndFinishNow()
                    }
                    _ = await sessionResultsTask?.value
                }
                group.addTask {
                    do {
                        try await Task.sleep(nanoseconds: 2_500_000_000)
                        sessionStartupTask?.cancel()
                        sessionResultsTask?.cancel()
                        if let sessionAnalyzer {
                            await sessionAnalyzer.cancelAndFinishNow()
                        }
                    } catch {}
                }
                _ = await group.next()
                group.cancelAll()
            }

            let latency = (CFAbsoluteTimeGetCurrent() - releaseTime) * 1000.0

            let combined = Self.appendSegment(
                existing: self.finalizedTranscript,
                next: self.volatileTranscript
            )

            if !combined.isEmpty {
                let record = TranscriptRecord(
                    id: UUID(),
                    text: combined,
                    timestamp: Date(),
                    durationSeconds: duration,
                    latencyMs: latency,
                    usedPreRoll: self.instantPreRollEnabled
                )
                self.history.insert(record, at: 0)
                self.saveHistory()

                if self.soundEffectsEnabled {
                    NSSound(named: "Pop")?.play()
                }

                if self.autoPasteEnabled {
                    self.pasteTextIntoActiveApp(combined, expectedPID: capturedTargetPID)
                } else {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(combined, forType: .string)
                }
            }

            if self.state == .finalizing {
                self.state = .idle
                self.audioLevels = Array(repeating: 0.08, count: 28)
                self.syncCaptureSessionState()

                try? await Task.sleep(nanoseconds: 200_000_000)
                if self.state == .idle {
                    self.onHUDVisibilityChange?(false)
                }
            }
        }
        activeFinalizationTasks[taskID] = finalizeTask
    }

    private static func appendSegment(existing: String, next: String) -> String {
        let a = existing.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = next.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !a.isEmpty else { return b }
        guard !b.isEmpty else { return a }
        if let firstChar = b.first, ",.!?;:)]}".contains(firstChar) {
            return a + b
        }
        return a + " " + b
    }

    // MARK: - Serialized Auto-Paste with Original User Clipboard Preservation

    func pasteTextIntoActiveApp(_ text: String, expectedPID: pid_t?) {
        let pb = NSPasteboard.general

        guard AXIsProcessTrusted() else {
            pb.clearContents()
            pb.setString(text, forType: .string)
            errorMessage = "Copied (Enable Accessibility for auto-paste)"
            return
        }

        let currentFrontPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
        if let expectedPID, let currentFrontPID, currentFrontPID != expectedPID {
            pb.clearContents()
            pb.setString(text, forType: .string)
            return
        }

        clipboardRestoreWorkItem?.cancel()
        clipboardRestoreWorkItem = nil

        if savedUserClipboard == nil || (lastDictationChangeCount != nil && pb.changeCount != lastDictationChangeCount) {
            savedUserClipboard = (pb.pasteboardItems ?? []).map { item in
                let reps = item.types.compactMap { type -> (NSPasteboard.PasteboardType, Data)? in
                    guard let data = item.data(forType: type) else { return nil }
                    return (type, data)
                }
                return PasteboardItemSnapshot(representations: reps)
            }
        }

        pb.clearContents()
        pb.setString(text, forType: .string)
        let writtenCount = pb.changeCount
        lastDictationChangeCount = writtenCount

        let src = CGEventSource(stateID: .combinedSessionState)
        let vKeyCode: CGKeyCode = 9
        if let keyDown = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: false) {
            keyDown.flags = .maskCommand
            keyUp.flags = .maskCommand
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
        }

        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                defer {
                    self.savedUserClipboard = nil
                    self.lastDictationChangeCount = nil
                    self.clipboardRestoreWorkItem = nil
                }
                guard pb.changeCount == writtenCount, let snapshot = self.savedUserClipboard else { return }
                pb.clearContents()
                let restoredItems: [NSPasteboardItem] = snapshot.compactMap { itemSnap in
                    guard !itemSnap.representations.isEmpty else { return nil }
                    let item = NSPasteboardItem()
                    for (type, data) in itemSnap.representations {
                        item.setData(data, forType: type)
                    }
                    return item
                }
                if !restoredItems.isEmpty {
                    pb.writeObjects(restoredItems)
                }
            }
        }
        clipboardRestoreWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: workItem)
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    var currentDisplayText: String {
        Self.appendSegment(existing: finalizedTranscript, next: volatileTranscript)
    }

    // MARK: - Explicit Idempotent Shutdown

    func shutdown() {
        guard !isShutDown else { return }
        isShutDown = true

        permissionTimer?.invalidate()
        permissionTimer = nil

        clipboardRestoreWorkItem?.cancel()
        clipboardRestoreWorkItem = nil

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let src = eventTapSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes)
            }
            eventTap = nil
            eventTapSource = nil
        }

        if let globalFlagsMonitor {
            NSEvent.removeMonitor(globalFlagsMonitor)
            self.globalFlagsMonitor = nil
        }
        if let localFlagsMonitor {
            NSEvent.removeMonitor(localFlagsMonitor)
            self.localFlagsMonitor = nil
        }
        for obs in deviceObservers {
            NotificationCenter.default.removeObserver(obs)
        }
        deviceObservers.removeAll()

        warmUpTask?.cancel()
        activeStartupTask?.cancel()
        activeResultsTask?.cancel()
        for (_, task) in activeFinalizationTasks {
            task.cancel()
        }
        activeFinalizationTasks.removeAll()

        let analyzersToCancel = [activeAnalyzer, preparedAnalyzer].compactMap { $0 }
        activeAnalyzer = nil
        preparedAnalyzer = nil
        for analyzer in analyzersToCancel {
            Task { await analyzer.cancelAndFinishNow() }
        }

        captureQueue.sync {
            audioOutput.setSampleBufferDelegate(nil, queue: nil)
            pipeline.endStreaming()
            pipeline.clearPreRoll()
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate

extension DictationController: AVCaptureAudioDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let scaledLevel = pipeline.processSampleBuffer(sampleBuffer) else { return }

        Task { @MainActor [weak self] in
            guard let self, self.state == .recording else { return }
            var next = self.audioLevels
            if !next.isEmpty {
                next.removeFirst()
                next.append(scaledLevel)
                self.audioLevels = next
            }
        }
    }
}

// MARK: - Floating HUD Panel

final class FloatingHUDPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel, .hudWindow, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// MARK: - Minimal Floating HUD View

struct ImmersiveHUDView: View {
    @ObservedObject var controller: DictationController
    @AppStorage("appearanceBackground") private var backgroundHex = "0E1118"
    @AppStorage("appearanceSurface") private var surfaceHex = "171B24"
    @AppStorage("appearanceAccent") private var accentHex = "E04755"
    @AppStorage("appearanceLogo") private var logoHex = "E04755"
    @AppStorage("appearanceOutline") private var outlineHex = "383E4E"
    @AppStorage("appearanceLogoShape") private var logoShape = "waveform"
    @AppStorage("appearanceBoxShape") private var boxShape = "rounded"
    @AppStorage("appearanceBorderWidth") private var borderWidth = 1.0
    @AppStorage("appearancePattern") private var pattern = "grid"

    private var background: Color { AuraStyle.color(backgroundHex, fallback: 0x0E1118) }
    private var surface: Color { AuraStyle.color(surfaceHex, fallback: 0x171B24) }
    private var accent: Color { AuraStyle.color(accentHex, fallback: 0xE04755) }
    private var logoColor: Color { AuraStyle.color(logoHex, fallback: 0xE04755) }
    private var outline: Color { AuraStyle.color(outlineHex, fallback: 0x383E4E) }
    private var cornerRadius: CGFloat { boxShape == "square" ? 3 : boxShape == "pill" ? 26 : 10 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)
                .overlay(
                    ChassisPatternOverlay(pattern: pattern, tint: outline)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            controller.state == .recording ? accent : outline,
                            lineWidth: max(1.0, borderWidth)
                        )
                )

            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    AuraMark(shape: logoShape, color: logoColor, size: 22)
                    Text(controller.state == .recording ? "REC" : "SYNC")
                        .font(AuraStyle.displayFont(size: 10))
                        .tracking(0.8)
                        .foregroundStyle(controller.state == .recording ? accent : AuraStyle.grayscale70)
                }

                Rectangle()
                    .fill(outline.opacity(0.65))
                    .frame(width: 1, height: 24)

                Text(controller.currentDisplayText.isEmpty ? "Listening..." : controller.currentDisplayText)
                    .font(AuraStyle.bodyMedium(size: 14.5))
                    .foregroundStyle(controller.currentDisplayText.isEmpty ? AuraStyle.grayscale60 : AuraStyle.grayscale100)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(outline.opacity(0.65))
                    .frame(width: 1, height: 24)

                HStack(alignment: .center, spacing: 3) {
                    ForEach(Array(controller.audioLevels.suffix(12).enumerated()), id: \.offset) { _, level in
                        RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                            .fill(AuraStyle.meterGradient(accent: accent))
                            .frame(width: 3, height: max(4, level * 26))
                            .animation(.linear(duration: 0.08), value: level)
                    }
                }
                .frame(height: 28)
            }
            .padding(.horizontal, 16)
        }
        .frame(width: 440, height: 52)
    }
}

// MARK: - Main Window

struct StudioMainView: View {
    @ObservedObject var controller: DictationController
    @AppStorage("appearanceBackground") private var backgroundHex = "0E1118"
    @AppStorage("appearanceSurface") private var surfaceHex = "171B24"
    @AppStorage("appearanceAccent") private var accentHex = "E04755"
    @AppStorage("appearanceLogo") private var logoHex = "E04755"
    @AppStorage("appearanceOutline") private var outlineHex = "383E4E"
    @AppStorage("appearanceLogoShape") private var logoShape = "waveform"
    @AppStorage("appearanceBoxShape") private var boxShape = "rounded"
    @AppStorage("appearanceBorderWidth") private var borderWidth = 1.0
    @AppStorage("appearancePattern") private var pattern = "grid"

    private var background: Color { AuraStyle.color(backgroundHex, fallback: 0x0E1118) }
    private var surface: Color { AuraStyle.color(surfaceHex, fallback: 0x171B24) }
    private var accent: Color { AuraStyle.color(accentHex, fallback: 0xE04755) }
    private var logoColor: Color { AuraStyle.color(logoHex, fallback: 0xE04755) }
    private var outline: Color { AuraStyle.color(outlineHex, fallback: 0x383E4E) }
    private var cornerRadius: CGFloat { boxShape == "square" ? 3 : boxShape == "pill" ? 20 : 10 }

    private func colorBinding(_ value: Binding<String>, fallback: UInt32) -> Binding<Color> {
        Binding(get: { AuraStyle.color(value.wrappedValue, fallback: fallback) },
                set: { value.wrappedValue = AuraStyle.hex($0) })
    }

    private func applyPreset(_ preset: AuraPreset) {
        backgroundHex = preset.backgroundHex
        surfaceHex = preset.surfaceHex
        accentHex = preset.accentHex
        logoHex = preset.logoHex
        outlineHex = preset.outlineHex
        boxShape = preset.boxShape
        pattern = preset.pattern
    }

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            ChassisPatternOverlay(pattern: pattern, tint: outline)
                .ignoresSafeArea()

            if controller.showOnboarding {
                OnboardingView(controller: controller, accent: accent, surface: surface, outline: outline, cornerRadius: cornerRadius)
            } else {
                VStack(spacing: 14) {
                    headerBar
                    visualizerPanel
                    controlsBar
                    historyList
                }
                .padding(20)
            }
        }
        .frame(minWidth: 580, minHeight: 500)
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var headerBar: some View {
        HStack(spacing: 12) {
            AuraMark(shape: logoShape, color: logoColor, size: 26)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("AURA DICTATE")
                    .font(AuraStyle.displayFont(size: 19))
                    .tracking(0.6)
                    .foregroundStyle(AuraStyle.grayscale100)

                Text(controller.state == .recording ? "● ON AIR" : "● ARMED // \(controller.triggerKey.rawValue.uppercased())")
                    .font(AuraStyle.mono(size: 10.5, weight: .semibold))
                    .foregroundStyle(controller.state == .recording ? accent : AuraStyle.grayscale60)
            }

            if let err = controller.errorMessage {
                Text(err.uppercased())
                    .font(AuraStyle.mono(size: 10.5, weight: .bold))
                    .foregroundStyle(AuraStyle.error)
                    .padding(.leading, 4)
            }

            Spacer()

            if !controller.microphoneGranted {
                statusButton(label: "MIC OFF", action: { controller.promptMicrophonePermission() })
            }
            if !controller.accessibilityGranted {
                statusButton(label: "ACCESS OFF", action: { controller.promptAccessibilityPermission() })
            }

            Button {
                controller.showAppearance.toggle()
            } label: {
                HStack(spacing: 7) {
                    Circle()
                        .fill(accent)
                        .frame(width: 7, height: 7)
                    Text("CHASSIS")
                        .font(AuraStyle.displayFont(size: 10.5))
                        .tracking(0.8)
                        .foregroundStyle(AuraStyle.grayscale100)
                }
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background(
                    RoundedRectangle(cornerRadius: max(3, cornerRadius * 0.5), style: .continuous)
                        .fill(surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: max(3, cornerRadius * 0.5), style: .continuous)
                                .strokeBorder(controller.showAppearance ? accent : outline, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $controller.showAppearance, arrowEdge: .bottom) {
                appearanceSettings
            }
        }
    }

    private var appearanceSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("CHASSIS & APPEARANCE")
                    .font(AuraStyle.displayFont(size: 12))
                    .tracking(0.7)
                    .foregroundStyle(AuraStyle.grayscale100)
                Spacer()
                Button("RESET") {
                    applyPreset(AuraStyle.presets[0])
                    logoShape = "waveform"
                    borderWidth = 1.0
                }
                .font(AuraStyle.mono(size: 10, weight: .bold))
                .foregroundStyle(accent)
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("HARDWARE PRESETS")
                    .font(AuraStyle.mono(size: 9.5, weight: .semibold))
                    .foregroundStyle(AuraStyle.grayscale60)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(AuraStyle.presets) { preset in
                        Button {
                            applyPreset(preset)
                        } label: {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preset.name)
                                        .font(AuraStyle.displayFont(size: 10))
                                        .foregroundStyle(AuraStyle.grayscale100)
                                    Text(preset.subtitle)
                                        .font(AuraStyle.mono(size: 8.5))
                                        .foregroundStyle(AuraStyle.grayscale60)
                                        .lineLimit(1)
                                }
                                Spacer(minLength: 4)
                                HStack(spacing: 3) {
                                    Circle().fill(AuraStyle.color(preset.backgroundHex, fallback: 0x0E1118)).frame(width: 9, height: 9)
                                    Circle().fill(AuraStyle.color(preset.accentHex, fallback: 0xE04755)).frame(width: 9, height: 9)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(AuraStyle.color(preset.surfaceHex, fallback: 0x171B24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .strokeBorder(
                                                accentHex.uppercased() == preset.accentHex.uppercased()
                                                    ? AuraStyle.color(preset.accentHex, fallback: 0xE04755)
                                                    : AuraStyle.color(preset.outlineHex, fallback: 0x383E4E),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("COLOR TOKENS")
                    .font(AuraStyle.mono(size: 9.5, weight: .semibold))
                    .foregroundStyle(AuraStyle.grayscale60)

                HStack(spacing: 12) {
                    ColorPicker("Ground", selection: colorBinding($backgroundHex, fallback: 0x0E1118), supportsOpacity: false)
                    ColorPicker("Surface", selection: colorBinding($surfaceHex, fallback: 0x171B24), supportsOpacity: false)
                }
                .font(AuraStyle.bodyMedium(size: 12))

                HStack(spacing: 12) {
                    ColorPicker("Accent", selection: colorBinding($accentHex, fallback: 0xE04755), supportsOpacity: false)
                    ColorPicker("Mark", selection: colorBinding($logoHex, fallback: 0xE04755), supportsOpacity: false)
                    ColorPicker("Rule", selection: colorBinding($outlineHex, fallback: 0x383E4E), supportsOpacity: false)
                }
                .font(AuraStyle.bodyMedium(size: 12))
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Picker("Mark", selection: $logoShape) {
                    Text("Wave").tag("waveform")
                    Text("Disc").tag("circle")
                    Text("Mic").tag("microphone")
                }
                .pickerStyle(.segmented)
                .font(AuraStyle.bodyMedium(size: 11.5))

                Picker("Corner", selection: $boxShape) {
                    Text("Rounded").tag("rounded")
                    Text("Square").tag("square")
                    Text("Pill").tag("pill")
                }
                .pickerStyle(.segmented)
                .font(AuraStyle.bodyMedium(size: 11.5))

                Picker("Texture", selection: $pattern) {
                    Text("Grid").tag("grid")
                    Text("Mesh").tag("mesh")
                    Text("Scan").tag("scanline")
                    Text("Matte").tag("none")
                }
                .pickerStyle(.segmented)
                .font(AuraStyle.bodyMedium(size: 11.5))

                HStack {
                    Text("Rule Width")
                        .font(AuraStyle.bodyMedium(size: 12))
                    Slider(value: $borderWidth, in: 0.5...3.0, step: 0.5)
                    Text(String(format: "%.1fpt", borderWidth))
                        .font(AuraStyle.mono(size: 11))
                        .foregroundStyle(AuraStyle.grayscale70)
                }
            }
        }
        .padding(16)
        .frame(width: 330)
    }

    private func statusButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(AuraStyle.warning)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(AuraStyle.mono(size: 10, weight: .bold))
                    .foregroundStyle(AuraStyle.grayscale100)
            }
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(
                RoundedRectangle(cornerRadius: max(3, cornerRadius * 0.5), style: .continuous)
                    .fill(surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: max(3, cornerRadius * 0.5), style: .continuous)
                            .strokeBorder(AuraStyle.warning, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Live Meter & Transcript Stage

    private var visualizerPanel: some View {
        VStack(spacing: 14) {
            HStack {
                Text("[001] ACOUSTIC SIGNAL DECK")
                    .font(AuraStyle.mono(size: 10, weight: .semibold))
                    .foregroundStyle(AuraStyle.grayscale60)
                Spacer()
                Text(String(format: "16KHZ PCM // LAST %.0fMS", controller.history.first?.latencyMs ?? 0))
                    .font(AuraStyle.mono(size: 10, weight: .medium))
                    .foregroundStyle(AuraStyle.grayscale60)
            }

            HStack(alignment: .center, spacing: 5) {
                ForEach(Array(controller.audioLevels.enumerated()), id: \.offset) { _, level in
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .fill(
                            controller.state == .recording
                                ? AnyShapeStyle(AuraStyle.meterGradient(accent: accent))
                                : AnyShapeStyle(outline.opacity(0.45))
                        )
                        .frame(width: 6, height: max(6, level * 46))
                        .animation(.linear(duration: 0.08), value: level)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: max(2, cornerRadius * 0.6), style: .continuous)
                    .fill(background.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: max(2, cornerRadius * 0.6), style: .continuous)
                            .strokeBorder(outline.opacity(0.45), lineWidth: 0.8)
                    )
            )

            if !controller.currentDisplayText.isEmpty {
                Text(controller.currentDisplayText)
                    .font(AuraStyle.bodyMedium(size: 16))
                    .foregroundStyle(AuraStyle.grayscale100)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
            }

            HStack(spacing: 12) {
                Text("HOLD \(controller.triggerKey.rawValue.uppercased()) ANYWHERE TO DICTATE")
                    .font(AuraStyle.mono(size: 10.5, weight: .medium))
                    .foregroundStyle(AuraStyle.grayscale60)

                Spacer()

                Button {
                    if controller.state == .idle {
                        controller.startDictation()
                    } else if controller.state == .recording {
                        controller.stopDictation()
                    }
                } label: {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: controller.state == .recording ? 1.5 : 5)
                            .fill(AuraStyle.grayscale100)
                            .frame(width: 8, height: 8)
                        Text(controller.state == .recording ? "STOP" : "RECORD")
                            .font(AuraStyle.displayFont(size: 11.5))
                            .tracking(0.9)
                    }
                    .foregroundStyle(AuraStyle.grayscale100)
                    .padding(.horizontal, 18)
                    .frame(height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: max(3, cornerRadius * 0.55), style: .continuous)
                            .fill(controller.state == .recording ? AuraStyle.error : accent)
                    )
                }
                .buttonStyle(.plain)
                .disabled(controller.state == .finalizing)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(surface)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            controller.state == .recording ? accent : outline,
                            lineWidth: borderWidth
                        )
                )
        )
    }

    // MARK: Compact Single-Row Controls

    private var controlsBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("[KEY]")
                    .font(AuraStyle.mono(size: 10.5, weight: .semibold))
                    .foregroundStyle(AuraStyle.grayscale60)

                Picker("", selection: $controller.triggerKey) {
                    ForEach(TriggerKeyOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .labelsHidden()
                .frame(width: 105)
            }

            Rectangle()
                .fill(outline.opacity(0.6))
                .frame(width: 1, height: 16)

            Toggle("Pre-roll (\(Int(controller.preRollMs))ms)", isOn: $controller.instantPreRollEnabled)
                .font(AuraStyle.bodyMedium(size: 12.5))
                .foregroundStyle(AuraStyle.grayscale90)
                .tint(accent)

            Rectangle()
                .fill(outline.opacity(0.6))
                .frame(width: 1, height: 16)

            Toggle("Auto-paste", isOn: $controller.autoPasteEnabled)
                .font(AuraStyle.bodyMedium(size: 12.5))
                .foregroundStyle(AuraStyle.grayscale90)
                .tint(accent)

            Rectangle()
                .fill(outline.opacity(0.6))
                .frame(width: 1, height: 16)

            Toggle("Sounds", isOn: $controller.soundEffectsEnabled)
                .font(AuraStyle.bodyMedium(size: 12.5))
                .foregroundStyle(AuraStyle.grayscale90)
                .tint(accent)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(surface)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(outline, lineWidth: borderWidth)
                )
        )
    }

    // MARK: History List

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("[002] TRANSCRIPT LOG (\(controller.history.count))")
                    .font(AuraStyle.mono(size: 10.5, weight: .semibold))
                    .foregroundStyle(AuraStyle.grayscale60)

                Spacer()

                if !controller.history.isEmpty {
                    Button {
                        controller.clearHistory()
                    } label: {
                        Text("CLEAR ALL")
                            .font(AuraStyle.mono(size: 10, weight: .bold))
                            .foregroundStyle(AuraStyle.grayscale60)
                    }
                    .buttonStyle(.plain)
                }
            }

            if controller.history.isEmpty {
                HStack {
                    Spacer()
                    Text("NO TRANSCRIPTS RECORDED YET")
                        .font(AuraStyle.mono(size: 11, weight: .medium))
                        .foregroundStyle(AuraStyle.grayscale60.opacity(0.75))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(surface.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(outline.opacity(0.6), lineWidth: borderWidth)
                        )
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(controller.history.enumerated()), id: \.element.id) { index, item in
                            HStack(alignment: .center, spacing: 12) {
                                Text(String(format: "[%02d]", index + 1))
                                    .font(AuraStyle.mono(size: 10.5, weight: .semibold))
                                    .foregroundStyle(accent)

                                Text(item.text)
                                    .font(AuraStyle.bodyRegular(size: 14.5))
                                    .foregroundStyle(AuraStyle.grayscale100)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)

                                Text(String(format: "%.1fs · %.0fms", item.durationSeconds, item.latencyMs))
                                    .font(AuraStyle.mono(size: 10.5))
                                    .foregroundStyle(AuraStyle.grayscale60)

                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.text, forType: .string)
                                } label: {
                                    Text("COPY")
                                        .font(AuraStyle.mono(size: 10, weight: .bold))
                                        .foregroundStyle(AuraStyle.grayscale90)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                .fill(background.opacity(0.65))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                        .strokeBorder(outline, lineWidth: 0.8)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .fill(surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                            .strokeBorder(outline, lineWidth: borderWidth)
                                    )
                            )
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - First-run setup

struct OnboardingView: View {
    @ObservedObject var controller: DictationController
    let accent: Color
    let surface: Color
    var outline: Color = Color(red: 0.22, green: 0.24, blue: 0.30)
    var cornerRadius: CGFloat = 10

    private var step: Int { controller.onboardingStep }
    private var accessPaneName: String {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27
            ? "Device Control and Data Access" : "Accessibility"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                AuraMark(shape: "waveform", color: accent, size: 26)
                Text("AURA DICTATE // SETUP").font(AuraStyle.displayFont(size: 16))
                Spacer()
                Text(String(format: "[STEP 0%d / 04]", step + 1))
                    .font(AuraStyle.mono(size: 11, weight: .semibold))
                    .foregroundStyle(AuraStyle.grayscale60)
            }

            VStack(alignment: .leading, spacing: 14) {
                switch step {
                case 0:
                    Text("PRECISION LOCAL DICTATION")
                        .font(AuraStyle.displayFont(size: 22))
                    Text("Hold a shortcut anywhere on macOS, speak naturally, and release to inject text directly into your active cursor.")
                        .font(AuraStyle.bodyRegular(size: 15))
                    Text("100% on-device via Apple SpeechTranscriber. Zero network bandwidth, ~30 MB RAM, and customizable industrial themes.")
                        .font(AuraStyle.bodyRegular(size: 14))
                        .foregroundStyle(AuraStyle.grayscale70)
                case 1:
                    Text("MICROPHONE ACCESS")
                        .font(AuraStyle.displayFont(size: 22))
                    Text("Aura needs microphone access to capture 16kHz PCM audio and maintain its 380ms pre-roll ring buffer so your first syllable is never clipped.")
                        .font(AuraStyle.bodyRegular(size: 15))
                    permissionStatus(controller.microphoneGranted)
                    Button(controller.microphoneGranted ? "MICROPHONE ENABLED" : "ALLOW MICROPHONE") {
                        controller.promptMicrophonePermission()
                    }
                    .font(AuraStyle.displayFont(size: 11))
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .disabled(controller.microphoneGranted)
                case 2:
                    Text("ACCESSIBILITY ACCESS")
                        .font(AuraStyle.displayFont(size: 22))
                    Text("Accessibility lets Aura detect your Right ⌘ push-to-talk key globally and paste finished transcripts straight into the active window.")
                        .font(AuraStyle.bodyRegular(size: 15))
                    Text("In Privacy & Security → \(accessPaneName), enable Aura Dictate.")
                        .font(AuraStyle.bodyRegular(size: 14))
                        .foregroundStyle(AuraStyle.grayscale70)
                    permissionStatus(controller.accessibilityGranted)
                    Button(controller.accessibilityGranted ? "ACCESSIBILITY ENABLED" : "OPEN \(accessPaneName.uppercased())") {
                        controller.promptAccessibilityPermission()
                    }
                    .font(AuraStyle.displayFont(size: 11))
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .disabled(controller.accessibilityGranted)
                default:
                    Text("READY FOR DICTATION")
                        .font(AuraStyle.displayFont(size: 22))
                    Text("Click any text field, hold Right ⌘ while speaking, and release. Use the CHASSIS button in the top bar anytime to switch hardware themes, colors, or surface patterns.")
                        .font(AuraStyle.bodyRegular(size: 15))
                    if !controller.microphoneGranted || !controller.accessibilityGranted {
                        Text("Some permissions are still pending. You can reopen this guide anytime from the menu bar.")
                            .font(AuraStyle.bodyMedium(size: 13.5))
                            .foregroundStyle(AuraStyle.warning)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(outline, lineWidth: 1)
                    )
            )

            HStack {
                Button("SKIP FOR NOW") { controller.finishOnboarding() }
                    .font(AuraStyle.mono(size: 11, weight: .semibold))
                    .buttonStyle(.plain)
                    .foregroundStyle(AuraStyle.grayscale70)
                Spacer()
                if step > 0 {
                    Button("BACK") { controller.onboardingStep -= 1 }
                        .font(AuraStyle.mono(size: 11, weight: .semibold))
                }
                Button(step == 3 ? "LAUNCH DECK" : "NEXT →") {
                    if step == 3 { controller.finishOnboarding() }
                    else { controller.onboardingStep += 1 }
                }
                .font(AuraStyle.displayFont(size: 11))
                .buttonStyle(.borderedProminent)
                .tint(accent)
            }
        }
        .padding(26)
        .frame(maxWidth: 620, maxHeight: 520)
        .foregroundStyle(AuraStyle.grayscale100)
    }

    private func permissionStatus(_ granted: Bool) -> some View {
        Label(granted ? "STATUS: ENABLED" : "STATUS: AWAITING PERMISSION", systemImage: granted ? "checkmark.circle.fill" : "circle")
            .font(AuraStyle.mono(size: 11.5, weight: .semibold))
            .foregroundStyle(granted ? AuraStyle.success : AuraStyle.grayscale70)
    }
}

// MARK: - Application Delegate & Window Management

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: DictationController!
    var hudPanel: FloatingHUDPanel!
    var studioWindow: NSWindow!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        AuraStyle.registerBundledFonts()
        controller = DictationController()

        setupFloatingHUD()
        setupStudioWindow()
        setupMenuBarItem()

        controller.onHUDVisibilityChange = { [weak self] visible in
            guard let self else { return }
            if visible {
                self.positionHUDAtBottomCenter()
                self.hudPanel.alphaValue = 0
                self.hudPanel.orderFrontRegardless()
                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.14
                    self.hudPanel.animator().alphaValue = 1.0
                }
            } else {
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.16
                    self.hudPanel.animator().alphaValue = 0.0
                }, completionHandler: {
                    Task { @MainActor in
                        if self.controller.state == .idle {
                            self.hudPanel.orderOut(nil)
                        }
                    }
                })
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller?.shutdown()
    }

    private func setupFloatingHUD() {
        let rect = NSRect(x: 0, y: 0, width: 440, height: 52)
        hudPanel = FloatingHUDPanel(contentRect: rect)
        hudPanel.contentView = NSHostingView(rootView: ImmersiveHUDView(controller: controller))
        positionHUDAtBottomCenter()
    }

    private func positionHUDAtBottomCenter() {
        let screen = NSScreen.main ?? NSScreen.screens.first
        guard let visibleFrame = screen?.visibleFrame else { return }
        let x = visibleFrame.midX - 220
        let y = visibleFrame.minY + 36
        hudPanel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func setupStudioWindow() {
        let rect = NSRect(x: 0, y: 0, width: 600, height: 500)
        studioWindow = NSWindow(
            contentRect: rect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        studioWindow.title = "AuraDictate"
        studioWindow.titlebarAppearsTransparent = true
        studioWindow.titleVisibility = .hidden
        studioWindow.isMovableByWindowBackground = true
        studioWindow.backgroundColor = NSColor(red: 0.055, green: 0.068, blue: 0.095, alpha: 1)
        studioWindow.contentView = NSHostingView(rootView: StudioMainView(controller: controller))
        studioWindow.center()
        studioWindow.isReleasedWhenClosed = false
        // Only pop open automatically on first launch if permissions are missing; otherwise stay quietly in the menu bar
        if controller.showOnboarding || !controller.microphoneGranted || !controller.accessibilityGranted {
            studioWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "Aura")
        }

        let menu = NSMenu()
        let openItem = NSMenuItem(title: "Settings & History...", action: #selector(showStudioWindow), keyEquivalent: ",")
        openItem.target = self
        menu.addItem(openItem)

        let setupItem = NSMenuItem(title: "Setup Guide...", action: #selector(showSetupGuide), keyEquivalent: "")
        setupItem.target = self
        menu.addItem(setupItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Aura", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc func showSetupGuide() {
        controller.onboardingStep = 0
        controller.showOnboarding = true
        showStudioWindow()
    }

    @objc func showStudioWindow() {
        studioWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showStudioWindow()
        }
        return true
    }
}

// MARK: - Entry Point

@main
struct AuraDictateMain {
    static func main() {
        let app = NSApplication.shared
        // Accessory policy = Menu-bar utility only, NEVER shows an icon in the Dock
        app.setActivationPolicy(.accessory)
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
