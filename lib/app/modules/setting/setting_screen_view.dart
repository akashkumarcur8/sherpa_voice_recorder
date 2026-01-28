import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mice_activeg/app/modules/setting/privacy_policy_screen_view.dart';
import '../help_centre/formWidget.dart';
import 'package:package_info_plus/package_info_plus.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedQuality = "Default (128 Kbps, 44.1 kHz)";
  String selectedFormat = "M4a";
  bool keepScreenOn = false;
  String appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  void _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "Version ${packageInfo.version}";
    });
  }

  void _showQualityBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Audio quality", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("High (257 Kbps, 48 kHz)"),
                leading: Radio(
                  value: "High (257 Kbps, 48 kHz)",
                  groupValue: selectedQuality,
                  onChanged: (value) {
                    setState(() {
                      selectedQuality = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("Default (128 Kbps, 44.1 kHz)"),
                leading: Radio(
                  value: "Default (128 Kbps, 44.1 kHz)",
                  groupValue: selectedQuality,
                  onChanged: (value) {
                    setState(() {
                      selectedQuality = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("Low (64 Kbps, 44.1 kHz)"),
                leading: Radio(
                  value: "Low (64 Kbps, 44.1 kHz)",
                  groupValue: selectedQuality,
                  onChanged: (value) {
                    setState(() {
                      selectedQuality = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFormatBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Recording format", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("M4a"),
                leading: Radio(
                  value: "M4a",
                  groupValue: selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      selectedFormat = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("WAV"),
                leading: Radio(
                  value: "WAV",
                  groupValue: selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      selectedFormat = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("AAC"),
                leading: Radio(
                  value: "AAC",
                  groupValue: selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      selectedFormat = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF565ADD),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: const Text("Quality"),
              subtitle: Text(selectedQuality),
              onTap: _showQualityBottomSheet,
            ),
            // ListTile(
            //   title: Text("Notification sounds"),
            //   subtitle: Text("Allow notifications while recording"),
            //   onTap: () {},
            // ),
            ListTile(
              title: const Text("Recording format"),
              subtitle: Text(selectedFormat),
              onTap: _showFormatBottomSheet,
            ),
            SwitchListTile(
              title: const Text("Keep screen on while recording"),
              value: keepScreenOn,
              onChanged: (value) {
                setState(() {
                  keepScreenOn = value;
                });
              },
            ),
            // ListTile(
            //   title: Text("Storage"),
            //   subtitle: Text("Audio recorder + other apps"),
            //   onTap: () {},
            // ),
            const Divider(),
            ListTile(
              title: const Text("Privacy Policy"),
              onTap: () {
                Get.to(const PrivacyPolicyPage());
              },
            ),



            // ListTile(
            //   title: Text("Open source licences"),
            //   onTap: () {},
            // ),
            ListTile(
              title: Text(appVersion),
            ),

            ListTile(
              title: const Text("Sherpa Help Center"),
              onTap: () {
                Get.to(HelpForm());

              },
            ),



          ],
        ),
      ),
    );
    return scaffold;
  }
}
