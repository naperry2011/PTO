import SwiftUI

struct TimerView: View {
    @StateObject private var sessionManager = SessionManager()
    @EnvironmentObject var settings: UserSettings
    @Environment(\.colorScheme) var colorScheme
    @State private var timerCancellable: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var currentEarnings: Double = 0
    @State private var isRunning = false
    @State private var showingSessionSheet = false
    @State private var pulseAnimation = false
    @State private var circleProgress: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern background with subtle material effect
                AppColors.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header Section
                        VStack(spacing: 12) {
                            Text("💩 Paid to Operate 💵")
                                .font(.largeTitle.bold())
                                .foregroundStyle(AppColors.primaryText)
                            
                            Text(settings.formattedWage)
                                .font(.title2.weight(.medium))
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        .padding(.top, 20)
                        
                        // Modern Timer Circle with enhanced visuals
                        ZStack {
                            // Background circle with subtle shadow
                            Circle()
                                .stroke(
                                    AppColors.timerBackground,
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .frame(width: 280, height: 280)
                                .dynamicCardShadow(colorScheme: colorScheme)
                            
                            // Progress circle with smooth animation
                            Circle()
                                .trim(from: 0, to: circleProgress)
                                .stroke(
                                    LinearGradient(
                                        colors: isRunning 
                                            ? AppColors.timerProgress
                                            : [AppColors.timerInactive],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .frame(width: 280, height: 280)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: circleProgress)
                            
                            // Center content with modern typography
                            VStack(spacing: 20) {
                                Text(formatTime(elapsedTime))
                                    .font(.system(size: 52, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppColors.primaryText)
                                    .monospacedDigit()
                                
                                VStack(spacing: 8) {
                                    Text("Earned")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(AppColors.secondaryText)
                                        .textCase(.uppercase)
                                        .tracking(1)
                                    
                                    Text(settings.formatEarnings(currentEarnings))
                                        .font(.title.bold())
                                        .foregroundStyle(AppColors.accent)
                                        .scaleEffect(pulseAnimation ? 1.08 : 1.0)
                                        .animation(
                                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                            value: pulseAnimation
                                        )
                                }
                            }
                        }
                        
                        // Modern action button with haptic feedback
                        Button(action: toggleTimer) {
                            HStack(spacing: 12) {
                                Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)
                                
                                Text(isRunning ? "End Session" : "Start Session")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: isRunning 
                                                ? AppColors.gradientDanger
                                                : AppColors.gradientPrimary,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .dynamicElevatedShadow(colorScheme: colorScheme)
                            )
                        }
                        .padding(.horizontal)
                        .scaleEffect(isRunning ? 0.98 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRunning)
                        
                        // Status indicator with modern styling
                        if isRunning {
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "toilet")
                                        .font(.title2)
                                        .foregroundStyle(AppColors.warning)
                                    
                                    Text("Session in Progress")
                                        .font(.headline.weight(.medium))
                                        .foregroundStyle(AppColors.primaryText)
                                }
                                
                                Text("Making money while you... you know")
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.warning.opacity(0.1))
                                    .stroke(AppColors.warning.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal)
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
                VStack(spacing: 32) {
                    // Celebration header with modern styling
                    VStack(spacing: 20) {
                        Text("🎉 Session Complete!")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppColors.primaryText)
                        
                        // Stats cards with modern design
                        HStack(spacing: 16) {
                            StatsSummaryCard(
                                title: "Duration",
                                value: formatTime(duration),
                                icon: "clock.fill",
                                color: .blue
                            )
                            
                            StatsSummaryCard(
                                title: "Earned",
                                value: settings.formatEarnings(earnings),
                                icon: "dollarsign.circle.fill",
                                color: .green
                            )
                        }
                    }
                    
                    // Selection sections with improved UX
                    VStack(alignment: .leading, spacing: 24) {
                        Text("How was your session?")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(AppColors.primaryText)
                        
                        // Type selection with modern cards
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Type")
                                .font(.headline.weight(.medium))
                                .foregroundStyle(AppColors.secondaryText)
                            
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
                        
                        // Mood selection with modern cards
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Mood")
                                .font(.headline.weight(.medium))
                                .foregroundStyle(AppColors.secondaryText)
                            
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
                        
                        // Notes section with modern text field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes (Optional)")
                                .font(.headline.weight(.medium))
                                .foregroundStyle(AppColors.secondaryText)
                            
                            TextField("Add any thoughts...", text: $notes, axis: .vertical)
                                .focused($notesFieldFocused)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                                .font(.body)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Save button with modern styling
                    Button(action: saveSession) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Save to Diary")
                                .font(.headline.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: AppColors.gradientPrimary,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .dynamicElevatedShadow(colorScheme: colorScheme)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        sessionManager.cancelSession()
                        dismiss()
                    }
                    .foregroundStyle(.red)
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
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.primaryText)
                .monospacedDigit()
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColors.secondaryText)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TypeSelectionCard: View {
    let type: PoopType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(type.icon)
                    .font(.system(size: 32))
                
                Text(type.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
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
    }
}

struct MoodSelectionCard: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                
                Text(mood.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
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
    }
}

#Preview("Light Mode") {
    TimerView()
        .environmentObject(UserSettings())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    TimerView()
        .environmentObject(UserSettings())
        .preferredColorScheme(.dark)
}