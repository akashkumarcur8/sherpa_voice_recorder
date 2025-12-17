////package com.example.mice_activeg;
////
////import android.content.Intent;
////import io.flutter.embedding.android.FlutterActivity;
////import io.flutter.plugin.common.MethodChannel;
////
////public class MainActivity extends FlutterActivity {
////    private static final String CHANNEL = "com.example.mice_activeg/record";
////
////    @Override
////    public void configureFlutterEngine(io.flutter.embedding.engine.FlutterEngine flutterEngine) {
////        super.configureFlutterEngine(flutterEngine);
////
////        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
////                (call, result) -> {
////                    if (call.method.equals("startRecordingService")) {
////                        startService(new Intent(MainActivity.this, AudioRecordService.class));
////                        result.success(null);
////                    } else if (call.method.equals("stopRecordingService")) {
////                        stopService(new Intent(MainActivity.this, AudioRecordService.class));
////                        result.success(null);
////                    } else {
////                        result.notImplemented();
////                    }
////                }
////        );
////    }
////}
//
//
//package com.example.mice_activeg;
//
//import android.content.Context;
//import android.content.Intent;
//import android.media.AudioManager;
//import android.os.Bundle;
//import android.util.Log;
//
//import io.flutter.embedding.android.FlutterActivity;
//import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.plugin.common.MethodChannel;
//
//public class MainActivity extends FlutterActivity {
//
//    private static final String AUDIO_DEVICE_CHANNEL = "audio_device_channel";
//    private static final String RECORDER_CHANNEL = "com.example.mice_activeg/record";
//
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//
//        // Ensure that FlutterEngine is initialized
//        FlutterEngine flutterEngine = getFlutterEngine();
//        if (flutterEngine == null) {
//            throw new IllegalStateException("FlutterEngine is not initialized");
//        }
//
//
//        // Setup the MethodChannel for checking wired headset connection
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), RECORDER_CHANNEL).setMethodCallHandler(
//                (call, result) -> {
//                    switch (call.method) {
//                        case "startRecordingService":
//                            startService(new Intent(MainActivity.this, AudioRecordService.class));
//                            result.success(null);
//                            break;
//                        case "stopRecordingService":
//                            stopService(new Intent(MainActivity.this, AudioRecordService.class));
//                            result.success(null);
//                            break;
//                        default:
//                            result.notImplemented();
//                            break;
//                    }
//                }
//        );
//
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), AUDIO_DEVICE_CHANNEL).setMethodCallHandler(
//                (call, result) -> {
//                    if (call.method.equals("isWiredHeadsetConnected")) {
//                        boolean isConnected = isWiredHeadsetConnected();
//                        result.success(isConnected);
//                    } else {
//                        result.notImplemented();
//                    }
//                }
//        );
//
//        // Setup the MethodChannel for starting/stopping recording services
//
//    }
//
//    @Override
//    public void configureFlutterEngine(FlutterEngine flutterEngine) {
//        super.configureFlutterEngine(flutterEngine);
//    }
//
//    // Method to check if wired headset is connected
//    private boolean isWiredHeadsetConnected() {
//        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
//        boolean isConnected = audioManager.isWiredHeadsetOn();
//        Log.d("MainActivity", "Wired headset connected: " + isConnected);
//        return isConnected;
//    }
//}
//
//


package com.sherpa;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.os.Bundle;
import android.util.Log;
import android.hardware.usb.UsbManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.provider.Settings;
import android.os.Build;

public class MainActivity extends FlutterActivity {

    private static final String AUDIO_DEVICE_CHANNEL = "audio_device_channel";
//    private static final String RECORDER_CHANNEL = "com.sherpa/record";
    private static final String CHANNEL = "com.sherpa/usb";
    private static final String CHANNEL_FOR_DEVICESTATUS = "com.example.otg_audio_status/device";


    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Setup the MethodChannel for starting/stopping recording services
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), RECORDER_CHANNEL).setMethodCallHandler(
//                (call, result) -> {
//                    switch (call.method) {
//                        case "startRecordingService":
//                            startService(new Intent(MainActivity.this, AudioRecordService.class));
//                            result.success(null);
//                            break;
//                        case "stopRecordingService":
//                            stopService(new Intent(MainActivity.this, AudioRecordService.class));
//                            result.success(null);
//                            break;
//                        default:
//                            result.notImplemented();
//                            break;
//                    }
//                }
//        );

        // Setup the MethodChannel for checking wired headset connection
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), AUDIO_DEVICE_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("isWiredHeadsetConnected")) {
                        boolean isConnected = isWiredHeadsetConnected();
                        result.success(isConnected);
                    } else {
                        result.notImplemented();
                    }
                }
        );


        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("checkOtgStatus")) {
                        boolean isConnected = checkOtgConnection();
                        result.success(isConnected);
                    } else {
                        result.notImplemented();
                    }
                }
        );



    }

    // Method to check if wired headset is connected
    private boolean isWiredHeadsetConnected() {
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        boolean isConnected = audioManager.isWiredHeadsetOn();
//        Log.d("MainActivity", "Wired headset connected: " + isConnected);
        return isConnected;
    }


    private boolean checkOtgConnection() {
        UsbManager usbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
        // Check if there are any connected USB devices
        if (usbManager != null && !usbManager.getDeviceList().isEmpty()) {
            return true;
        }
        return false;
    }




}

