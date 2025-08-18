import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var tempWage: String = ""
    @State private var showingAbout = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: DesignTokens.spacing.sm) {
                        Image(systemName: "person.circle.fill")
                            .font(DesignTokens.typography.title3)
                            .foregroundStyle(AppColors.interactive)
                        
                        TextField("Corporate Alias", text: $settings.userName)
                            .font(DesignTokens.typography.body)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityLabel("Corporate alias text field")
                            .accessibilityHint("Enter your code name")
                    }
                } header: {
                    Text("🕵️ EMPLOYEE IDENTIFICATION")
                        .corporateHeaderStyle()
                } footer: {
                    Text("Use a code name to protect your identity from corporate surveillance")
                        .corporateCaptionStyle()
                        .italic()
                }
                
                Section {
                    HStack(spacing: DesignTokens.spacing.md) {
                        Label("Hourly Rate", systemImage: "banknote.fill")
                            .foregroundStyle(AppColors.rebellion)
                            .font(DesignTokens.typography.body)
                        
                        Spacer()
                        
                        TextField("25.00", text: $tempWage)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .font(DesignTokens.typography.monospacedDigit)
                            .onAppear {
                                tempWage = String(format: "%.2f", settings.hourlyWage)
                            }
                            .onChange(of: tempWage) { _, newValue in
                                if let wage = Double(newValue), wage > 0 {
                                    settings.hourlyWage = wage
                                }
                            }
                            .accessibilityLabel("Hourly wage input")
                            .accessibilityValue(tempWage)
                        
                        Text(settings.currencySymbol + "/hr")
                            .corporateSubheadStyle()
                    }
                    
                    Picker("Currency", selection: $settings.currencySymbol) {
                        Text("$ USD").tag("$")
                        Text("€ EUR").tag("€")
                        Text("£ GBP").tag("£")
                        Text("¥ JPY").tag("¥")
                    }
                    .font(DesignTokens.typography.body)
                    .accessibilityLabel("Currency selection")
                } header: {
                    Text("💰 EARNINGS CONFIGURATION")
                        .corporateHeaderStyle()
                } footer: {
                    Text("Configure your hourly rate for break time calculations.")
                        .corporateCaptionStyle()
                        .italic()
                }
                
                Section {
                    // Appearance Mode Picker
                    Picker("Appearance", selection: $settings.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            HStack(spacing: DesignTokens.spacing.sm) {
                                Image(systemName: mode.icon)
                                    .foregroundStyle(AppColors.secondaryText)
                                Text(mode.displayName)
                                    .font(DesignTokens.typography.body)
                            }
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.interactive)
                    .accessibilityLabel("Appearance mode selection")
                    
                    Toggle(isOn: $settings.enableHaptics) {
                        Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                            .font(DesignTokens.typography.body)
                    }
                    .tint(AppColors.accent)
                    .accessibilityHint("Enables vibration feedback for interactions")
                    
                    Toggle(isOn: $settings.enableNotifications) {
                        Label("Notifications", systemImage: "bell.badge")
                            .font(DesignTokens.typography.body)
                    }
                    .tint(AppColors.accent)
                    .accessibilityHint("Enables push notifications")
                } header: {
                    Text("⚙️ USER EXPERIENCE SETTINGS")
                        .corporateHeaderStyle()
                }
                
                Section {
                    HStack {
                        Label("Daily Earnings Goal", systemImage: "target")
                            .font(DesignTokens.typography.body)
                        Spacer()
                        Text("Coming Soon")
                            .corporateSubheadStyle()
                    }
                    .accessibilityLabel("Daily earnings goal feature coming soon")
                    
                    HStack {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .font(DesignTokens.typography.body)
                        Spacer()
                        Text("Coming Soon")
                            .corporateSubheadStyle()
                    }
                    .accessibilityLabel("Export data feature coming soon")
                    
                    HStack {
                        Label("Achievements", systemImage: "trophy.fill")
                            .font(DesignTokens.typography.body)
                        Spacer()
                        Text("Coming Soon")
                            .corporateSubheadStyle()
                    }
                    .accessibilityLabel("Achievements feature coming soon")
                } header: {
                    Text("🚀 ADVANCED FEATURES")
                        .corporateHeaderStyle()
                }
                
                Section {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Label("About", systemImage: "info.circle")
                                .font(DesignTokens.typography.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .corporateCaptionStyle()
                        }
                    }
                    .accessibilityLabel("About this app")
                    .accessibilityHint("Shows app information and features")
                    
                    HStack {
                        Label("Version", systemImage: "gear")
                            .font(DesignTokens.typography.body)
                        Spacer()
                        Text("1.0.0")
                            .corporateSubheadStyle()
                    }
                    .accessibilityLabel("App version 1.0.0")
                } header: {
                    Text("📝 APP INFORMATION")
                        .corporateHeaderStyle()
                }
                
                Section {
                    VStack(spacing: DesignTokens.spacing.md) {
                        Text("💩 CORPORATE BATHROOM INTELLIGENCE 💩")
                            .rebellionHeaderStyle()
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: DesignTokens.spacing.sm) {
                            FactRow(emoji: "🚽", fact: "Average person spends 3 years on the toilet")
                            FactRow(emoji: "💰", fact: "That could be $18,750 at $25/hr!")
                            FactRow(emoji: "📱", fact: "75% of people use phones in the bathroom")
                            FactRow(emoji: "⏰", fact: "Average bathroom break: 12-15 minutes")
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Fun facts about bathroom habits")
                    }
                    .padding(.vertical, DesignTokens.spacing.sm)
                } header: {
                    Text("🏆 BATHROOM STATISTICS")
                        .corporateHeaderStyle()
                }
            }
            .navigationTitle("💼 Corporate Control Panel")
            .navigationBarTitleDisplayMode(.automatic)
            .accessibilityLabel("Settings and control panel")
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
        HStack(alignment: .top, spacing: DesignTokens.spacing.sm) {
            Text(emoji)
                .font(DesignTokens.typography.title3)
                .accessibilityHidden(true)
            Text(fact)
                .corporateCaptionStyle()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(fact)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.spacing.xl) {
                    VStack(spacing: DesignTokens.spacing.md) {
                        Text("💩")
                            .font(.system(size: 80))
                            .accessibilityHidden(true)
                        
                        Text("Paid to Operate")
                            .font(DesignTokens.typography.heroTitle)
                            .foregroundStyle(AppColors.corporate)
                        
                        Text("Version 1.0.0")
                            .corporateCaptionStyle()
                    }
                    .padding(.top, DesignTokens.spacing.lg)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Paid to Operate app, Version 1.0.0")
                    
                    VStack(spacing: DesignTokens.spacing.md) {
                        Text("Making Money While You... You Know")
                            .rebellionHeaderStyle()
                        
                        Text("Track your earnings during bathroom breaks at work. Because if you're good at something, never do it for free!")
                            .corporateBodyStyle()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignTokens.spacing.md)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("App description: Track your earnings during bathroom breaks at work")
                    
                    VStack(alignment: .leading, spacing: DesignTokens.spacing.lg) {
                        FeatureRow(icon: "clock.fill", title: "Track Time", description: "Precise timer for your sessions")
                        FeatureRow(icon: "dollarsign.circle.fill", title: "Calculate Earnings", description: "Real-time earnings based on your wage")
                        FeatureRow(icon: "book.fill", title: "Poop Diary", description: "Log type, mood, and notes")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Statistics", description: "Track your bathroom economy")
                    }
                    .sectionContainerStyle(colorScheme: colorScheme)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("App features list")
                    
                    VStack(spacing: DesignTokens.spacing.sm) {
                        Text("Remember:")
                            .rebellionHeaderStyle()
                        Text("Boss makes a dollar, I make a dime")
                            .corporateBodyStyle()
                        Text("That's why I poop on company time! 🚽")
                            .corporateBodyStyle()
                            .fontWeight(.bold)
                    }
                    .elevatedCardStyle(colorScheme: colorScheme)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.cornerRadius.lg)
                            .stroke(AppColors.warning, lineWidth: 2)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("App motto: Boss makes a dollar, I make a dime, that's why I poop on company time")
                    
                    Spacer(minLength: DesignTokens.spacing.xl)
                }
                .padding(.horizontal, DesignTokens.spacing.md)
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
        HStack(alignment: .top, spacing: DesignTokens.spacing.md) {
            Image(systemName: icon)
                .font(DesignTokens.typography.title3)
                .foregroundStyle(AppColors.interactive)
                .frame(width: 30)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: DesignTokens.spacing.xs) {
                Text(title)
                    .corporateBodyStyle()
                    .fontWeight(.semibold)
                Text(description)
                    .corporateCaptionStyle()
            }
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
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