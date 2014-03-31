import 'dart:html';
import 'dart:async' show Future;

Grid grid;
ParagraphElement debugElement;

String whiteColor = "#ffffff";
String blackColor = "#000000";

void main() {
  CanvasElement canvas = querySelector("#canvas");
  debugElement = querySelector("#debug_output");
  
  grid = new Grid(10, canvas);
  grid.start();
  
  querySelector("#clear-button").onClick.listen((_) => grid.clear());
  querySelector("#start-button").onClick.listen((_) => grid.play());
}

class Grid {
  num unitSize;
  CanvasElement canvas;
  Map _spaces;
  
  bool isResponding = false;
  
  int eventsFired = 0;
  
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
  
  start() {
    draw();
    
    responderBegin(MouseEvent event) => isResponding = true;
    responderEnd(MouseEvent event) => isResponding = false;
    
    Point pointOfLastEvent = new Point(-1, -1);
    
    canvas..onMouseDown.listen(responderBegin)
          ..onMouseLeave.listen(responderEnd)
          ..onMouseUp.listen(responderEnd)
          ..onClick.listen(respondToMouseEvent)
          ..onMouseMove.listen((MouseEvent event) {
            Point position = new Point(event.offset.x ~/ unitSize, event.offset.y ~/ unitSize);
            
            bool pointsAreEqual = position == pointOfLastEvent;
            if(isResponding && !pointsAreEqual)
              respondToMouseEvent(event);
            
            pointOfLastEvent = position;
          });
  }
  
  draw() {
    CanvasRenderingContext2D context = canvas.context2D;
          
    context..strokeStyle = blackColor
           ..lineWidth = 0.5
           ..clearRect(0, 0, canvas.width, canvas.height);
    
    _spaces.forEach((_, V) => (V as Space).draw(context));
  }
  
  
  
  respondToMouseEvent(MouseEvent event) {
    Point position = new Point(event.offset.x ~/ unitSize, event.offset.y ~/ unitSize);
    
    debugElement.text = eventsFired.toString() + " Last on: " + position.toString();
    
    Space space = _spaces[position];
    
    if(space != null && !event.altKey){
      space.fill();
    } else if (space != null) {
      space.clear();
    }
  
    eventsFired++;
    
    draw();
  }
  
  clear(){
    _spaces.forEach((_, V) => (V as Space).clear());
    draw();
  }
  
  play(){
    _spaces.forEach((K, V) =>
      (V as Space).checkIfFills(getLivingNeighbors(K)));
    
    int totalTicks = 0;
    
    requestUpdate() => _spaces.forEach((_,V) => totalTicks += (V as Space).tick());
    
    Future update = new Future.delayed(new Duration(milliseconds: 300), requestUpdate);
    
    update.then((_) {
      draw();
      if(totalTicks != 0) {
        play();
      }
    });
  }
  
  num getLivingNeighbors(Point p) {
    num livingNeighbors = 0;
    
    for(int i = -1; i < 2; i++){
      for(int j = -1; j < 2; j++) {
        if(i == 0 && j == 0) continue;
        
        Space space = _spaces[new Point(p.x + i, p.y + j)];
        if (space != null && space.isFilled) {
            livingNeighbors++;
        }
      }
    }
    
    return livingNeighbors;
  }
  
  num get gridWidth => canvas.width ~/ unitSize;
  num get gridHeight => canvas.height ~/ unitSize;
}

class Space {
  Rectangle frame;
  bool isFilled = false;
  bool shouldFill;
  
  Space(this.frame);
  
  draw(CanvasRenderingContext2D context) {
    if (isFilled) {
      context.fillStyle = blackColor;
    } else {
      context.fillStyle = whiteColor;
    }
    
    context..strokeRect(frame.left, frame.top, frame.width, frame.height)
           ..fillRect(frame.left, frame.top, frame.width, frame.height);
  }
  
  checkIfFills(num livingNeighbors) {
    if(isFilled){
      shouldFill = livingNeighbors < 2 || livingNeighbors > 3 ? false : true;
    } else {
      shouldFill = livingNeighbors == 3 ? true : false;
    }
  }
  
  num tick() {
    if(isFilled == shouldFill) {
      return 0;
    }
    
    isFilled = shouldFill;
    return 1;
  }
  
  fill() => isFilled = true;
  clear() => isFilled = false;
}