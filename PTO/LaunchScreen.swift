import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.spacing.xl) {
                Text("🚽")
                    .font(.system(size: 80))
                    .accessibilityHidden(true)
                
                Text("Paid to Operate")
                    .font(DesignTokens.typography.largeTitle)
                    .foregroundStyle(AppColors.corporate)
                    .accessibilityLabel("Paid to Operate")
            }
        }
    }
}

#Preview("Light Mode") {
    LaunchScreen()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    LaunchScreen()
        .preferredColorScheme(.dark)
}