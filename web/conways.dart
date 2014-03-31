import 'dart:html';

Grid grid;
ParagraphElement debugElement;

String whiteColor = "#ffffff";
String blackColor = "#000000";

void main() {
  CanvasElement canvas = querySelector("#canvas");
  debugElement = querySelector("#debug_output");
  
  grid = new Grid(10, canvas);
  grid.draw();
}

class Grid {
  num unitSize;
  CanvasElement canvas;
  Map _spaces;
  
  static const num canvasMargin = 1;
  
  Grid(this.unitSize, this.canvas) {
    _spaces = new Map();
    
    for(int i = 0; i < gridWidth; i++) {
      for(int j = 0; j < gridHeight; j++) {
        Point gridCoordinate = new Point(i, j);
        Rectangle spaceFrame = new Rectangle(i*unitSize + canvasMargin, j*unitSize + canvasMargin, unitSize, unitSize);
        
        _spaces[gridCoordinate] = new Space(spaceFrame);
      }
    }
  }
  
  draw() {
    CanvasRenderingContext2D context = canvas.context2D;
          
    context..strokeStyle = blackColor
           ..lineWidth = 0.5;
    
    _spaces.forEach((_, V) => (V as Space).draw(context));
  }
  
  num get gridWidth => canvas.width ~/ unitSize;
  num get gridHeight => canvas.height ~/ unitSize;
}

class Space {
  Rectangle frame;
  bool isFilled;
  
  Space(this.frame) : isFilled = false;
  
  draw(CanvasRenderingContext2D context) {
    if (isFilled) {
      context.fillStyle = blackColor;
    } else {
      context.fillStyle = whiteColor;
    }
    
    context..strokeRect(frame.left, frame.top, frame.width, frame.height)
           ..fillRect(frame.left, frame.top, frame.width, frame.height);
  }
}