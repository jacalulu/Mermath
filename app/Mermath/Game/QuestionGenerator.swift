import Foundation

/// Builds three choices: the target plus two near distractors, shuffled.
private func choices(around target: Int, range: ClosedRange<Int>) -> [Int] {
    var pool = Set(range)
    pool.remove(target)
    // Prefer neighbours so the discrimination is meaningful but fair
    let near = pool.sorted { abs($0 - target) < abs($1 - target) }
    var picked = Array(Array(near.prefix(4)).shuffled().prefix(2))
    while picked.count < 2, let extra = pool.subtracting(picked).randomElement() {
        picked.append(extra)
    }
    return ([target] + picked).shuffled()
}

struct TidePoolGenerator {
    let level: TideLevel
    let rangeMax: Int

    private var range: ClosedRange<Int> { 1...max(3, rangeMax) }

    func next(avoiding lastTarget: Int?) -> Question {
        var target = range.randomElement() ?? 1
        while target == lastTarget, rangeMax > 2 {
            target = range.randomElement() ?? 1
        }
        let presentation: QuestionPresentation
        switch level {
        case .listen: presentation = .listen
        case .count: presentation = .count
        }
        return Question(target: target, choices: choices(around: target, range: range), presentation: presentation)
    }
}

struct CoralReefGenerator {
    /// Shells show until she has answered several in a row quickly; a wrong tap
    /// brings them back (open-questions.md #8 default).
    func next(avoiding lastTarget: Int?, quickStreak: Int) -> Question {
        var a = Int.random(in: 1...9)
        var b = Int.random(in: 1...(10 - a))
        if a + b == lastTarget {
            a = Int.random(in: 1...9)
            b = Int.random(in: 1...(10 - a))
        }
        let sum = a + b
        return Question(
            target: sum,
            choices: choices(around: sum, range: 2...10),
            presentation: .addition(a: a, b: b, showShells: quickStreak < 4)
        )
    }
}
