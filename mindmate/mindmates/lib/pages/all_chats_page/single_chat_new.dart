

// import 'package:flutter/material.dart';
// import 'package:mindmates/flutter_flow/chat/index.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class FFChatPreview extends StatelessWidget {
//   const FFChatPreview({
   
//   }) : super(key: key);


//   @override
//   Widget build(BuildContext context) {
//     final chatTitle = title.isNotEmpty ? title : '';
//     return StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection('chats')
//                           .where('users', arrayContains: userId)
//                           .orderBy('timestamp', descending: true)
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                           return Center(
//                             child: Container(
//                                 padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
//                                 child: const Text('No chats. Start a chat.')),
//                           );
//                         }
//                         if (snapshot.error != null) {
//                           return Center(
//                             child: Container(
//                                 padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
//                                 child: const Text('Error loading chats...')),
//                           );
//                         }
//                            if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 // Handle loading state
//                                 return const Center();
//                               }

//                         List<Chats> chats = snapshot.data!.docs.map((doc) {
//                           return Chats(
//                             id: doc['chatId'],
//                             seen: doc['seen'],
//                             time: doc['timestamp'],
//                             message: doc['lastmessage'],
//                             users: doc['users'],
//                             receiver: doc['receiverId'],
//                             senderId: doc['senderId'],

//                             // Add other properties as needed
//                           );
//                         }).toList();

//         return InkWell(
//           onTap: onTap,
//           child: Column(
//             children: [
//               ClipRRect(
//                 borderRadius: borderRadius,
//                 child: ListTile(
//                   tileColor: color,
//                   contentPadding: contentPadding,
//                   leading: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Padding(
//                         padding:
//                             const EdgeInsetsDirectional.only(start: 0.0, end: 8.0),
//                         child: Container(
//                           width: 12.0,
//                           height: 12.0,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: seen ? Colors.transparent : unreadColor,
//                           ),
//                         ),
//                       ),
//                       AvatarContainer(
//                         user: ChatUser(avatar: userProfilePic),
//                         avatarMaxSize: 30.0,
//                         constraints: BoxConstraints(
//                           maxHeight: 420.0,
//                           maxWidth: 420.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                   title: Padding(
//                     padding: const EdgeInsets.only(top: 2.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           // width: MediaQuery.of(context).size.width * .7,
//                           child: Row(
//                             // mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                  width: MediaQuery.of(context).size.width * .55,
//                                 child: Text(chatTitle,
//                                 // overflow: TextOverflow.ellipsis,
//                                  style: titleTextStyle)),
//                               // isProfessional
//                               //     ? Icon(
//                               //         Icons.verified,
//                               //         color: Color(0xFF12CCEE),
//                               //       )
//                               //     : Container(),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           formattedDate(lastChatTime),
//                           style: dateTextStyle,
//                         ),
//                       ],
//                     ),
//                   ),
//                   subtitle: Text(
//                     lastChatText,
//                     style: previewTextStyle,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     size: 18,
//                     color: previewTextStyle.color,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 2.0),
//             ],
//           ),
//         );
//       }
//     );
//   }
// }

// String formattedDate(DateTime? dateTime) {
//   if (dateTime == null) {
//     return 'Unknown';
//   }
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   final yesterday = DateTime(now.year, now.month, now.day - 1);
//   final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
//   if (dateTime.isAfter(now.subtract(const Duration(minutes: 1)))) {
//     return timeago.format(dateTime);
//   }
//   if (today == day) {
//     return DateFormat.jm().format(dateTime);
//   }
//   if (yesterday == day) {
//     return 'Yesterday';
//   }
//   return DateFormat.MMMd().format(dateTime);
// }




// class Chats {
//   String id;
//   bool seen;
//   String message;
//   Timestamp time;
//   List users;
//   String receiver;
//   String senderId;

//   Chats({
//     required this.id,
//     required this.seen,
//     required this.message,
//     required this.time,
//     required this.users,
//     required this.receiver,
//     required this.senderId,
//   });
// }
