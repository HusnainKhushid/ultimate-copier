import Foundation
import Combine

struct HistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let date: Date

    init(id: UUID = UUID(), text: String, date: Date = Date()) {
        self.id = id
        self.text = text
        self.date = date
    }
}

final class HistoryStore: ObservableObject {
    @Published private(set) var items: [HistoryItem] = [] {
        didSet { persist() }
    }

    private let userDefaultsKey = "ClipboardHistoryItems.v1"
    private let maxItems = 200

    init() {
        restore()
    }

    func add(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Avoid immediate duplicates (last item same text)
        if let last = items.first, last.text == trimmed {
            // Update timestamp instead of duplicating
            items[0] = HistoryItem(id: last.id, text: last.text, date: Date())
            return
        }

        items.insert(HistoryItem(text: trimmed), at: 0)
        if items.count > maxItems {
            items.removeLast(items.count - maxItems)
        }
    }

    func clear() {
        items.removeAll()
    }

    // MARK: - Persistence

    private func persist() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            // Non-fatal
            print("Failed to persist history: \(error)")
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            items = try JSONDecoder().decode([HistoryItem].self, from: data)
        } catch {
            // Non-fatal
            print("Failed to restore history: \(error)")
            items = []
        }
    }
}
