import 'package:flutter/material.dart';
import 'package:realtimechat/SupaHandler.dart';

import 'chatPage.dart';


class NewChatPage extends StatefulWidget {
  const NewChatPage({Key? key}) : super(key: key);

  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final TextStyle placeHolderTextFieldStyle = TextStyle(color: Colors.grey.shade400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color(0xFF756d54),
                        size: 32,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(child: FutureBuilder(
              builder: (context,AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError)
                      return Icon(Icons.error);
                    else if (snapshot.data == null)
                      return Icon(Icons.error);
                    else
                      Icon(Icons.error);
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (context,position){
                        return GestureDetector(
                          onTap: () {
                            _checkChat(snapshot.data[position]['id'].toString(), snapshot.data[position]['name']);
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(snapshot.data[position]['name'],
                                    style: TextStyle(fontSize: 22.0),)
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                }
              },
              future: SupabaseHandler().getLatestCustomers(),
            )
            )
          ],
        ),
      ),
    );
  }

  _checkChat(String id,String name) async {
    final result = await SupabaseHandler()
        .client
        .from('chat')
        .select()
        .or('sender.eq.${id},rec.eq.${id}')
    .execute();

    final datalist = result.data as List;

    if(datalist.length > 0) {
      Navigator.of(context).push(ChatPage.route(datalist[0]['id'],id,name));
    } else {
      final res = await SupabaseHandler()
          .client
          .from("chat")
          .insert({'rec':id,'sender':1}).execute();

      Navigator.of(context).push(ChatPage.route(res.data[0]['id'],id,name));
    }
  }
}

