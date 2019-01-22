import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text(
          'Canvas Rotation',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      body: MyCanvas(),
    ),
  ));
}

class MyCanvas extends StatefulWidget {
  @override
  _MyCanvasState createState() {
    return _MyCanvasState();
  }
}

class _MyCanvasState extends State<MyCanvas> {
  ui.Image _originalImage;
  ui.Image _displayImage;
  double _rotateAngle = 0.0;
  final double increment = pi / 18; // 10 degrees
  final String imagePath = 'images/Lotus.jpg';

  @override
  void initState() {
    super.initState();
    loadImage(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scale = screenSize.width / _originalImage.width;
    return Column(
      children: <Widget>[
        SizedBox(
          child: CustomPaint(
            painter: MyPainter(image: _displayImage, scale: scale),
            size:
                Size(_displayImage.width * scale, _displayImage.height * scale),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.rotate_left),
              onPressed: () {
                rotateImage(angle: -increment);
              },
            ),
            IconButton(
              icon: Icon(Icons.rotate_right),
              onPressed: () {
                rotateImage(angle: increment);
              },
            ),
          ],
        ),
      ],
    );
  }

  void loadImage(String filePath) async {
    ui.Image image = await imageFromFilePath(filePath);
    _originalImage = image;
    setState(() {
      _displayImage = image;
    });
  }

  void rotateImage({double angle}) {
    _rotateAngle += angle;
    ui.Image image = rotatedImage(image: _originalImage, angle: _rotateAngle);
    setState(() {
      _displayImage = image;
    });
  }
}

class MyPainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  MyPainter({this.image, this.scale});

  @override
  void paint(Canvas canvas, Size size) async {
    canvas.scale(scale);
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

Future<ui.Image> imageFromFilePath(String filePath) async {
  var byteData = await rootBundle.load(filePath);
  Uint8List lst = Uint8List.view(byteData.buffer);
  var codec = await ui.instantiateImageCodec(lst);
  var nextFrame = await codec.getNextFrame();
  return nextFrame.image;
}

ui.Image rotatedImage({ui.Image image, double angle}) {
  var pictureRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);

  final double r =
      sqrt(image.width * image.width + image.height * image.height) / 2;
  final alpha = atan(image.height / image.width);
  final gama = alpha + angle;
  final shiftY = r * sin(gama);
  final shiftX = r * cos(gama);
  final translateX = image.width / 2 - shiftX;
  final translateY = image.height / 2 - shiftY;
  canvas.translate(translateX, translateY);
  canvas.rotate(angle);
  canvas.drawImage(image, Offset.zero, Paint());

  return pictureRecorder.endRecording().toImage(image.width, image.height);
}
