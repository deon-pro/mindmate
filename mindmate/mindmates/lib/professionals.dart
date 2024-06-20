import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindmates/flutter_flow/flutter_flow_theme.dart';
import 'package:mindmates/pages/professionals/view_professional.dart';

class ProfessionalsPage extends StatefulWidget {
  const ProfessionalsPage({super.key});

  @override
  State<ProfessionalsPage> createState() => _ProfessionalsPageState();
}

class _ProfessionalsPageState extends State<ProfessionalsPage> {
  String field1 = 'professional';
  String filter1 = 'professional';
  String field2 = 'codec';
  int filter2 = 101;
  String searchText = '';

  Future<void> showMenuWithFirebaseItems(BuildContext context) async {
    List<PopupMenuItem<int>> menuItems = await fetchMenuItemsFromFirestore();

    final int? selectedValue = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(0, 100, -10, 0),
      elevation: 4,
      items: menuItems,
    );

    if (selectedValue != null) {
      // Handle the selected option based on its value
      final String selectedText =
          (menuItems[selectedValue - 1].child as Text).data!;
      setState(() {
        field1 = 'servicesOffered';
        filter1 = selectedText;
      });
      print('Selected: $selectedText');
      // Add your logic here for the selected item
    }
  }

  Future<List<PopupMenuItem<int>>> fetchMenuItemsFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('mental_health_professionals')
        .get();

    Set<String> uniqueItems = Set(); // Use a set to ensure uniqueness
    List<PopupMenuItem<int>> menuItems = [];

    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((doc) {
        final String itemName = doc['servicesOffered'].toString();
        // Check if the item is not already in the set to avoid duplicates
        if (!uniqueItems.contains(itemName)) {
          menuItems.add(
            PopupMenuItem<int>(
              value: menuItems.length + 1,
              child: Text(itemName),
            ),
          );
          // Add the item to the set to mark it as added
          uniqueItems.add(itemName);
        }
      });
    }

    return menuItems;
  }

  Future<void> showMenuWithFirebaseRate(BuildContext context) async {
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(0, 100, -10, 0),
      elevation: 4,
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Text('Less Than 100'),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text('Less Than 50'),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: Text('Less Than 10'),
        ),
        PopupMenuItem<int>(
          value: 4,
          child: Text('Less Than 5'),
        ),
      ],
    ).then((value) {
      // Handle the selected option (if needed)
      if (value == 1) {
        setState(() {
          field2 = 'rate';
          filter2 = 100;
        });
      } else if (value == 2) {
        setState(() {
          field2 = 'rate';
          filter2 = 50;
        });
      } else if (value == 3) {
        setState(() {
          field2 = 'rate';
          filter2 = 10;
        });
      } else if (value == 4) {
        setState(() {
          field2 = 'rate';
          filter2 = 5;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey, // Set app bar background color to black
        centerTitle: true, //
        title: Text(
          'PROFESSIONAL',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            // fontWeight: FontWeight.bold,
            // color: Color.fromARGB(255, 2, 219, 92)
          ),
        ),
        actions: [
          field1 != 'professional' || field2 != 'codec'
              ? IconButton(
                  onPressed: () {
                    showMenu<int>(
                      context: context,
                      position: RelativeRect.fromLTRB(0, 100, -10, 0),
                      elevation: 4,
                      items: [
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ],
                    ).then((value) {
                      // Handle the selected option (if needed)
                      if (value == 1) {
                        setState(() {
                          field1 = 'professional';
                          filter1 = 'professional';
                          field2 = 'codec';
                          filter2 = 101;
                        });
                      }
                    });
                  },
                  icon: Icon(Icons.more_vert_outlined))
              : Container()
        ],
      ),
       body: Container(
        color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground, // Set the background color to black
        child: SingleChildScrollView(
          child: Column(
            children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              width: MediaQuery.of(context).size.width * .98,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 36,
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    // width: MediaQuery.of(context).size.width * 7,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).search,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 26,
                            color: Theme.of(context).shadowColor,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .72,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextFormField(
                              // controller: _email,

                              onChanged: (value) {
                                setState(() {
                                  searchText = value
                                      .toLowerCase(); // Update the searchText on text changes
                                });
                              },

                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'search...',
                                hintStyle: const TextStyle(
                                    //  color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 63, 62, 62)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showMenu<int>(
                        context: context,
                        position: RelativeRect.fromLTRB(0, 100, -10, 0),
                        elevation: 4,
                        items: [
                          PopupMenuItem<int>(
                            value: 1,
                            child: Text('Service'),
                          ),
                          PopupMenuItem<int>(
                            value: 2,
                            child: Text('Rate'),
                          ),
                        ],
                      ).then((value) {
                        // Handle the selected option (if needed)
                        if (value == 1) {
                          showMenuWithFirebaseItems(context);
                        } else if (value == 2) {
                          showMenuWithFirebaseRate(context);
                        }
                      });
                    },
                    child: Container(
                      child: Icon(Icons.filter_list),
                    ),
                  )
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mental_health_professionals')
                    .where(field1, isEqualTo: filter1)
                    .where(field2, isLessThanOrEqualTo: filter2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          alignment: Alignment.topCenter,
                          child: const Text('..')),
                    );
                  }
                  if (snapshot.error != null) {
                    return Center(
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: const Text('Error loading posts...')),
                    );
                  }

                  List<ProfessionalData> professionalDataAll =
                      snapshot.data!.docs.map((doc) {
                    return ProfessionalData(
                      about: doc['aboutMe'],
                      education: doc['education'],
                      email: doc['email'],
                      name: doc['name'],
                      phone: doc['phone'],
                      license: doc['license'],
                      docid: doc['id'],
                      profile: doc['profileImageUrl'] ??
                          '', // Use an empty string as a default
                      service: doc['servicesOffered'],
                      rate: doc['rate'],
                    );
                  }).toList();

                  // Filter followers based on search text
                  final List<ProfessionalData> professionalData =
                      professionalDataAll.where((follower) {
                    final username = follower.name.toLowerCase();
                    final searchQuery = searchText.toLowerCase();
                    return username.contains(searchQuery);
                  }).toList();

                  return Column(
                    children: [
                      ListView.builder(
                        itemCount: professionalData.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          String profilePic = professionalData[index].profile;
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ViewProfesional(
                                        data: professionalData[index],
                                      )));
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(14, 10, 10, 10),
                                  height: 100,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 14, 0),
                                        child: CircleAvatar(
                                          radius: 34,
                                          foregroundImage: profilePic.isNotEmpty
                                              ? NetworkImage(profilePic)
                                              : null,
                                          child: const Icon(Icons.person),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(professionalData[index].name),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            professionalData[index].service,
                                            style: TextStyle(
                                                fontSize: 12,
                                                // fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 2, 219, 92)),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            'Hourly rate: \$${professionalData[index].rate.toString()} ',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 151, 2, 219)),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: .6,
                                  color:
                                      const Color.fromARGB(255, 112, 112, 112),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
       ),
    );
  }
}

class ProfessionalData {
  String about;
  String docid;
  String education;
  String email;
  String name;
  String phone;
  String license;
  String profile;
  String service;
  int rate;

  ProfessionalData({
    required this.about,
    required this.rate,
    required this.docid,
    required this.education,
    required this.email,
    required this.name,
    required this.phone,
    required this.license,
    required this.profile,
    required this.service,
  });

  get aboutMe => null;
}
