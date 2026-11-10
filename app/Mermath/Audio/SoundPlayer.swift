import AVFoundation

/// Preloaded effect sounds. A soft chime for a right answer, a little fanfare
/// for the chest. Nothing ever plays on a wrong answer.
final class SoundPlayer {
    enum Effect: String, CaseIterable {
        case chime
        case fanfare
        case pop
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
