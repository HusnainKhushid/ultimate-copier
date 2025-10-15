import Foundation
import Combine

final class LogStore: ObservableObject {
    @Published private(set) var text: String = ""

    // Append text, coalescing small chunks efficiently
    func append(_ newText: String) {
        // You can add timestamping or filtering here if desired
        text.append(newText)
    }

    func clear() {
        text = ""
    }
}
