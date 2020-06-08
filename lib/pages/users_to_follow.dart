import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterfluttershare/models/user.dart';
import 'package:flutterfluttershare/pages/activity_feed.dart';
import 'package:flutterfluttershare/pages/home.dart';
import 'package:flutterfluttershare/widgets/header.dart';
import 'package:flutterfluttershare/widgets/progress.dart';

class Users_to_follow  extends StatefulWidget {

  List <dynamic> users = [];
  List<Users_to_follow_Result> users_to_follow_result =[];
  bool isLoading = false;


  @override
  _Users_to_followState createState() => _Users_to_followState();


  // eh elfr2 ?? kda static m4 hy3mel define lel variables kol mara grby run

}

class _Users_to_followState extends State<Users_to_follow> {



  @override
  void initState(){

    //getUsers();
    //getUserByID();
    //createUser();
    //updateUser();
    //deleteUser();

    handleuserstofollow();

    super.initState();
  }

   
  handleuserstofollow() async {

    widget.users.clear();
    widget.users_to_follow_result.clear();

    setState(() {

      widget.isLoading = true;

    });

    QuerySnapshot snapshotusers = await usersRef.orderBy("timestamp",descending: true).limit(50).getDocuments();

    widget.users.addAll(snapshotusers.documents.map((doc) => User.fromDocument(doc)).toList());

    print(widget.users.length);

    for(var user in widget.users){

      if(user.id != currentUser.id) {
        Users_to_follow_Result user_to_follow_result = Users_to_follow_Result(
            user);
        //searchResults.add(Text(user.username));
        widget.users_to_follow_result.add(user_to_follow_result);
      }
    }

    print(widget.users_to_follow_result.length);

    //return users_to_follow_result;

    setState(() {

      widget.isLoading = false;

    });

  }

/*
for(User user in users){

      Users_to_follow_Result users_to_follow_result = Users_to_follow_Result();
      //searchResults.add(Text(user.username));
      users_to_follow_result.add(user);

    }
 */

  buildUsersToFollowResults(context) {

       if(widget.isLoading){

         return circularProgress();

       }

       else if (widget.users_to_follow_result.isEmpty){

         return Text("");

       }
       else{


        print(widget.users_to_follow_result.length);
        return ListView(

           children: widget.users_to_follow_result,

       );
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
        header(context, titletext: "User to follow"),

      body: buildUsersToFollowResults(context),

      );

  }
}





class Users_to_follow_Result extends StatelessWidget {

  final User user;

  Users_to_follow_Result(this.user);


    @override
    Widget build(BuildContext context) {
      return Container(

        color: Theme
            .of(context)
            .primaryColor
            .withOpacity(0.7),
        child: Column(
          children: <Widget>[
            GestureDetector(

              onTap: () => showProfile(context, profileId: user.id),

              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                title: Text(user.username,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),),
                subtitle: Text(user.email,
                    style: TextStyle(color: Colors.white)),
              ),

            ),
            Divider(
              height: 2.0,
              color: Colors.white54,
            )
          ],
        ),

      );
    }



}