import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfluttershare/models/user.dart';
import 'package:flutterfluttershare/pages/create_account.dart';
import 'package:flutterfluttershare/pages/profile.dart';
import 'package:flutterfluttershare/pages/search.dart';
import 'package:flutterfluttershare/pages/timeline.dart';
import 'package:flutterfluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'activity_feed.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');

final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();

}



class _HomeState extends State<Home> {

  bool isAuth= false;

  PageController pageController;


  int pageIndex =0;

  @override
  void initState(){

   super.initState();

   pageController = PageController();

   googleSignIn.onCurrentUserChanged.listen((account){

     //account != null ? isAuth = true: isAuth =false;

     handleSignIn(account);


   }, onError: (err){

     print("Error signing in: $err");

   });

   googleSignIn.signInSilently(suppressErrors: false).then((account){

     handleSignIn(account);

   }).catchError((err){

     print("Error signing in: $err");
   });

  }

  @override
  void dispose(){

    pageController.dispose();
    super.dispose();


  }

  login(){

    setState(() {
      googleSignIn.signIn();
      buildAuthScreen();

    });


  }

  logout(){


      setState(() {
        googleSignIn.signOut();
        buildAuthScreen();

      });
    }


  onPageChanged(int pageIndex){

    setState(() {

      this.pageIndex=pageIndex;

    });

  }

  /*onTap(int pageIndex){

    pageController.jumpToPage(pageIndex,);

  }*/

  onTap(int pageIndex){

    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceInOut);

  }

  handleSignIn(GoogleSignInAccount account) async {

    if(account !=null){

      await createUserInFirestore();

      print('User signed in ! : $account');

      setState(() {

        isAuth = true;
        buildAuthScreen();

      });

    }else{

      setState(() {
        isAuth = false;
        buildUnAuthScreen();
      });
    }


  }



  createUserInFirestore() async{


    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if(!doc.exists){

      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));

      usersRef.document(user.id).setData({

        "id":user.id,
         "username":username,
        "photoUrl":user.photoUrl,
        "email":user.email,
        "displayName":user.displayName,
        "bio":"",
         "timestamp" : timestamp,

      });

      doc = await usersRef.document(user.id).get();


    }

    currentUser = User.fromDocument(doc);

    print(currentUser);
    print(currentUser.username);


  }

  /*Widget buildAuthScreen(){

    return RaisedButton(child: Text("Logout"), onPressed: logout);

  }*/


  Scaffold buildAuthScreen(){

    return Scaffold(

      body: PageView(
        children: <Widget>[
          //Timeline(),
          //RaisedButton(child: Text("Logout"), onPressed: logout),
          Timeline(),
          ActivityFeed(),
          Upload(currentUser : currentUser),
          Search(),
          Profile(profileId : currentUser.id),

        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),

      ),

      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [

          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size:35.0)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),



        ],

      ),

    );

  }

  Widget buildUnAuthScreen(){

    return Scaffold(

      body:  Container(

        decoration: BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [

              /*Colors.teal,
              Colors.purple,*/

              Theme.of(context).accentColor.withOpacity(.2),
              Theme.of(context).primaryColor,

            ]


          )

        ),

        alignment: Alignment.center,

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[

            //Image(image: AssetImage('assets/images/food.png')),

            SvgPicture.asset("assets/images/food.svg", height: 260.0,),


             Text(

               "FOOD LOVERS", style: TextStyle(fontFamily: "Signatra", fontSize: 90.0,color: Colors.white),

             ),

            GestureDetector(

              onTap: login,

              child: Container(
                width: 260 ,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover
                  )


                ),
              ),

            )


          ],


        ),
      ),


    );

  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen() ;
  }
}
