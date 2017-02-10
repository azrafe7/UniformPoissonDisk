package ;

import upd.UniformPoissonDisk;

import haxe.Resource;
import hxnoise.Perlin;

import JsCommon.*;
import JsCommon.Palette;

import js.Browser.*;
import js.html.*;
import js.html.Int32Array;
import js.html.Uint8Array;

using TinyCanvas;


class JsDemo_Noise {
  
  static var perlinPalette = YELLOW_PALETTE;

  static var tinyCanvasPerlin:TinyCanvas;
  static var noiseData:Int32Array;
  static var noise:Float32Array;
  
  
  public static function main() {
    
    // perlin
    tinyCanvasPerlin = new TinyCanvas(WIDTH, HEIGHT, "canvas-perlin");
    document.body.appendChild(tinyCanvasPerlin.canvas);
    initTinyCanvas(tinyCanvasPerlin, X + (WIDTH + SPACE) * 2, Y);
    
    createPerlinNoise();
    
    // draw perlin noise
    clearCanvas(tinyCanvasPerlin);
    var u8Array = new Uint8ClampedArray(noiseData.buffer);
    var imageData:ImageData = new ImageData(u8Array, WIDTH, HEIGHT);
    tinyCanvasPerlin.context.putImageData(imageData, 0, 0);
    
    
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
  }

  
  static function createPerlinNoise() {
    var perlin = new Perlin();
    noiseData = new Int32Array(WIDTH * HEIGHT);
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
        noiseData[i] = color;
        noise[i] = value;
        i++;
      }
    }
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
      return UpdTools.clamp(dist, UniformPoissonDisk.MIN_DISTANCE_THRESHOLD, minDist);
    }
    
    function reject(p:Point):Bool {
      var value = getNoiseValue(p.x, p.y);
      return value < .49;
    }
    
    upd.firstPoint = mousePos;
    var samples = upd.sample(topLeft, bottomRight, minDistanceFunc, minDist, null, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
    
    return samples;
  }
}