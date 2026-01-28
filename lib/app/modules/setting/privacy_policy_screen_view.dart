import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _policyText = """
# Privacy Policy for Sherpa Voice Recorder
**Last updated:** June 5, 2025

Sherpa Voice Recorder we provides audio recording and real-time analysis services. This Privacy Policy explains what data we collect, how we use it, and the controls you have.

---

## 1. Information We Collect

### 1.1. Audio Recordings & Streams
**What:**
- **File Uploads:** Complete recordings you start within the App are saved as audio files and sent to our servers.
- **Live Streaming:** If you opt into real-time analysis, your audio is streamed over a secure WebSocket connection as you record.
1
**Why:** To perform transcription, voice-analysis and other value-added services.

> **Note:** We do **not** record or upload phone calls or any microphone activity outside of those recordings you explicitly start.

### 1.2. Device & Usage Data
**What:** Device model, OS version, App version, usage metrics (e.g. number of recordings, session length), and crash logs.
**Why:** To diagnose issues, improve performance, and enhance features.

### 1.3. Permissions & Background Service Behavior
- **Microphone Access:** Needed to record audio files or stream.
- **Storage Access:** Needed to save, retrieve, and export recordings.
- **Background Recording Service:**
  - Only runs when you tap **Record** in the App.
  - Immediately stops if another app (e.g. a phone call) takes control of the microphone.
  - Resumes only when you explicitly tap **Record** again.

---

## 2. How We Use Your Information
- **Recording & Analysis:** Transcribe and analyze your recordings on our servers.
- **Real-Time Features:** Provide live feedback or analysis via WebSocket streaming.
- **App Improvement:** Aggregate anonymized usage and crash data to fix bugs and add features.
- **Support:** Respond to your support requests and inquiries.

---

## 3. Sharing & Disclosure
- **Service Providers:** We share recordings and streams with our analytics and processing partners (e.g., AWS, Google Cloud). They’re bound by contract to keep data confidential.
- **Legal Compliance:** We may disclose data if required by law (subpoena, court order).
- **Business Transfers:** In the event of a merger or sale, your data may transfer—but we’ll notify you first.

---

## 4. Data Retention & Deletion
- **Your Recordings:** Remain on your device (and in your server account) until you delete them.
- **Streams:** Not stored beyond the duration of your live session, except as part of your completed recording file if you choose to save it.
- **Analytics Data:** Anonymized usage data kept up to 24 months.
- **Delete Request:** Email us at **transform@darwix.ai** to erase any data.

---

## 5. Security
We use industry-standard protections (TLS encryption, secure cloud storage) to safeguard your data. However, no system is impervious—use at your own risk.

---

## 6. Children’s Privacy
Not intended for users under 13. We don’t knowingly collect data from children. If you believe we have, contact us to remove it.

---

## 7. Your Rights
Depending on where you live, you can: access, correct, delete, restrict, or port your data. To exercise any right, contact **transform@darwix.ai**; we’ll respond within 30 days.

---

## 8. Third-Party Links
Our App may link to other sites. We’re not responsible for their privacy practices—please review their policies separately.

---

## 9. Changes to This Policy
We’ll post updates here and change the “Last updated” date. If materially significant, we’ll notify you in-App or by email if you’ve opted in.

---

## 10. Contact Us
**Darwix AI Support**
Email: **transform@darwix.ai**
Address: **7th Floor, Imperia MindSpace, Golf Course Ext Rd, Sector 62, Gurugram, Haryana 122001**
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Markdown(
        data: _policyText,
        padding: EdgeInsets.all(16),
        // you can customize style here if needed
      ),
    );
  }
}
