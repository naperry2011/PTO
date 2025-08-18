//
//  ContentView.swift
//  PTO
//
//  Created by Nicholas Perry on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @StateObject private var sessionManager = SessionManager()
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView(sessionManager: sessionManager)
                .tabItem {
                    Label("Operations", systemImage: "timer")
                }
                .tag(0)
                .badge(sessionManager.currentSession != nil ? "Active" : nil)
                .accessibilityLabel("Operations tab")
                .accessibilityHint("Timer functionality for tracking bathroom breaks")
            
            PoopDiaryView(sessionManager: sessionManager)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.doc.horizontal")
                }
                .tag(1)
                .if(sessionManager.sessions.count > 0) { view in
                    view.badge(sessionManager.sessions.count)
                }
                .accessibilityLabel("Dashboard tab")
                .accessibilityHint("View statistics and session history")
            
            SettingsView()
                .tabItem {
                    Label("Control", systemImage: "gearshape")
                }
                .tag(2)
                .accessibilityLabel("Control tab")
                .accessibilityHint("App settings and configuration")
        }
        .environmentObject(settings)
        .environmentObject(sessionManager)
        .tint(AppColors.corporate)
        .preferredColorScheme(settings.appearanceMode.colorScheme)
        .onChange(of: selectedTab) { _, newValue in
            // Haptic feedback on tab change
            if settings.enableHaptics {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            previousTab = newValue
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Use default transparent background for better HIG compliance
        appearance.configureWithDefaultBackground()
        
        // Configure item appearance with subtle corporate theming
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.corporate)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.corporate)
        
        // Apply appearance to all tab bar configurations
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Remove custom selection indicator for standard iOS behavior
        UITabBar.appearance().selectionIndicatorImage = nil
    }
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
