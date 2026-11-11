import AVFoundation

/// Preloaded effect sounds. A soft chime for a right answer, a little fanfare
/// for the chest. Nothing ever plays on a wrong answer.
final class SoundPlayer {
    enum Effect: String, CaseIterable {
        case chime
        case fanfare
        case pop
        case thud
        case musicbox
        case rumble
        case introMusic = "intro-music"
        case bubbleMusic = "bubble-music"
        case note1, note2, note3, note4, note5

        /// The bonus-bubble melody, lowest to highest.
        static let notes: [Effect] = [.note1, .note2, .note3, .note4, .note5]
    }

    private var players: [Effect: AVAudioPlayer] = [:]

    init() {
        for effect in Effect.allCases {
            var url: URL?
            for ext in ["wav", "mp3"] {
                url = Bundle.main.url(forResource: effect.rawValue, withExtension: ext, subdirectory: "Sounds")
                    ?? Bundle.main.url(forResource: effect.rawValue, withExtension: ext)
                if url != nil { break }
            }
            if let url,
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                // Music sits well under the voice
                player.volume = switch effect {
                case .introMusic: 0.24
                case .bubbleMusic: 0.34
                default: 0.6
                }
                players[effect] = player
            }
        }
    }

    func play(_ effect: Effect) {
        guard let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }

    /// Fade-free stop, for skipping out of the intro.
    func stop(_ effect: Effect) {
        players[effect]?.stop()
    }
}
