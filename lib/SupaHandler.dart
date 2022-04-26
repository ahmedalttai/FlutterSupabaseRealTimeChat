import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class SupabaseHandler {
  static String supabaseURL = "https://sywemvpwchyabzldtvlp.supabase.co";
  static String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5d2VtdnB3Y2h5YWJ6bGR0dmxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTA3MjQ2NzIsImV4cCI6MTk2NjMwMDY3Mn0.edhWX2U43x_j0ioySg58DjD4pYNfNoSs6XjbB6sD5t0";

  final client = SupabaseClient(supabaseURL, supabaseKey);

  readChatData() async {
    var response = await client
        .rpc('list_private_chat_rooms', params: {'keyword': 1}).execute();

    final datalist = response.data as List;
    return datalist;
  }

  uploadImageFile(File image, String filename) {
    client.storage
        .from("chat")
        .upload(image.path, image)
        .then((value) => {debugPrint("line26 ${value.toString()}")});

  }

  getChatMessages(String chatId) async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var response = await client
        // .rpc('search_chats', params: { 'keyword': sharedPreferences!.getString("userId") })
        .from('chatMessages')
        .select()
        .eq("chatid", chatId)
        .execute();

    final datalist = response.data as List;
    return datalist;
  }

  getLatestCustomers() async {

    var response =
        await client.from("users").select("id,name").limit(50).execute();

    final datalist = response.data as List;
    return datalist;
  }
}
