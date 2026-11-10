import AVFoundation

protocol PromptSpeaker {
    func speak(_ prompt: Prompt)
    func stop()
}

/// Speech-synthesis stand-in for the parent's voice. If a recording named
/// `<prompt id>.m4a` exists in the bundle's Voice folder, it is preferred.
final class SynthSpeaker: NSObject, PromptSpeaker {
    private let synthesizer = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?
    private let voice: AVSpeechSynthesisVoice?

    override init() {
        // Best available US English voice, preferring enhanced quality.
        let english = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
        voice = english.first { $0.quality == .premium }
            ?? english.first { $0.quality == .enhanced }
            ?? AVSpeechSynthesisVoice(language: "en-US")
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ prompt: Prompt) {
        stop()
        let recordedURL = Bundle.main.url(forResource: prompt.id, withExtension: "m4a", subdirectory: "Voice")
            ?? Bundle.main.url(forResource: prompt.id, withExtension: "m4a")
        if let url = recordedURL,
           let recorded = try? AVAudioPlayer(contentsOf: url) {
            player = recorded
            recorded.play()
            return
        }
        let utterance = AVSpeechUtterance(string: prompt.text)
        utterance.voice = voice
        utterance.rate = 0.42
        utterance.pitchMultiplier = 1.05
        synthesizer.speak(utterance)
    }

    func stop() {
        player?.stop()
        player = nil
        synthesizer.stopSpeaking(at: .immediate)
    }
}

/// For previews and tests.
final class SilentSpeaker: PromptSpeaker {
    func speak(_ prompt: Prompt) {}
    func stop() {}
}
