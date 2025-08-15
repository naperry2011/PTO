import SwiftUI

struct TimerView: View {
    @StateObject private var sessionManager = SessionManager()
    @EnvironmentObject var settings: UserSettings
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var currentEarnings: Double = 0
    @State private var isRunning = false
    @State private var showingSessionSheet = false
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("💩 Paid to Operate 💵")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(settings.formattedWage)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(min(elapsedTime / 1800, 1.0)))
                            .stroke(
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                              startPoint: .topLeading,
                                              endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.5), value: elapsedTime)
                        
                        VStack(spacing: 16) {
                            Text(formatTime(elapsedTime))
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                            
                            VStack(spacing: 4) {
                                Text("Earned")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(settings.formatEarnings(currentEarnings))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: pulseAnimation)
                            }
                        }
                    }
                    
                    Button(action: toggleTimer) {
                        HStack {
                            Image(systemName: isRunning ? "stop.fill" : "play.fill")
                                .font(.title2)
                            Text(isRunning ? "End Session" : "Start Session")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(gradient: Gradient(colors: isRunning ? [Color.red, Color.orange] : [Color.green, Color.blue]),
                                          startPoint: .leading,
                                          endPoint: .trailing)
                        )
                        .cornerRadius(30)
                        .shadow(radius: 5)
                    }
                    
                    if isRunning {
                        VStack(spacing: 8) {
                            Text("🚽 Session in Progress")
                                .font(.headline)
                            Text("Making money while you... you know")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSessionSheet) {
            SessionLoggingSheet(sessionManager: sessionManager, 
                              duration: elapsedTime,
                              earnings: currentEarnings,
                              settings: settings)
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if isRunning {
                elapsedTime += 0.1
                currentEarnings = settings.calculateEarnings(seconds: elapsedTime)
            }
        }
    }
    
    private func toggleTimer() {
        if isRunning {
            isRunning = false
            pulseAnimation = false
            sessionManager.startSession(hourlyWage: settings.hourlyWage)
            showingSessionSheet = true
        } else {
            isRunning = true
            pulseAnimation = true
            elapsedTime = 0
            currentEarnings = 0
            
            if settings.enableHaptics {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
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
    
    @State private var selectedType: PoopType = .normal
    @State private var selectedMood: MoodType = .satisfied
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Text("🎉 Session Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 40) {
                            VStack {
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatTime(duration))
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            VStack {
                                Text("Earned")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(settings.formatEarnings(earnings))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How was it?")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Type")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(PoopType.allCases, id: \.self) { type in
                                    Button(action: { selectedType = type }) {
                                        VStack(spacing: 4) {
                                            Text(type.icon)
                                                .font(.largeTitle)
                                            Text(type.rawValue)
                                                .font(.caption)
                                        }
                                        .frame(width: 100, height: 80)
                                        .background(selectedType == type ? type.color.opacity(0.2) : Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedType == type ? type.color : Color.clear, lineWidth: 2)
                                        )
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mood")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(MoodType.allCases, id: \.self) { mood in
                                    Button(action: { selectedMood = mood }) {
                                        VStack(spacing: 4) {
                                            Text(mood.emoji)
                                                .font(.largeTitle)
                                            Text(mood.rawValue)
                                                .font(.caption)
                                        }
                                        .frame(width: 100, height: 80)
                                        .background(selectedMood == mood ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedMood == mood ? Color.blue : Color.clear, lineWidth: 2)
                                        )
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Add any thoughts...", text: $notes, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: saveSession) {
                        Text("Save to Diary")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                              startPoint: .leading,
                                              endPoint: .trailing)
                            )
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Log Your Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        sessionManager.cancelSession()
                        dismiss()
                    }
                }
            }
        }
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