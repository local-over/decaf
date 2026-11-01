import Foundation
import AppKit
import IOKit.pwr_mgt
import IOKit.ps
import UserNotifications

public extension Notification.Name {
    static let sleepStateDidChange = Notification.Name("sleepStateDidChange")
    static let sleepTimerDidTick = Notification.Name("sleepTimerDidTick")
}

public final class SleepManager {
    public static let shared = SleepManager()
    
    private var assertionID: IOPMAssertionID = 0
    public private(set) var isActive: Bool = false
    private var timer: Timer?
    public private(set) var remainingSeconds: Int = 0
    public private(set) var activeUntilDate: Date?
    public var isTimed: Bool { remainingSeconds > 0 }
    
    private var powerRunLoopSource: CFRunLoopSource?
    
    private init() {
        setupPowerMonitoring()
    }
    
    deinit {
        if let source = powerRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }
    
    @discardableResult
    public func activate(durationMinutes: Int? = nil) -> Bool {
        deactivate(postNotification: false)
        
        let prefs = PreferencesManager.shared
        let preventDisplay = !prefs.allowDisplaySleep
        let assertionType = preventDisplay ?
            kIOPMAssertionTypePreventUserIdleDisplaySleep :
            kIOPMAssertionTypePreventUserIdleSystemSleep
        
        let reason = "Cafaine Anti-Sleep Utility Active" as CFString
        let result = IOPMAssertionCreateWithName(
            assertionType as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        
        if result == kIOReturnSuccess {
            isActive = true
            
            let minutes = durationMinutes ?? prefs.selectedDurationMinutes
            
            if minutes > 0 {
                remainingSeconds = minutes * 60
                activeUntilDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
                
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    if self.remainingSeconds > 1 {
                        self.remainingSeconds -= 1
                        NotificationCenter.default.post(name: .sleepTimerDidTick, object: nil)
                    } else {
                        self.handleTimerExpired()
                    }
                }
            } else {
                remainingSeconds = 0
                activeUntilDate = nil
            }
            
            NotificationCenter.default.post(name: .sleepStateDidChange, object: nil)
            return true
        } else {
            assertionID = 0
            isActive = false
            activeUntilDate = nil
            NotificationCenter.default.post(name: .sleepStateDidChange, object: nil)
            return false
        }
    }
    
    public func deactivate(postNotification: Bool = true) {
        if isActive && assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        
        timer?.invalidate()
        timer = nil
        remainingSeconds = 0
        activeUntilDate = nil
        isActive = false
        
        if postNotification {
            NotificationCenter.default.post(name: .sleepStateDidChange, object: nil)
        }
    }
    
    public func toggle() {
        if isActive {
            deactivate()
        } else {
            activate()
        }
    }
    
    private func handleTimerExpired() {
        deactivate()
        if PreferencesManager.shared.allowNotifications {
            sendNotification(title: "Cafaine", body: "Anti-sleep timer expired. Your Mac can now sleep normally.")
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request)
    }
    
    public func formattedActiveUntil() -> String {
        guard let until = activeUntilDate else { return "Active" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "Active Until \(formatter.string(from: until))"
    }
    
    public func formattedRemainingTime() -> String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return "\(seconds)s"
        }
    }
    
    private func setupPowerMonitoring() {
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        if let source = IOPSNotificationCreateRunLoopSource({ context in
            guard let context = context else { return }
            let manager = Unmanaged<SleepManager>.fromOpaque(context).takeUnretainedValue()
            manager.powerSourceChanged()
        }, context)?.takeRetainedValue() {
            powerRunLoopSource = source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }
    
    private func powerSourceChanged() {
        let status = BatteryMonitor.shared.currentStatus()
        let prefs = PreferencesManager.shared
        
        if prefs.activateOnPowerConnect && status.isCharging && !isActive {
            activate()
        } else if prefs.deactivateOnPowerDisconnect && !status.isCharging && isActive {
            deactivate()
        }
    }
}
