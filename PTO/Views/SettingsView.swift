import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var tempWage: String = ""
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.interactive)
                        
                        TextField("Your Name", text: $settings.userName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } header: {
                    Text("Profile")
                }
                
                Section {
                    HStack {
                        Label("Hourly Wage", systemImage: "dollarsign.circle.fill")
                        
                        Spacer()
                        
                        TextField("25.00", text: $tempWage)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .onAppear {
                                tempWage = String(format: "%.2f", settings.hourlyWage)
                            }
                            .onChange(of: tempWage) { newValue in
                                if let wage = Double(newValue), wage > 0 {
                                    settings.hourlyWage = wage
                                }
                            }
                        
                        Text(settings.currencySymbol + "/hr")
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    
                    Picker("Currency", selection: $settings.currencySymbol) {
                        Text("$ USD").tag("$")
                        Text("€ EUR").tag("€")
                        Text("£ GBP").tag("£")
                        Text("¥ JPY").tag("¥")
                    }
                } header: {
                    Text("Earnings")
                } footer: {
                    Text("Your hourly wage is used to calculate earnings during bathroom breaks.")
                        .font(.caption)
                }
                
                Section {
                    // Appearance Mode Picker
                    Picker("Appearance", selection: $settings.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                    .foregroundStyle(AppColors.secondaryText)
                                Text(mode.displayName)
                            }
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.interactive)
                    
                    Toggle(isOn: $settings.enableHaptics) {
                        Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .tint(AppColors.accent)
                    
                    Toggle(isOn: $settings.enableNotifications) {
                        Label("Notifications", systemImage: "bell.badge")
                    }
                    .tint(AppColors.accent)
                } header: {
                    Text("Preferences")
                }
                
                Section {
                    HStack {
                        Label("Daily Earnings Goal", systemImage: "target")
                        Spacer()
                        Text("Coming Soon")
                            .foregroundStyle(AppColors.secondaryText)
                            .font(.caption)
                    }
                    
                    HStack {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                        Spacer()
                        Text("Coming Soon")
                            .foregroundStyle(AppColors.secondaryText)
                            .font(.caption)
                    }
                    
                    HStack {
                        Label("Achievements", systemImage: "trophy.fill")
                        Spacer()
                        Text("Coming Soon")
                            .foregroundStyle(AppColors.secondaryText)
                            .font(.caption)
                    }
                } header: {
                    Text("Advanced")
                }
                
                Section {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Label("About", systemImage: "info.circle")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    
                    HStack {
                        Label("Version", systemImage: "gear")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
                
                Section {
                    VStack(spacing: 16) {
                        Text("💩 Fun Facts 💩")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FactRow(emoji: "🚽", fact: "Average person spends 3 years on the toilet")
                            FactRow(emoji: "💰", fact: "That could be $18,750 at $25/hr!")
                            FactRow(emoji: "📱", fact: "75% of people use phones in the bathroom")
                            FactRow(emoji: "⏰", fact: "Average bathroom break: 12-15 minutes")
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("⚙️ Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

struct FactRow: View {
    let emoji: String
    let fact: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.title3)
            Text(fact)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Text("💩")
                            .font(.system(size: 80))
                        
                        Text("Paid to Operate")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        Text("Making Money While You... You Know")
                            .font(.headline)
                        
                        Text("Track your earnings during bathroom breaks at work. Because if you're good at something, never do it for free!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppColors.secondaryText)
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(icon: "clock.fill", title: "Track Time", description: "Precise timer for your sessions")
                        FeatureRow(icon: "dollarsign.circle.fill", title: "Calculate Earnings", description: "Real-time earnings based on your wage")
                        FeatureRow(icon: "book.fill", title: "Poop Diary", description: "Log type, mood, and notes")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Statistics", description: "Track your bathroom economy")
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        Text("Remember:")
                            .font(.headline)
                        Text("Boss makes a dollar, I make a dime")
                            .font(.subheadline)
                        Text("That's why I poop on company time! 🚽")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(AppColors.warning.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("About")
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppColors.interactive)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
            Spacer()
        }
    }
}

#Preview("Light Mode") {
    SettingsView()
        .environmentObject(UserSettings())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    SettingsView()
        .environmentObject(UserSettings())
        .preferredColorScheme(.dark)
}