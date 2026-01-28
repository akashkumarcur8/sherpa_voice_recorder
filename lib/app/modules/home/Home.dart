// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:hive/hive.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:mice_activeg/app/core/utils/extensions/snackbar_extensions.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// im'../login/login.dart'ket_channel/io.dart';
// import '../../../login.dart';
// import '../../../main.dart';
// import '../../core/services/storage/database_helpher.dart';
// import '../../core/services/storage/sharedPrefHelper.dart';
// import '../../routes/app_routes.dart';
// import '../conversation/conversation_view.dart';
// import '../faq_guide/faq_guide.dart';
// import '../setting/setting_screen_view.dart';
// import '../analytics/analytics_widget.dart';
// import '../geo_tracking/LocationController.dart';
// import 'controllers/mark_conversation_controller.dart';
// import 'controllers/mice_blinking_controller.dart';
// import '../help_centre/audio_quality.dart';
// import '../live_nudges/widget_page.dart';
// import 'package:firebase_performance/firebase_performance.dart';
// import 'dart:math';
// import 'package:omni_datetime_picker/omni_datetime_picker.dart';
// import 'dart:convert';
// import '../profile/profile_page.dart';
// import 'controllers/statistics_data_controller.dart';
//
//
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> with WidgetsBindingObserver {
//   @override
//   FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FlutterSoundRecorder _streamRecorder = FlutterSoundRecorder();
//   final dbHelper = DatabaseHelper();
//   // final FlutterSoundRecorder _fileRecorder   = FlutterSoundRecorder();
//
//
//   //static const platform = MethodChannel('com.sherpa/record');
//   static const platform2 = MethodChannel('audio_device_channel');
//   static const platform3 = MethodChannel('com.sherpa/usb');
//
//
//
//
//
//   String? _filePath;
//   Timer? _uploadTimer;
//   bool isRecording = false;
//   Timer? _timer;
//   int _lastUploadedPosition = 0;
//   int _seconds = 0;
//   var startTimeStamp = 0;
//   Timer? _timerforBatery;
//   Timer? _hourlyTimer;
//   String? username;
//   String email="";
//   String emp_name ="";
//   String? storeName;
//   String teamId="NA";
//   String managerId="NA";
//   String companyId="NA";
//   IOWebSocketChannel? _channel;
//
//   String? empType;
//
//   List<DateTime>? dateTimeList;
//
// // Declare variables outside the function to manage state
//   bool firstNotificationTriggered = false;
//   int silentIntervals = 0;
//   bool initialBuffer = true;
//   StreamSubscription? _amplitudeSubscription; // To manage the subscription
//   bool isUploading = false; // Define this in your class
//   String uploadStatus = "Waiting to upload..."; // Upload status message
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final MiceBlinkingController miceBlinkingController = Get.put(MiceBlinkingController());
//   // Initialize the controller to start the periodic updates automatically
//   final LocationController locationController = Get.put(LocationController());
//   var numberOfDisconnects=0;
//   // 1) Declare your active‐tab index here:
//   int _currentIndex = 0;
//
//
//
//
//
//
//
//   final statisticsDataController = Get.put(StatisticsDataController());
//   late StreamController<Uint8List>? _audioController;
//
//
//   final trace = FirebasePerformance.instance.newTrace("dashboard");
//
//
//
//
//
//   Timer? _audioTestTimer;
//
//   QualityAnalyzer? _quality;   // analyzer instance
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeRecorder();
//     _initializeRecorders();
//     _loadUserData();
//     monitorConnectedDevices();
//     _fetchstatisticsData();
//
//   }
//
//
//
//
//   Future<void> _initializeRecorders() async {
//     await _streamRecorder.openRecorder();
//   }
//
//   @override
//   void didChangeDependencies() async {
//     // TODO: implement didChangeDependencies
//     super.didChangeDependencies();
//     //  await _initializeTracking();
//     await _fetchstatisticsData();
//     await trace.start();
//   }
//
//   @override
//   void dispose() async {
//     _timer?.cancel();
//     _recorder?.openRecorder();
//     _uploadTimer?.cancel();
//     _timerforBatery?.cancel();
//     _hourlyTimer?.cancel();
//
//     WidgetsBinding.instance.removeObserver(this); // Remove observer
//
//     super.dispose();
//
//     _audioTestTimer?.cancel();
//     _quality = null;
//   }
//
//   _fetchstatisticsData() async {
//     final DateTime selectedDate = DateTime.now();
//     var user_Id = await SharedPrefHelper.getpref("user_id");
//
//     await statisticsDataController.fetchUserAudioStats(
//         userId: int.parse(user_Id), selectedDate: selectedDate);
//     // setState(() {
//     //   numberOfDisconnects = statisticsDataController.numberOfDisconnects.value;
//     // });
//
//   }
//
//
//   Future<void> _loadUserData() async {
//     var fetchedUsername = await SharedPrefHelper.getpref("username");
//     var fetchEmail = await SharedPrefHelper.getpref("email");
//     var fetchempname = await SharedPrefHelper.getpref("emp_name");
//
//     var fetchstorename = await SharedPrefHelper.getpref("store_name");
//     var fetchemptype = await SharedPrefHelper.getpref("emp_type");
//
//
//     var fetchteamId = await SharedPrefHelper.getpref("team_id");
//     var fetchmanagerId = await SharedPrefHelper.getpref("manager_id");
//     var fetchcompanyId = await SharedPrefHelper.getpref("company_id");
//
//     setState(() {
//       username = fetchedUsername;
//       email = fetchEmail;
//       emp_name = fetchempname;
//       storeName = fetchstorename;
//       empType = fetchemptype;
//       companyId=fetchcompanyId;
//       managerId=fetchmanagerId;
//       teamId=fetchteamId;
//
//     });
//   }
//   // Start streaming audio
//   Future<void> startStreaming() async {
//     startSeervice();
//     try {
//       _channel = IOWebSocketChannel.connect('wss://devreal.darwix.ai/ws/audio-stream'
//           '?user_id=$email'
//           '&manager_id=$managerId'
//           '&company_id=$companyId'
//           '&team_id=$teamId'
//           '&full_name=$emp_name'
//           '&region=east'
//       );
//
//        // await _recorder.openRecorder();
//
//
//       // Debug: Check if WebSocket is connected
//       if (_channel != null && _channel?.sink != null) {
//       } else {
//       }
//
//
//       // 💡 Always create a new StreamController
//       //_audioController = StreamController<Uint8List>();
//       //final StreamController<Uint8List> audioController = StreamController<Uint8List>();
//
//       // Listen to audio chunks and send via WebSocket
//       //  _audioController!.stream.listen((Uint8List data) async{
//       //   try {
//       //      _channel?.sink.add(data);
//       //   } catch (e) {
//       //   }
//       // });
//
//
//
//       // 2) Create controller & pipe chunks to socket
//       _audioController = StreamController<Uint8List>();
//       _audioController!.stream.listen((data) {
//         _channel!.sink.add(data);
//
//       }, onError: (e) {
//       });
//
//
//       _timer?.cancel();
//       _seconds = 0;
//
//       setState(() {
//         isRecording = true;
//       });
//
//
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         setState(() {
//           _seconds++;
//
//         });
//
//
//       });
//
//       // Start recording with audio going to the StreamSink
//       // await _recorder.startRecorder(
//       //   codec: Codec.pcm16,
//       //   numChannels: 1,
//       //   sampleRate: 16000,
//       //   toStream: _audioController!.sink,
//       // );
//
//
//       // 3) Start the streamer
//       await _streamRecorder.startRecorder(
//         codec: Codec.pcm16,
//         numChannels: 1,
//         sampleRate: 16000,
//         toStream: _audioController!.sink,
//       );
//       if(mounted){
//         context.showSuccessSnackBar("Your call is now live.");
//
//       }
//
//     } catch (e) {
//       if(mounted){
//         context.showErrorSnackBar("The call was disconnected. Please try again.");
//       }
//
//     }
//   }
//
//
// //  Stop recording and clean up
//   Future<void> stopStreaming() async {
//     //Stop Background Service
//     FlutterBackgroundService().invoke('stopService');
//     try {
//       // 1) Stop the recorder first
//
//       await _streamRecorder.stopRecorder();
//
//       // await _recorder.stopRecorder();
//
//       _timer?.cancel();
//       setState(() {
//         isRecording = false;
//       });
//
//       // 2) Send the “disconnect” JSON over the same WebSocket, if it’s still open
//       if (_channel != null && _channel!.sink != null) {
//         final disconnectPayload = jsonEncode({
//           "user_id": email,
//           "manager_id": managerId,
//           "company_id": companyId,
//           "team_id": teamId,
//           "full_name": emp_name,
//           "status": "disconnect",
//         });
//         try {
//           _channel!.sink.add(disconnectPayload);
//         } catch (e) {
//         }
//
//         // 3) Close the WebSocket sink (optional: wait a fraction to ensure server receives the JSON)
//         await Future.delayed(const Duration(milliseconds: 200));
//         await _channel!.sink.close();
//         _channel = null;
//       }
//
//       // 4) Close the stream to clean up resources
//       await _audioController?.close();
//       _audioController = null;
//     } catch (e) {
//     }
//   }
//
//
//
//
//
//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) async {
//   //   super.didChangeAppLifecycleState(state);
//   //   if (state == AppLifecycleState.paused ||
//   //       state == AppLifecycleState.inactive ||
//   //       state == AppLifecycleState.detached) {
//   //     FlutterBackgroundService().invoke('setAsForeground');
//   //      startSeervice();
//   //     if (!isRecording) {
//   //       isRecording = true;
//   //     }
//   //   } else if (state == AppLifecycleState.resumed) {
//   //     if (isRecording) {
//   //       //ForegroundTask.onStop(); // Stop foreground service
//   //     }
//   //   }
//   // }
//
//   void startSeervice() async {
//     final service = FlutterBackgroundService();
//     service.startService();
//     FlutterBackgroundService().invoke('setAsForeground');
//     // bool isRunning = await service.isRunning();
//     // if (isRunning) {
//     //   service.invoke("stopService");
//     // }
//
//   }
//
//   late Box _uploadBox;
//
//   Future<void> initializeHive() async {
//     final directory = await getApplicationDocumentsDirectory();
//     Hive.init(directory.path);
//     _uploadBox = await Hive.openBox('uploads');
//   }
//
//   Future<void> requestPermissions() async {
//     if (await Permission.location.request().isGranted) {
//     } else {
//       // Permission denied, show a message or handle accordingly
//     }
//   }
//
//   Future<void> requestMicrophonePermissions() async {
//     if (await Permission.microphone.request().isGranted) {
//       // Microphone permission granted
//     } else {
//       // Handle the case where permission is denied
//     }
//   }
//
//   Future<void> _initializeRecorder() async {
//     await _recorder.openRecorder();
//
//     PermissionStatus status = await Permission.microphone.request();
//
//     if (status.isGranted) {
//       await WakelockPlus.enable(); // Prevents the screen from sleeping
//     }
// // Get app directory for storing recordings
//   }
//
//   Future<bool> isAnyOtgDeviceConnected() async {
//     try {
//       final bool result = await platform3.invokeMethod('checkOtgStatus');
//       return result;
//     } on PlatformException catch (e) {
//       return false;
//     }
//   }
//
//   Future<bool> isAnyWiredAudioDeviceConnected() async {
//     try {
//       final bool result =
//       await platform2.invokeMethod('isWiredHeadsetConnected');
//       return result;
//     } on PlatformException catch (e) {
//       return false;
//     }
//   }
//
//   Future<bool> isAnyAudioDeviceConnected() async {
//     return await isAnyWiredAudioDeviceConnected();
//   }
//
//   Future<void> callPushNotificationApi() async {
//     const String apiUrl = "https://13.233.246.42/api/push_notification/";
//     var user_id = await SharedPrefHelper.getpref("user_id");
//
//     Dio dio = Dio();
//
//     try {
//       final response = await dio.post(
//         apiUrl,
//         data: {"external_id": user_id},
//       );
//
//       if (response.statusCode == 200) {
//       } else {
//
//       }
//     } catch (e) {
//     }
//   }
//
//   void monitorConnectedDevices() async {
//     bool isRecording = false; // State to track recording status
//
//     // You can run a periodic check for wired device connection
//     Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
//       bool isWiredDeviceConnected = await isAnyWiredAudioDeviceConnected();
//       bool isOtgDeviceConnected = await isAnyOtgDeviceConnected();
//
//       if (isWiredDeviceConnected || isOtgDeviceConnected) {
//         if (!isRecording) {
//           // startStreaming();
//
//           await Future.wait([
//             startStreaming(),
//             startRecording(),
//           ]);
//           // Get.snackbar("Connection", " Device Connected. Recording started.");
//           // if(mounted)
//           //   {
//           //     context.showSuccessSnackBar("Device connected successfully. Recording in progress");
//           //   }
//           isRecording = true; // Update state to recording
//         }
//       } else {
//         if (isRecording) {
//           await Future.wait([
//             stopStreaming(),
//             stopRecording(),
//           ]);
//           // Get.snackbar("Connection", " device disconnected. Recording stopped.");
//           isRecording = false;
//           showNotification(
//               title: "Recording Stopped!! ⚠️",
//               body:
//               "The receiver has been disconnected. Plug it back in to resume recording seamlessly. 🚀",
//               sound: "plugout",
//               channelid: "3"); // Update state to not recording\
//
//           callPushNotificationApi();
//         }
//       }
//     });
//   }
//
//   void startUploadTimer() async {
//     _uploadTimer?.cancel();
//
//     // if(empType!.contains("realtime"))
//     // {
//     //
//     //   _uploadTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//     //     startTimeStamp = await DateTime.now().millisecondsSinceEpoch;
//     //     startTimeStamp -= 5 * 60 * 60 * 1000;
//     //     await uploadData();
//     //     if(!isRecording)
//     //     {
//     //       _uploadTimer?.cancel();
//     //     }
//     //
//     //
//     //
//     //   });
//     //
//     // }
//
//
//       _uploadTimer = Timer.periodic(const Duration(minutes: 31), (timer) async {
//         startTimeStamp = await DateTime.now().millisecondsSinceEpoch;
//         startTimeStamp -= 30 * 60 * 1000; // Increment startTimeStamp by 30 minutes in milliseconds
//
//         await uploadData();
//         if(!isRecording)
//         {
//           _uploadTimer?.cancel();
//         }
//
//       });
//
//
//
//   }
//
//   void startAmplitudeMonitoring() {
//     // Reset variables when starting monitoring
//     firstNotificationTriggered = false;
//     silentIntervals = 0;
//     initialBuffer = true;
//
//     // Set subscription interval (check every second)
//     _recorder?.setSubscriptionDuration(const Duration(seconds: 1));
//
//     // Cancel any existing subscription
//     _amplitudeSubscription?.cancel();
//
//     // Start listening to amplitude updates
//     _amplitudeSubscription = _recorder?.onProgress?.listen((e) {
//       double amplitudeDb = e.decibels ?? 0;
//
//       // Log amplitude values for debugging
//
//       if (initialBuffer) {
//         // Ignore values during the initial buffer
//         return;
//       }
//
//       if (amplitudeDb < 30) {
//         // Adjust this threshold if needed
//         silentIntervals++; // Increment if silence is detected
//       } else {
//         silentIntervals = 0; // Reset if sound is detected
//         firstNotificationTriggered = false; // Allow future warnings
//
//       }
//
//       // First warning at 1 minute (60 seconds)
//       if (silentIntervals == 60 && !firstNotificationTriggered) {
//         firstNotificationTriggered = true;
//         showNotification(
//           title: "Silence Detected!! ⚠️",
//           body:
//           "No voice input detected. Please check if your microphone is muted, turned off, or out of charge, and try reconnecting. 🚀",
//           sound: "muted",
//           channelid: "2",
//         );
//       }
//
//       // Stop recording after 15 minutes (900 seconds)
//       if (silentIntervals >= 120) {
//         showNotification(
//           title: "Silence detected for 15 minutes!! ⚠️",
//           body:
//           "Your recording has stopped after being muted for 15 minutes. Please unmute your mic or start your receiver mic to start recording again. 🚀",
//           sound: "fiveminutemute",
//           channelid: "1",
//         );
//       }
//     });
//
//     // Start the initial buffer timer
//   }
//
//
//
//
// // Convert raw amplitude to decibels (dB)
//   double amplitudeToDb(double amplitude) {
//     return 20 * log(amplitude) / ln10; // Convert linear to dB
//   }
//
//   Future<void> startRecording() async {
//     // Reset variables when starting a new recording
//     // startSeervice();
//     firstNotificationTriggered = false;
//     silentIntervals = 0;
//     initialBuffer = true;
//     miceBlinkingController.startAnimation();
//
//     startTimeStamp = await DateTime.now().millisecondsSinceEpoch;
//     var connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.mobile
//         || connectivityResult == ConnectivityResult.wifi
//         || connectivityResult == ConnectivityResult.ethernet
//     ) {
//       await attemptUpload();
//     }
//
//     // else{
//     //   showNotificationforInternet();
//     //   _showNoInternetDialog();
//     // }
//
//     _lastUploadedPosition = 0;
//     WakelockPlus.enable();
//     // await platform.invokeMethod('startRecordingService');
//     final directory = await getApplicationDocumentsDirectory();
//     final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
//     _filePath = '${directory.path}/$fileName';
//
//     try {
//       //final mediaConstraints = {
//       //   'audio': {
//       //     'autoGainControl': false,   // Enable AGC
//       //     'noiseSuppression': true,  // Optionally enable noise suppression
//       //     'echoCancellation': true,  // Optionally enable echo cancellation
//       //   },
//       // };
//
//       // Create a media stream with the constraints
//       //  MediaStream stream = await rtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
//
//       // Access the microphone track and adjust properties if needed
//
//       // Initialize the recorder (custom code, assuming you have implemented it)
//
//       if (_recorder == null) {
//         await _initializeRecorder();
//       }
//
//       if (_recorder!.isRecording) {
//         await _recorder?.stopRecorder();
//       }
//
//       await _recorder?.openRecorder();
//
//       // Start recording with the WebRTC-enhanced audio stream
//       await _recorder?.startRecorder(
//         toFile: _filePath,
//         codec: Codec.aacADTS,
//         // fromStream: stream, // Pass the WebRTC stream
//       );
//
//       // setState(() {
//       //   isRecording = true;
//       //   _seconds = 0;
//       // });
//
//       // Start monitoring silence
//       startAmplitudeMonitoring();
//       // Set up the timer
//       // _timer?.cancel();
//
//       // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       //   setState(() {
//       //     _seconds++;
//       //   });
//       // });
//
//       startUploadTimer();
//     } catch (e) {
//       if(mounted){
//         context.showWarningSnackBar("Failed to start recording. Please try again");
//       }
//     }
//   }
//
//   Future<void> stopRecording() async {
//     // FlutterBackgroundService().invoke('stopService');
//
//     _amplitudeSubscription?.cancel();
//     await _recorder?.stopRecorder();
//     _timer?.cancel();
//
//     // await dbHelper.incrementDisconnectCount(DateTime.now());
//
//     // await platform.invokeMethod('stopRecordingService');
//     await uploadData();
//
//
//     setState(() {
//       isRecording = false;
//     });
//
//     await _fetchstatisticsData();
//     setState(() {
//     });
//
//     WakelockPlus.disable();
//     miceBlinkingController.stopAnimation();
//
//
//     // FlutterForegroundTask.stopService();
//   }
//
//
//   Future<void> uploadData() async {
//     if (!Hive.isBoxOpen('uploads')) await initializeHive();
//     // var connectivityResult = await Connectivity().checkConnectivity();
//     // if (connectivityResult.contains(ConnectivityResult.none)) {
//     //   // showNotificationforInternet();
//
//     // }
//
//     var timestamp = DateTime.now().millisecondsSinceEpoch;
//
//     var user_id = await SharedPrefHelper.getpref("user_id");
//
//     trace.putAttribute("user_id", user_id);
//     // _fetchstatisticsData();
//
//     // final DateTime selectedDate = DateTime.now();
//     // statisticsDataController.fetchUserAudioStats(
//     //     userId: int.parse(user_id), selectedDate: selectedDate);
//
//
//     if (_filePath == null) return;
//
//
//     final Dio _dio = Dio(
//       BaseOptions(
//         connectTimeout:
//         const Duration(seconds: 300), // Time to establish a connection
//         receiveTimeout: const Duration(seconds: 300), // Time to receive data
//         sendTimeout: const Duration(seconds: 300),
//         // Time to send data
//       ),
//     );
//
//
//
//     File file = File(_filePath!);
//     // Get the total file size
//
//     int totalFileSize = await file.length();
//
//
//     // Calculate the new portion of data to upload (from the last uploaded position)
//     if (totalFileSize > _lastUploadedPosition) {
//       List<int> fileBytes = await file.readAsBytes();
//       List<int> newBytes = fileBytes.sublist(_lastUploadedPosition);
//       Map<String, dynamic> formDataMap = {
//         'user_id': user_id,
//         'recording_name': '$timestamp/_$user_id',
//         'employee_id': user_id,
//         'company_id': companyId,
//         'start_time': startTimeStamp,
//         'end_time': timestamp,
//         'disconnection':isRecording ? 0:1,
//         'file': dio.MultipartFile.fromBytes(newBytes,
//             filename: '${timestamp}_$user_id.mp3'),
//       };
//
//       // Check for internet connection
//       if (await InternetConnectionChecker().hasConnection) {
//         try {
//
//           dio.FormData formData = dio.FormData.fromMap(formDataMap);
//           dio.Response response = await _dio.post(
//             'https://dashboard.cur8.in/api/upload/',
//             data: formData,
//           );
//
//           if (response.statusCode == 201) {
//             await trace.stop();
//
//             // Update the last uploaded position to the current file size
//             _lastUploadedPosition = totalFileSize;
//           }
//         } on DioError catch (e) {
//
//         } catch (e) {
//
//         }
//       } else {
//         saveDataLocally();
//       }
//     } else {
//     }
//   }
//
//
//   void saveDataLocally() async {
//     var timestamp = DateTime.now().millisecondsSinceEpoch;
//     var username = await SharedPrefHelper.getpref("username");
//     var user_id = await SharedPrefHelper.getpref("user_id");
//
//     if (_filePath == null) return;
//
//     File file = File(_filePath!);
//
//     // Get the total file size
//     int totalFileSize = await file.length();
//
//     // If there's new data to save
//     if (totalFileSize > _lastUploadedPosition) {
//       // Read only the new data
//       List<int> fileBytes = await file.readAsBytes();
//       List<int> newBytes = fileBytes.sublist(_lastUploadedPosition);
//
//       // Save the new bytes and metadata in Hive
//       await _uploadBox.put(
//         timestamp.toString(),
//         {
//           'user_id': user_id,
//           'recording_name': '${timestamp}/_$user_id',
//           'employee_id': user_id,
//           'start_time': startTimeStamp,
//           'company_id': '19',
//           'file_bytes': newBytes,
//           'end_time': timestamp,
//         },
//       );
//
//       // Update the last saved position
//       _lastUploadedPosition = totalFileSize;
//
//       // startTimeStamp=  await DateTime.now().millisecondsSinceEpoch;
//     } else {
//     }
//   }
//
//
//   Future<void> attemptUpload() async {
//     if (!Hive.isBoxOpen('uploads')) await initializeHive();
//
//     if (_uploadBox.isEmpty) {
//       return;
//     }
//
//     setState(() {
//       isUploading = true;
//       uploadStatus = "Uploading data, please wait...";
//     });
//
//     final Dio _dio = Dio();
//     _dio.options.validateStatus = (status) => status! < 500;
//
//     final keys = _uploadBox.keys.toList();
//
//     for (var key in keys) {
//       final data = _uploadBox.get(key);
//       if (data == null) continue;
//
//       try {
//         dio.FormData formData = dio.FormData.fromMap({
//           'user_id': data['user_id'],
//           'recording_name': data['recording_name'],
//           'employee_id': data['employee_id'],
//           'company_id': data['company_id'],
//           'file': dio.MultipartFile.fromBytes(
//             List<int>.from(data['file_bytes']),
//             filename: '${data['recording_name']}.mp3',
//           ),
//         });
//
//         dio.Response response = await _dio.post(
//           'https://dashboard.cur8.in/api/upload/',
//           data: formData,
//         );
//
//         if (response.statusCode == 201) {

//               'Upload successful local data to the server for ${data['recording_name']}');
//           await _uploadBox.delete(key); // Remove the data from local storage
//         } else {

//               'Upload failed for ${data['recording_name']} with status: ${response.statusCode}');
//         }
//       } catch (e) {
//       }
//     }
//     setState(() {
//       isUploading = false;
//       uploadStatus = "Upload complete!";
//     });
//
//     return;
//   }
//
//   String formatTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final secs = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () => exitPopup(),
//         child: SafeArea(
//           child: Scaffold(
//             key: scaffoldKey,
//             backgroundColor: Colors.white,
//             drawer: Drawer(
//               child: ListView(
//                 padding: const EdgeInsets.all(0),
//                 children: [
//                   DrawerHeader(
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF565ADD),
//                     ),
//                     child: UserAccountsDrawerHeader(
//                       decoration: const BoxDecoration(color: Color(0xFF565ADD)),
//                       accountName: Text(
//                         emp_name,
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                       accountEmail: Text(email),
//                       currentAccountPictureSize: const Size.square(50),
//                     ),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.tips_and_updates),
//                     title: const Text('FAQ Guide'),
//                     onTap: () {
//                       Get.to(() => const FAQScreen());
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.message_outlined),
//                     title: const Text('Conversation Centre'),
//                     onTap: () {
//
//                       Get.to(() => const ConversationView());
//
//                       // if(empType!.contains("realtime"))
//                       //   {
//                       //    // Get.to(() =>  SessionListScreen());
//                       //
//                       //
//                       //
//                       //   }
//                       // else{
//                       //   Get.to(() => const ConversationView());
//                       //
//                       // }
//                     },
//                   ),
//
//                   // ListTile(
//                   //   leading: const Icon(Icons.message_outlined),
//                   //   title: const Text('Tracking Centre'),
//                   //   onTap: () {
//                   //     Get.to(() => GeoTrackingScreen());
//                   //
//                   //   },
//                   // ),
//
//
//                   // ListTile(
//                   //   leading: const Icon(Icons.analytics_outlined),
//                   //   title: const Text('Analytics Dashboard'),
//                   //   onTap: () {
//                   //     Get.to(() =>AnalyticsDashboard ());
//                   //   },
//                   // ),
//
//
//
//
//
//
//                   // ListTile(
//                   //   leading: const Icon(Icons.delivery_dining),
//                   //   title: const Text('Delivery Tracker'),
//                   //   onTap: () {
//                   //     Get.toNamed(Routes.deliveryTracker);
//                   //   },
//                   // ),
//
//
//                   ListTile(
//                     leading: const Icon(Icons.generating_tokens),
//                     title: const Text('Raise Ticket'),
//                     onTap: () {
//                       Get.toNamed(Routes.raiseTicket);
//                     },
//                   ),
//
//
//                   ListTile(
//                     leading: const Icon(Icons.settings),
//                     title: const Text('Settings'),
//                     onTap: () {
//                       Get.to(() => SettingsPage());
//                     },
//                   ),
//
//                   ListTile(
//                     leading: const Icon(Icons.logout),
//                     title: const Text('Sign Out'),
//                     onTap: () async {
//                       await SharedPrefHelper.setIsloginValue(false);
//                       Get.offAll(const Login());
//                     },
//                   ),
//
//                 ],
//               ),
//             ),
//             body: Column(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//
//                     color: Color(0xFF565ADD),
//                     borderRadius:
//                     BorderRadius.vertical(bottom: Radius.circular(30)),
//                   ),
//                   padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.menu,
//                               color: Colors.white, size: 28,),
//                             onPressed: () {
//                               scaffoldKey.currentState?.openDrawer();
//                             },
//                           ),
//                           Obx(() {
//                             if (miceBlinkingController.isRecording.value) {
//                               return ScaleTransition(
//                                 scale: miceBlinkingController.animationController,
//                                 child: Container(
//                                   width: 20, // slightly bigger than icon size
//                                   height: 20,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Color(0XFFF8FFF7), // icon color
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Color(0xFF00E244).withOpacity(0.6),
//                                         spreadRadius: 4,
//                                         blurRadius: 8,
//                                       ),
//                                     ],
//                                   ),
//                                   child: Center(
//                                     child: Icon(
//                                       Icons.circle,
//                                       size: 10,
//                                       color: Color(0xFF00E244), // or transparent if you just want the glow
//                                     ),
//                                   ),
//                                 )
//                                 ,
//                               );
//                             } else {
//                               return const Icon(Icons.mic_off,
//                                   color: Colors.white, size: 28);
//                             }
//                           }),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         isRecording ? 'Recording ongoing' : 'Recording Stopped',
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               // Container(
//                               //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                               //   decoration: BoxDecoration(
//                               //     color: Colors.white24,
//                               //     borderRadius: BorderRadius.circular(4),
//                               //   ),
//                               //    child: Text("Timer", style: TextStyle(color: Colors.white)),
//                               // ),
//                               // SizedBox(width: 8),
//                               Text(_formatTime(_seconds),
//                                   style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 40,
//                                       fontWeight: FontWeight.bold)),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: () async {
//                               final controller = Get.put(ConversationController());
//                               controller.reset();
//
//                               var result = await  Get.dialog(
//                                 // barrierDismissible: false,
//                                 Builder(
//                                   builder: (dialogContext) {
//                                     return AlertDialog(
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                       title: const Text(
//                                         "Mark a Conversation",
//                                         style: TextStyle(fontWeight: FontWeight.bold),
//                                       ),
//                                       content: SingleChildScrollView(
//                                         child: ConstrainedBox(
//                                           constraints: BoxConstraints(
//                                             maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
//                                             maxWidth: MediaQuery.of(dialogContext).size.width * 0.9,
//                                             minWidth: MediaQuery.of(dialogContext).size.width * 0.9,
//                                           ),
//                                           child: GetBuilder<ConversationController>(
//                                             builder: (controller) {
//                                               return Form(
//                                                 key: controller.formKey,
//                                                 child: Column(
//                                                   mainAxisSize: MainAxisSize.min,
//                                                   children: [
//                                                     // Product input
//                                                     TextFormField(
//                                                       controller: controller.productInputController,
//                                                       decoration: InputDecoration(
//                                                         label: RichText(
//                                                           text: TextSpan(
//                                                             text: 'Enter Product Name',
//                                                             style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
//                                                             children: const [
//                                                               TextSpan(
//                                                                 text: ' *',
//                                                                 style: TextStyle(color: Colors.red, fontSize: 18),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         suffixIcon: controller.productInputController.text.trim().isNotEmpty
//                                                             ? Container(
//                                                           decoration: BoxDecoration(
//                                                             borderRadius: BorderRadius.circular(50),
//                                                             color: Color(0xFFD6D9FF),
//                                                           ),
//                                                           child: IconButton(
//                                                             icon: const Icon(
//                                                               Icons.add,
//                                                               color: Color(0xFF565ADD),
//                                                               weight: 18,
//                                                             ),
//                                                             onPressed: () {
//                                                               controller.addProductFromInput();
//                                                             },
//                                                           ),
//                                                         )
//                                                             : null,
//                                                       ),
//                                                       onChanged: (value) {
//                                                         controller.update();
//                                                       },
//                                                       validator: (value) {
//                                                         if ((controller.selectedProducts.isEmpty &&
//                                                             (value == null || value.trim().isEmpty))) {
//                                                           return "Product Name is required";
//                                                         }
//                                                         return null;
//                                                       },
//                                                     ),
//                                                     const SizedBox(height: 8),
//
//                                                     // Chips of selected Products
//                                                     Obx(() => Wrap(
//                                                       spacing: 8,
//                                                       children: controller.selectedProducts
//                                                           .map((product) => Chip(
//                                                         label: Text(product, style: TextStyle(color: Colors.white)),
//                                                         backgroundColor: const Color(0xFF565ADD),
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius: BorderRadius.circular(50),
//                                                           side: const BorderSide(color: Colors.transparent),
//                                                         ),
//                                                         deleteIcon: const Icon(
//                                                           Icons.cancel,
//                                                           color: Colors.white,
//                                                         ),
//                                                         onDeleted: () => controller.removeProduct(product),
//                                                         labelPadding: const EdgeInsets.only(left: 8, right: 2),
//                                                         padding:
//                                                         const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
//                                                       ))
//                                                           .toList(),
//                                                     )),
//                                                     const SizedBox(height: 16),
//
//                                                     // Customer ID input (optional)
//                                                     TextFormField(
//                                                       controller: controller.customerIdController,
//                                                       decoration: const InputDecoration(
//                                                         labelText: "Customer ID",
//                                                       ),
//                                                       keyboardType: TextInputType.number,
//                                                     ),
//                                                     const SizedBox(height: 16),
//
//                                                     // Date range picker
//                                                     TextFormField(
//                                                       controller: controller.dateRangeController,
//                                                       readOnly: true,
//                                                       style: const TextStyle(color: Color(0xFF6B7071)),
//                                                       decoration: InputDecoration(
//                                                         label: RichText(
//                                                           text: TextSpan(
//                                                             text: 'Start Time & End Time',
//                                                             style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
//                                                             children: const [
//                                                               TextSpan(
//                                                                 text: ' *',
//                                                                 style: TextStyle(color: Colors.red, fontSize: 18),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         suffixIcon: IconButton(
//                                                           icon: const Icon(
//                                                             Icons.date_range_rounded,
//                                                             color: Color(0xFF565ADD),
//                                                             size: 30,
//                                                           ),
//                                                           onPressed: () {
//                                                             controller.pickDateRange(dialogContext);
//                                                           },
//                                                         ),
//                                                       ),
//                                                       validator: (value) {
//                                                         if (value == null || value.isEmpty) {
//                                                           return 'Start Time & End Time is required';
//                                                         }
//                                                         return null;
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       actions: [
//                                         const SizedBox(height: 10),
//                                         Align(
//                                           alignment: Alignment.center,
//                                           child: Obx(() {
//                                             return InkWell(
//                                               onTap: () async {
//                                                 FocusManager.instance.primaryFocus?.unfocus();
//                                                 await Future.delayed(const Duration(milliseconds: 100));
//                                                 if (!controller.formKey.currentState!.validate()) {
//                                                   showCustomToast(context);
//                                                   return;
//                                                 }
//                                                 var message = await controller.submitForm();
//
//
//                                                 // Now check if message is not null, and show a snackbar
//                                                 if (message != null && message == "Conversation session saved successfully") {
//                                                   await _fetchstatisticsData();
//                                                   Get.snackbar(
//                                                     "", // Title
//                                                     "", // Message
//                                                     snackPosition: SnackPosition.BOTTOM,
//                                                     backgroundColor: Color(0xFFFFFFFF),
//                                                     duration: Duration(seconds: 3),
//                                                     margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
//                                                     borderRadius: 12,
//                                                     borderColor: Color(0xFF6B7071),
//                                                     borderWidth: 1,
//                                                     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                                                     icon: Padding(
//                                                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                                                       child: Icon(
//                                                         Icons.check_circle,
//                                                         color: Color(0xFF00E244),
//                                                         size: 30,
//                                                       ),
//                                                     ),
//                                                     shouldIconPulse: false,
//                                                     titleText: Column(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       mainAxisSize: MainAxisSize.min,
//                                                       children: [
//                                                         Padding(
//                                                           padding: const EdgeInsets.only(left: 2),
//                                                           child: Text(
//                                                             "Congratulations🎉",
//                                                             style: TextStyle(
//                                                               fontSize: 16,
//                                                               fontWeight: FontWeight.bold,
//                                                               color: Color(0XFF005409),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(height: 0), // Adjust spacing as needed
//                                                         Text(
//                                                           "You have successfully added the conversation",
//                                                           style: TextStyle(
//                                                             fontSize: 14,
//                                                             color: Colors.black,
//                                                             fontWeight: FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     messageText: SizedBox(), // Prevents default spacing
//                                                   );
//
//                                                 }
//
//
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: BorderRadius.circular(12),
//                                                   color: controller.isFormValid.value
//                                                       ? const Color(0xFF565ADD)
//                                                       : const 	Color(0xFFE0E0E0) ,
//                                                 ),
//                                                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
//                                                 child:  Text(
//                                                   "Submit",
//                                                   style: TextStyle(color:controller.isFormValid.value
//                                                       ? Colors.white
//                                                       : Color(0xFF1A1A1A)  , fontSize: 15),
//                                                 ),
//                                               ),
//                                             );
//                                           }),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               );
//                               // Explicitly close any remaining dialogs before showing new one
//                               if (Get.isDialogOpen ?? false) {
//                                 Get.back();
//                               }
//
//                               if (result != true) {
//
//                                 Get.snackbar(
//                                   "", // title
//                                   "", // message
//                                   snackPosition: SnackPosition.BOTTOM,
//                                   backgroundColor: Color(0xFFFFFFFF),
//                                   duration: Duration(seconds: 2),
//                                   margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
//                                   borderRadius: 12,
//                                   borderColor: Color(0xFF6B7071),
//                                   borderWidth: 1,
//                                   icon: Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                                     child: Icon(
//                                       Icons.message,
//                                       color: Color(0xFFFF2222),
//                                       size: 25,
//                                     ),
//                                   ),
//                                   shouldIconPulse: false,
//                                   titleText: Padding(
//                                     padding: const EdgeInsets.only(left: 2),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Oops!",
//                                           style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0XFFBD0000),
//                                           ),
//                                         ),
//                                         SizedBox(height: 0), // Control spacing here
//                                         Text(
//                                           "You missed adding the conversation",
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   messageText: SizedBox(), // Prevent default spacing by setting it empty
//                                 );
//
//
//                               }
//
//                             },
//                             icon: const Icon(Icons.add, size: 16,color:Color(0xFF00A58E) ,),
//                             label: const Text(
//                               "Mark a Conversation",
//                               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: Colors.black),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(width: 8),
//                           Flexible(  // 👉 Add Flexible here to allow it to shrink
//                             child: Container(
//                               padding: const EdgeInsets.only(left: 12,right: 2, top: 2,bottom: 2),
//                               decoration: BoxDecoration(
//
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Flexible(
//                                     child: InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => const ConversationView(), // your destination widget
//                                           ),
//                                         );
//                                       },
//
//                                       child: Text(
//                                         'Conversation Count',
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                           color:  Colors.black,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Container(
//                                     width: 35, // You can adjust according to your design
//                                     height: 35,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFF0080FF),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     alignment: Alignment.center,
//                                     child: Obx(() => Text(
//                                       statisticsDataController.conversationCount.value.toString(),
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     )),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//
//
//
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20,),
//                 // if ((empType?.contains('realtime') ?? false ) )...[
//                 //   LiveNudgeSection(isRecording: isRecording,),
//                 //   SizedBox(height: 20,),
//                 //
//                 // ],
//                 LiveNudgeSection(isRecording: isRecording,),
//                 SizedBox(height: 20,),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 12),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Recording Statistics",
//                           style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.filter_list_sharp,
//                           color: Colors.black,
//                           size: 30,
//                         ),
//                         onPressed: () async {
//                           DateTime? pickedDate = await showOmniDateTimePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate:
//                             DateTime(1600).subtract(const Duration(days: 3652)),
//                             lastDate: DateTime.now().add(
//                               const Duration(days: 3652),
//                             ),
//                             is24HourMode: false,
//                             isShowSeconds: false,
//                             minutesInterval: 1,
//                             secondsInterval: 1,
//                             borderRadius:
//                             const BorderRadius.all(Radius.circular(16)),
//                             constraints: const BoxConstraints(
//                               maxWidth: 350,
//                               maxHeight: 650,
//                             ),
//                             transitionBuilder: (context, anim1, anim2, child) {
//                               return Theme(
//                                 data: ThemeData.light(),
//                                 child: FadeTransition(
//                                   opacity: anim1.drive(Tween(begin: 0.0, end: 1.0)),
//                                   child: child,
//                                 ),
//                               );
//                             },
//                             transitionDuration: const Duration(milliseconds: 200),
//                             barrierDismissible: true,
//                           );
//
//                           // ✅ If no date selected, use current date
//                           DateTime finalDate = pickedDate ?? DateTime.now();
//                           var user_Id = await SharedPrefHelper.getpref("user_id");
//                           await statisticsDataController.fetchUserAudioStats(
//                             userId: int.parse(user_Id),
//                             selectedDate: finalDate,
//                           );
//                         },
//                       ),
//                     )
//                   ],
//                 ),
//                 SizedBox(height: 8),
//
//
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 9),
//                     child: Obx(() {
//                       // List<String>totalRecordingHours = statisticsDataController.totalRecordingHours.split(' ');
//                       // List<String>totalQualityAudioHours = statisticsDataController.totalQualityAudioHours.split(' ');
//
//
//                       final items = [
//                         {
//                           "name": "Recording Duration",
//                           "value": statisticsDataController
//                               .totalRecordingHours.value,
//
//                           "color": Colors.pink[100],
//                         },
//                         {
//                           "name": "Quality Audio Duration",
//                           "value": statisticsDataController
//                               .totalRecordingHours.value,
//
//                           "color": Colors.blue[100],
//                         },
//                         {
//                           "name": "Number of Disconnects",
//                           "value": statisticsDataController.numberOfDisconnects.value,
//                           "color": Colors.teal[100],
//                         },
//
//                       ];
//
//                       return GridView.builder(
//                         itemCount: 3,
//                         gridDelegate:
//                         SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           mainAxisSpacing: 10,
//                           crossAxisSpacing: 10,
//                           childAspectRatio: Get.width > 600 ? 1.2 : 1,
//                         ),
//                         itemBuilder: (context, index) {
//                           var item = items[index];
//                           return Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: const [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 4,
//                                     offset: Offset(0, 0)),
//                               ],
//                             ),
//                             child: Padding(
//                               padding:  EdgeInsets.symmetric(
//                                   horizontal: Get.width * 0.03,  vertical: Get.width * 0.02),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 // mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//                                 children: [
//                                   // CircleAvatar(
//                                   //   // backgroundColor: item['color'] as Color?,
//                                   //   radius: 30,
//                                   //   child: Text(
//                                   //     item['value'].toString(),
//                                   //     style: const TextStyle(
//                                   //       fontWeight: FontWeight.w600,
//                                   //       color: Color(0xFF565ADD),
//                                   //     ),
//                                   //   ),
//                                   // ),
//
//                                   Text(
//                                     item['value'].toString(),
//                                     textAlign: TextAlign.start,
//                                     style:  TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black,
//                                       fontSize: Get.width * 0.05,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Flexible(
//                                     child: Text(
//                                       item['name'].toString(),
//                                       textAlign: TextAlign.left,
//                                       style: const TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }),
//                   ),
//                 ),
//
//               ],
//             ),
//
//             bottomNavigationBar: _buildBottomNavigation(),
//             // const BottomAppBar(
//             //   color: Color(0xFF565ADD),
//             //   shape: CircularNotchedRectangle(),
//             //   notchMargin: 8.0,
//             //   child: Padding(
//             //     padding: EdgeInsets.all(10.0),
//             //     child: Row(
//             //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //       children: <Widget>[],
//             //     ),
//             //   ),
//             // ),
//             // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//             // floatingActionButton: Container(
//             //   width: 100,
//             //   height: 100,
//             //   decoration: BoxDecoration(
//             //     shape: BoxShape.circle,
//             //     boxShadow: [
//             //       BoxShadow(
//             //         color: Colors.black.withOpacity(0.3),
//             //         spreadRadius: 4,
//             //         blurRadius: 10,
//             //         offset: const Offset(0, 4), // changes position of shadow
//             //       ),
//             //     ],
//             //   ),
//             //   child: FloatingActionButton(
//             //     backgroundColor: Colors.white,
//             //
//             //     shape: RoundedRectangleBorder(
//             //       borderRadius: BorderRadius.circular(
//             //           50), // Half of width/height for circular
//             //     ),
//             //
//             //
//             //
//             //     //onPressed: null,
//             //     // child: Icon(Icons.mic),
//             //     onPressed: () async {
//             //       if (isRecording) {
//             //         // Stop both streaming and recording in parallel
//             //         await Future.wait([
//             //           stopStreaming(),
//             //           stopRecording(),
//             //         ]);
//             //       } else {
//             //         // Start both streaming and recording in parallel
//             //         await Future.wait([
//             //           startStreaming(),
//             //           startRecording(),
//             //
//             //
//             //         ]);
//             //       }
//             //     },
//             //     child: Icon(
//             //       isRecording ? Icons.stop : Icons.mic,
//             //       size: 40,
//             //       color: isRecording ? const Color(0xFF565ADD) : Colors.black,
//             //     ),
//             //   ),
//             // ),
//
//
//             // BottomAppBar(
//             //   color: Color(0xFF001FD0),
//             //   shape: CircularNotchedRectangle(),
//             //   notchMargin: 8.0,
//             //   child: Padding(
//             //     padding: const EdgeInsets.all(10.0),
//             //     child: Row(
//             //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //       // children: <Widget>[
//             //       //   IconButton(
//             //       //     icon: Icon(Icons.home, color: Colors.white),
//             //       //     onPressed: () {},
//             //       //   ),
//             //       //   IconButton(
//             //       //     icon: Icon(Icons.calendar_today, color: Colors.white),
//             //       //     onPressed: () {},
//             //       //   ),
//             //       //   SizedBox(width: 50),
//             //       //   IconButton(
//             //       //     icon: Icon(Icons.notifications, color: Colors.white),
//             //       //     onPressed: () {},
//             //       //   ),
//             //       //   IconButton(
//             //       //     icon: Icon(Icons.folder, color: Colors.white),
//             //       //     onPressed: () {},
//             //       //   ),
//             //       // ],
//             //     ),
//             //   ),
//             // ),
//             // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//             // floatingActionButton: FloatingActionButton(
//             //   //onPressed: null,
//             //   //child: Icon(Icons.mic),
//             //     onPressed: ()async {
//             //     if (isRecording) {
//             //       // Stop both streaming and recording in parallel
//             //       await Future.wait([
//             //         stopStreaming(),
//             //         stopRecording(),
//             //       ]);
//             //     } else {
//             //       // Start both streaming and recording in parallel
//             //       await Future.wait([
//             //         startStreaming(),
//             //         startRecording(),
//             //       ]);
//             //     }
//             //   },
//             //   child: Icon(isRecording ? Icons.stop : Icons.mic),
//             // ),
//           ),
//         )
//     );
//   }
//
//
//
//
//
//   // Obx(() {
//   //   return CustomBottomNavigationBar(
//   //     currentIndex: Get.find<AppController>().currentIndex.value,
//   //     onTabChanged: (index) {
//   //       Get.find<AppController>().changeTab(index);
//   //       NavigationState.saveTabIndex(index);  // Save selected tab index
//   //     },
//   //   );
//   // }),
//
//   // const BottomAppBar(
//   //   color: Color(0xFF565ADD),
//   //   shape: CircularNotchedRectangle(),
//   //   notchMargin: 8.0,
//   //   child: Padding(
//   //     padding: EdgeInsets.all(10.0),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: <Widget>[],
//   //     ),
//   //   ),
//   // ),
//   // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//   // floatingActionButton: Container(
//   //   width: 100,
//   //   height: 100,
//   //   decoration: BoxDecoration(
//   //     shape: BoxShape.circle,
//   //     boxShadow: [
//   //       BoxShadow(
//   //         color: Colors.black.withOpacity(0.3),
//   //         spreadRadius: 4,
//   //         blurRadius: 10,
//   //         offset: const Offset(0, 4), // changes position of shadow
//   //       ),
//   //     ],
//   //   ),
//   //   child: FloatingActionButton(
//   //     backgroundColor: Colors.white,
//   //
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.circular(
//   //           50), // Half of width/height for circular
//   //     ),
//   //
//   //     //onPressed: null,
//   //     // child: Icon(Icons.mic),
//   //     onPressed: () async {
//   //       if (isRecording) {
//   //         // Stop both streaming and recording in parallel
//   //         await Future.wait([
//   //           stopStreaming(),
//   //           stopRecording(),
//   //         ]);
//   //
//   //       } else {
//   //         // Start both streaming and recording in parallel
//   //         await Future.wait([
//   //           startStreaming(),
//   //           startRecording(),
//   //         ]);
//   //       }
//   //     },
//   //     child: Icon(
//   //       isRecording ? Icons.stop : Icons.mic,
//   //       size: 40,
//   //       color: isRecording ? const Color(0xFF565ADD) : Colors.black,
//   //     ),
//   //   ),
//   // ),
//
//
//
//
//   void showCustomToast(BuildContext context) {
//     final overlay = Overlay.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         bottom: 50,
//         left: screenWidth * 0.1,
//         right: screenWidth * 0.1,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFD5D5), // Light red background
//               border: Border.all(color: const Color(0xFF941717)), // Red border
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.warning_amber_rounded,
//                   color: Color(0xFFFACC39),
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 // Use Flexible to avoid overflow
//                 Flexible(
//                   child: Text(
//                     "Please Fill the Necessary Details",
//                     style: const TextStyle(
//                       color: Color(0xFF941717),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//     overlay.insert(overlayEntry);
//
//     // Remove the toast after 3 seconds
//     Future.delayed(const Duration(seconds: 1), () {
//       overlayEntry.remove();
//     });
//   }
//
//
//   // Future<bool> exitPopup() async {
//   //   return await showDialog(
//   //         context: context,
//   //         builder: (context) => AlertDialog(
//   //           contentPadding: EdgeInsets.zero,
//   //           content: Container(
//   //             alignment: Alignment.center,
//   //             width: double.infinity,
//   //             decoration: const BoxDecoration(
//   //               // color: Color(0xFF001FD0),
//   //               borderRadius: BorderRadius.only(
//   //                 topRight: Radius.circular(3.0),
//   //                 // bottomRight: Radius.circular(40.0),
//   //                 topLeft: Radius.circular(3.0),
//   //                 // bottomLeft: Radius.circular(40.0),
//   //               ),
//   //             ),
//   //             height: 40,
//   //             child: const Text(
//   //               "Alert!",
//   //               textAlign: TextAlign.left,
//   //               style: TextStyle(
//   //                   color: Colors.black,
//   //                   fontWeight: FontWeight.bold,
//   //                   fontSize: 20),
//   //             ),
//   //           ),
//   //           actions: [
//   //             Container(
//   //               margin: const EdgeInsets.symmetric(vertical: 20),
//   //               child: const Row(
//   //                 crossAxisAlignment: CrossAxisAlignment.center,
//   //                 mainAxisAlignment: MainAxisAlignment.center,
//   //                 children: [
//   //                   Text('Do you want to exit the application ?',
//   //                       style: TextStyle(
//   //                           fontWeight: FontWeight.bold, fontSize: 15)),
//   //                 ],
//   //               ),
//   //             ),
//   //             const SizedBox(
//   //               height: 20,
//   //             ),
//   //             Row(
//   //               mainAxisAlignment: MainAxisAlignment.end,
//   //               children: [
//   //                 const SizedBox(width: 5),
//   //                 Expanded(
//   //                   child: TextButton(
//   //                     style: ButtonStyle(
//   //                       backgroundColor: MaterialStateProperty.all(
//   //                         Colors.green.withOpacity(0.2),
//   //                       ),
//   //                     ),
//   //                     onPressed: () => exit(0),
//   //                     // onPressed: () => SystemNavigator.pop(),
//   //                     child: const Text('Yes',
//   //                         style: TextStyle(color: Colors.black)),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(width: 5),
//   //                 Expanded(
//   //                   child: TextButton(
//   //                     style: ButtonStyle(
//   //                       backgroundColor: MaterialStateProperty.all(
//   //                           Colors.red.withOpacity(0.2)),
//   //                     ),
//   //                     onPressed: () => Navigator.pop(context, false),
//   //                     child: const Text('Cancel',
//   //                         style: TextStyle(color: Colors.black)),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(width: 5),
//   //               ],
//   //             ),
//   //             const SizedBox(height: 10),
//   //           ],
//   //         ),
//   //       ) ??
//   //       false;
//   // }
//
//
//   Future<bool> exitPopup() async {
//     return (await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 1) The red alert icon in a pale red circle
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.red.withOpacity(0.1),
//                   child: const Icon(
//                     Icons.exit_to_app,
//                     color: Colors.red,
//                     size: 30,
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 2) Title
//                 const Text(
//                   'Are you Sure ?',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 // 3) Subtitle
//                 const Text(
//                   'Do you want to exit the application',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // 4) Buttons
//                 Row(
//                   children: [
//                     // Exit button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           side: BorderSide(color: Colors.grey.shade300),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12,),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 16),
//
//                     // Continue button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () => exit(0),
//                         style: TextButton.styleFrom(
//                           backgroundColor: const Color(0xFF565ADD),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text(
//                           'Yes',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     )) ?? false;
//   }
//
//
//
//   String _formatTime(int seconds) {
//     final int hours = seconds ~/ 3600;
//     final int minutes = (seconds % 3600) ~/ 60;
//     final int secs = seconds % 60;
//
//     final String hoursStr = hours.toString().padLeft(2, '0');
//     final String minutesStr = minutes.toString().padLeft(2, '0');
//     final String secondsStr = secs.toString().padLeft(2, '0');
//
//     return '$hoursStr:$minutesStr:$secondsStr';
//   }
//
//
//
// // 1) Bottom nav builder — pass in isActive + onTap for each item:
//   Widget _buildBottomNavigation() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           top: BorderSide(color: Color(0xFFEBEBEB), width: 1),
//         ),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             children: [
//               _buildNavItem(
//                 icon: Icons.home,
//                 label: 'Home',
//                 isActive: _currentIndex == 0,
//                 onTap: () {
//                   setState(() => _currentIndex = 0);
//                   // Navigator.of(context).push(
//                   //   MaterialPageRoute(builder: (_) => Home()),
//                   // );
//                 },
//               ),
//               _buildNavItem(
//                 icon: Icons.bar_chart,
//                 label: 'Analytics',
//                 isActive: _currentIndex == 1,
//                 onTap: () {
//                   setState(() => _currentIndex = 1);
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (_) => const AnalyticsDashboard(),
//                       ));
//                   // push your Analytics screen here...
//                 },
//               ),
//               _buildMicButton(), // your existing mic button
//               _buildNavItem(
//                 icon: Icons.history,
//                 label: 'History',
//                 isActive: _currentIndex == 2,
//                 onTap: () {
//                   setState(() => _currentIndex = 2);
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (_) => const ConversationView(),
//                       ));
//                 },
//               ),
//               _buildNavItem(
//                 icon: Icons.person,
//                 label: 'Profile',
//                 isActive: _currentIndex == 3,
//                 onTap: () {
//                   setState(() => _currentIndex = 3);
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// // 2) Nav-item builder — wraps everything in an InkWell + Material
//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: Material(
//         color: Colors.transparent,              // needed for InkWell’s splash
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   icon,
//                   size: 24,
//                   color: isActive ? Color(0xFF565ADD) : Color(0xFF9D9D9D),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight:
//                     isActive ? FontWeight.w600 : FontWeight.normal,
//                     color: isActive ? Color(0xFF565ADD) : Color(0xFF9D9D9D),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildMicButton() {
//     return InkWell(
//       onTap: () async {
//         if (isRecording) {
//           // Stop both streaming and recording in parallel
//           await Future.wait([
//             stopStreaming(),
//             stopRecording(),
//           ]);
//         } else {
//           // Start both streaming and recording in parallel
//           await Future.wait([
//             startStreaming(),
//             startRecording(),
//
//
//           ]);
//         }
//       },
//       child: Container(
//         width: 70,
//         height: 70,
//         decoration: BoxDecoration(
//           color: Color(0xFF565ADD),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           isRecording ? Icons.stop : Icons.mic,
//           size: 30,
//           color: Colors.white,
//         ),
//       ),
//
//     );
//   }
//
//
//
//
// }
//
// Future<void> showNotification(
//     {required String title,
//       required String body,
//       required String sound,
//       required String channelid}) async {
//   final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     channelid, // Unique channel ID
//     'channelname', // Channel name
//     channelDescription: 'This is a description of the channel',
//     importance: Importance.high,
//     priority: Priority.high,
//     icon: '@drawable/ic_bg_service_small',
//     playSound: true,
//     sound: RawResourceAndroidNotificationSound(sound),
//   );
//
//   final NotificationDetails notificationDetails =
//   NotificationDetails(android: androidDetails);
//
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     title, // Dynamic Notification Title
//     body, // Dynamic Notification Body
//     notificationDetails,
//   );
// }
//
// Future<void> showNotificationforInternet() async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'channel_id', // Unique channel ID
//     'channel_name', // Channel name
//     channelDescription: 'This is a description of the channel',
//     importance: Importance.high,
//     priority: Priority.high,
//     icon: '@drawable/ic_bg_service_small',
//     playSound: true,
//   );
//
//   const NotificationDetails notificationDetails =
//   NotificationDetails(android: androidDetails);
//
//   await flutterLocalNotificationsPlugin.show(
//     1, // Notification ID
//     ' ⚠️ Internet Disconnected!! ', // Notification Title
//     'Connect to the internet now to ensure your recording is uploaded successfully. 🚀', // Notification Body
//     notificationDetails,
//   );
// }
//
//
//
//
//
