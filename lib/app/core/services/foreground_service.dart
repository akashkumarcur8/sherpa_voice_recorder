import 'dart:async';
import 'dart:ui';

 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initializeService() async {
  final service =FlutterBackgroundService();

  await service.configure(

    iosConfiguration: IosConfiguration(

      autoStart: true,

      onForeground: onStart,

      onBackground: onIosBackground,

    ),

    // androidConfiguration: AndroidConfiguration(
    //
    //     onStart: onStart, isForegroundMode: true, autoStart: true),


    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,            // ← don’t start at app launch
      autoStartOnBoot: false,      // ← don’t restart on device boot

    ),

  );
}
@pragma('vm:entry-point')

Future<bool> onIosBackground (ServiceInstance service) async {

  WidgetsFlutterBinding.ensureInitialized();

  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {

    service.on('setAsForeground').listen((event) {

      service.setAsForegroundService();

    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

  }

  service.on('stopService').listen((event) {

    service.stopSelf();

  });



  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(

             title: "Sherpa", content: " Background Service Running",);
      }
    }

    service.invoke('update');
  });
// Timer.periodic
}

