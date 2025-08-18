import SwiftUI

struct TimerView: View {
    @ObservedObject var sessionManager: SessionManager
    @EnvironmentObject var settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    @State private var timerCancellable: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var currentEarnings: Double = 0
    @State private var isRunning = false
    @State private var showingSessionSheet = false
    @State private var pulseAnimation = false
    @State private var circleProgress: CGFloat = 0
    
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern background with subtle material effect
                AppColors.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignTokens.spacing.xl) {
                        // Simplified Header Section
                        VStack(spacing: DesignTokens.spacing.md) {
                            Text("💼 BREAK TRACKING 🚽")
                                .font(DesignTokens.typography.title1)
                                .foregroundStyle(AppColors.corporate)
                                .multilineTextAlignment(.center)
                                .accessibilityLabel("Break Tracking")
                            
                            HStack(spacing: DesignTokens.spacing.sm) {
                                Text("Earning Rate:")
                                    .corporateHeaderStyle()
                                    .foregroundStyle(AppColors.secondaryText)
                                
                                Text(settings.formattedWage)
                                    .font(DesignTokens.typography.headline)
                                    .foregroundStyle(AppColors.rebellion)
                                    .fontWeight(.bold)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Earning rate: \(settings.formattedWage) per hour")
                        }
                        .padding(.top, DesignTokens.spacing.md)
                        
                        // Streamlined Timer Display
                        VStack(spacing: DesignTokens.spacing.lg) {
                            // Timer Status
                            Text(isRunning ? "🚨 ACTIVE OPERATION" : "⏸️ READY TO DEPLOY")
                                .font(DesignTokens.typography.title3)
                                .foregroundStyle(isRunning ? AppColors.warning : AppColors.secondaryText)
                                .accessibilityLabel(isRunning ? "Timer is running" : "Timer is stopped")
                            
                            // Main Timer Circle - Reduced Size
                            ZStack {
                                Circle()
                                    .stroke(AppColors.timerBackground, lineWidth: 12)
                                    .frame(width: 220, height: 220)
                                
                                Circle()
                                    .trim(from: 0, to: circleProgress)
                                    .stroke(
                                        LinearGradient(
                                            colors: isRunning ? [AppColors.rebellion, AppColors.accent] : [AppColors.timerInactive],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 220, height: 220)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: circleProgress)
                                    .accessibilityLabel("Timer progress: \(Int(circleProgress * 100)) percent complete")
                                
                                // Timer Content
                                VStack(spacing: DesignTokens.spacing.md) {
                                    Text(formatTime(elapsedTime))
                                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                                        .foregroundStyle(AppColors.primaryText)
                                        .monospacedDigit()
                                        .accessibilityLabel("Elapsed time: \(formatTime(elapsedTime))")
                                    
                                    Text(settings.formatEarnings(currentEarnings))
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppColors.rebellion)
                                        .scaleEffect(pulseAnimation && isRunning ? 1.08 : 1.0)
                                        .animation(
                                            isRunning ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default,
                                            value: pulseAnimation
                                        )
                                        .accessibilityLabel("Current earnings: \(settings.formatEarnings(currentEarnings))")
                                }
                            }
                            .dynamicCardShadow(colorScheme: colorScheme)
                        }
                        
                        // Simplified Action Button
                        Button(action: toggleTimer) {
                            HStack(spacing: DesignTokens.spacing.sm) {
                                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                
                                Text(isRunning ? "END SESSION" : "START SESSION")
                                    .font(DesignTokens.typography.headline)
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignTokens.spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md)
                                    .fill(
                                        isRunning 
                                            ? LinearGradient(colors: [AppColors.error, AppColors.warning], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient(colors: [AppColors.rebellion, AppColors.accent], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .dynamicCardShadow(colorScheme: colorScheme)
                            )
                        }
                        .accessibilityLabel(isRunning ? "Stop timer" : "Start timer")
                        .accessibilityHint(isRunning ? "Stops the current session and opens completion form" : "Starts tracking your bathroom break session")
                        .padding(.horizontal, DesignTokens.spacing.lg)
                        .scaleEffect(isRunning ? 0.98 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRunning)
                        
                        // Simplified Status Display
                        if isRunning {
                            VStack(spacing: DesignTokens.spacing.sm) {
                                Text("💼 Boss makes a dollar, you make a dime...")
                                    .corporateSubheadStyle()
                                    .italic()
                                    .multilineTextAlignment(.center)
                                
                                Text("That's why you earn on company time! 🚽")
                                    .corporateBodyStyle()
                                    .foregroundStyle(AppColors.rebellion)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(DesignTokens.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md)
                                    .fill(AppColors.rebellion.opacity(0.1))
                                    .stroke(AppColors.rebellion.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.scale.combined(with: .opacity))
                            .accessibilityLabel("Timer is currently running")
                        }
                        
                        Spacer(minLength: DesignTokens.spacing.xxl)
                    }
                    .padding(.horizontal, DesignTokens.spacing.md)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSessionSheet) {
            SessionLoggingSheet(
                sessionManager: sessionManager,
                duration: elapsedTime,
                earnings: currentEarnings,
                settings: settings
            )
        }
        .onChange(of: showingSessionSheet) { _, newValue in
            // Reset everything when sheet is dismissed
            if !newValue {
                resetTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func toggleTimer() {
        if isRunning {
            stopTimer()
            sessionManager.startSession(hourlyWage: settings.hourlyWage)
            showingSessionSheet = true
        } else {
            startTimer()
            
            if settings.enableHaptics {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
    
    private func startTimer() {
        // Reset values before starting
        elapsedTime = 0
        currentEarnings = 0
        circleProgress = 0
        isRunning = true
        pulseAnimation = true
        
        // Create and start the timer
        timerCancellable = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
            currentEarnings = settings.calculateEarnings(seconds: elapsedTime)
            circleProgress = CGFloat(min(elapsedTime / 1800, 1.0))
        }
    }
    
    private func stopTimer() {
        // Stop and cleanup the timer
        timerCancellable?.invalidate()
        timerCancellable = nil
        isRunning = false
        pulseAnimation = false
    }
    
    private func resetTimer() {
        // Complete reset of all timer values
        stopTimer()
        elapsedTime = 0
        currentEarnings = 0
        circleProgress = 0
        isRunning = false
        pulseAnimation = false
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SessionLoggingSheet: View {
    @ObservedObject var sessionManager: SessionManager
    let duration: TimeInterval
    let earnings: Double
    let settings: UserSettings
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedType: PoopType = .normal
    @State private var selectedMood: MoodType = .satisfied
    @State private var notes: String = ""
    @FocusState private var notesFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.spacing.xl) {
                    // Corporate Mission Accomplished Header
                    VStack(spacing: DesignTokens.spacing.lg) {
                        VStack(spacing: DesignTokens.spacing.sm) {
                            Text("🏆 MISSION ACCOMPLISHED 🏆")
                                .font(DesignTokens.typography.heroTitle)
                                .foregroundStyle(AppColors.rebellion)
                                .multilineTextAlignment(.center)
                                .accessibilityLabel("Mission accomplished")
                            
                            Text("Break Session Complete")
                                .corporateHeaderStyle()
                                .accessibilityLabel("Operation completion subtitle")
                        }
                        
                        // Corporate Performance Metrics
                        HStack(spacing: DesignTokens.spacing.md) {
                            StatsSummaryCard(
                                title: "Time Stolen",
                                value: formatTime(duration),
                                icon: "clock.badge.exclamationmark.fill",
                                color: AppColors.warning
                            )
                            
                            StatsSummaryCard(
                                title: "Profit Gained",
                                value: settings.formatEarnings(earnings),
                                icon: "banknote.fill",
                                color: AppColors.rebellion
                            )
                        }
                    }
                    
                    // Corporate Performance Assessment
                    VStack(alignment: .leading, spacing: DesignTokens.spacing.lg) {
                        VStack(alignment: .leading, spacing: DesignTokens.spacing.sm) {
                            Text("📈 PERFORMANCE EVALUATION")
                                .rebellionHeaderStyle()
                                .accessibilityLabel("Performance evaluation section")
                            
                            Text("Please rate your anti-corporate bathroom experience")
                                .corporateCaptionStyle()
                                .italic()
                                .accessibilityHint("Rate your session type and mood")
                        }
                        
                        // Mission Type Classification
                        VStack(alignment: .leading, spacing: DesignTokens.spacing.md) {
                            Text("OPERATION CLASSIFICATION")
                                .corporateHeaderStyle()
                                .accessibilityLabel("Select operation type")
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 110, maximum: 140))
                            ], spacing: 12) {
                                ForEach(PoopType.allCases, id: \.self) { type in
                                    TypeSelectionCard(
                                        type: type,
                                        isSelected: selectedType == type
                                    ) {
                                        selectedType = type
                                        if settings.enableHaptics {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Corporate Satisfaction Survey
                        VStack(alignment: .leading, spacing: DesignTokens.spacing.md) {
                            Text("REBELLION SATISFACTION LEVEL")
                                .corporateHeaderStyle()
                                .accessibilityLabel("Select satisfaction mood")
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 110, maximum: 140))
                            ], spacing: 12) {
                                ForEach(MoodType.allCases, id: \.self) { mood in
                                    MoodSelectionCard(
                                        mood: mood,
                                        isSelected: selectedMood == mood
                                    ) {
                                        selectedMood = mood
                                        if settings.enableHaptics {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Corporate Incident Report
                        VStack(alignment: .leading, spacing: DesignTokens.spacing.sm) {
                            Text("INCIDENT REPORT (Optional)")
                                .corporateHeaderStyle()
                                .accessibilityLabel("Optional notes field")
                            
                            Text("Document any suspicious corporate activity...")
                                .corporateCaptionStyle()
                                .italic()
                            
                            TextField("Boss walked by, narrowly avoided detection...", text: $notes, axis: .vertical)
                                .focused($notesFieldFocused)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                                .font(DesignTokens.typography.body)
                                .accessibilityLabel("Session notes text field")
                        }
                    }
                    .padding(.horizontal, DesignTokens.spacing.md)
                    
                    // Corporate Submit Button
                    Button(action: saveSession) {
                        HStack(spacing: DesignTokens.spacing.sm) {
                            Image(systemName: "doc.badge.plus")
                                .font(DesignTokens.typography.title3)
                            Text("SAVE TO HISTORY")
                                .font(DesignTokens.typography.headline)
                                .tracking(0.3)
                                .textCase(.uppercase)
                        }
                        .primaryButtonStyle(colorScheme: colorScheme)
                    }
                    .accessibilityLabel("Submit session")
                    .accessibilityHint("Saves your bathroom break session to the archive")
                    .padding(.horizontal, DesignTokens.spacing.md)
                    
                    Spacer(minLength: DesignTokens.spacing.lg)
                }
                .padding(.vertical, DesignTokens.spacing.md)
            }
            .navigationTitle("Mission Debrief")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ABORT") {
                        sessionManager.cancelSession()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.error)
                    .font(.caption.weight(.bold))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if notesFieldFocused {
                        Button("Done") {
                            notesFieldFocused = false
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveSession() {
        sessionManager.endSession(type: selectedType, mood: selectedMood, notes: notes)
        
        if settings.enableHaptics {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        dismiss()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views

struct StatsSummaryCard: View {
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
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.md)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct TypeSelectionCard: View {
    let type: PoopType
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.spacing.sm) {
                Text(type.icon)
                    .font(.system(size: 32))
                
                Text(type.rawValue)
                    .corporateCaptionStyle()
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.sm)
                    .fill(isSelected ? type.color.opacity(0.15) : AppColors.secondaryBackground)
                    .stroke(
                        isSelected ? type.color : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(type.rawValue)
        .accessibilityHint("Select this operation type")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct MoodSelectionCard: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.spacing.sm) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                
                Text(mood.rawValue)
                    .corporateCaptionStyle()
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.sm)
                    .fill(isSelected ? AppColors.interactive.opacity(0.15) : AppColors.secondaryBackground)
                    .stroke(
                        isSelected ? AppColors.interactive : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(mood.rawValue)
        .accessibilityHint("Select this mood")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light Mode") {
    TimerView(sessionManager: SessionManager())
        .environmentObject(UserSettings())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    TimerView(sessionManager: SessionManager())
        .environmentObject(UserSettings())
        .preferredColorScheme(.dark)
}