//
//  SignalGeneratorAppApp.swift
//  SignalGeneratorApp
//
//  Created by Mark Erbaugh on 2/28/22.
//

import SwiftUI

@main
struct SignalGeneratorAppApp: App {
    @NSApplicationDelegateAdaptor(CloseDelegate.self) var closeDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
