import Foundation

/// Per-child progress, on the device only: a small JSON file in Application
/// Support, written through on every change.
final class ProgressStore {
    private let url: URL
    private var save: SaveFile

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = support.appendingPathComponent("Mermath", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        url = folder.appendingPathComponent("progress.json")
        if let data = try? Data(contentsOf: url),
           let loaded = try? JSONDecoder().decode(SaveFile.self, from: data) {
            save = loaded
        } else {
            save = SaveFile(children: ChildID.allCases.map { .fresh($0) })
        }
    }

    func progress(for child: ChildID) -> ChildProgress {
        save.children.first { $0.child == child } ?? .fresh(child)
    }

    func update(_ progress: ChildProgress) {
        if let i = save.children.firstIndex(where: { $0.child == progress.child }) {
            save.children[i] = progress
        } else {
            save.children.append(progress)
        }
        persist()
    }

    func reset(_ child: ChildID) {
        update(.fresh(child))
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(save) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
