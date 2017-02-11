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

  
  public static function main() {
    
    // image (prim)
    var tinyCanvasPrim = new TinyCanvas(WIDTH, HEIGHT, "canvas-prim");
    document.body.appendChild(tinyCanvasPrim.canvas);
    initTinyCanvas(tinyCanvasPrim, X + (WIDTH + SPACE) * 3, Y);
    
    // load image from resource
    loadImageResource("prim.png", function(image) {
      
      clearCanvas(tinyCanvasPrim);
      tinyCanvasPrim.context.drawImage(image, 0, 0, WIDTH, HEIGHT);

      
      // use image
      var tinyCanvasSamplePrim = new TinyCanvas(WIDTH, HEIGHT, "canvas-sampleprim");
      document.body.appendChild(tinyCanvasSamplePrim.canvas);
      initTinyCanvas(tinyCanvasSamplePrim, tinyCanvasPrim.canvas.offsetLeft, tinyCanvasPrim.canvas.offsetTop);
      
      var canvasSamplePrimOnClick = function(?event) {
        
        var minDist = 2;
        var drawRadius = minDist * .15;
        var rect = {
          x: 15, 
          y: 15, 
          width: tinyCanvasSamplePrim.width - 30,
          height: tinyCanvasSamplePrim.height - 30
        }
        
        grabMousePos(event);
        
        var samples = generatePrimSamples(rect.x, rect.y, rect.width, rect.height, minDist, tinyCanvasPrim.context.getImageData(0, 0, WIDTH, HEIGHT));
        
        clearCanvas(tinyCanvasSamplePrim, imagePalette);
        
        // draw rect from which we're sampling
        tinyCanvasSamplePrim.lineStyle(2., BOUNDS_COLOR, .75)
          .drawRect(rect.x, rect.y, rect.width, rect.height);
        
        drawSamples(tinyCanvasSamplePrim, samples, drawRadius, imagePalette, true, true);
        
      };
      
      tinyCanvasSamplePrim.canvas.addEventListener("click", canvasSamplePrimOnClick);
      canvasSamplePrimOnClick();
      
    });
    
    
    // image (fallout)
    var tinyCanvasFallout = new TinyCanvas(WIDTH, HEIGHT, "canvas-fallout");
    document.body.appendChild(tinyCanvasFallout.canvas);
    initTinyCanvas(tinyCanvasFallout, X + (WIDTH + SPACE) * 4, Y);
    
    // load image from resource
    loadImageResource("fallout.png", function(image) {
      
      clearCanvas(tinyCanvasFallout);
      tinyCanvasFallout.context.drawImage(image, 0, 0, WIDTH, HEIGHT);

      
      // use image
      var tinyCanvasSampleFallout = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplefallout");
      document.body.appendChild(tinyCanvasSampleFallout.canvas);
      initTinyCanvas(tinyCanvasSampleFallout, tinyCanvasFallout.canvas.offsetLeft, tinyCanvasFallout.canvas.offsetTop);
      
      var canvasSampleFalloutOnClick = function(?event) {
        
        var minDist = 15;
        var drawRadius = minDist * .05;
        var rect = {
          x: 15, 
          y: 15, 
          width: tinyCanvasSampleFallout.width - 30,
          height: tinyCanvasSampleFallout.height - 30
        }
        
        grabMousePos(event);
        
        var samples = generateFalloutSamples(rect.x, rect.y, rect.width, rect.height, minDist, tinyCanvasFallout.context.getImageData(0, 0, WIDTH, HEIGHT));
        
        clearCanvas(tinyCanvasSampleFallout, imagePalette);
        
        // draw rect from which we're sampling
        tinyCanvasSampleFallout.lineStyle(2., BOUNDS_COLOR, .75)
          .drawRect(rect.x, rect.y, rect.width, rect.height);
        
        drawSamples(tinyCanvasSampleFallout, samples, drawRadius, imagePalette, true, true);
        
      };
      
      tinyCanvasSampleFallout.canvas.addEventListener("click", canvasSampleFalloutOnClick);
      canvasSampleFalloutOnClick();
      
    });
  }

  
  static function loadImageResource(resourceId:String, onLoad:ImageElement->Void):Void {
    var pngBytes = Resource.getBytes(resourceId);
    if (pngBytes == null) throw 'Could not find resource with id "$resourceId"!';
    var image = document.createImageElement();
    image.onload = function() { onLoad(image); }
    image.src = "data:image/png;base64," + haxe.crypto.Base64.encode(pngBytes);
  }
  
  // generate sample points from image (prim)
  static function generatePrimSamples(x:Float, y:Float, width:Float, height:Float, minDist:Float, imageData:ImageData):Array<Point> {
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
  
  // generate sample points from image (fallout)
  static function generateFalloutSamples(x:Float, y:Float, width:Float, height:Float, minDist:Float, imageData:ImageData):Array<Point> {
    var topLeft = new Point(x, y);
    var bottomRight = new Point(x + width, y + height);
    
    var upd = new UniformPoissonDisk();
    var bgraBytes = imageData.data;
    var center = new Point(x + width * .5, y + height * .5);
    var radius = Math.min(width, height) * .5;
    
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
      return upd.distanceSquared(p, center) > radius * radius;
    }
    
    upd.firstPoint = mousePos;
    return upd.sample(topLeft, bottomRight, minDistanceFunc, minDist, reject, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
}