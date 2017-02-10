package ;

import upd.UniformPoissonDisk;

import haxe.Resource;

import JsCommon.*;
import JsCommon.Palette;

import js.Browser.*;
import js.html.*;
import js.html.Int32Array;
import js.html.Uint8Array;

using TinyCanvas;


class JsDemo_Image {
  
  static var imagePalette = FIRE_PALETTE;

  static var imageData:ImageData;
  
  
  public static function main() {
    
    // image
    var tinyCanvasPNG = new TinyCanvas(WIDTH, HEIGHT, "canvas-png");
    document.body.appendChild(tinyCanvasPNG.canvas);
    initTinyCanvas(tinyCanvasPNG, X + (WIDTH + SPACE) * 3, Y);
    
    // load image from resource
    var pngBytes = Resource.getBytes("prim.png");
    var image = document.createImageElement();
    image.onload = function(event) {
      
      clearCanvas(tinyCanvasPNG);
      tinyCanvasPNG.context.drawImage(image, 0, 0, WIDTH, HEIGHT);

      
      // use image
      var tinyCanvasSamplePNG = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplepng");
      document.body.appendChild(tinyCanvasSamplePNG.canvas);
      initTinyCanvas(tinyCanvasSamplePNG, tinyCanvasPNG.canvas.offsetLeft, tinyCanvasPNG.canvas.offsetTop);
      
      var canvasSamplePNGOnClick = function(?event) {
        
        var minDist = 2;
        var drawRadius = minDist * .15;
        var rect = {
          x: 15, 
          y: 15, 
          width: tinyCanvasSamplePNG.width - 30,
          height: tinyCanvasSamplePNG.height - 30
        }
        
        grabMousePos(event);
        
        var samples = generateImageSamples(rect.x, rect.y, rect.width, rect.height, minDist, tinyCanvasPNG.context.getImageData(0, 0, WIDTH, HEIGHT));
        
        clearCanvas(tinyCanvasSamplePNG, imagePalette);
        
        // draw rect from which we're sampling
        tinyCanvasSamplePNG.lineStyle(2., BOUNDS_COLOR, .75)
          .drawRect(rect.x, rect.y, rect.width, rect.height);
        
        drawSamples(tinyCanvasSamplePNG, samples, drawRadius, imagePalette, true, true);
        
      };
      
      tinyCanvasSamplePNG.canvas.addEventListener("click", canvasSamplePNGOnClick);
      canvasSamplePNGOnClick();
      
    }
    
    image.src = "data:image/png;base64," + haxe.crypto.Base64.encode(pngBytes);
  }

  
  // generate sample points from image
  static function generateImageSamples(x:Float, y:Float, width:Float, height:Float, minDist:Float, imageData:ImageData):Array<Point> {
    var topLeft = new Point(x, y);
    var bottomRight = new Point(x + width, y + height);
    
    var upd = new UniformPoissonDisk();
    var bgraBytes = imageData.data;
    
    inline function getValue(x:Float, y:Float):Float {
      var ix = Std.int(x);
      var iy = Std.int(y);
      var i = (iy * WIDTH + ix) * 4;
      return bgraBytes[i] / 255;
    }
    
    function minDistanceFunc(p:Point):Float {
      var value = getValue(p.x, p.y);
      var dist = minDist * value;
      return clamp(dist, UniformPoissonDisk.MIN_DISTANCE_THRESHOLD, minDist);
    }
    
    function reject(p:Point):Bool {
      var value = getValue(p.x, p.y);
      return value < .6 || value > .8;
    }
    
    upd.firstPoint = mousePos;
    return upd.sample(topLeft, bottomRight, minDistanceFunc, minDist, reject, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
}