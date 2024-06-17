import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resume Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ResumeScanner(),
    );
  }
}

class ResumeScanner extends StatefulWidget {
  @override
  _ResumeScannerState createState() => _ResumeScannerState();
}

class _ResumeScannerState extends State<ResumeScanner> {
  final ImagePicker _picker = ImagePicker();
  String _extractedText = '';
  double _rating = 0.0;
  bool _loading = false;

  final List<String> jobKeywords = [
    'PHP', 'SQL', 'database', 'API', 'integration', 'web applications',
    'front-end', 'JavaScript', 'HTML', 'CSS', 'MySQL', 'PostgreSQL',
    'Git', 'version control', 'problem-solving', 'teamwork', 'communication',
    'Laravel', 'Symfony', 'Apache', 'Nginx'
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _loading = true;
      });
      final inputImage = InputImage.fromFile(File(image.path));
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textDetector.processImage(inputImage);
      String text = recognizedText.text;

      setState(() {
        _extractedText = text;
        _rating = _rateResume(text);
        _loading = false;
      });
    }
  }

  double _rateResume(String text) {

    double keywordWeight = 0.4;
    double experienceWeight = 0.2;
    double educationWeight = 0.1;
    double skillsWeight = 0.1;
    double achievementsWeight = 0.1;

    int keywordCount = jobKeywords.where((keyword) => text.contains(keyword)).length;
    bool hasExperience = text.contains("Experience") || text.contains("experience");
    bool hasEducation = text.contains("Education") || text.contains("education");
    bool hasSkills = text.contains("Skills") || text.contains("skills");
    bool hasAchievements = text.contains("Achievements") || text.contains("achievements");

    double keywordScore = (keywordCount / jobKeywords.length).clamp(0, 1) * keywordWeight;
    double experienceScore = hasExperience ? 1 * experienceWeight : 0;
    double educationScore = hasEducation ? 1 * educationWeight : 0;
    double skillsScore = hasSkills ? 1 * skillsWeight : 0;
    double achievementsScore = hasAchievements ? 1 * achievementsWeight : 0;

    double totalScore = keywordScore + experienceScore + educationScore + skillsScore + achievementsScore;

    return (totalScore * 5).clamp(0, 5).toDouble();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resume Scanner'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick a Resume Image'),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _extractedText.isNotEmpty
                    ? Column(
                        children: [
                          Text(
                            'Rating: ${_rating.toStringAsFixed(1)} / 5',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
