import SwiftUI
import Foundation

enum PoopType: String, CaseIterable, Codable {
    case ghost = "Quick Break"
    case normal = "Standard Procedure"
    case sticky = "Extended Mission"
    case explosive = "Emergency Evacuation"
    case quick = "Lightning Strike"
    case marathon = "Corporate Siege"
    
    var icon: String {
        switch self {
        case .ghost: return "🕵️"
        case .normal: return "💼"
        case .sticky: return "⏳"
        case .explosive: return "🚨"
        case .quick: return "⚡"
        case .marathon: return "🏆"
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
    case relieved = "Mission Complete"
    case satisfied = "Corporate Defeated"
    case struggling = "Under Pressure"
    case victorious = "Rebellion Victory"
    case rushed = "Boss Approaching"
    case zen = "Perfect Crime"
    
    var emoji: String {
        switch self {
        case .relieved: return "✅"
        case .satisfied: return "🎯"
        case .struggling: return "⚠️"
        case .victorious: return "🏆"
        case .rushed: return "🚨"
        case .zen: return "😎"
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
    
    var rebellionLevel: String {
        switch duration {
        case 0..<180: // Under 3 minutes
            return "ROOKIE REBEL"
        case 180..<300: // 3-5 minutes
            return "CORPORATE ANNOYANCE"
        case 300..<600: // 5-10 minutes
            return "BREAK TIME PRO"
        case 600..<900: // 10-15 minutes
            return "BATHROOM BOSS"
        case 900..<1200: // 15-20 minutes
            return "CORPORATE NEMESIS"
        default: // 20+ minutes
            return "LEGENDARY REBEL"
        }
    }
    
    var rebellionDescription: String {
        switch duration {
        case 0..<180:
            return "Building your break time analytics"
        case 180..<300:
            return "Making corporate pay, one flush at a time"
        case 300..<600:
            return "Professional bathroom break warrior"
        case 600..<900:
            return "Corporate's worst nightmare"
        case 900..<1200:
            return "Bathroom empire ruler"
        default:
            return "The stuff of corporate legend"
        }
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
        
        // Add corporate rebellion context if notes are empty
        if notes.isEmpty {
            let corporateNotes = [
                "Successfully completed bathroom-based corporate resistance operation",
                "Mission accomplished - corporate funds successfully redirected",
                "Another victory in the war against bathroom surveillance",
                "Corporate productivity decreased by bathroom break duration",
                "Break completed successfully"
            ]
            session.notes = corporateNotes.randomElement() ?? notes
        } else {
            session.notes = notes
        }
        
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
    
    var corporateRebellionQuote: String {
        let quotes = [
            "Every minute in the bathroom is a victory against corporate oppression!",
            "Boss makes a dollar, you make a dime - that's why you poop on company time!",
            "The revolution starts in the bathroom stall!",
            "Corporate can't control your bathroom breaks... yet.",
            "Taking breaks: Essential for productivity.",
            "Your bathroom break is their profit loss.",
            "Stick it to the man, one flush at a time!",
            "Freedom isn't free, but bathroom breaks are!"
        ]
        return quotes.randomElement() ?? "Viva la bathroom revolución!"
    }
    
    var formattedAverageTime: String {
        let minutes = Int(averageSessionTime) / 60
        let seconds = Int(averageSessionTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var overallRebellionLevel: String {
        let sessionCount = sessions.count
        switch sessionCount {
        case 0:
            return "CORPORATE DRONE"
        case 1..<5:
            return "BATHROOM ROOKIE"
        case 5..<15:
            return "BREAK TIME BEGINNER"
        case 15..<30:
            return "REBELLION WARRIOR"
        case 30..<50:
            return "CORPORATE NIGHTMARE"
        case 50..<100:
            return "BATHROOM EMPEROR"
        default:
            return "LEGENDARY REBEL MASTER"
        }
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