import Foundation

public final class PreferencesManager {
    public static let shared = PreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    public enum Keys {
        public static let launchAtLogin = "launchAtLogin"
        public static let activateAtLaunch = "activateAtLaunch"
        public static let activateWithLeftClick = "activateWithLeftClick"
        public static let allowDisplaySleep = "allowDisplaySleep"
        public static let keepAwakeWithLidClosed = "keepAwakeWithLidClosed"
        public static let allowNotifications = "allowNotifications"
        public static let coloredMenuBarIcon = "coloredMenuBarIcon"
        public static let activateOnPowerConnect = "activateOnPowerConnect"
        public static let deactivateOnPowerDisconnect = "deactivateOnPowerDisconnect"
        public static let selectedDurationMinutes = "selectedDurationMinutes"
    }
    
    private init() {
        registerDefaults()
    }
    
    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.launchAtLogin: false,
            Keys.activateAtLaunch: false,
            Keys.activateWithLeftClick: true,
            Keys.allowDisplaySleep: false,
            Keys.keepAwakeWithLidClosed: true,
            Keys.allowNotifications: true,
            Keys.coloredMenuBarIcon: false,
            Keys.activateOnPowerConnect: false,
            Keys.deactivateOnPowerDisconnect: false,
            Keys.selectedDurationMinutes: 0 // 0 = indefinite
        ])
    }
    
    public var launchAtLogin: Bool {
        get { defaults.bool(forKey: Keys.launchAtLogin) }
        set { 
            defaults.set(newValue, forKey: Keys.launchAtLogin)
            NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
        }
    }
    
    public var activateAtLaunch: Bool {
        get { defaults.bool(forKey: Keys.activateAtLaunch) }
        set { defaults.set(newValue, forKey: Keys.activateAtLaunch) }
    }
    
    public var activateWithLeftClick: Bool {
        get { defaults.bool(forKey: Keys.activateWithLeftClick) }
        set { defaults.set(newValue, forKey: Keys.activateWithLeftClick) }
    }
    
    public var allowDisplaySleep: Bool {
        get { defaults.bool(forKey: Keys.allowDisplaySleep) }
        set { 
            defaults.set(newValue, forKey: Keys.allowDisplaySleep)
            NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
        }
    }
    
    public var keepAwakeWithLidClosed: Bool {
        get { defaults.bool(forKey: Keys.keepAwakeWithLidClosed) }
        set { 
            defaults.set(newValue, forKey: Keys.keepAwakeWithLidClosed)
            NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
        }
    }
    
    public var allowNotifications: Bool {
        get { defaults.bool(forKey: Keys.allowNotifications) }
        set { defaults.set(newValue, forKey: Keys.allowNotifications) }
    }
    
    public var coloredMenuBarIcon: Bool {
        get { defaults.bool(forKey: Keys.coloredMenuBarIcon) }
        set { 
            defaults.set(newValue, forKey: Keys.coloredMenuBarIcon)
            NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
        }
    }
    
    public var activateOnPowerConnect: Bool {
        get { defaults.bool(forKey: Keys.activateOnPowerConnect) }
        set { defaults.set(newValue, forKey: Keys.activateOnPowerConnect) }
    }
    
    public var deactivateOnPowerDisconnect: Bool {
        get { defaults.bool(forKey: Keys.deactivateOnPowerDisconnect) }
        set { defaults.set(newValue, forKey: Keys.deactivateOnPowerDisconnect) }
    }
    
    public var selectedDurationMinutes: Int {
        get { defaults.integer(forKey: Keys.selectedDurationMinutes) }
        set { defaults.set(newValue, forKey: Keys.selectedDurationMinutes) }
    }
}

public extension Notification.Name {
    static let preferencesDidChange = Notification.Name("preferencesDidChange")
}
