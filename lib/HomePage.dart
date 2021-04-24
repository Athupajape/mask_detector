import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "dart:io";
import "package:tflite/tflite.dart";
import "package:image_picker/image_picker.dart";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool loading=false;
  File _image;
  List _result;
  final picker=ImagePicker();
  var img="assets/mask.svg";

  pickImage()async{
    var pickedimg=await picker.getImage(source: ImageSource.camera);
    if(pickedimg==null){
      return null;
    }
    setState(() {
      _image=File(pickedimg.path);
    });

    detectImage(_image);
  }

  pickImageFromGallery()async{
    var pickedimg=await picker.getImage(source: ImageSource.gallery);
    if(pickedimg==null){
      return null; 
    }
    setState(() {
      _image=File(pickedimg.path);
    });

    detectImage(_image);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading=true;
    loadModel();
  }

  detectImage(File image)async{
    var result=await Tflite.runModelOnImage(path:image.path,numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      loading=false;
      _result=result;
    });   
    print(_result); 
  }

  loadModel()async{
    await Tflite.loadModel(model: "assets/model_unquant.tflite",
  labels: "assets/labels.txt");
  }

  @override 
  void dispose() {
    Tflite.close();
    // TODO: implement dispose
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mask detector"),
      backgroundColor: Colors.blue,
    ),
    body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loading ? Container(
                height: 300,
                width: 250,
                child: SvgPicture.asset(img),
              ) : Container(
               child:Column(
                 mainAxisAlignment: MainAxisAlignment.center,

                 children: [
                   Container(
                     height: 300,
                     child:Image.file(_image)
                   ),
                   SizedBox(height:20),
                   _result!=null ? Container(
                     child: Text("${_result[0]['label']}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                     ,
                   ) : Container()
                 ],
               )
              ),
              SizedBox(height:40),
              Row( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                GestureDetector(
                  onTap: pickImage,
                  child:Container(
                    width: MediaQuery.of(context).size.width - 260,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("Pick a Image",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        margin: EdgeInsets.only(right:10),
                  )
                  

                ),
                
                GestureDetector(
                  onTap:pickImageFromGallery,
                  child:Container(
                    width: MediaQuery.of(context).size.width - 200,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("Pick a Image from Gallery",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                  )
                )
              ],)
            ],
            
          ),
        ),
      ),
    );
  }
}