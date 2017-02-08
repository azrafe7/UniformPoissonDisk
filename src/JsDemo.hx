package ;

import haxe.Resource;
import upd.UniformPoissonDisk;

import hxnoise.Perlin;

import js.Browser.*;
import js.html.*;
import js.html.Int32Array;
import js.html.Uint8Array;

using TinyCanvas;

typedef Palette = Array<Int>;


class JsDemo {
  
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
  
  static var rectPalette = FIRE_PALETTE;
  static var circlePalette = GRASS_PALETTE;
  static var perlinPalette = YELLOW_PALETTE;
  static var imagePalette = FIRE_PALETTE;

  static var mousePos:Point = null;
  
  static var tinyCanvasPerlin:TinyCanvas;
  static var noise:Float32Array;
  static var imageData:ImageData;
  
  
  public static function main() {
    
    // sampleRect
    var tinyCanvasRect = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplerect");
    document.body.appendChild(tinyCanvasRect.canvas);
    initTinyCanvas(tinyCanvasRect, X, Y);
    
    var canvasRectOnClick = function(?event) {
      
      var minDist = 8;
      var drawRadius = minDist * .75;
      var rect = {
        x: 15, 
        y: 15, 
        width: tinyCanvasRect.width - 30,
        height: tinyCanvasRect.height - 30
      }
      
      grabMousePos(event);
      
      var samples = generateSamplesInRect(rect.x, rect.y, rect.width, rect.height, minDist);
      
      clearCanvas(tinyCanvasRect, rectPalette);
      
      // draw rect from which we're sampling
      tinyCanvasRect.lineStyle(2., BOUNDS_COLOR, .75)
        .drawRect(rect.x, rect.y, rect.width, rect.height);
        
      drawSamples(tinyCanvasRect, samples, drawRadius, rectPalette);
      
    };
    
    tinyCanvasRect.canvas.addEventListener("click", canvasRectOnClick);
    canvasRectOnClick();
    
    
    // sampleCircle
    var tinyCanvasCircle = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplecircle");
    document.body.appendChild(tinyCanvasCircle.canvas);
    initTinyCanvas(tinyCanvasCircle, X + WIDTH + SPACE, Y);
    
    var canvasCircleOnClick = function(?event) {
      
      var minDist = 8;
      var radius = tinyCanvasCircle.width * .45;
      var drawRadius = minDist * .75;
      var center = new Point(tinyCanvasCircle.width * .5, tinyCanvasCircle.height * .5);
      
      grabMousePos(event);
      
      var samples = generateSamplesInCircle(center.x, center.y, radius, minDist);
      
      clearCanvas(tinyCanvasCircle, circlePalette);
      
      // draw circle from which we're sampling
      tinyCanvasCircle.lineStyle(2., BOUNDS_COLOR, .75)
        .drawCircle(center.x, center.y, radius);
      
      drawSamples(tinyCanvasCircle, samples, drawRadius, circlePalette);
      
    };
    
    tinyCanvasCircle.canvas.addEventListener("click", canvasCircleOnClick);
    canvasCircleOnClick();
    
    
    // perlin
    tinyCanvasPerlin = new TinyCanvas(WIDTH, HEIGHT, "canvas-perlin");
    document.body.appendChild(tinyCanvasPerlin.canvas);
    initTinyCanvas(tinyCanvasPerlin, X + (WIDTH + SPACE) * 2, Y);
    
    function createPerlinNoise() {
      var perlin = new Perlin();
      var i32Array = new Int32Array(WIDTH * HEIGHT);
      noise = new Float32Array(WIDTH * HEIGHT);
      
      var i = 0;
      var value:Float;
      var u8, r, g, b;
      for (y in 0...HEIGHT) {
        for (x in 0...WIDTH) {
          value = perlin.OctavePerlin(x / 8, y / 8, 0.1, 1, 0.5, .25);
          u8 = Std.int(value * 255);
          r = u8;
          g = u8;
          b = u8;
          var color = (b << 16) | (g << 8) | (r) | 0xFF000000;
          i32Array[i] = color;
          noise[i] = value;
          i++;
        }
      }
      
      clearCanvas(tinyCanvasPerlin);
      var u8Array = new Uint8ClampedArray(i32Array.buffer);
      var imageData:ImageData = new ImageData(u8Array, WIDTH, HEIGHT);
      tinyCanvasPerlin.context.putImageData(imageData, 0, 0);
    }
    
    createPerlinNoise();
    
    
    // use perlin
    var tinyCanvasPerlinSample = new TinyCanvas(WIDTH, HEIGHT, "canvas-sampleperlin");
    document.body.appendChild(tinyCanvasPerlinSample.canvas);
    initTinyCanvas(tinyCanvasPerlinSample, tinyCanvasPerlin.canvas.offsetLeft, tinyCanvasPerlin.canvas.offsetTop);
    
    var canvasPerlinSampleOnClick = function(?event) {
      
      var minDist = 10;
      var drawRadius = minDist * .25;
      var rect = {
        x: 15, 
        y: 15, 
        width: tinyCanvasPerlinSample.width - 30,
        height: tinyCanvasPerlinSample.height - 30
      }
      
      grabMousePos(event);
      
      var samples = generatePerlinSamples(rect.x, rect.y, rect.width, rect.height, minDist);
      
      clearCanvas(tinyCanvasPerlinSample, perlinPalette);
      
      // draw rect from which we're sampling
      tinyCanvasPerlinSample.lineStyle(2., BOUNDS_COLOR, .75)
        .drawRect(rect.x, rect.y, rect.width, rect.height);
      
      drawSamples(tinyCanvasPerlinSample, samples, drawRadius, perlinPalette, false, true);
      
    };
    
    tinyCanvasPerlinSample.canvas.addEventListener("click", canvasPerlinSampleOnClick);
    canvasPerlinSampleOnClick();
    
    
    // image
    var tinyCanvasPNG = new TinyCanvas(WIDTH, HEIGHT, "canvas-png");
    document.body.appendChild(tinyCanvasPNG.canvas);
    initTinyCanvas(tinyCanvasPNG, X + (WIDTH + SPACE) * 3, Y);
    
    var pngBytes = Resource.getBytes("prim.png");
    trace(pngBytes.length);
    var image = document.createImageElement();
    image.onload = function(event) {
      trace("image loaded");
      trace(event);
      
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

  
  
  // make canvas' position absolute and set some styles on it
  static function initTinyCanvas(tinyCanvas:TinyCanvas, x:Int, y:Int):Void {
    var style = tinyCanvas.canvas.style;
    //style.backgroundColor = "#000000";
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
    
    upd.firstPoint = mousePos;
    return upd.sampleRectangle(topLeft, bottomRight, minDist, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
  
  // generate sample points inside the specified circle
  static function generateSamplesInCircle(cx:Float, cy:Float, radius:Float, minDist:Float):Array<Point> {
    var center = new Point(cx, cy);
    
    var upd = new UniformPoissonDisk();
    
    upd.firstPoint = mousePos;
    return upd.sampleCircle(center, radius, minDist, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
  
  // generate sample points inside the specified rectangle using a custom reject function
  static function generateCustomSamples(x:Float, y:Float, width:Float, height:Float, minDist:Float):Array<Point> {
    var topLeft = new Point(x, y);
    var bottomRight = new Point(x + width, y + height);
    
    var upd = new UniformPoissonDisk();
    
    function reject(p:Point):Bool {
      return (p.x < width * .5 && p.y < height * .5) || (p.x > width * .5 && p.y > height * .5);
    }
    
    function minDistanceFunc(p:Point):Float {
      var dist = minDist * Math.random();
      return clamp(dist, UniformPoissonDisk.MIN_DISTANCE_THRESHOLD, minDist);
    }
    
    upd.firstPoint = mousePos;
    return upd.sample(topLeft, bottomRight, minDistanceFunc, minDist, null, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
    
  // generate sample points from perlin noise
  static function generatePerlinSamples(x:Float, y:Float, width:Float, height:Float, minDist:Float):Array<Point> {
    var topLeft = new Point(x, y);
    var bottomRight = new Point(x + width, y + height);
    
    var upd = new UniformPoissonDisk();
    
    inline function getNoiseValue(x:Float, y:Float):Float {
      var ix = Std.int(x);
      var iy = Std.int(y);
      var i = (iy * WIDTH + ix);
      return noise[i];
    }
    
    function minDistanceFunc(p:Point):Float {
      var value = 1.0 - getNoiseValue(p.x, p.y);
      var dist = minDist * value;
      return clamp(dist, UniformPoissonDisk.MIN_DISTANCE_THRESHOLD, minDist);
    }
    
    function reject(p:Point):Bool {
      var value = getNoiseValue(p.x, p.y);
      return value < .49;
    }
    
    upd.firstPoint = mousePos;
    return upd.sample(topLeft, bottomRight, minDistanceFunc, minDist, null, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
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
  
  // draw samples onto tinyCanvas, optionally using a color palette
  static function drawSamples(tinyCanvas:TinyCanvas, samples:Array<Point>, radius:Float, ?palette:Palette, ?fill:Bool = false, ?highlightFirstPoint:Bool = true):Void {
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
  
  // clear and add border
  static function clearCanvas(tinyCanvas:TinyCanvas, ?palette:Palette):Void {
    var color = palette != null ? palette[0] : 0xFF0000;
    
    tinyCanvas
      .clear()
      .lineStyle(3, color, 1)
      .drawRect(0, 0, tinyCanvas.width, tinyCanvas.height);
  }
  
  static function getRandomColorFrom(palette:Palette, defaultColor:Int):Int {
    if (palette == null || palette.length == 0) return defaultColor;
    else return palette[Std.random(palette.length)];
  }
  
  static inline function clamp(value:Float, min:Float, max:Float):Float {
    return (value < min ? min : (value > max ? max : value));
  }
  
  static inline function grabMousePos(mouseEvent):Void {
    if (mouseEvent != null) {
      var rect = mouseEvent.target.getBoundingClientRect();
      mousePos = new Point(mouseEvent.clientX - rect.left, mouseEvent.clientY - rect.top);
    }
  }
}