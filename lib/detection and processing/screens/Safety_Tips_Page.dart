import 'package:flutter/material.dart';

class SafetyTipsPage extends StatelessWidget {
  final List<Map<String, String>> safetyTips = [
    {
      'title': 'Stay Calm',
      'description':
          'If you encounter a wild animal, avoid sudden movements and remain calm to avoid provoking it.'
    },
    {
      'title': 'Keep Your Distance',
      'description':
          'Maintain a safe distance from wildlife to avoid startling them or putting yourself in danger.'
    },
    {
      'title': 'Don’t Feed Animals',
      'description':
          'Feeding wildlife can make them reliant on humans and disrupt their natural behaviors.'
    },
    {
      'title': 'Travel in Groups',
      'description':
          'Traveling in groups reduces the chance of being targeted by predators. Avoid isolated areas.'
    },
    {
      'title': 'Know Emergency Contacts',
      'description':
          'Keep a list of local emergency numbers and first-aid information readily available.'
    },
    {
      'title': 'Make Noise',
      'description':
          'While hiking, make noise to alert animals of your presence. This can prevent surprising them.'
    },
    {
      'title': 'Avoid Bright Colors',
      'description':
          'Wearing neutral clothing helps you blend in with the environment and not attract unnecessary attention.'
    },
    {
      'title': 'Be Aware of Surroundings',
      'description':
          'Keep an eye out for tracks, scat, or other signs of wildlife to avoid potential encounters.'
    },
    {
      'title': 'Learn Animal Behavior',
      'description':
          'Understand basic behaviors of local wildlife to know when an animal feels threatened or aggressive.'
    },
    {
      'title': 'Carry Safety Gear',
      'description':
          'Carry essentials like a whistle, flashlight, and first-aid kit for emergencies.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Tips'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color:
            Colors.lightGreenAccent.withOpacity(0.2), // Light green background
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: safetyTips.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.warning,
                  color: Colors.orangeAccent,
                  size: 30,
                ),
                title: Text(
                  safetyTips[index]['title']!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  safetyTips[index]['description']!,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
