import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.minha, required this.data});

  final bool minha;
  final data;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
     child: Row(
      children: [
        !minha ?
          Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              data['senderPhotoUrl']
              ),
          ),
        ): Container(),
        Expanded(
          child: Column(
            crossAxisAlignment: 
            minha ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                data()['senderName'], 
                style : const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.w500),
              ),
              data()['imgUrl'] != null 
              ? Image.network(
                data()['imgUrl'],
                width: 250,
                ) 
              : Text(
                data()['texto'],
                style : const TextStyle(fontSize: 18),
                ),
                
            ],
          )
          ),
          minha ?
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              data['senderPhotoUrl']
              ),
          ),
        ): Container(),
       ],
     ),
    );
  }
}