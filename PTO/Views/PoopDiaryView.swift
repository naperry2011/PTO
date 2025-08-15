import SwiftUI

struct PoopDiaryView: View {
    @StateObject private var sessionManager = SessionManager()
    @EnvironmentObject var settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSession: PoopSession?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        StatsHeaderView(sessionManager: sessionManager, settings: settings)
                            .padding(.horizontal)
                        
                        if sessionManager.sessions.isEmpty {
                            EmptyDiaryView()
                                .padding(.top, 50)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(sessionManager.sessions) { session in
                                    SessionCard(session: session, settings: settings)
                                        .onTapGesture {
                                            selectedSession = session
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("💩 Poop Diary")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session, settings: settings)
            }
        }
    }
}

struct StatsHeaderView: View {
    @ObservedObject var sessionManager: SessionManager
    let settings: UserSettings
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Earned",
                    value: sessionManager.formattedTotalEarnings,
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Sessions",
                    value: "\(sessionManager.sessions.count)",
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Time",
                    value: sessionManager.formattedAverageTime,
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.secondaryBackground)
        .cornerRadius(15)
        .dynamicCardShadow(colorScheme: colorScheme)
    }
}

struct SessionCard: View {
    let session: PoopSession
    let settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(session.poopType?.icon ?? "💩")
                    .font(.largeTitle)
                Text(session.mood?.emoji ?? "😊")
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(dateFormatter.string(from: session.startTime))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                
                HStack(spacing: 12) {
                    Label(session.formattedDuration, systemImage: "clock")
                        .font(.caption)
                    
                    Label(session.formattedEarnings, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(AppColors.accent)
                }
                
                if !session.notes.isEmpty {
                    Text(session.notes)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(15)
        .dynamicCardShadow(colorScheme: colorScheme)
    }
}

struct EmptyDiaryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🚽")
                .font(.system(size: 80))
            
            Text("No Sessions Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Start your first paid bathroom break!")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct SessionDetailView: View {
    let session: PoopSession
    let settings: UserSettings
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            Text(session.poopType?.icon ?? "💩")
                                .font(.system(size: 60))
                            Text(session.mood?.emoji ?? "😊")
                                .font(.system(size: 60))
                        }
                        
                        Text(dateFormatter.string(from: session.startTime))
                            .font(.headline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    
                    HStack(spacing: 20) {
                        DetailCard(
                            title: "Duration",
                            value: session.formattedDuration,
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        DetailCard(
                            title: "Earned",
                            value: session.formattedEarnings,
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if let type = session.poopType {
                            DetailRow(label: "Type", value: type.rawValue, icon: type.icon)
                        }
                        
                        if let mood = session.mood {
                            DetailRow(label: "Mood", value: mood.rawValue, icon: mood.emoji)
                        }
                        
                        DetailRow(label: "Hourly Rate", value: settings.formatEarnings(session.hourlyWage) + "/hr", icon: "💰")
                        
                        if !session.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes", systemImage: "note.text")
                                    .font(.headline)
                                
                                Text(session.notes)
                                    .font(.body)
                                    .foregroundStyle(AppColors.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.secondaryBackground)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.primaryText)
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.secondaryBackground)
        .cornerRadius(10)
    }
}

#Preview("Light Mode") {
    PoopDiaryView()
        .environmentObject(UserSettings())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    PoopDiaryView()
        .environmentObject(UserSettings())
        .preferredColorScheme(.dark)
}