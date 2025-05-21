import 'package:flutter/material.dart';
import 'package:flutter_firebase/firestore_service.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  List<String> _options = [];

  void _vote(String surveyId, int optionIndex) {
    _firestoreService.vote(surveyId, optionIndex);
  }

  void _addSurvey() {
    if (_questionController.text.isNotEmpty && _options.length >= 2) {
      _firestoreService.addSurvey(_questionController.text, _options);
      _questionController.clear();
      _options.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey App'),
      ),
      body: Column(
        children: [
          ///Adding UI
          Padding(padding: EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Survey Question'),
              ),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: _optionController,
                        decoration: InputDecoration(labelText: 'Option'),
                      ) ,
                  ),
                  IconButton(icon: Icon(Icons.add),
                    onPressed: (){
                    if(_optionController.text.isNotEmpty){
                      setState(() {
                        _options.add(_optionController.text);
                      });
                      _optionController.clear();
                    }
                    },
                  )
                ],
              ),
              Wrap(
                children: _options.map((opt)=>Chip(label: Text(opt))).toList(),
              ),
              ElevatedButton(onPressed: _addSurvey,
                  child: Text('Add Survey'),
              )
            ],
          ),
          ),
          ///Showing UI
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getSurveys(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(data['question']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(data['options'].length, (index) {
                            return ListTile(
                              title: Text(data['options'][index]),
                              trailing: Text("${data["votes"][index]} votes"),
                              onTap: ()=>_vote(doc.id, index),
                            );
                          }),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
