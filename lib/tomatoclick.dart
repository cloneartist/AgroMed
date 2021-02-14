import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

class TomatoDiseaseDetection extends StatefulWidget {
  @override
  _DiseaseDetectionState createState() => _DiseaseDetectionState();
}

class _DiseaseDetectionState extends State<TomatoDiseaseDetection> {
  List _outputs;
  File _image;
  bool _loading = false;
  int _selectedIndex = 1;

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/tomato_trained.tflite",
      labels: "assets/tomato_trained.txt",
      numThreads: 1,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      captureImage();
    } else if (index == 2) {
      pickImage();
    } else if (index == 1) {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  captureImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Tomato",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          //elevation: 0,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.image),
              label: 'Gallery',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loading
                    ? Container(
                        height: 300,
                        width: 300,
                      )
                    : Container(
                        margin: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _image == null
                                ? Container()
                                : Image.file(
                                    _image,
                                    // scale: 3,
                                  ),
                            SizedBox(
                              height: 20,
                            ),
                            _image == null
                                ? Container()
                                : _outputs != null
                                    ? Column(
                                        children: [
                                          Text(
                                            _outputs[0]["label"],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          ),
                                          //_outputs[0]["label"]=="2 banana_black_sigatoka"Text('Good')?null:
                                          Text(_outputs[0]["label"] ==
                                                  "0 tomato_early_blight"
                                              ? "\nBiological Control: BACILLUS SUBTILS or Copper-based FUNGICIDES\n\nChemical Control: CYMOXANIL 8.0% WP, MANCOZEB 64.0% WP\n"
                                              : _outputs[0]["label"] ==
                                                      "1 tomato_late_blight"
                                                  ? "\nBiological Control: NO BIOLOGICAL CONTROL\n\nChemical Control: MANDIPROPAMID 23.4% SC, CYMOXANIL 8.0% WP, MANCOZEB 64.0% WP, AZOXYSTROBIN 23.0% SC\n"
                                                  : _outputs[0]["label"] ==
                                                          "2 tomato_healthy"
                                                      ? " "
                                                      : _outputs[0]["label"] ==
                                                              "3 tomato_mosaic_virus"
                                                          ? "\nBiological Control: Dry Heating seed at 70 degree Celcius\n\nChemical Control: Consider INTEGRATED APPROACH with preventive measures \n"
                                                          : "")
                                        ],
                                      )
                                    : Container(child: Text("")),
                            FlatButton(
                                color: Colors.green[300],
                                textColor: Colors.white,
                                disabledColor: Colors.grey,
                                disabledTextColor: Colors.black,
                                padding: EdgeInsets.fromLTRB(73, 20, 73, 20),
                                splashColor: Colors.greenAccent,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/fertcalctomato');
                                },
                                child: Text('Fertilizer Calculator')),
                            Container(
                              height: 3,
                            ),
                            FlatButton(
                                color: Colors.green[300],
                                textColor: Colors.white,
                                disabledColor: Colors.grey,
                                disabledTextColor: Colors.black,
                                padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                                splashColor: Colors.greenAccent,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/sentmail');
                                },
                                child: Text('''Couldn't Find Your Answer!''')),
                            Container(
                              height: 3,
                            ),
                            FlatButton(
                                color: Colors.green[300],
                                textColor: Colors.white,
                                disabledColor: Colors.grey,
                                disabledTextColor: Colors.black,
                                padding: EdgeInsets.fromLTRB(60, 20, 60, 20),
                                splashColor: Colors.greenAccent,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/location');
                                },
                                child: Text('Fertilizer Store Location'))
                          ],
                        ),
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
