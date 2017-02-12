package;

import upd.UniformPoissonDisk;

using TinyCanvas;

typedef Palette = Array<Int>;



/**
 * ...
 * @author azrafe7
 */
@:publicFields
class JsCommon {

  // position/size
  static var X:Int = 15;
  static var Y:Int = 15;
  static var SPACE:Int = 15;
  
  static var WIDTH:Int = 200;
  static var HEIGHT:Int = 200;
  
  // (defaults to 30, try with 2)
  static var OVERRIDE_DEFAULT_POINTS_PER_ITERATION:Null<Int> = null; // 2;
  
  // palettes
  static var BOUNDS_COLOR:Int = 0xC0C0C0;
  
  static var RED_PALETTE:Palette = [0xFF0000, 0xF52000, 0xE01515, 0xFF3010];
  static var GREEN_PALETTE:Palette = [0x00FF00, 0x00F520, 0x15E015, 0x10FF30];
  static var FIRE_PALETTE:Palette = [0xFD5039, 0xFD7303, 0xFD9D4F, 0xFDE181, 0xFD4403, 0xFD5039, 0xFD7303, 0xFD9D4F];
  static var GRASS_PALETTE:Palette = [0xA9F281, 0xBAEB81, 0x7CD582, 0x3ECF83, 0x00D984, 0x59F281, 0xBADB81, 0x7CF582];
  static var OCEAN_PALETTE:Palette = [0xA981F2, 0xBA81EB, 0x7C82D5, 0x3E83CF, 0x0084D9, 0x5981F2, 0xBA81DB, 0x7C82F5];
  static var YELLOW_PALETTE:Palette = [0xF2D040, 0xF0F000, 0xF4FF20, 0xFFFF00];
  
  
  static var mousePos:Point;
  
  
  // draw samples onto tinyCanvas, optionally using a color palette
  public static function drawSamples(tinyCanvas:TinyCanvas, samples:Array<Point>, radius:Float, ?palette:Palette, ?fill:Bool = false, ?highlightFirstPoint:Bool = true):Void {
    if (samples == null || samples.length == 0) return;
    
    var color = palette != null ? palette[0] : 0xFF0000;
    var fillAlpha = .25;
    
    // draw circles at sampled points
    if (highlightFirstPoint) {
      var p = samples[0];
      tinyCanvas.lineStyle(2, color, 1);
      tinyCanvas.beginFill(color, .75);
      tinyCanvas.drawCircle(p.x, p.y, .25); // center dot
      tinyCanvas.drawCircle(p.x, p.y, radius);
      tinyCanvas.endFill();
    }
    for (p in samples) {
      tinyCanvas.lineStyle(1.5, color, 1);
      if (fill) {
        tinyCanvas.beginFill(color, fillAlpha);
        tinyCanvas.drawCircle(p.x, p.y, radius);
        tinyCanvas.endFill();
      }
      tinyCanvas.drawCircle(p.x, p.y, .25); // center dot
      
      color = getRandomColorFrom(palette, color);
    }
  }
  
  // make canvas' position absolute and set some styles on it
  public static function initTinyCanvas(tinyCanvas:TinyCanvas, x:Int, y:Int):Void {
    var style = tinyCanvas.canvas.style;
    //style.backgroundColor = "#000000";
    style.position = "absolute";
    style.left = Std.string(x);
    style.top = Std.string(y);
    style.cursor = "hand";
  }  
  
  // clear and add border
  public static function clearCanvas(tinyCanvas:TinyCanvas, ?palette:Palette):Void {
    var color = palette != null ? palette[0] : 0xFF0000;
    
    tinyCanvas
      .clear()
      .lineStyle(3, color, 1)
      .drawRect(0, 0, tinyCanvas.width, tinyCanvas.height);
  }
  
  public static function getRandomColorFrom(palette:Palette, defaultColor:Int):Int {
    if (palette == null || palette.length == 0) return defaultColor;
    else return palette[Std.random(palette.length)];
  }
  
  public static inline function clamp(value:Float, min:Float, max:Float):Float {
    return (value < min ? min : (value > max ? max : value));
  }
  
  // grab mouse pos from `mouseEvent` (if possible) and store it into `mousePos`
  public static inline function grabMousePos(mouseEvent):Void {
    mousePos = null;
    if (mouseEvent != null) {
      var rect = mouseEvent.target.getBoundingClientRect();
      var mouseX = mouseEvent.clientX - rect.left;
      var mouseY = mouseEvent.clientY - rect.top;
      if (mousePos == null) mousePos = new Point(0, 0);
      mousePos.x = mouseX;
      mousePos.y = mouseY;
    }
  }
}