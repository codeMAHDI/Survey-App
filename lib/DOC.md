1. Firestore is a flexible, scalable NoSQL(Data is not stored in tables with rows and columns)
   cloud database provided by Google Firebase. It's used for storing and syncing data in real time for
   web, Android, iOS, and server applications.
2. Then search firebase->go to console-> create project-> build->firestore db(This is the backend)->Create DB
3. Then project overview->click flutter-> Firebase CLI connection(The Firebase CLI (Command Line Interface) is a tool that lets you interact with Firebase services directly from your terminal or command prompt)
4. CLI(Command line Interface)-> So , by writing terminal command we can do our things.
   Firebase CLI make sure the authentication of project under the mail account.
   And the connection between project and the firebase.
5. The FlutterFire CLI is a command-line tool that helps you integrate 
   Firebase with Flutter apps easily. It automatically sets up platform-specific 
   Firebase configurations for Android, iOS, macOS, and web — without manual edits to 
   google-services.json or GoogleService-Info.plist.
6. Then after that add two package->
   add this plugin->  firebase_core: ^3.13.0(to get the firebase related service)
   And then if we want use firestore then->
   add this plugin-> cloud_firestore: ^5.6.7
7. How to use that now->
   When we use firebase then in main.dart->
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
8. Then go to firestore->Create a collection.
9. Then create firestore_service.dart->
   class FirestoreService{
   final FirebaseFirestore _db= FirebaseFirestore.instance;//Take the Firestore db ref or instance
//Method for Add survey
Future<void> addSurvey(String question, List<String> options)async{//Params->Survey qn, and also List of String which is options
try{
await _db.collection("surveys").add({// add data as map
'question': question,
'options': options,
'votes': List.filled(options.length, 0)//Auto filled in list
});
}catch(e){
print('Error adding survey:$e');
}
}
10. Then we've to write this method inside FirestoreService->
    //Get real-time survey data(Why Stream? because when the data will change at that time we want to grab the data)
    Stream<QuerySnapshot> getSurveys(){//QuerySnapshot is Stream datatype
    return _db.collection("surveys").snapshots();
    }
    }
11. Then create survey_screen.dart->
    import 'package:flutter/material.dart';
    import 'package:flutter_firebase/firestore_service.dart';
class SurveyScreen extends StatefulWidget {
const SurveyScreen({super.key});
@override
State<SurveyScreen> createState() => _SurveyScreenState();
}
class _SurveyScreenState extends State<SurveyScreen> {
final FirestoreService _firestoreService = FirestoreService();//We need our FirestoreService class instance
final TextEditingController _questionController = TextEditingController();
final TextEditingController _optionController = TextEditingController();
List<String> _options = [];
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Survey App'),
),
body: Column(
children: [
///Adding UI
///Showing UI
Expanded(
child: StreamBuilder(//StreamBuilder listens to a stream and rebuilds the widget tree every time new data arrives. Basically we can tell the streamBuilder which stream to listen then he automatically listen that stream.
stream: _firestoreService.getSurveys(),//Listen getSurveys stream
builder: (context, snapshot) {
if(!snapshot.hasData || snapshot.data==null){
return Center(child: CircularProgressIndicator(),
);
}
return ListView(//If data available
children:  snapshot.data!.docs.map((doc){//Process the docs data because data is inside this docs
Map<String,dynamic> data= doc.data() as Map<String,dynamic>;
return Card(
margin: EdgeInsets.all(8),
child: ListTile(
title: Text(data['question']),
subtitle: Column(//Options->multiple that's why we took col
crossAxisAlignment: CrossAxisAlignment.start,
children:
List.generate(data['options'].length, (index){//Index dore data dekhabo
return ListTile(
title: Text(data['options'][index]),//Index wise show the option
trailing: Text("${data["votes"][index]} votes"),
); }),), ), ); }).toList(),// Map of individual doc. Whole things makes it a list ); },),),], ),); } }
12. Now lets write the vote method on firestore_service.dart->
    //Voting
    Future<void> vote(String surveyId,int optionsIndex)async{//surveyId->to know on which survey we want to vote/access,optionsIndex-> to know which option we're choosing
    try{
    DocumentReference surveyRef= _db.collection('surveys').doc(surveyId);//First we've get the collection ref. using DocumentReference. then doc ID. cause we can have multiple doc
    DocumentSnapshot doc= await surveyRef.get();//snapshot for data(It reads the document from Firestore using the surveyRef)
    if(doc.exists){//if exist then we'll vote
    List<dynamic> votes= doc['votes'];//data type wise this list will map. though our vote is int number.then from doc we'll access the key
    votes[optionsIndex]+=1;//Where i want to vote.then increase the value
    await surveyRef.update({//now update the vote
    'votes': votes//Existing 'votes' updated by votes
    }); }
    }catch(e){
      print('Error adding survey:$e');}}
13. Now  go to survey_screen.dart. We need method an vote for an option.
    void _vote(String surveyId, int optionIndex){
    _firestoreService.vote(surveyId, optionIndex);
    } 
    Then also need add a new survey method
    void _addSurvey() {
    if (_questionController.text.isNotEmpty && _options.length >= 2) {//_options.length >= 2->The user has added at least two options.
    _firestoreService.addSurvey(_questionController.text, _options);
    _questionController.clear();
    _options.clear();
    setState(() {});
    }
    }
14. Then Adding UI code on survey_screen.dart->
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
15. Then lastly call the vote method on listTile onTap->
    onTap: ()=>_vote(doc.id, index),
    
    


   

