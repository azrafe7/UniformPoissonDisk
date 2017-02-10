package ;

import upd.UniformPoissonDisk;

import JsCommon.*;
import JsCommon.Palette;

import js.Browser.*;
import js.html.*;
import js.html.Int32Array;
import js.html.Uint8Array;

using TinyCanvas;


class JsDemo_Simple {
  
  static var rectPalette = FIRE_PALETTE;
  static var circlePalette = GRASS_PALETTE;

  
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
}