package ;

import upd.UniformPoissonDisk;

import js.Browser.*;
import js.html.*;


using TinyCanvas;

typedef Point = upd.Point;
typedef Palette = Array<Int>;


class JsDemo {
  
  // position/size
  static var X:Int = 15;
  static var Y:Int = 15;
  static var SPACE:Int = 15;
  
  static var WIDTH:Int = 300;
  static var HEIGHT:Int = 300;
  
  // (defaults to 30, try with 2)
  static var OVERRIDE_DEFAULT_POINTS_PER_ITERATION:Null<Int> = null; // 2;
  
  // palettes
  static var BOUND_COLOR:Int = 0xC0C0C0;
  
  static var RED_PALETTE:Palette = [0xFF0000, 0xF52000, 0xE01515, 0xFF3010];
  static var GREEN_PALETTE:Palette = [0x00FF00, 0x00F520, 0x15E015, 0x10FF30];
  static var FIRE_PALETTE:Palette = [0xFD5039, 0xFD7303, 0xFD9D4F, 0xFDE181, 0xFD4403, 0xFD5039, 0xFD7303, 0xFD9D4F];
  static var GRASS_PALETTE:Palette = [0xA9F281, 0xBAEB81, 0x7CD582, 0x3ECF83, 0x00D984, 0x59F281, 0xBADB81, 0x7CF582];
  
  static var rectPalette = FIRE_PALETTE;
  static var circlePalette = GRASS_PALETTE;
  
  
  public static function main() {
    
    // sampleRect
    var tinyCanvasRect = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplerect");
    document.body.appendChild(tinyCanvasRect.canvas);
    initTinyCanvas(tinyCanvasRect, X, Y);
    
    tinyCanvasRect.canvas.addEventListener("click", function(event) {
      
      var minDist = 15;
      var drawRadius = minDist * .85;
      var samples = generateSamplesInRect(0, 0, tinyCanvasRect.width, tinyCanvasRect.height, minDist);
      drawSamples(tinyCanvasRect, samples, drawRadius, rectPalette);
      
    });
    
    tinyCanvasRect.canvas.click();
    
    
    // sampleCircle
    var tinyCanvasCircle = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplecircle");
    document.body.appendChild(tinyCanvasCircle.canvas);
    initTinyCanvas(tinyCanvasCircle, X + WIDTH + SPACE, Y);
    
    tinyCanvasCircle.canvas.addEventListener("click", function(event) {
      
      var minDist = 15;
      var radius = tinyCanvasCircle.width * .45;
      var drawRadius = minDist * .75;
      var center = new Point(tinyCanvasCircle.width * .5, tinyCanvasCircle.height * .5);
      var samples = generateSamplesInCircle(center.x, center.y, radius, minDist);
      drawSamples(tinyCanvasCircle, samples, drawRadius, circlePalette);
      
      tinyCanvasCircle.lineStyle(2., BOUND_COLOR, .75)
        .drawCircle(center.x, center.y, radius);
    });
    
    tinyCanvasCircle.canvas.click();
  }
  
  // make canvas' position absolute and set some styles on it
  static function initTinyCanvas(tinyCanvas:TinyCanvas, x:Int, y:Int):Void {
    var style = tinyCanvas.canvas.style;
    style.backgroundColor = "#000000";
    style.position = "absolute";
    style.left = Std.string(x);
    style.top = Std.string(y);
    style.cursor = "hand";
  }
  
  // generate sample points inside the specified rectangle
  static function generateSamplesInRect(x:Float, y:Float, width:Float, height:Float, minDist:Float):Array<Point> {
    var topLeft = new Point(x, y);
    var bottomRight = new Point(x + width, y + height);
    
    var upd = new UniformPoissonDisk();
    
    return upd.sampleRectangle(topLeft, bottomRight, minDist, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
  
  // generate sample points inside the specified circle
  static function generateSamplesInCircle(cx:Float, cy:Float, radius:Float, minDist:Float):Array<Point> {
    var center = new Point(cx, cy);
    
    var upd = new UniformPoissonDisk();
    
    return upd.sampleCircle(center, radius, minDist, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
  
  // draw samples onto tinyCanvas, optionally using a color palette
  static function drawSamples(tinyCanvas:TinyCanvas, samples:Array<Point>, radius:Float, ?palette:Palette):Void {
    var color = palette != null ? palette[0] : 0xFF0000;
    var fillAlpha = .8;
    
    // clear, add border and set new lineStyle
    tinyCanvas
      .clear()
      .lineStyle(3, color, 1)
      .drawRect(0, 0, tinyCanvas.width, tinyCanvas.height);
    
    // draw circles at sampled points
    for (p in samples) {
      color = getRandomColorFrom(palette, color);
      
      tinyCanvas.lineStyle(1.5, color, 1);
      tinyCanvas.beginFill(color, fillAlpha);
      tinyCanvas.drawCircle(p.x, p.y, .25); // center dot
      tinyCanvas.drawCircle(p.x, p.y, radius);
      tinyCanvas.endFill();
    }
  }
  
  static function getRandomColorFrom(palette:Palette, defaultColor:Int):Int {
    if (palette == null || palette.length == 0) return defaultColor;
    else return palette[Std.random(palette.length)];
  }
}