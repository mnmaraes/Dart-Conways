import 'dart:html';

Grid grid;
ParagraphElement debugElement;

void main() {
  CanvasElement canvas = querySelector("#canvas");
  debugElement = querySelector("#debug_output");
  
  grid = new Grid(10, canvas);
  grid.draw();
  
  canvas.onClick.listen(grid.receiveClick);
}

drawVerticalLine(num initialX, num finalY, CanvasRenderingContext2D context) {
  context..beginPath()
         ..moveTo(initialX, 0)
         ..lineTo(initialX, finalY)
         ..stroke();
}

drawHorizontalLine(num initialY, finalX, CanvasRenderingContext2D context) {
  context..beginPath()
         ..moveTo(0, initialY)
         ..lineTo(finalX, initialY)
         ..stroke();
}

class Grid {
  num unitSize;
  CanvasElement canvas;
  Map _spaces;
  
  Grid(this.unitSize, this.canvas) {
    _spaces = new Map();
  }
  
  draw() {
    CanvasRenderingContext2D context = canvas.context2D;
    
    num gridWidth = canvas.width / unitSize;
    num gridHeight = canvas.height / unitSize;
    
    context..lineWidth = 0.3
           ..strokeStyle = "#000000"
           ..fillStyle = "#000000";
    
    context.strokeRect(0, 0, canvas.width, canvas.height);
    
    for(int i = 1; i <= gridWidth; i++) {
      drawVerticalLine(i*unitSize, canvas.height, context);
    }
    
    for(int i = 1; i <= gridHeight; i++) {
      drawHorizontalLine(i*unitSize, canvas.width, context);
    }
    
  }
  
  receiveClick(MouseEvent event) {
    Point position = event.offset;
    Point gridPosition = new Point(position.x ~/ unitSize, position.y ~/ unitSize);
    
    bool isFilled = _spaces[gridPosition];
    
    if (isFilled == null || !isFilled ){
      fillSpace(gridPosition);
    } else {
      clearSpace(gridPosition);
    }
      
    debugElement.text = gridPosition.toString();   
  }
  
  fillSpace(Point position) {
    CanvasRenderingContext2D context = canvas.context2D;
    
    Rectangle rectToFill = getRectForPosition(position);
    
    context.fillRect(rectToFill.left, rectToFill.top, rectToFill.width, rectToFill.height);
  }
  
  clearSpace(Point position) {
    CanvasRenderingContext2D context = canvas.context2D;
        
    Rectangle rectToFill = getRectForPosition(position);
        
    context.clearRect(rectToFill.left, rectToFill.top, rectToFill.width, rectToFill.height);
  }
  
  Rectangle getRectForPosition(Point position) {
    num x = position.x * unitSize;
    num y = position.y * unitSize;
    
    return new Rectangle(x, y, unitSize, unitSize);
  }
}