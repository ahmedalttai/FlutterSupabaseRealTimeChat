import 'package:flutter/material.dart';
import 'package:realtimechat/NewChatPage.dart';
import 'package:realtimechat/SupaHandler.dart';

import 'chatPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
           Padding(padding: EdgeInsets.all(8.0),
           child: Row(
             children: [
               Text("Chats",style: TextStyle(fontSize: 40),),
               GestureDetector(
                 onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => NewChatPage()));
                 },
                 child: Container(
                   width: 40,
                   height: 40,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Icon(
                     Icons.add,
                     color: Colors.grey,
                     size: 42,
                   ),
                 ),
               )
             ],
           ),
           ),
            SizedBox(height: 20,),
            FutureBuilder(builder: (context,AsyncSnapshot snapshot){
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator(),);
                default:
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (context,position) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(ChatPage.route(
                            snapshot.data[position]["id"],
                            snapshot.data[position]["rec"].toString(),
                            snapshot.data[position]["recname"]
                          ));
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  snapshot.data[position]['recname'],
                                  style: TextStyle(fontSize: 22.0),
                                ),
                                Text(
                                  snapshot.data[position]['content'],
                                  style:TextStyle(fontSize: 12.0)
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
              }
            },
              future: SupabaseHandler().readChatData(),
            )
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
