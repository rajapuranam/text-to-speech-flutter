import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File selectedImage;
  String imageText = '';
  bool isImage = false;
  bool isExtract = false;

  Future pickImage(String sourceOfImage) async {
    var img = sourceOfImage == "camera"
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null)
      setState(() {
        selectedImage = img;
        isImage = true;
        imageText = '';
        isExtract = false;
      });
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
      isImage = false;
      isExtract = false;
      imageText = '';
    });
  }

  Future readText() async {
    if (!isExtract) {
      FirebaseVisionImage ourImage =
          FirebaseVisionImage.fromFile(selectedImage);
      TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
      VisionText readText = await recognizeText.processImage(ourImage);

      for (TextBlock block in readText.blocks) {
        for (TextLine line in block.lines) {
          imageText += line.text + " ";
        }
        imageText += "\n";
      }

      setState(() {
        isExtract = true;
      });
    }
  }

  Future chooseDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250.0,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () {
                          pickImage("camera");
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Use Camera",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: 250.0,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () {
                          pickImage("gallery");
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Import from Gallery",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Text Recognition App"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: isImage
                      ? Card(
                          child: Container(
                            height: 250.0,
                            width: 250.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              image: DecorationImage(
                                image: FileImage(selectedImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 250.0,
                          width: 250.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue[400],
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Center(
                            child: Text(
                              "No Image selected!!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    elevation: 5.0,
                    color: Colors.blue[500],
                    child: Text(
                      'Select image',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[100],
                      ),
                    ),
                    onPressed: chooseDialog,
                  ),
                  RaisedButton(
                    elevation: 5.0,
                    color: Colors.blue[500],
                    child: Text(
                      'Remove image',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[100],
                      ),
                    ),
                    onPressed: isImage ? removeImage : null,
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                elevation: 5.0,
                color: Colors.blue[500],
                child: Text(
                  'Extract Text',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[100],
                  ),
                ),
                onPressed: isImage ? readText : null,
              ),
              SizedBox(height: 15.0),
              Center(
                child: isExtract
                    ? Text(
                        "$imageText",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : Text(
                        "Text will be displayed here..",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
