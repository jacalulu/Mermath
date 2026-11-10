import SwiftUI
import UIKit

/// Loads painted art from the bundled Art/ folder (a folder reference, so the
/// repo's assets/ paths carry over: "scenes/tide-pool/bg.jpg", "characters/crab/body.png", …).
/// Decoded images are cached for reuse across screens.
enum ArtStore {
    private static var cache: [String: UIImage] = [:]

    static func image(_ path: String) -> UIImage {
        if let cached = cache[path] { return cached }
        let full = "Art/" + path
        let sub = (full as NSString).deletingLastPathComponent
        let file = (full as NSString).lastPathComponent
        let name = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        guard
            let url = Bundle.main.url(forResource: name, withExtension: ext.isEmpty ? "png" : ext, subdirectory: sub),
            let image = UIImage(contentsOfFile: url.path)
        else {
            assertionFailure("Missing art: \(path)")
            return UIImage()
        }
        cache[path] = image
        return image
    }
}

/// A resizable image view over ArtStore. Pass the path under assets/, including extension.
struct ArtImage: View {
    let path: String

    init(_ path: String) { self.path = path }

    var body: some View {
        Image(uiImage: ArtStore.image(path))
            .resizable()
            .interpolation(.high)
    }
}
