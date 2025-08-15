import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    @Published var hourlyWage: Double {
        didSet {
            UserDefaults.standard.set(hourlyWage, forKey: "hourlyWage")
        }
    }
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }
    
    @Published var currencySymbol: String {
        didSet {
            UserDefaults.standard.set(currencySymbol, forKey: "currencySymbol")
        }
    }
    
    @Published var enableNotifications: Bool {
        didSet {
            UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
        }
    }
    
    @Published var enableHaptics: Bool {
        didSet {
            UserDefaults.standard.set(enableHaptics, forKey: "enableHaptics")
        }
    }
    
    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        }
    }
    
    init() {
        let savedWage = UserDefaults.standard.double(forKey: "hourlyWage")
        self.hourlyWage = savedWage == 0 ? 25.0 : savedWage
        
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.enableNotifications = UserDefaults.standard.bool(forKey: "enableNotifications")
        self.enableHaptics = UserDefaults.standard.bool(forKey: "enableHaptics")
        
        // Load appearance mode with system as default
        let savedAppearance = UserDefaults.standard.string(forKey: "appearanceMode") ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: savedAppearance) ?? .system
    }
    
    var formattedWage: String {
        return "\(currencySymbol)\(String(format: "%.2f", hourlyWage))/hr"
    }
    
    func calculateEarnings(seconds: TimeInterval) -> Double {
        return (hourlyWage / 3600) * seconds
    }
    
    func formatEarnings(_ amount: Double) -> String {
        return "\(currencySymbol)\(String(format: "%.2f", amount))"
    }
}