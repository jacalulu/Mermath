import AVFoundation

/// Preloaded effect sounds. A soft chime for a right answer, a little fanfare
/// for the chest. Nothing ever plays on a wrong answer.
final class SoundPlayer {
    enum Effect: String, CaseIterable {
        case chime
        case fanfare
        case pop
        case musicbox
        case rumble
        case note1, note2, note3, note4, note5

        /// The bonus-bubble melody, lowest to highest.
        static let notes: [Effect] = [.note1, .note2, .note3, .note4, .note5]
    }

    private var players: [Effect: AVAudioPlayer] = [:]

    init() {
        for effect in Effect.allCases {
            let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav", subdirectory: "Sounds")
                ?? Bundle.main.url(forResource: effect.rawValue, withExtension: "wav")
            if let url,
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                player.volume = 0.6
                players[effect] = player
            }
        }
    }

    func play(_ effect: Effect) {
        guard let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }
}
