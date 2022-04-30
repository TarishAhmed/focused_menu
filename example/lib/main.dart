import 'package:example/ScreenTwo.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focused Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentPage = FocusedMenuPages.first;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Music Albums",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Center()),
                  IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
                  CircleAvatar(
                    child: Image.asset("assets/images/dp_default.png"),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Look for your Interest!",
                    fillColor: Colors.grey.shade200,
                    filled: true),
              ),
              SizedBox(
                height: 10,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     DropdownButton(
              //         style: TextStyle(fontSize: 15, color: Colors.black),
              //         icon: Icon(Icons.keyboard_arrow_down),
              //         underline: Container(
              //           color: Colors.white,
              //         ),
              //         items: ["Featured", "Most Rated", "Recent", "Popular"].map<DropdownMenuItem>((e) => DropdownMenuItem(child: Text(e))).toList(),
              //         onChanged: (newItem) {}),
              //     IconButton(icon: Icon(Icons.sort), onPressed: () {})
              //   ],
              // ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: GridView(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                      .map((e) => FocusedMenuHolder(
                            menuWidth: MediaQuery.of(context).size.width * 0.50,
                            blurSize: 5.0,
                            menuItemExtent: 45,
                            menuBoxDecoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            duration: Duration(milliseconds: 100),
                            animateMenuItems: true,
                            blurBackgroundColor: Colors.black54,
                            bottomOffsetHeight: 100,
                            jumpToPage: currentPage,
                            menuItems: Text('hello'),
                            onPressed: (){},
                            child: Card(
                              child: Column(
                                children: <Widget>[
                                  Image.asset("assets/images/image_$e.jpg"),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        )),
        bottomNavigationBar:
            BottomNavigationBar(items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Menu 2"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Menu 3"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Menu 4"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Menu 5"),
        ]),
      ),
    );
  }
}
