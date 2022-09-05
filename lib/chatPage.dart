import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtimechat/SupaHandler.dart';
import 'package:realtimechat/components/FullImageView.dart';
import 'package:realtimechat/components/Message.dart';
import 'package:realtimechat/components/chatImage.dart';
import 'package:realtimechat/components/kTextInputDecoration.dart';
import 'package:supabase/supabase.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  static Route<void> route(int roomId,String recId,String recName) {
    return MaterialPageRoute(builder: (_) => ChatPage(roomId,recId,recName));
  }

  final int roomId;
  final String recId;
  final String recName;

  const ChatPage(this.roomId,this.recId,this.recName, {Key? key}) : super(key: key);

  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SupabaseHandler supabaseHandler = SupabaseHandler();
  List<Message> _messages = [];
  var _listner;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20,),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFfcf4e4)
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(0xFF756d54),
                      size: 16,
                    ),
                  ),
                ),
                Spacer(),
                Center(
                  child: Text(
                    widget.recName,
                    style: TextStyle(
                      fontSize: 25
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20,),
            Expanded(child:
            _isLoading
                ? const Center(child: CircularProgressIndicator(),)
                :ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                reverse: true,
                itemBuilder: (_,index) {
                  final message = _messages[index];
                  final user = message.userId;
                  final mtype = message.mtype;
                  final isMyChat = user == "1";
                  final isTM = mtype == 0;
                  List<Widget> chatContents = [
                    if(!isMyChat) ... [
                      CircleAvatar(
                        radius: 25,
                        child: Text(widget.recName),
                      ),
                      const SizedBox(width: 12,),
                    ],
                    Flexible(child:
                    Material(
                      borderRadius: BorderRadius.circular(8),
                      color: isMyChat
                      ? Colors.grey
                      : Colors.red ,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: isTM ? Text(message.message,style: TextStyle(color: Colors.white,fontSize: 15),):
                        ChatImage( imageSrc: message.message, onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FullImageView(url: message.message)));
                        }, BuildContext: context),
                      ),
                    )
                    ),
                    const SizedBox(width: 12,),
                    if (message.isSending)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 1,),
                      )
                    else
                      Text(
                        timeago.format(message.insertedAt,locale: 'en'),
                      )
                  ];
                  if(isMyChat) {
                    chatContents = chatContents.reversed.toList();
                  }
                  return Padding(padding: EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: isMyChat
                    ? MainAxisAlignment.end
                    :MainAxisAlignment.start,
                    children:
                      chatContents,

                  ),);

                }
                ,
            itemCount: _messages.length,)
            ),
            _MessageInput(
                roomId:widget.roomId,
                onSend:(message) {
                  setState(() {
                    _messages.insert(0, message);
                  });
                }
            )
          ],

        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _listner.unsubscribe();
  }

  Future<void> getChats() async {
    final snap = await supabaseHandler.client
        .from("chatMessages")
        .select()
        .eq('chatid', widget.roomId)
        .order('created_at')
        .execute();

    final messages = Message.fromRows(snap.data as List);

    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    _listner = supabaseHandler.client
    .from('chatMessages:chatid=eq.${widget.roomId}')
    .on(SupabaseEventTypes.insert, (payload) {
      _messages.removeWhere((message) => message.isSending);
      _messages.insertAll(0, Message.fromRows([payload.newRecord as Map<String,dynamic>].toList()));
      setState(() {

      });
    }).subscribe();
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput({
    Key? key,
    required this.roomId,
    required this.onSend,
}) : super(key: key);

  final int roomId;
  final void Function(Message) onSend;

  __MessageInputState createState() => __MessageInputState();
}

class __MessageInputState extends State<_MessageInput> {

  late TextEditingController _textController;
  SupabaseHandler supabaseHandler = SupabaseHandler();

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    Material(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(child:
            TextField(
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              controller: _textController,
              decoration:
              kTextInputDecoration.copyWith(hintText: 'Write your message...'),
            )),
            Container(
              margin: const EdgeInsets.only(left:4),
              child: IconButton(
                onPressed: () async {
                  final message = _textController.text;
                  if (message.isEmpty) {
                    return;
                  }

                  final sendingMessage = Message(id: 0, userId: "1", insertedAt: DateTime.now(), message: message, mtype: 0,isSending: true);
                  widget.onSend(sendingMessage);
                  final result = await supabaseHandler.client.from('chatMessages').insert(
                    {
                      'content':message,
                      'sender':1,
                      'chatid':widget.roomId,
                      'mtype':0
                    }
                  ).execute();
                  if(result.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("error occured")));
                  }
                  _textController.clear();
                },
                icon: const Icon(Icons.send_outlined,size: 36,),
                color: Colors.red,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: IconButton(
                onPressed: () {
                  final sendingMessage = Message(id: 0, userId: "1", insertedAt: DateTime.now(), message: "Sending Image...", mtype: 1,isSending: true);
                  widget.onSend(sendingMessage);
                  _upload();
                },
                icon: Icon(
                  Icons.camera_alt_outlined,
                  size: 36,
                ),
                color: Colors.red,
              ),
            )
          ],
        ),
      ),
    )
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {

        });
        _upload();
      }
    }
  }

  Future<void> _upload() async {
    final _picker = ImagePicker();
    final imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if(imageFile == null) {
      return;
    }

    final bytes = await imageFile.readAsBytes();
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
    final filePath = fileName;
    final response = await supabaseHandler.client.storage.from('chat').updateBinary(filePath, bytes);

    final error = response.error;
    if(error != null) {
      Fluttertoast.showToast(msg: error.message);
      return;
    }

    final imageUrlResponse = supabaseHandler.client.storage.from('chat').getPublicUrl(filePath);
    _onUpload(imageUrlResponse.data!);
  }

  Future<void> _onUpload(String imageUrl) async {
    final response = await supabaseHandler.client.from('chatMessages').insert({
      'content':imageUrl,
      'sender':1,
      'chatid':widget.roomId,
      'mtype':1
    }).execute();

    final error = response.error;
    if(error != null) {
      Fluttertoast.showToast(msg: error.message);
      return;
    }
    Fluttertoast.showToast(msg: 'Uploaded Image!');
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }
}