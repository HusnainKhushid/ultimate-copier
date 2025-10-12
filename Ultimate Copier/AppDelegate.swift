//
//  UltimateCopierAppDelegate.swift
//  UltimateCopier
//
//  Created by Husnain Khurshid on 12/10/2025.
//

import Cocoa
import Carbon.HIToolbox // RegisterEventHotKey, key codes, etc.

final class UltimateCopierAppDelegate: NSObject, NSApplicationDelegate {

    // Keep Carbon references alive
    private var globalHotKeyRef: EventHotKeyRef?
    private var hotKeyEventHandlerRef: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("UltimateCopierAppDelegate launched")
        registerGlobalHotKeyOptionC()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let globalHotKeyRef {
            UnregisterEventHotKey(globalHotKeyRef)
        }
        if let hotKeyEventHandlerRef {
            RemoveEventHandler(hotKeyEventHandlerRef)
        }
    }

    // MARK: - Carbon global hotkey (fires when app is not frontmost)
    private func registerGlobalHotKeyOptionC() {
        // 1) Install an event handler for hotkey presses
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Make a UPP that calls back into this instance
        let handler: EventHandlerUPP = { (_, eventRef, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            let me = Unmanaged<UltimateCopierAppDelegate>
                .fromOpaque(userData)
                .takeUnretainedValue()

            // Optional: inspect which hotkey ID triggered
            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                eventRef,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )

            // Only one hotkey in this sample, so just handle:
            me.handleOptionCPressed()
            return noErr
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            selfPtr,
            &hotKeyEventHandlerRef
        )

        guard installStatus == noErr else {
            print("InstallEventHandler failed with status \(installStatus)")
            return
        }

        // 2) Register Option (Alt) + C
        // Signature can be any 4-byte tag you like; using 'OPTC'
        var hotKeyID = EventHotKeyID(signature: OSType(bitPattern: 0x4F505443), id: 1)
        let keyCode: UInt32 = UInt32(kVK_ANSI_C)   // letter 'C'
        let modifiers: UInt32 = UInt32(optionKey)  // Option only

        let regStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &globalHotKeyRef
        )

        if regStatus == noErr {
            print("Registered global hotkey: Option + C")
        } else {
            print("RegisterEventHotKey failed with status \(regStatus)")
        }
    }

    private func handleOptionCPressed() {
        print("Option + C pressed (Carbon hotkey)")

        // Read clipboard example
        if let text = NSPasteboard.general.string(forType: .string) {
            print("Clipboard:", text)
        } else {
            print("Clipboard empty or non-string")
        }

        // TODO: Integrate with UltimateCopier capture/history pipeline here
    }
}
