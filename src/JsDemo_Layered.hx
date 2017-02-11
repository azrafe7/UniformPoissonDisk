package ;

import upd.UniformPoissonDisk;

import JsCommon.*;
import JsCommon.Palette;

import js.Browser.*;
import js.html.*;
import js.html.Int32Array;
import js.html.Uint8Array;

using TinyCanvas;


class JsDemo_Layered {
  
  static var layerPalettes = [OCEAN_PALETTE, FIRE_PALETTE, GRASS_PALETTE];
  static var layerPalette = OCEAN_PALETTE;

  
  public static function main() {
    
    // sample multi layers
    var tinyCanvasRect = new TinyCanvas(WIDTH, HEIGHT, "canvas-samplelayered");
    document.body.appendChild(tinyCanvasRect.canvas);
    initTinyCanvas(tinyCanvasRect, X + (WIDTH + SPACE) * 2, Y + (HEIGHT + SPACE) * 1);
    
    var canvasRectOnClick = function(?event) {
      
      var minDist = 28.;
      var layerScale = .75;
      var rect = {
        x: 15, 
        y: 15, 
        width: tinyCanvasRect.width - 30,
        height: tinyCanvasRect.height - 30
      }
      
      grabMousePos(event);
      
      clearCanvas(tinyCanvasRect, layerPalette);
      
      // draw rect from which we're sampling
      tinyCanvasRect.lineStyle(2., BOUNDS_COLOR, .75)
        .drawRect(rect.x, rect.y, rect.width, rect.height);
        
      var samples = [];
      
      function filter(currSamples:Array<Point>, prevSamples:Array<Point>, minDistance:Float):Void {
        var distSquared = minDistance * minDistance;
        var i = 0;
        var toRemove = [];
        for (p in currSamples) {
          for (q in prevSamples) {
            if (UpdTools.distanceSquared(p, q) < distSquared) {
              toRemove.push(i);
            }
          }
          i++;
        }
        toRemove.reverse();
        for (index in toRemove) {
          currSamples.splice(index, 1);
        }
      }
      
      var layers = [];
      
      for (i in 0...3) {
        samples = generateSamplesInRect(rect.x, rect.y, rect.width, rect.height, minDist);
        layers.push(samples);
        minDist *= layerScale;
        if (i > 0) {
          filter(layers[i], layers[i - 1], minDist);
          if (layers.length > 1) {
            layers[i].concat(layers[i - 1]);
          }
        }
        var drawRadius = minDist * .5;
        drawSamples(tinyCanvasRect, layers[i], drawRadius, layerPalette, true);
      }
    };
    
    tinyCanvasRect.canvas.addEventListener("click", canvasRectOnClick);
    canvasRectOnClick();
  }

  
  // generate sample points inside the specified rectangle
  static function generateSamplesInRect(x:Float, y:Float, width:Float, height:Float, minDist:Float):Array<Point> {
    var topLeft = new Point(x, y);
    var bottomRight = new Point(x + width, y + height);
    
    var upd = new UniformPoissonDisk();
    
    upd.firstPoint = mousePos;
    return upd.sampleRectangle(topLeft, bottomRight, minDist, OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
  }
}

class Cache {
  
}