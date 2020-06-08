import 'package:flutter/material.dart';
import 'package:flutterfluttershare/pages/home.dart';
import 'package:flutterfluttershare/widgets/header.dart';
import 'package:flutterfluttershare/widgets/post.dart';
import 'package:flutterfluttershare/widgets/progress.dart';

class PostScreen extends StatefulWidget {

  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  _PostScreenState createState() => _PostScreenState();
}



class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(currentUser.id)
          .collection('userPosts')
          .document(widget.postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return circularProgress();
        }

        //print(snapshot.data.data); //run to see if snapshot.data has a value
        print(widget.userId);
        print(widget.postId);


        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titletext: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }}