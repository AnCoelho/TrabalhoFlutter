
import 'package:ads_chat/widgets/chat_message.dart';
import 'package:ads_chat/widgets/escreve_texto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;

  void iniState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  } 

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount? googleSignInAccount = 
          await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication = 
        await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      return user;
    } catch (error) {
      return null;
    }
  }


  void _salvaMensagem({String? texto, XFile? imgFile}) async {
    final User? user = await _getUser();

    if(user == null){
      print('Não foi possível realizar o login, try again');
    }
    Map<String, dynamic> data = {
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now(),
      };

    if (imgFile != null) {
      final myPhoto = File(imgFile.path);
      UploadTask task = FirebaseStorage.instance
      .ref()
      .child(DateTime.now().millisecondsSinceEpoch.toString())
      .putFile(myPhoto);
      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }
    if (texto != null) data['texto'] = texto;
    
    FirebaseFirestore.instance.collection('mensagens').add(data); 
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUser != null 
          ? 'Olá, ${_currentUser!.displayName}' 
          : 'Ads Chat'),
        backgroundColor: Colors.blue,
        actions:[
          _currentUser != null 
          ? IconButton(
            icon: Icon(Icons.exit_to_app), 
            onPressed: () {
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
            }, 
            ) 
            : Container()
          ],
      ),
      body: Column(
        children: [
            Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
              .collection('mensagens')
              .orderBy('time')
              .snapshots(),
              builder: ((context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
                default:
                List<DocumentSnapshot> messages = 
                  snapshot.data!.docs.reversed.toList();
                return ListView.builder(
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return ChatMessage(
                      data: messages[index].data, minha: true);
                  },
                );
              }
              }),
            ),
            ),
          EscreveTexto(
            salvaMensagem: _salvaMensagem,
          ),
        ],
      ),
    );
  }
}