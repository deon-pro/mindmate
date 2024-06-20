import 'package:flutter/material.dart';

class ViewPet extends StatelessWidget {
  final image;
  final name;
  final breed;
  final age;
  const ViewPet({super.key, required this.image, required this.name, required this.breed, required this.age});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
              alignment: Alignment.centerLeft,
              child: Text(name),
            ),
            Container(
                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Image.network(
                image,
                fit: BoxFit.fitWidth,
              ),
            ),
            Container(
                 padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
              child: Column(
                children: [
                  Row(
                    children: [Text('Breed: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),), Text(breed)],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [Text('Age: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                    ), Text(age)],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
