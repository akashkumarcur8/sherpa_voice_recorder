import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF565ADD),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'FAQ Guide',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search FAQs",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: faqData.length,
                itemBuilder: (context, index) {
                  if (faqData[index]["question"]!.toLowerCase().contains(searchQuery)) {
                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          faqData[index]["question"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(faqData[index]["answer"]!),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, String>> faqData = [
  {"question": "What is Sherpa?", "answer": "Sherpa is a powerful audio recording app designed for high-quality voice capture. It features automatic noise reduction and seamless cloud sync when connected to the internet."},
  {"question": "How do I start recording in Sherpa?", "answer": "Simply open the app and tap the Record button. Your recording will start instantly, and Sherpa will handle automatic noise reduction for a clearer sound."},
  {"question": "Where are my recordings saved?", "answer": "If your device is offline, recordings are saved locally. If you are connected to the internet, Sherpa automatically syncs your recordings to our secure cloud server for backup."},
  {"question": "Unable to use an external microphone or Bluetooth device?", "answer": "Ensure your microphone is properly connected, and that Sherpa has the required microphone permissions in your device settings."},
  {"question": "How can I reduce background noise in my recordings?", "answer": "Sherpa automatically applies AI-powered noise reduction, so you don’t need to enable anything manually."},
  {"question": "Does Sherpa support stereo recording?", "answer": "No, Sherpa currently supports only mono recording to maintain optimized performance and clarity."},
  {"question": "How do I export my recordings to an SD card?", "answer": "Sherpa does not support direct SD card storage. However, you can manually move your recordings from the local storage folder."},
  {"question": "What is the default exporting format in Sherpa?", "answer": "Sherpa saves recordings in MP3 format to ensure compatibility and optimized file size."},
  {"question": "What is the maximum recording duration?", "answer": "Sherpa allows unlimited recording time, depending on your device's available storage."},
  {"question": "Can I edit my recordings within the app?", "answer": "No, Sherpa does not have an editing feature. However, you can export your recordings and edit them using third-party apps."},
  {"question": "Does Sherpa support cloud backup?", "answer": "Yes! If you are connected to the internet, Sherpa automatically syncs your recordings to our secure cloud server for backup and easy access."}
];