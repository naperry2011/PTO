//
//  ContentView.swift
//  PTO
//
//  Created by Nicholas Perry on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: selectedTab == 0 ? "timer.circle.fill" : "timer")
                }
                .tag(0)
            
            PoopDiaryView()
                .tabItem {
                    Label("History", systemImage: selectedTab == 1 ? "book.circle.fill" : "book")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                }
                .tag(2)
        }
        .environmentObject(settings)
        .tint(AppColors.accent)
        .preferredColorScheme(settings.appearanceMode.colorScheme)
        .onChange(of: selectedTab) { newValue in
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
        
        // Configure background with modern material
        appearance.configureWithOpaqueBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        // Configure item appearance
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemGreen
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure selection indicator
        UITabBar.appearance().selectionIndicatorImage = createSelectionIndicator()
    }
    
    private func createSelectionIndicator() -> UIImage? {
        let size = CGSize(width: 60, height: 2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        UIColor.systemGreen.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
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
