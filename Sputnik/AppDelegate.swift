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
    var windows: [NSWindow] = []
    var previousWindowPoint: NSPoint = NSZeroPoint
    
    // preferences window
    @IBAction func prefWindow(_ sender: Any) {
        let pref = Preferences()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.contentView = NSHostingView(rootView: pref)
        setupWindow(window: window)
    }
    
    @IBAction func newWindow(_ sender: Any) {
        openNewWindow()
    }
    
    @IBAction func back(_ sender: Any) {
        if let document = getCurrentDocument() {
            document.back()
        }
    }

    @IBAction func forward(_ sender: Any) {
        if let document = getCurrentDocument() {
            document.forward()
        }
    }

    @IBAction func viewSource(_ sender: Any) {
        if let document = getCurrentDocument() {
            let lines = document.rawText
            let contentView = SourceView(content: lines)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false
            )
            window.contentView = NSHostingView(rootView: contentView)
            setupWindow(window: window)
        }
    }

    func getCurrentDocument() -> GeminiDocument? {
        if let window = NSApp.mainWindow {
            if let geminiWindow = window as? GeminiDocumentWindow {
                return geminiWindow.document
            }
        }

        return nil
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        openNewWindow()
    }

    func openNewWindow() {
        let document = GeminiDocument()
        let contentView = ContentView(document: document)
        let window = GeminiDocumentWindow(document: document)
        window.contentView = NSHostingView(rootView: contentView)
        setupWindow(window: window)
    }
    
    func setupWindow(window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        window.setFrameAutosaveName("Main Window")

        window.center()
        previousWindowPoint = window.cascadeTopLeft(from: previousWindowPoint)
        self.windows.append(window)
    }
}

class GeminiDocumentWindow : NSWindow {
    let document: GeminiDocument

    init(document: GeminiDocument) {
        self.document = document

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
    }

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            if let chars = event.charactersIgnoringModifiers {
                let scalars = chars.unicodeScalars.map{ $0.value }

                if scalars.contains(63234) {
                    document.back()
                } else if scalars.contains(63235) {
                    document.forward()
                }
            }
        }
    }
}
