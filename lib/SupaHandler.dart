

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class SupabaseHandler {
  static String supabaseURL = "YourUrl";
  static String supabaseKey = "YourApiKey";

  final client = SupabaseClient(supabaseURL, supabaseKey);

  readChatData() async {
    var response = await client.rpc('list_private_chat_rooms',params: {'keyword':1}).execute();

    debugPrint("line17 ${response.toJson()}");

    final datalist = response.data as List;
    return datalist;
  }

  uploadImageFile(File image,String filename) {
    client.storage
        .from("chat")
        .upload(image.path, image)
        .then((value) => {debugPrint("line24 ${value.toString()}")});
  }

  getChatMessages(String chatId) async {
    var response = await client
        .from('chatMessages')
        .select()
        .eq("chatid",chatId)
        .execute();

    final datalist = response.data as List;
    return datalist;
  }

  getLatestCustomers() async {
    var response = await client.from("users").select("id,name").limit(50).execute();
    debugPrint("line24 ${response.toString()}");
    final datalist = response.data as List;
    return datalist;
  }
}