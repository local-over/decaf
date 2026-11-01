import AppKit
import Foundation
import SwiftUI
import ServiceManagement

public final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    private var animationTimer: Timer?
    private var currentAnimationFrame: Int = 0
    private var globalHotkeyMonitor: Any?
    
    public override init() {
        super.init()
        setupStatusItem()
        setupPopover()
        setupGlobalHotkey()
        updateUI()
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleStateUpdate), name: .sleepStateDidChange, object: nil)
        center.addObserver(self, selector: #selector(handleTimerTick), name: .sleepTimerDidTick, object: nil)
        center.addObserver(self, selector: #selector(handlePreferencesUpdate), name: .preferencesDidChange, object: nil)
        
        if PreferencesManager.shared.activateAtLaunch {
            SleepManager.shared.activate()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        animationTimer?.invalidate()
        if let monitor = globalHotkeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateIcon()
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: PopoverContentView())
    }
    
    private func setupGlobalHotkey() {
        // Option + C global hotkey
        globalHotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.option) && event.keyCode == 8 {
                DispatchQueue.main.async {
                    SleepManager.shared.toggle()
                }
            }
        }
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let currentEvent = NSApp.currentEvent else { return }
        
        let isRightClick = currentEvent.type == .rightMouseUp ||
            (currentEvent.modifierFlags.contains(.control) && currentEvent.type == .leftMouseUp)
        
        if PreferencesManager.shared.activateWithLeftClick {
            if isRightClick {
                togglePopover()
            } else {
                SleepManager.shared.toggle()
            }
        } else {
            togglePopover()
        }
    }
    
    public func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    @objc private func handleStateUpdate() {
        updateUI()
    }
    
    @objc private func handleTimerTick() {
        updateTooltip()
    }
    
    @objc private func handlePreferencesUpdate() {
        updateUI()
    }
    
    private func updateUI() {
        updateIcon()
        updateTooltip()
    }
    
    private func updateIcon() {
        let active = SleepManager.shared.isActive
        let colored = PreferencesManager.shared.coloredMenuBarIcon
        
        if active {
            startAnimation(colored: colored)
        } else {
            stopAnimation()
            statusItem.button?.image = MenuBarIconGenerator.shared.inactiveIcon()
        }
    }
    
    private func startAnimation(colored: Bool) {
        if animationTimer == nil {
            currentAnimationFrame = 0
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.20, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentAnimationFrame = (self.currentAnimationFrame + 1) % 4
                self.statusItem.button?.image = MenuBarIconGenerator.shared.activeIcon(
                    frame: self.currentAnimationFrame,
                    colored: PreferencesManager.shared.coloredMenuBarIcon
                )
            }
        }
        statusItem.button?.image = MenuBarIconGenerator.shared.activeIcon(frame: 0, colored: colored)
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateTooltip() {
        let active = SleepManager.shared.isActive
        if active {
            if SleepManager.shared.isTimed {
                statusItem.button?.toolTip = "Cafaine: \(SleepManager.shared.formattedActiveUntil())"
            } else {
                statusItem.button?.toolTip = "Cafaine: Active (Indefinitely)"
            }
        } else {
            statusItem.button?.toolTip = "Cafaine: Inactive"
        }
    }
}
