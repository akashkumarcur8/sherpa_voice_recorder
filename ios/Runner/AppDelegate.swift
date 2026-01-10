// import Flutter
// import UIKit
//
// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }


import UIKit
import Flutter
import AVFoundation
import CoreAudio
import ExternalAccessory

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let recorderChannel = "com.sherpa/record"
    private let audioDeviceChannel = "audio_device_channel"
    private let otgChannel = "com.sherpa/usb"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        // Setup for recording service channel
        let recorderChannel = FlutterMethodChannel(name: self.recorderChannel, binaryMessenger: controller.binaryMessenger)
        recorderChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "startRecordingService":
                self.startRecording()
                result(nil)
            case "stopRecordingService":
                self.stopRecording()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Setup for checking wired headset connection
        let audioDeviceChannel = FlutterMethodChannel(name: self.audioDeviceChannel, binaryMessenger: controller.binaryMessenger)
        audioDeviceChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "isWiredHeadsetConnected" {
                let isConnected = self.isWiredHeadsetConnected()
                result(isConnected)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // Setup for checking OTG connection status
        let otgChannel = FlutterMethodChannel(name: self.otgChannel, binaryMessenger: controller.binaryMessenger)
        otgChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "checkOtgStatus" {
                let isConnected = self.isOtgConnected()
                result(isConnected)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Method to check if wired headset is connected
    private func isWiredHeadsetConnected() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for output in route.outputs {
            if output.portType == .headphones {
                return true
            }
        }
        return false
    }

    // Methods to start/stop recording
    private func startRecording() {
        // Implement your recording logic here (using AVAudioRecorder or similar)
        print("Recording started")
    }

    private func stopRecording() {
        // Implement your stop recording logic here
        print("Recording stopped")
    }

    // Method to check if OTG (USB) is connected
    private func isOtgConnected() -> Bool {
        let accessoryManager = EAAccessoryManager.shared()
        return !accessoryManager.connectedAccessories.isEmpty
    }
}
