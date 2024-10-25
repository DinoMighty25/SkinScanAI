//
//  skinscanApp.swift
//  skinscan
//
//  Created by Troy on 6/19/24.
//

import SwiftUI
import AVFoundation

@main
struct skinscanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Permission received")
            } else {
                print("Permission denied")
            }
        }
    }
}

