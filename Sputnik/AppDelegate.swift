//
//  AppDelegate.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-07-08.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var document = GeminiDocument()
    var windows: [GeminiWindow] = []
    var sourceWindows: [NSWindow] = []
    
    @IBAction func newWindow(_ sender: Any) {
        openNewWindow()
    }
    
    @IBAction func viewSource(_ sender: Any) {
        if let window = NSApp.mainWindow {
            if let geminiWindow = windows.first(where: {
                $0.window == window
            }) {
                let lines = geminiWindow.document.rawText
                let contentView = SourceView(content: lines)
                sourceWindows.append(createWindow(view: AnyView(contentView)))
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        openNewWindow()
    }

    func openNewWindow() {
        let document = GeminiDocument()
        let contentView = ContentView(document: document)
        let window = createWindow(view: AnyView(contentView))
        windows.append(GeminiWindow(window: window, document: document))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func createWindow(view: AnyView) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: view)
        window.makeKeyAndOrderFront(nil)
        
        return window
    }
}


struct GeminiWindow {
    let window: NSWindow
    let document: GeminiDocument
}

