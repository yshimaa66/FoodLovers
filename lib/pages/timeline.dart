import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfluttershare/models/user.dart';
import 'package:flutterfluttershare/pages/home.dart';
import 'package:flutterfluttershare/pages/users_to_follow.dart';
import 'package:flutterfluttershare/widgets/header.dart';
import 'package:flutterfluttershare/widgets/post.dart';
import 'package:flutterfluttershare/widgets/post_tile.dart';
import 'package:flutterfluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

final usersRef = Firestore.instance.collection("users");


class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

 // List<dynamic> users = [];

  List<Post> usersPosts = [];
  List<dynamic> usersId = [];
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState(){

    //getUsers();
    //getUserByID();
    //createUser();
    //updateUser();
    //deleteUser();

    getUsersPosts();

    super.initState();
  }


  getUsersPosts() async{

    usersPosts.clear();
    usersId.clear();

    setState(() {

      isLoading = true;

    });


    /*await followingRef.document(currentUser.id)
        .collection("userFollowing").getDocuments().then((value) => value.documents.forEach((element) {

          usersId.add(element.data.toString());
    }));*/

    //usersId= snapshotUserId.documents.map((doc) => User.fromDocument(doc)).toList();


    //currentUserId = currentUser.id as UserId;
    QuerySnapshot snapshotusersId = await followingRef.document(currentUser.id)
        .collection("userFollowing").getDocuments();

    //var usersId = snapshotusersId.documents;

    for (int i = 0; i < snapshotusersId.documents.length; i++) {
      var a = snapshotusersId.documents[i];
      usersId.add(a.documentID);
    }
    //print(documents[0].data['cites'].length);

    //usersId.addAll(documents);
    usersId.add(currentUser.id);

    //print(usersId.elementAt(0));

    for(var userId in usersId) {

      QuerySnapshot snapshotPosts = await postsRef.document(userId.toString())
          .collection("userPosts").orderBy("timestamp",descending: true).getDocuments();

      usersPosts.addAll(snapshotPosts.documents.map((doc) => Post.fromDocument(doc)).toList());

      print(usersPosts);

    }

    usersPosts.sort((a,b) {
      Timestamp as = a.timestamp;
      Timestamp bs = b.timestamp;
      var adate = timeago.format(as.toDate());
      var bdate = timeago.format(bs.toDate());
      return bdate.compareTo(adate);
    });

      setState(() {

        isLoading =false;

      });


    /*if(doc.exists) {

    }*/

  }




  buildProfilePosts(context) {
    if (isLoading) {
      return circularProgress();
    }

    /*return Column(

      children:posts,

    );*/

    else if (usersPosts.isEmpty) {
      return Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset("assets/images/no_content.svg", height: 260.0,),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text("No Posts, try to follow users to show posts"
                , style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: RaisedButton.icon( elevation: 4.0,
                  icon: Icon(Icons.group_add) ,
                  color: Theme.of(context).primaryColor,
                  onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => Users_to_follow())),
                  label: Text("Users to follow",style: TextStyle(
                      color: Colors.white, fontSize: 16.0))
              ),

            )
          ],
        ),

      );
    }

    else{

      return Column(

        children:usersPosts,

      );


    }
  }


  /*createUser()async{

    await usersRef.document("gfdy78gjjkkkljklj7").setData({

      "username":"Jeff",
      "postscount":0,
      "isAdmin":false,


    });
  }

    updateUser()async{

      final doc = await usersRef.document("gfdy78gjjkkkljklj7").get();

      if(doc.exists){

        doc.reference.updateData({

        "username":"John",
        "postscount":0,
        "isAdmin":false,


        });

      }


  }


  deleteUser()async{

    final doc = await usersRef.document("gfdy78gjjkkkljklj7").get();

    if(doc.exists){

      doc.reference.delete();

    }

  }

  *//*getUsers() async{

    //final QuerySnapshot query = await usersRef.where("postscount", isGreaterThan: 1).where("isAdmin", isEqualTo: true).getDocuments();
   //final QuerySnapshot query = await usersRef.limit(1).getDocuments();
    final QuerySnapshot query = await usersRef.orderBy("postscount", descending: true).getDocuments();

    setState(() {

      users = query.documents;

    });*//*

   *//* query.documents.forEach((DocumentSnapshot documentSnapshot) {


      //print(documentSnapshot.data);

    });*//*

    *//*usersRef.getDocuments().then((QuerySnapshot snapShot){

      snapShot.documents.forEach((DocumentSnapshot documentSnapshot) {

        print(documentSnapshot.data);

      });

    });

  }*//*

  getUserByID() async{

    final String userid= "OcyjgSH2keaYaPfBtJ90";


    final DocumentSnapshot doc = await usersRef.document(userid).get();

    print(doc.data);
    print(doc.documentID);
    print(doc.exists);

    *//*usersRef.document(userid).get().then((DocumentSnapshot snapShot){


        print(snapShot.data);
        print(snapShot.documentID);
        print(snapShot.exists);


    });*//*




  }*/

  /*@override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isApptitle: true),
      body: StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context,snapshot) {
            if (!snapshot.hasData) {
              return linearProgress();
            }


            else {
              final List<Text> children = snapshot.data.documents.map((doc) {
                return Text(doc['username']);
              }).toList();


              return Container(

                  child: ListView(
                    children: children,

                  )
              );
            }
          }
    )




    );
  }

}*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isApptitle: true),
      body: RefreshIndicator(

        onRefresh: () =>
            getUsersPosts(),
        child: ListView(
          children: <Widget>[
            buildProfilePosts(context),
          ],
        ),
      ),

    );
  }
}