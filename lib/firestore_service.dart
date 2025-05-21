import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final FirebaseFirestore _db= FirebaseFirestore.instance;


  Future<void> addSurvey(String question, List<String> options)async{
    try{
      await _db.collection("surveys").add({
        'question': question,
        'options': options,
        'votes': List.filled(options.length, 0)
      });
    }catch(e){
      print('Error adding survey:$e');
    }
  }

  Future<void> vote(String surveyId, int optionsIndex)async{
    try{
      DocumentReference surveyRef= _db.collection("surveys").doc(surveyId);
      DocumentSnapshot doc= await surveyRef.get();
      if(doc.exists){
        List<dynamic> votes= doc['votes'];
        votes[optionsIndex]+=1;
        await surveyRef.update({
          'votes': votes,
        });
      }
    }catch(e){
      print('Error adding survey:$e');
    }
  }



  Stream<QuerySnapshot> getSurveys(){
    return _db.collection('surveys').snapshots();
  }
}



