
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'components/chatImage.dart';
import 'components/kTextInputDecoration.dart';
import 'supaHandler.dart';
import 'package:supabase/supabase.dart';

import 'FullImageView.dart';
import 'Message.dart';

class ChatPage extends StatefulWidget {
  static Route<void> route(int roomId,String recid,String recname) {
    return MaterialPageRoute(builder: (_) => ChatPage(roomId,recid,recname));
  }

  final int roomId;
  final String recid;
  final String recname;

  const ChatPage(this.roomId,this.recid,this.recname, {Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SupabaseHandler supabaseHandler = SupabaseHandler();
  List<Message> _messages = [];
  var _listener;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
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
                          borderRadius: BorderRadius.circular(40/2),
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
                    child: Text(widget.recname,
                      style: TextStyle(
                        fontSize: 25,


                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                reverse: true,
                itemBuilder: (_, index) {
                  final message = _messages[index];
                  final user = message.userId;
                  final mtype = message.mtype;
                  final isMyChat = user == "1";
                  final isTM = mtype == 0;
                  List<Widget> chatContents = [
                    if (!isMyChat) ...[
                      CircleAvatar(
                        radius: 25,
                        child: Text(widget.recname),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        color: isMyChat
                            ? Colors.grey
                            : Colors.red,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: isTM ? Text(message.message,style: TextStyle(color: Colors.white,fontSize: 15),) :
                          chatImage(
                              imageSrc: message.message, onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  FullImageView(url: message.message, ),
                            ));
                          }, context: context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (message.isSending)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      )
                    else
                      Text(
                        timeago.format(message.insertedAt,
                            locale: 'en'),
                      ),
                  ];
                  if (isMyChat) {
                    chatContents = chatContents.reversed.toList();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: isMyChat
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: chatContents,
                    ),
                  );
                },
                itemCount: _messages.length,
              ),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: _MessageInput(
                roomId: widget.roomId,
                onSend: (message) {
                  setState(() {
                    _messages.insert(0, message);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _getChats();
    super.initState();
  }

  @override
  void dispose() {
    _listener.unsubscribe();
    super.dispose();
  }

  Future<void> _getChats() async {

    final snap = await supabaseHandler.client
        .from('chatMessages')
        .select()
        .eq('chatid', widget.roomId)
        .order('created_at')
        .execute();
    final messages = Message.fromRows(snap.data as List);

    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _listener = supabaseHandler.client
        .from('chatMessages:chatid=eq.${widget.roomId}')
        .on(SupabaseEventTypes.insert, (payload) {
      _messages.removeWhere((message) => message.isSending);
      _messages.insertAll(
        0,
        Message.fromRows([payload.newRecord as Map<String, dynamic>].toList()),
      );
      setState(() {});
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

  @override
  __MessageInputState createState() => __MessageInputState();
}

class __MessageInputState extends State<_MessageInput> {
  late TextEditingController _textController;
  SupabaseHandler supabaseHandler = SupabaseHandler();

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child:
          TextField(
                // focusNode: focusNode,
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                controller: _textController,
                decoration:
                kTextInputDecoration.copyWith(hintText: 'Write your message ...'),

              )

              ),
              Container(
                margin: const EdgeInsets.only(right: 4),

                child: IconButton(
                  onPressed: () async {
                    final message = _textController.text;
                    if (message.isEmpty) {
                      return;
                    }

                    final sendingMessage = Message(
                      id: 0,
                      userId: "1",
                      insertedAt: DateTime.now(),
                      message: message,
                      mtype: 0,
                      isSending: true,
                    );
                    widget.onSend(sendingMessage);
                    final result = await supabaseHandler.client.from('chatMessages').insert([
                      {
                        'content': message,
                        'sender': 1,
                        'chatid': widget.roomId,
                        'mtype': 0
                      }
                    ]).execute();
                    if (result.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error occured'),
                      ));
                    }
                    _textController.clear();
                  },
                  icon: const Icon(Icons.send_outlined,size: 36,),
                  color: Colors.red,
                ),
              ),
        Container(
            margin: const EdgeInsets.only(right: 4),

            child: IconButton(
              onPressed: () {
                final sendingMessage = Message(
                  id: 0,
                  userId: "1",
                  insertedAt: DateTime.now(),
                  message: "Sending file...",
                  mtype: 0,
                  isSending: true,
                );
                widget.onSend(sendingMessage);
                _upload();
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 36,
              ),
              color: Colors.red,
            ),
          ),

            ],
          ),
        ),
      ),
    );
  }

    Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          // isLoading = true;
        });
        _upload();
      }
    }
  }

  Future<void> _upload() async {
    final _picker = ImagePicker();
    final imageFile = await _picker.pickImage(
      source: ImageSource.gallery
    );
    if (imageFile == null) {
      return;
    }

    final bytes = await imageFile.readAsBytes();
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
    final filePath = fileName;
    final response =
    await supabaseHandler.client.storage.from('chat').uploadBinary(filePath, bytes);

    final error = response.error;
    if (error != null) {
      Fluttertoast.showToast(msg: error.message);
      return;
    }
    final imageUrlResponse =
    supabaseHandler.client.storage.from('chat').getPublicUrl(filePath);
    _onUpload(imageUrlResponse.data!);
  }

  Future<void> _onUpload(String imageUrl) async {
    final response = await supabaseHandler.client.from('chatMessages').insert([
      {
        'content': imageUrl,
        'sender': 1,
        'chatid': widget.roomId,
        'mtype': 1
      }
    ]).execute();
    final error = response.error;
    if (error != null) {
      Fluttertoast.showToast(msg: error.message);
    }
    setState(() {
      // _avatarUrl = imageUrl;
    });
    Fluttertoast.showToast(msg: 'Uploaded image!');
  }


  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
