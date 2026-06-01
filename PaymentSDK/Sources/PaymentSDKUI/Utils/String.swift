import Foundation

extension String {
    var extractedNumber: String? {
        let pattern = "\\d+"
        if let range = self.range(of: pattern, options: .regularExpression) {
            return String(self[range])
        }
        return nil
    }
    
    var removingNumbers: String {
        return self.replacingOccurrences(of: "\\d+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - String Sanitization Helpers
extension String {
    /// Truncate middle with 3...3 rule
    func truncatedMiddle() -> String {
        let keep = 3
        guard self.count > keep * 2 else { return self }
        return "\(prefix(keep))...\(suffix(keep))"
    }
}
