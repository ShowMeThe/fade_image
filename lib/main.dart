import 'package:fade_image/widget/fade_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: 0.0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.0),
          controller: _controller,
          itemCount: list.length,
          itemBuilder: (context, index) => buildItem(index)),
    );
  }

  Widget buildItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: buildNetImage(list[index])),
    );
  }

  Widget buildAssetImage(String url) {
    return FadeImage.asset(
      url,
      duration: 350,
      imageWidth: 300,
      imageHeight: 300,
    );
  }

  Widget buildNetImage(String url) {
    return FadeImage.network(
      url,
      duration: 350,
      imageWidth: 300,
      imageHeight: 300,
    );
  }
}
