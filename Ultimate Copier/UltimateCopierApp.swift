//
//  UltimateCopierApp.swift
//  Ultimate Copier
//
//  Created by Husnain Khurshid on 12/10/2025.
//


//
//  UltimateCopierApp.swift
//  UltimateCopier
//
//  Created by Husnain Khurshid on 12/10/2025.
//

import SwiftUI

@main
struct UltimateCopierApp: App {
    // Bridge AppDelegate into the SwiftUI lifecycle
    @NSApplicationDelegateAdaptor(UltimateCopierAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // Keep the app alive and visible so you can test local/global monitoring
            Text(
                """
                UltimateCopier keyboard monitoring…
                Bring another app frontmost to test the global hotkey (Option + C).
                Keep this window frontmost to test local events.
                """
            )
            .padding()
        }
    }
}
