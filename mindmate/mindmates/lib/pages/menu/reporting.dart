
import 'package:flutter/material.dart';
import 'package:mindmates/pages/menu/post_reporting.dart';
import 'package:mindmates/pages/menu/reporting_user.dart';

class GeneralReportingWidget extends StatelessWidget {
  final reporteeId;
  final postId;
  final username;
  const GeneralReportingWidget(
      {super.key, this.reporteeId, this.postId, this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height *.44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 16,
            color: Color.fromARGB(31, 26, 25, 25),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              // height: 70,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              width: MediaQuery.of(context).size.width * .88,
              child: Text(
                  'Do you really want to report a the user, account, post or comment. Your views remain confidential.',
                  style: TextStyle(
                    fontSize: 12,
                  )),
            ),
          ),
          Container(
            height: 1,
            color: Color.fromARGB(31, 82, 82, 82),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostAndDataReporting(
                        reporteeId: reporteeId,
                        postId: postId,
                      )));
            },
            child: Container(
              height: 60,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              width: MediaQuery.of(context).size.width * .88,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report post, message or comment.',
                      style: TextStyle(
                        fontSize: 12,
                      )),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Theme.of(context).shadowColor,
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Color.fromARGB(31, 82, 82, 82),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UserReporting(
                        reporteeId: reporteeId,
                        username: username,
                      )));
            },
            child: Container(
              height: 60,
              
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              width: MediaQuery.of(context).size.width * .88,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report user.',
                      style: TextStyle(
                        fontSize: 12,
                      )),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Theme.of(context).shadowColor,
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Color.fromARGB(31, 82, 82, 82),
          ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
