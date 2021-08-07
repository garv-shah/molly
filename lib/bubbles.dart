import 'dart:math';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:characters/characters.dart';

class Bubbles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BubblesState();
  }
}


BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(
        width: 3.0,
        color: Colors.black54,
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(30.0) //                 <--- border radius here
    ),
    color: Color.fromRGBO(255, 250, 148, 0.7),
  );
}

class _BubblesState extends State<Bubbles> with SingleTickerProviderStateMixin {

  var _mFacts;

  Future<dynamic> getData() async {

    final DocumentReference document =   Firestore.instance.collection("molly").document('Facts');

    await document.get().then<dynamic>(( DocumentSnapshot snapshot) async{
      setState(() {
        _mFacts = snapshot.data['mFacts'];
        print(_mFacts);
      });
    });
  }


  var _random = 'Click the button to find out a bit more about Molly!';

  void incrementCounter() {
    setState(() {
      Random random = new Random();
      _random = _mFacts[random.nextInt(_mFacts.length)];
    });
  }

  AnimationController _controller;
  List<Bubble> bubbles;
  final int numberOfBubbles = 200;
  final Color color = Colors.amber[200];
  final double maxBubbleSize = 10.0;
  final bool applyElevationOverlayColor = true;

  @override
  void initState() {
    super.initState();
    getData();

    // Initialize bubbles
    bubbles = List();
    int i = numberOfBubbles;
    while (i > 0) {
      bubbles.add(Bubble(color, maxBubbleSize));
      i--;
    }

    // Init animation controller
    _controller = new AnimationController(
        duration: const Duration(seconds: 1000), vsync: this);
    _controller.addListener(() {
      updateBubblePosition();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomPaint(
            foregroundPainter:
                BubblePainter(bubbles: bubbles, controller: _controller),
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(30.0),
                    padding: const EdgeInsets.all(30.0),
                    decoration:
                    myBoxDecoration(), //             <--- BoxDecoration here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Molly', style: TextStyle(fontFamily: 'Lemonada', fontSize: 60)),
                        Text('$_random', style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: incrementCounter,
                  color: Color.fromRGBO(251, 168, 255, 0.85),
                  elevation: 8.0,
                  padding: EdgeInsets.all(20.0),
                  splashColor: Color.fromRGBO(255, 250, 148, 1),
                  animationDuration: Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Color.fromRGBO(209, 101, 214, 1), width: 3.0),
                  ),
                  child: Text('Click Me!', style: TextStyle(fontSize: 16, fontFamily: 'Comfortaa')),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[400],
    );
  }

  void updateBubblePosition() {
    bubbles.forEach((it) => it.updatePosition());
    setState(() {});
  }
}

class BubblePainter extends CustomPainter {
  List<Bubble> bubbles;
  AnimationController controller;

  BubblePainter({this.bubbles, this.controller});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    bubbles.forEach((it) => it.draw(canvas, canvasSize));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Bubble {
  Color colour;
  double direction;
  double speed;
  double radius;
  double x;
  double y;

  Bubble(Color colour, double maxBubbleSize) {
    this.colour = colour.withOpacity(Random().nextDouble());
    this.direction = Random().nextDouble() * 360;
    this.speed = 1;
    this.radius = Random().nextDouble() * maxBubbleSize;
  }

  draw(Canvas canvas, Size canvasSize) {
    Paint paint = new Paint()
      ..color = colour
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    assignRandomPositionIfUninitialized(canvasSize);

    randomlyChangeDirectionIfEdgeReached(canvasSize);

    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  void assignRandomPositionIfUninitialized(Size canvasSize) {
    if (x == null) {
      this.x = Random().nextDouble() * canvasSize.width;
    }

    if (y == null) {
      this.y = Random().nextDouble() * canvasSize.height;
    }
  }

  updatePosition() {
    var a = 180 - (direction + 90);
    direction > 0 && direction < 180
        ? x += speed * sin(direction) / sin(speed)
        : x -= speed * sin(direction) / sin(speed);
    direction > 90 && direction < 270
        ? y += speed * sin(a) / sin(speed)
        : y -= speed * sin(a) / sin(speed);
  }

  randomlyChangeDirectionIfEdgeReached(Size canvasSize) {
    if (x > canvasSize.width || x < 0 || y > canvasSize.height || y < 0) {
      direction = Random().nextDouble() * 360;
    }
  }
}
