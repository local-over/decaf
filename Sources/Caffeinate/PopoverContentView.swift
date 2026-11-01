import SwiftUI
import ServiceManagement

public final class PopoverState: ObservableObject {
    public static let shared = PopoverState()
    @Published public var isActive: Bool = false
    @Published public var statusText: String = ""
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .sleepStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .sleepTimerDidTick, object: nil)
        update()
    }
    
    @objc public func update() {
        isActive = SleepManager.shared.isActive
        if isActive {
            if SleepManager.shared.isTimed {
                statusText = SleepManager.shared.formattedActiveUntil()
            } else {
                statusText = "Active"
            }
        } else {
            statusText = ""
        }
    }
}

struct PopoverContentView: View {
    @ObservedObject var state = PopoverState.shared
    @AppStorage(PreferencesManager.Keys.launchAtLogin) private var launchAtLogin = false
    @AppStorage(PreferencesManager.Keys.activateAtLaunch) private var activateAtLaunch = false
    @AppStorage(PreferencesManager.Keys.activateWithLeftClick) private var activateWithLeftClick = true
    @AppStorage(PreferencesManager.Keys.allowDisplaySleep) private var allowDisplaySleep = false
    @AppStorage(PreferencesManager.Keys.keepAwakeWithLidClosed) private var keepAwakeWithLidClosed = true
    @AppStorage(PreferencesManager.Keys.allowNotifications) private var allowNotifications = true
    @AppStorage(PreferencesManager.Keys.coloredMenuBarIcon) private var coloredMenuBarIcon = false
    @AppStorage(PreferencesManager.Keys.activateOnPowerConnect) private var activateOnPowerConnect = false
    @AppStorage(PreferencesManager.Keys.deactivateOnPowerDisconnect) private var deactivateOnPowerDisconnect = false
    @AppStorage(PreferencesManager.Keys.selectedDurationMinutes) private var selectedDurationMinutes = 0
    
    @State private var isDurationExpanded = true
    @State private var isSettingsExpanded = false
    @State private var showAboutModal = false
    @State private var showDonateModal = false

    // Exactly 8 items in a single horizontal row matching Caffeinated: [ ∞ ] [ 15 ] [ 30 ] [ 45 ] [ 01 ] [ 04 ] [ 08 ] [ ⚙ ]
    // Fits cleanly within 252px with ZERO scrollbar and ZERO second row
    private let durationPills: [(Int, String)] = [
        (0, "∞"),
        (15, "15"),
        (30, "30"),
        (45, "45"),
        (60, "01"),
        (240, "04"),
        (480, "08")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Title, Status, and Main Toggle Switch
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cafaine")
                        .font(.system(size: 14, weight: .bold))
                    
                    if state.isActive {
                        Text(state.statusText)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(red: 0.00, green: 0.68, blue: 0.95))
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { state.isActive },
                    set: { newVal in
                        if newVal {
                            SleepManager.shared.activate()
                        } else {
                            SleepManager.shared.deactivate()
                        }
                    }
                ))
                .toggleStyle(.switch)
                .scaleEffect(0.85)
                .labelsHidden()
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // Duration Section (Single Horizontal Row of 8 items, NO scrollbar)
            VStack(alignment: .leading, spacing: 6) {
                Button {
                    withAnimation(.spring(response: 0.20, dampingFraction: 0.85)) {
                        isDurationExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("Duration")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: isDurationExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if isDurationExpanded {
                    HStack(spacing: 5) {
                        ForEach(durationPills, id: \.0) { item in
                            pillButton(mins: item.0, label: item.1)
                        }
                        
                        // Custom Duration Button (Gear)
                        Button {
                            promptCustomDuration()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 10))
                                .frame(width: 24, height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.primary.opacity(0.06))
                                )
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                        .help("Custom Duration")
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // Settings Section (Compact Accordion)
            VStack(alignment: .leading, spacing: 6) {
                Button {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        isSettingsExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: isSettingsExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if isSettingsExpanded {
                    VStack(spacing: 5) {
                        SettingItemRow(icon: "power", title: "Launch at Login", isOn: $launchAtLogin) { val in
                            setLaunchAtLogin(val)
                        }
                        SettingItemRow(icon: "power.circle", title: "Activate at Launch", isOn: $activateAtLaunch)
                        SettingItemRow(icon: "cursorarrow.rays", title: "Activate with Left Click", isOn: $activateWithLeftClick)
                        
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.00, green: 0.50, blue: 0.95).opacity(0.12))
                                    .frame(width: 18, height: 18)
                                Image(systemName: "keyboard")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(Color(red: 0.00, green: 0.55, blue: 0.95))
                            }
                            Text("Keyboard Shortcut")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("⌥C")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.primary.opacity(0.08))
                                .cornerRadius(4)
                        }
                        .frame(height: 22)
                        
                        SettingItemRow(icon: "display", title: "Allow Display Sleep", isOn: $allowDisplaySleep) { _ in
                            if SleepManager.shared.isActive {
                                SleepManager.shared.activate()
                            }
                        }
                        SettingItemRow(icon: "laptopcomputer", title: "Keep Awake with Lid Closed", isOn: $keepAwakeWithLidClosed)
                        SettingItemRow(icon: "bell", title: "Allow Notifications", isOn: $allowNotifications)
                        SettingItemRow(icon: "paintpalette", title: "Colored Menu Bar Icon", isOn: $coloredMenuBarIcon) { _ in
                            NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
                        }
                        SettingItemRow(icon: "bolt", title: "Activate on Power Connect", isOn: $activateOnPowerConnect)
                        SettingItemRow(icon: "powerplug", title: "Deactivate on Power Disconnect", isOn: $deactivateOnPowerDisconnect)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 10)
            
            // Footer Action Links
            VStack(alignment: .leading, spacing: 2) {
                Button {
                    FloatingWindowManager.shared.showDonateWindow()
                } label: {
                    HStack {
                        Label("Donate (PayPal / Crypto)", systemImage: "heart")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.00, green: 0.68, blue: 0.95))
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                Button {
                    if let url = URL(string: "https://local-over.github.io/decaf") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Website & Documentation")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .padding(.vertical, 3)
                }
                .buttonStyle(.plain)
                
                Button {
                    FloatingWindowManager.shared.showAboutWindow()
                } label: {
                    Text("About")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .padding(.vertical, 3)
                }
                .buttonStyle(.plain)
                
                Button {
                    SleepManager.shared.deactivate()
                    NSApp.terminate(nil)
                } label: {
                    Text("Quit")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .padding(.vertical, 3)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
        }
        .frame(width: 254)
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private func pillButton(mins: Int, label: String) -> some View {
        let isSelected = (selectedDurationMinutes == mins)
        Button {
            selectedDurationMinutes = mins
            SleepManager.shared.activate(durationMinutes: mins)
        } label: {
            Text(label)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isSelected ? Color(red: 0.00, green: 0.68, blue: 0.95) : Color.primary.opacity(0.06))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    private func promptCustomDuration() {
        let alert = NSAlert()
        alert.messageText = "Custom Duration"
        alert.informativeText = "Enter active duration in minutes:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Activate")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 160, height: 24))
        input.placeholderString = "e.g. 50"
        input.stringValue = "50"
        alert.accessoryView = input
        
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            if let mins = Int(input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)), mins > 0 {
                selectedDurationMinutes = mins
                SleepManager.shared.activate(durationMinutes: mins)
            }
        }
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if enabled && service.status != .enabled {
                    try service.register()
                } else if !enabled && service.status == .enabled {
                    try service.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }
}

struct SettingItemRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    var onChange: ((Bool) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.00, green: 0.50, blue: 0.95).opacity(0.12))
                    .frame(width: 18, height: 18)
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(red: 0.00, green: 0.55, blue: 0.95))
            }
            Text(title)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .scaleEffect(0.70)
                .labelsHidden()
                .onChange(of: isOn) { val in
                    onChange?(val)
                }
        }
        .frame(height: 22)
    }
}

// MARK: - Floating Windows for Donate & About

public final class FloatingWindowManager: NSObject, NSWindowDelegate {
    public static let shared = FloatingWindowManager()
    private var donateWindow: NSWindow?
    private var aboutWindow: NSWindow?
    
    public func showDonateWindow() {
        if let win = donateWindow {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 260),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Support Cafaine"
        win.center()
        win.isReleasedWhenClosed = false
        win.level = .floating
        win.delegate = self
        win.contentView = NSHostingView(rootView: DonateModalView { [weak win] in
            win?.close()
        })
        self.donateWindow = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func showAboutWindow() {
        if let win = aboutWindow {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 290),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "About Cafaine"
        win.center()
        win.isReleasedWhenClosed = false
        win.level = .floating
        win.delegate = self
        win.contentView = NSHostingView(rootView: AboutModalView { [weak win] in
            win?.close()
        })
        self.aboutWindow = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func windowWillClose(_ notification: Notification) {
        if let closedWin = notification.object as? NSWindow {
            if closedWin == donateWindow {
                donateWindow = nil
            } else if closedWin == aboutWindow {
                aboutWindow = nil
            }
        }
    }
}

struct DonateModalView: View {
    var onClose: () -> Void
    @State private var copied = false
    private let cryptoAddr = "UQBEJwLa4EGPRmUKw4O1i9d_JjJGmjkJ2myqR5lborzgceT-"
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Support Cafaine")
                    .font(.system(size: 16, weight: .bold))
                Text("Created by Hassan Elkady (local-over)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
            
            VStack(spacing: 10) {
                // PayPal
                Button {
                    if let url = URL(string: "https://paypal.me/HassanElkady2") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Donate via PayPal")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.00, green: 0.48, blue: 1.0))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                // Crypto USDT
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("USDT (TON / TRC20)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(copied ? "Copied!" : "Copy") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(cryptoAddr, forType: .string)
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        }
                        .font(.system(size: 11, weight: .bold))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    Text(cryptoAddr)
                        .font(.system(size: 10, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(6)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 16)
            
            HStack {
                Button("Donate Web Page") {
                    if let url = URL(string: "https://local-over.github.io/decaf/donate.html") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .font(.system(size: 12))
                .buttonStyle(.link)
                
                Spacer()
                
                Button("Close") {
                    onClose()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .frame(width: 360, height: 260)
    }
}

struct AboutModalView: View {
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.00, green: 0.48, blue: 1.0).opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 0.00, green: 0.48, blue: 1.0))
            }
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                Text("Cafaine")
                    .font(.system(size: 17, weight: .bold))
                Text("Version 1.0.0")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("Created by Hassan Elkady (local-over)")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.top, 2)
                Text("100% Free & Open-Source under MIT License.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Website") {
                    if let url = URL(string: "https://local-over.github.io/decaf") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
                
                Button("GitHub") {
                    if let url = URL(string: "https://github.com/local-over/decaf") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Button("Close") {
                onClose()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .frame(width: 360, height: 290)
    }
}
