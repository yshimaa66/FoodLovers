import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfluttershare/models/user.dart';
import 'package:flutterfluttershare/pages/activity_feed.dart';
import 'package:flutterfluttershare/pages/comments.dart';
import 'package:flutterfluttershare/pages/home.dart';
import 'package:flutterfluttershare/widgets/custom_image.dart';
import 'package:flutterfluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final dynamic mediaUrl;
  final Timestamp timestamp;
  final dynamic likes;

  Post({this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.timestamp,this.likes});



  factory Post.fromDocument(DocumentSnapshot doc)
  {
    return Post(

      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'],
      likes: doc['likes'],

    );
  }

  int getCountLikes(likes){

    if(likes==null){
      return 0;
    }

    int count =0;

    likes.values.forEach((val){
      if(val == true){
        count +=1;
      }
    });

    return count;
  }

  @override
  _PostState createState() => _PostState(

    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    timestamp:this.timestamp,
    likeCount: this.getCountLikes(this.likes),


  );


}


class _PostState extends State<Post> {


  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  Timestamp timestamp;
  final String description;
  final dynamic mediaUrl;
  bool showHeart = false;
  int likeCount;
  Map likes;
  bool _isLiked;

  int i =0;

  _PostState({this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.likes,this.likeCount, this.timestamp});




  handleDeletePost(BuildContext context){

  return showDialog(context: context,

  builder:(context){

    return SimpleDialog( title: Text("Remove this post ?"),

      children: <Widget>[

        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            deletePost();
          },
          child: Text("Delete", style: TextStyle(color: Colors.red),),

        ),

        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),

        ),
      ],

    ) ;


  }



  );


  }


  deletePost() async{

    postsRef.document(ownerId).collection("userPosts")
        .document(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    storageRef.child("post_$postId.jpg").delete();

    QuerySnapshot activityFeedsnapshot = await activityFeedRef.document(ownerId).collection("feedItems")
        .where('postId', isEqualTo: postId).getDocuments();

    activityFeedsnapshot.documents.forEach((doc) {

      if(doc.exists){

        doc.reference.delete();

      }

    });


    QuerySnapshot commentsnapshot = await commentsRef.document(postId).collection("comments")
        .getDocuments();

    commentsnapshot.documents.forEach((doc) {

      if(doc.exists){

        doc.reference.delete();

      }

    });
  }


  builderPostHeader(){

    return FutureBuilder(

      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot){

         if(!snapshot.hasData){
           return circularProgress();
         }
         User user = User.fromDocument(snapshot.data);
         bool isOwnerPost = currentUser.id == ownerId;
         return ListTile(

           leading: GestureDetector(
             onTap: () => showProfile(context, profileId: user.id),
             child: CircleAvatar(
               backgroundImage: CachedNetworkImageProvider(user.photoUrl),
               backgroundColor: Colors.grey,
             ),
           ),
           title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
             child: Text(
               user.username,
               style: TextStyle(
                 color: Colors.black,
                 fontWeight: FontWeight.bold,
               ),
             ),

           ),

           subtitle:
               Text(location),
           trailing: isOwnerPost ? IconButton(
             onPressed: () => handleDeletePost(context),
             icon:  Icon(Icons.more_vert),
           ): Text(""),
         );

      },

    );

  }



  handleLikePost(){


   bool _isLiked = likes[currentUserId] == true;

   if(_isLiked){


     postsRef.document(ownerId).collection("userPosts")
         .document(postId).updateData({'likes.$currentUserId':false});

     removeLikeFromActivityFeed();

     setState(() {

       likeCount-=1;
       _isLiked=false;
       likes[currentUserId] = false;

     });

   }


   else if(!_isLiked){


     postsRef.document(ownerId).collection("userPosts")
         .document(postId).updateData({'likes.$currentUserId':true});

     addLikeToActivityFeed();

     setState(() {

       likeCount+=1;
       _isLiked=true;
       likes[currentUserId] = true;

       showHeart =true;
     });

     Timer(Duration(milliseconds:500),(){

       setState(() {
         showHeart =false;
       });

     });

   }

  }




  addLikeToActivityFeed(){

    bool isNotPostOwner = currentUserId != ownerId;

    if(isNotPostOwner) {
      activityFeedRef.document(ownerId)
          .collection("feedItems").document(postId)
          .setData({

        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,

      });
    }
  }



  removeLikeFromActivityFeed(){

    bool isNotPostOwner = currentUserId != ownerId;

    if(isNotPostOwner) {
      activityFeedRef.document(ownerId)
          .collection("feedItems").document(postId)
          .get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }

  }


  builderPostImage(int i){

    return Container(
      child: GestureDetector(
        onDoubleTap: handleLikePost,

        child: Stack(

          alignment: Alignment.center,
          children: <Widget>[
            /*SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: mediaUrl.map((e) => cachedNetworkImage(e)).toList(),
                )
            ),*/

            cachedNetworkImage(mediaUrl[i]),
          showHeart ? Animator(
            tween: Tween(begin: 0.8, end: 1.4),
            curve: Curves.elasticOut,
            cycles: 0,
            builder: (context, animatorState, child ) => Center(
                child: Icon(
                  Icons.favorite,
                  size: 80.0,
                  color: Colors.red,
                )
            ),):Text(""),


             /*showHeart ? Animator(
              duration: Duration(milliseconds: 300),
              tween: Tween(begin: 0.8, end: 1.4),
              curve: Curves.elasticOut,
              cycles: 0,
              builder: (anim) => Transform.scale(
                  scale: anim.value,
                  child: Icon(
                    Icons.favorite,
                    size: 80.0,
                    color: Colors.red,
                  )
              ),
            )
                : Text(""),*/
            /*showHeart ? Icon(

              Icons.favorite,
              size: 80.0,
              color: Colors.red,

            ):
                Text(""),*/

          ],

        )

      ),
    );

  }



  showComments(BuildContext context, {String postId, String ownerId, String mediaUrl}){


     Navigator.push(context, MaterialPageRoute(builder: (context){

       return Comments(
         postId : postId ,
         postownerId : ownerId ,
         postmediaUrl : mediaUrl ,
       );

     }));


  }



  builderPostFooter(){

    return Column(
      children: <Widget>[


        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:40.0,left: 20.0), ),
              GestureDetector(
                onTap: handleLikePost,
                child: Icon(
                  _isLiked ? Icons.favorite :Icons.favorite_border,
                  size: 28.0,
                  color: Colors.pink,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:40.0,left: 20.0),),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId : postId ,
                ownerId : ownerId ,
                mediaUrl : mediaUrl[0] ,
                ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),

        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
                child: Text("$likeCount likes"
                ,style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,

                  ),)
            ),
          ],
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text("$username"
                  ,style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,

                  ),)
            ),

            Expanded(child:Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("  $description"),
            )),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:5.0,left: 20.0),
              child: Text(timeago.format(timestamp.toDate())
              ,style: TextStyle(fontSize: 12.0, color: Colors.black45),),
            ),
          ],
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {

     //bool isloading = false;
    _isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        builderPostHeader(),
        Stack(
          children: <Widget>[

            builderPostImage(i),

            IconButton(
              icon: Icon(Icons.swap_horizontal_circle,color: Colors.white ,size: 40.0,),
              onPressed: (){
                if(i==mediaUrl.length-1){
                  setState(() {
                    i=0;
                  });
                }else{
                  setState(() {
                    i++;
                  });

                }

              },
            ),
          ],
        ),

        builderPostFooter(),

      ],
    );
  }
}
