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
    
    init() {
        self.hourlyWage = UserDefaults.standard.double(forKey: "hourlyWage")
        if hourlyWage == 0 {
            hourlyWage = 25.0
        }
        
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.enableNotifications = UserDefaults.standard.bool(forKey: "enableNotifications")
        self.enableHaptics = UserDefaults.standard.bool(forKey: "enableHaptics")
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