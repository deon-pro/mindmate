import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';

import 'index.dart';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class FFChatPreview extends StatelessWidget {
  const FFChatPreview({
    Key? key,
    required this.lastChatText,
    required this.lastChatTime,
    required this.seen,
    required this.isSender,
    required this.seenState,
    required this.title,
    required this.userProfilePic,
    required this.onTap,
    required this.isProfessional,
    // Theme settings
    required this.color,
    required this.unreadColor,
    required this.titleTextStyle,
    required this.dateTextStyle,
    required this.previewTextStyle,
    this.contentPadding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    // required this.userid,
  }) : super(key: key);

  final String lastChatText;
  final DateTime? lastChatTime;
  final bool seen;
  final bool isSender;
  final bool seenState;
  final String title;
  final String userProfilePic;
  final Function() onTap;
  final bool isProfessional;
  // final userid;

  final Color color;
  final Color unreadColor;
  final TextStyle titleTextStyle;
  final TextStyle dateTextStyle;
  final TextStyle previewTextStyle;
  final EdgeInsetsGeometry contentPadding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final chatTitle = title.isNotEmpty ? title : '';
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: ListTile(
              tileColor: color,
              contentPadding: contentPadding,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 0.0, end: 8.0),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSender
                            ? Colors.transparent
                            : seen
                                ? Colors.transparent
                                : unreadColor,
                      ),
                    ),
                  ),
                  AvatarContainer(
                    user: ChatUser(avatar: userProfilePic),
                    avatarMaxSize: 30.0,
                    constraints: BoxConstraints(
                      maxHeight: 420.0,
                      maxWidth: 420.0,
                    ),
                  ),
                ],
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      // width: MediaQuery.of(context).size.width * .7,
                      child: Row(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              // width: MediaQuery.of(context).size.width * .55,
                              child: Text(chatTitle,
                                  // overflow: TextOverflow.ellipsis,
                                  style: titleTextStyle)),
                          isProfessional
                              ? Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      6.0, 0.0, 0.0, 0.0),
                                  child: Icon(
                                    Icons.verified,
                                    color: Color(0xFF12CCEE),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          formattedDate(lastChatTime),
                          style: dateTextStyle,
                        ),
                        !isSender
                            ? Container()
                            : seenState
                                ? Icon(
                                    Icons.check,
                                    //  color: Color(0xFF12CCEE),
                                    color: FlutterFlowTheme.of(context).primary,
                                  )
                                : Icon(
                                    Icons.check,
                                    //  color: Color(0xFF12CCEE),
                                    color: Color.fromARGB(255, 196, 196, 196),
                                  ),
                      ],
                    ),
                  ],
                ),
              ),
              subtitle: lastChatText != ''
                  ? lastChatText != 'mindmate*144#V16k//C.2023'
                      ? Text(
                          lastChatText,
                          style: previewTextStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'Message deleted',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                              fontWeight: FontWeight.w300),
                        )
                  : Text(
                      'Sent a photo',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: previewTextStyle.color,
              ),
            ),
          ),
          const SizedBox(height: 2.0),
        ],
      ),
    );
  }
}

String formattedDate(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Unknown';
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
  if (dateTime.isAfter(now.subtract(const Duration(minutes: 1)))) {
    return timeago.format(dateTime);
  }
  if (today == day) {
    return DateFormat.jm().format(dateTime);
  }
  if (yesterday == day) {
    return 'Yesterday';
  }
  return DateFormat.MMMd().format(dateTime);
}
