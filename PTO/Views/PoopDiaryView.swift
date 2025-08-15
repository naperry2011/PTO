import SwiftUI

struct PoopDiaryView: View {
    @ObservedObject var sessionManager: SessionManager
    @EnvironmentObject var settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedSession: PoopSession?
    
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.spacing.lg) {
                        StatsHeaderView(sessionManager: sessionManager, settings: settings)
                            .padding(.horizontal, DesignTokens.spacing.md)
                        
                        if sessionManager.sessions.isEmpty {
                            EmptyDiaryView()
                                .padding(.top, DesignTokens.spacing.xxl)
                        } else {
                            LazyVStack(spacing: DesignTokens.spacing.md) {
                                ForEach(sessionManager.sessions) { session in
                                    SessionCard(session: session, settings: settings)
                                        .onTapGesture {
                                            selectedSession = session
                                            if settings.enableHaptics {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }
                                        .accessibilityHint("Double tap to view session details")
                                }
                            }
                            .padding(.horizontal, DesignTokens.spacing.md)
                        }
                    }
                    .padding(.vertical, DesignTokens.spacing.md)
                }
            }
            .navigationTitle("📈 Productivity Dashboard")
            .navigationBarTitleDisplayMode(.automatic)
            .accessibilityLabel("Dashboard showing bathroom break statistics and session history")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session, settings: settings)
            }
        }
    }
}

struct StatsHeaderView: View {
    @ObservedObject var sessionManager: SessionManager
    let settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: DesignTokens.spacing.lg) {
            VStack(alignment: .leading, spacing: DesignTokens.spacing.sm) {
                Text("🏆 QUARTERLY PERFORMANCE METRICS")
                    .rebellionHeaderStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Performance metrics section")
                
                Text("Time Theft Division - Bathroom Operations Department")
                    .corporateCaptionStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                    .accessibilityLabel("Department subtitle")
            }
            
            HStack(spacing: DesignTokens.spacing.sm) {
                StatCard(
                    title: "Revenue Theft",
                    value: sessionManager.formattedTotalEarnings,
                    icon: "banknote.fill",
                    color: AppColors.rebellion
                )
                
                StatCard(
                    title: "Operations",
                    value: "\(sessionManager.sessions.count)",
                    icon: "briefcase.fill",
                    color: AppColors.corporate
                )
                
                StatCard(
                    title: "Avg Efficiency",
                    value: sessionManager.formattedAverageTime,
                    icon: "chart.line.uptrend.xyaxis",
                    color: AppColors.warning
                )
            }
            .accessibilityElement(combining: .children)
            .accessibilityLabel("Performance statistics")
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
        VStack(spacing: DesignTokens.spacing.sm) {
            Image(systemName: icon)
                .font(DesignTokens.typography.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(DesignTokens.typography.monospacedLarge)
                .foregroundStyle(AppColors.primaryText)
                .monospacedDigit()
            
            Text(title)
                .corporateHeaderStyle()
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .corporateCardStyle(colorScheme: colorScheme)
        .accessibilityElement(combining: .children)
        .accessibilityLabel("\(title): \(value)")
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
        HStack(spacing: DesignTokens.spacing.md) {
            VStack(spacing: DesignTokens.spacing.xs) {
                Text(session.poopType?.icon ?? "💩")
                    .font(.largeTitle)
                    .accessibilityLabel("Operation type: \(session.poopType?.rawValue ?? "Unknown")")
                Text(session.mood?.emoji ?? "😊")
                    .font(DesignTokens.typography.title3)
                    .accessibilityLabel("Mood: \(session.mood?.rawValue ?? "Unknown")")
            }
            
            VStack(alignment: .leading, spacing: DesignTokens.spacing.sm) {
                Text(dateFormatter.string(from: session.startTime))
                    .corporateSubheadStyle()
                    .accessibilityLabel("Date: \(dateFormatter.string(from: session.startTime))")
                
                HStack(spacing: DesignTokens.spacing.sm) {
                    Label(session.formattedDuration, systemImage: "clock")
                        .corporateCaptionStyle()
                        .accessibilityLabel("Duration: \(session.formattedDuration)")
                    
                    Label(session.formattedEarnings, systemImage: "dollarsign.circle")
                        .corporateCaptionStyle()
                        .foregroundStyle(AppColors.accent)
                        .accessibilityLabel("Earnings: \(session.formattedEarnings)")
                }
                
                if !session.notes.isEmpty {
                    Text(session.notes)
                        .corporateCaptionStyle()
                        .lineLimit(2)
                        .accessibilityLabel("Notes: \(session.notes)")
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .corporateCaptionStyle()
                .accessibilityHidden(true)
        }
        .corporateCardStyle(colorScheme: colorScheme)
        .accessibilityElement(combining: .children)
        .accessibilityHint("Session from \(dateFormatter.string(from: session.startTime))")
    }
}

struct EmptyDiaryView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: DesignTokens.spacing.lg) {
            VStack(spacing: DesignTokens.spacing.sm) {
                Text("💼")
                    .font(.system(size: 64))
                    .accessibilityHidden(true)
                Text("🚽")
                    .font(.system(size: 48))
                    .accessibilityHidden(true)
            }
            
            VStack(spacing: DesignTokens.spacing.sm) {
                Text("NO TIME THEFT OPERATIONS")
                    .rebellionHeaderStyle()
                    .multilineTextAlignment(.center)
                
                Text("DETECTED")
                    .rebellionHeaderStyle()
                    .foregroundStyle(AppColors.error)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(combining: .children)
            .accessibilityLabel("No time theft operations detected")
            
            VStack(spacing: DesignTokens.spacing.sm) {
                Text("Initiate your first corporate rebellion!")
                    .corporateBodyStyle()
                    .multilineTextAlignment(.center)
                
                Text("The man won't pay himself while you poop...")
                    .corporateSubheadStyle()
                    .multilineTextAlignment(.center)
                    .italic()
            }
            .accessibilityElement(combining: .children)
            .accessibilityLabel("Initiate your first corporate rebellion! The man won't pay himself while you poop...")
        }
        .sectionContainerStyle(colorScheme: colorScheme)
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
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.spacing.xl) {
                    VStack(spacing: DesignTokens.spacing.md) {
                        HStack(spacing: DesignTokens.spacing.lg) {
                            Text(session.poopType?.icon ?? "💩")
                                .font(.system(size: 60))
                                .accessibilityLabel("Operation type: \(session.poopType?.rawValue ?? "Unknown")")
                            Text(session.mood?.emoji ?? "😊")
                                .font(.system(size: 60))
                                .accessibilityLabel("Mood: \(session.mood?.rawValue ?? "Unknown")")
                        }
                        
                        Text(dateFormatter.string(from: session.startTime))
                            .rebellionHeaderStyle()
                            .foregroundStyle(AppColors.secondaryText)
                            .accessibilityLabel("Session date: \(dateFormatter.string(from: session.startTime))")
                    }
                    
                    HStack(spacing: DesignTokens.spacing.md) {
                        DetailCard(
                            title: "Duration",
                            value: session.formattedDuration,
                            icon: "clock.fill",
                            color: AppColors.warning
                        )
                        
                        DetailCard(
                            title: "Earned",
                            value: session.formattedEarnings,
                            icon: "dollarsign.circle.fill",
                            color: AppColors.rebellion
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: DesignTokens.spacing.md) {
                        if let type = session.poopType {
                            DetailRow(label: "Type", value: type.rawValue, icon: type.icon)
                        }
                        
                        if let mood = session.mood {
                            DetailRow(label: "Mood", value: mood.rawValue, icon: mood.emoji)
                        }
                        
                        DetailRow(label: "Hourly Rate", value: settings.formatEarnings(session.hourlyWage) + "/hr", icon: "💰")
                        
                        if !session.notes.isEmpty {
                            VStack(alignment: .leading, spacing: DesignTokens.spacing.sm) {
                                Label("Notes", systemImage: "note.text")
                                    .rebellionHeaderStyle()
                                    .accessibilityLabel("Session notes")
                                
                                Text(session.notes)
                                    .corporateBodyStyle()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .corporateCardStyle(colorScheme: colorScheme)
                                    .accessibilityLabel("Notes: \(session.notes)")
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.spacing.md)
                    
                    Spacer()
                }
                .padding(.vertical, DesignTokens.spacing.md)
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityLabel("Session details view")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close session details")
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: DesignTokens.spacing.sm) {
            Image(systemName: icon)
                .font(DesignTokens.typography.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(DesignTokens.typography.monospacedLarge)
                .foregroundStyle(AppColors.primaryText)
                .monospacedDigit()
            
            Text(title)
                .corporateHeaderStyle()
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .corporateCardStyle(colorScheme: colorScheme)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md)
                .fill(color.opacity(0.1))
        )
        .accessibilityElement(combining: .children)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: DesignTokens.spacing.md) {
            Text(icon)
                .font(DesignTokens.typography.title3)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: DesignTokens.spacing.xs) {
                Text(label)
                    .corporateCaptionStyle()
                Text(value)
                    .corporateBodyStyle()
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .corporateCardStyle(colorScheme: colorScheme)
        .accessibilityElement(combining: .children)
        .accessibilityLabel("\(label): \(value)")
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