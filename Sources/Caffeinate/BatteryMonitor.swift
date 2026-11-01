import Foundation
import IOKit.ps

public struct BatteryStatus {
    public let isPresent: Bool
    public let isCharging: Bool
    public let percentage: Int
}

public final class BatteryMonitor {
    public static let shared = BatteryMonitor()
    
    private init() {}
    
    public func currentStatus() -> BatteryStatus {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return BatteryStatus(isPresent: false, isCharging: false, percentage: 100)
        }
        
        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else {
                continue
            }
            
            let isCharging = (description[kIOPSIsChargingKey] as? Bool) ?? false
            let current = description[kIOPSCurrentCapacityKey] as? Int ?? 0
            let max = description[kIOPSMaxCapacityKey] as? Int ?? 100
            let percentage = max > 0 ? Int((Double(current) / Double(max)) * 100) : 100
            
            return BatteryStatus(isPresent: true, isCharging: isCharging, percentage: percentage)
        }
        
        return BatteryStatus(isPresent: false, isCharging: false, percentage: 100)
    }
}
