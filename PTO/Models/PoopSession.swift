import SwiftUI
import Foundation

enum PoopType: String, CaseIterable, Codable {
    case ghost = "Ghost"
    case normal = "Normal"
    case sticky = "Sticky"
    case explosive = "Explosive"
    case quick = "Quick"
    case marathon = "Marathon"
    
    var icon: String {
        switch self {
        case .ghost: return "👻"
        case .normal: return "💩"
        case .sticky: return "🍯"
        case .explosive: return "💥"
        case .quick: return "⚡"
        case .marathon: return "🏃"
        }
    }
    
    var color: Color {
        switch self {
        case .ghost: return .gray
        case .normal: return .brown
        case .sticky: return .orange
        case .explosive: return .red
        case .quick: return .blue
        case .marathon: return .purple
        }
    }
}

enum MoodType: String, CaseIterable, Codable {
    case relieved = "Relieved"
    case satisfied = "Satisfied"
    case struggling = "Struggling"
    case victorious = "Victorious"
    case rushed = "Rushed"
    case zen = "Zen"
    
    var emoji: String {
        switch self {
        case .relieved: return "😌"
        case .satisfied: return "😊"
        case .struggling: return "😣"
        case .victorious: return "💪"
        case .rushed: return "😰"
        case .zen: return "🧘"
        }
    }
}

class PoopSession: Identifiable, Codable, ObservableObject {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var hourlyWage: Double
    var poopType: PoopType?
    var mood: MoodType?
    var notes: String
    
    init(startTime: Date = Date(), hourlyWage: Double) {
        self.id = UUID()
        self.startTime = startTime
        self.hourlyWage = hourlyWage
        self.notes = ""
    }
    
    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var earnings: Double {
        return (hourlyWage / 3600) * duration
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedEarnings: String {
        return String(format: "$%.2f", earnings)
    }
    
    func endSession() {
        endTime = Date()
    }
}

class SessionManager: ObservableObject {
    @Published var sessions: [PoopSession] = []
    @Published var currentSession: PoopSession?
    
    private let sessionsKey = "savedSessions"
    
    init() {
        loadSessions()
    }
    
    func startSession(hourlyWage: Double) {
        currentSession = PoopSession(hourlyWage: hourlyWage)
    }
    
    func endSession(type: PoopType, mood: MoodType, notes: String = "") {
        guard let session = currentSession else { return }
        session.endSession()
        session.poopType = type
        session.mood = mood
        session.notes = notes
        sessions.insert(session, at: 0)
        saveSessions()
        currentSession = nil
    }
    
    func cancelSession() {
        currentSession = nil
    }
    
    var totalEarnings: Double {
        sessions.reduce(0) { $0 + $1.earnings }
    }
    
    var averageSessionTime: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        let totalTime = sessions.reduce(0) { $0 + $1.duration }
        return totalTime / Double(sessions.count)
    }
    
    var formattedTotalEarnings: String {
        String(format: "$%.2f", totalEarnings)
    }
    
    var formattedAverageTime: String {
        let minutes = Int(averageSessionTime) / 60
        let seconds = Int(averageSessionTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([PoopSession].self, from: data) {
            sessions = decoded
        }
    }
}