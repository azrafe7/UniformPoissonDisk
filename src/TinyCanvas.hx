/**
 * Implementation choices have been influenced by the following references.
 * 
 * References:
 * 
 * @see http://html5tutorial.com/advanced-path-painting/
 * @see https://github.com/fponticelli/minicanvas
 * @see https://github.com/hxDaedalus/hxDaedalus/blob/master/src/wings/jsCanvas
 */

import js.Browser.*;
import js.html.*;

using TinyCanvas;


class TinyCanvas {
  
  public var canvas(default, null):CanvasElement;
  
  public var context(default, null):CanvasRenderingContext2D;
  
  public var width(get, never):Int;
  inline function get_width():Int {
    return canvas.width;
  }
  
  public var height(get, never):Int;
  inline function get_height():Int {
    return canvas.height;
  }
  
  public var id(get, never):String;
  inline function get_id():String {
    return canvas.id;
  }
  
  public function new(width:Int, height:Int, id:String, ?useThisCanvas:CanvasElement):Void {
    if (useThisCanvas == null) this.canvas = document.createCanvasElement();
    else this.canvas = useThisCanvas;
    
    this.canvas.width = width;
    this.canvas.height = height;
    this.canvas.id = id;
    this.context = canvas.getContext2d();
  }
  
  inline static public function intToRgb(color:Int) {
    return {
      r: (color >> 16) & 0xFF,
      g: (color >> 8) & 0xFF,
      b: (color) & 0xFF
    };
  }
  
  static public function clear(tinyCanvas:TinyCanvas):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.clearRect(0, 0, tinyCanvas.width, tinyCanvas.height);
    return tinyCanvas;
  }

  static public function lineStyle(tinyCanvas:TinyCanvas, thickness:Float, color:Int, alpha:Float = 1.):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.lineWidth = thickness;
    
    var rgb = intToRgb(color);
    
    if (alpha != 1.0) {
      ctx.strokeStyle = 'rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, $alpha)';
    } else {
      ctx.strokeStyle = 'rgb(${rgb.r}, ${rgb.g}, ${rgb.b})';
    }
    return tinyCanvas;
  }

  static public function beginFill(tinyCanvas:TinyCanvas, color:Int, alpha:Float = 1.):TinyCanvas {
    var ctx = tinyCanvas.context;
    
    var rgb = intToRgb(color);
    
    if (alpha != 1.0) {
      ctx.fillStyle = 'rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, $alpha)';
    } else {
      ctx.fillStyle = 'rgb(${rgb.r}, ${rgb.g}, ${rgb.b})';
    }
    
    return tinyCanvas;
  }

  static public function endFill(tinyCanvas:TinyCanvas):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.fill();
    return tinyCanvas;
  }
  
  static public function moveTo(tinyCanvas:TinyCanvas, x:Float, y:Float):TinyCanvas {
		var ctx = tinyCanvas.context;
    ctx.beginPath();
		ctx.moveTo(x, y);
    return tinyCanvas;
	}

	static public function lineTo(tinyCanvas:TinyCanvas, x:Float, y:Float):TinyCanvas {
    var ctx = tinyCanvas.context;
		ctx.lineTo(x, y);
    return tinyCanvas;
  }
  
  static public function quadTo(tinyCanvas:TinyCanvas, cx:Float, cy:Float, ax:Float, ay:Float):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.quadraticCurveTo(cx, cy, ax, ay);
    return tinyCanvas;
  }
  
  static public function stroke(tinyCanvas:TinyCanvas, closePath:Bool = true):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.stroke();
    if (closePath) ctx.closePath();
    return tinyCanvas;
  }

  static public function drawCircle(tinyCanvas:TinyCanvas, x:Float, y:Float, radius:Float):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false);
    ctx.stroke();
    ctx.closePath();
    return tinyCanvas;
  }

  static public function drawRect(tinyCanvas:TinyCanvas, x:Float, y:Float, width:Float, height:Float):TinyCanvas {
    var ctx = tinyCanvas.context;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + width, y);
    ctx.lineTo(x + width, y + height);
    ctx.lineTo(x, y + height);
    ctx.lineTo(x, y);
    ctx.stroke();
    ctx.closePath();
    return tinyCanvas;
  }
  
  
  // entry point for testing
  
  @:noCompletion 
  @:noUsing
  static function main() {
    var tinyCanvas = new TinyCanvas(300, 300, "canvas");
    document.body.appendChild(tinyCanvas.canvas);
    
    tinyCanvas.lineStyle(0, 0, 0);
    tinyCanvas.beginFill(0x00FF00);
    tinyCanvas.drawCircle(40, 40, 40);
    tinyCanvas.endFill();
    
    tinyCanvas
      .beginFill(0xFFFF00)
      .drawRect(0, 0, 40, 40)
      .endFill()
      .lineStyle(2., 0xFF0000, 1)
      .drawRect(0, 0, 40, 40)
    ;
    
    tinyCanvas
      .lineStyle(5, 0xFFFFFF, .5)
      .moveTo(0, 0)
      .lineTo(50, 50)
      .stroke()
      .moveTo(100, 100)
      .lineTo(30, 70)
      .lineTo(80, 20)
      .lineTo(60, 60)
      .quadTo(80, 60, 80, 80);
    
    tinyCanvas.stroke();
    tinyCanvas.endFill();
  }
}