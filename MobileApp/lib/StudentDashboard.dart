import 'package:flutter/material.dart';
import 'dart:math';
import 'package:english_words/english_words.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: HomeDash(),
    );
  }
}

class HomeDash extends StatefulWidget {
  @override
  _HomeDashState createState() => _HomeDashState();
}

class _HomeDashState extends State<HomeDash> {
  var name = "Ivan Ivanov";
  final _biggerFont = TextStyle(fontSize: 40.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text("Hello! "+ name,style: TextStyle(fontSize: 35.0)),
            ),
            SizedBox(height: 10),
            Container(
              decoration: dashboardBorder(),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text("Current classes: ",style: TextStyle(fontSize: 25.0)),
                  ),
                  Container(
                      height: 700,
                      child: _listClasses()
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration dashboardBorder(){
    return BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) //         <--- border radius here
      ),
    );
  }

  Widget _listClasses(){
    //Placeholders:
    var classNames = ["Subj1","Subj2","Subj3","Subj4","Subj5","Subj6","Subj7","Subj8","Subj9","Subj10","Subj11","Subj12","Subj13","Subj14"];
    var classTimes = ["10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30","10:00-11:30"];
    List colors = [null, Colors.green];
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: classNames.length*2,
        itemBuilder: (BuildContext context, int index) {
          if(index.isOdd){
            return Divider();
          }
          final i = index~/2;
          return FlatButton(
            onPressed: (){
              _subjAttendence(classNames[i]);
            },
            child: Container(
              height: 70,
              child: Column(
                children: [
                  Text(classNames[i],style: TextStyle(fontSize: 20.0)),
                  SizedBox(height: 10),
                  Text(classTimes[i],style: TextStyle(fontSize: 15.0)),
                ],
              ),
            ),
          );
        }
    );
  }

  void _subjAttendence(String className){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          List names = <WordPair>[];
          List handle = <String>[];
          Random random = new Random();
          handle.addAll(nouns.take(7));
          names.addAll(generateWordPairs().take(7));
          return Scaffold(
            appBar: AppBar(
              title: Text('Innopolis University : '+className),
            ),
            body: Column(
              children: [
                SizedBox(height: 20),
                Text("Professors and TAs:",style: TextStyle(fontSize: 25.0)),
                SizedBox(height: 10),
                Container(
                    height: 700,
                    child: _buildAttendanceList(names, handle)
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceList(List names, List handle){
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: names.length*2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          return Column(
            children: [ListTile(
                title: Text(
                  names[index].first + " " + names[index].second,
                  style: TextStyle(fontSize: 20),
                ),
                trailing: Text("@"+handle[index])
            ),
              Text(names[index].first[0]+"."+names[index].second+"@innopolis.ru"),
            ],
          );
        });
  }

}


