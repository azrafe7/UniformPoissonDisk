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
  
  static var mergedPalette = FIRE_PALETTE;
  static var layerPalette = OCEAN_PALETTE;

  
  public static function main() {
    
    var rect = {
      x: 15, 
      y: 15, 
      width: WIDTH - 30,
      height: HEIGHT - 30
    }
    
    var numLayers = 3;
    var layers = [];
    var filteredLayers = [];
    var minDistances = [6., 24, 54];
    var drawRadiusScales = [.5, .5, .5];
    var tinyCanvases = [];
    
    // merge canvas
    var tinyCanvasMerge = new TinyCanvas(WIDTH, HEIGHT, "canvas-sample-merged");
    document.body.appendChild(tinyCanvasMerge.canvas);
    initTinyCanvas(tinyCanvasMerge, X + (WIDTH + SPACE) * (numLayers), Y + (HEIGHT + SPACE) * 1);
    
    var canvasMergeOnClick = function(?event) {
      
      clearCanvas(tinyCanvasMerge, mergedPalette);
      
      // draw rect from which we're sampling
      tinyCanvasMerge.lineStyle(2., BOUNDS_COLOR, .75)
        .drawRect(rect.x, rect.y, rect.width, rect.height);
      
      filteredLayers = mergeLayers(layers, minDistances);
      
      for (i in 0...numLayers) {
        var drawRadius = minDistances[i] * drawRadiusScales[i];
        drawSamples(tinyCanvasMerge, filteredLayers[i], drawRadius, mergedPalette, true);
      }
    };
    
    
    // sample multi layers
    for (i in 0...numLayers) {
      var tinyCanvasLayer = new TinyCanvas(WIDTH, HEIGHT, "canvas-layer-" + i);
      document.body.appendChild(tinyCanvasLayer.canvas);
      initTinyCanvas(tinyCanvasLayer, X + (WIDTH + SPACE) * (0 + i), Y + (HEIGHT + SPACE) * 1);
      tinyCanvases.push(tinyCanvasLayer);
      
      var canvasOnClick = function(?event, layer:Int) {
        
        var tinyCanvas = tinyCanvases[layer];
        
        grabMousePos(event);
        
        clearCanvas(tinyCanvas, layerPalette);
        
        var minDistance = minDistances[layer];
        
        layers[layer] = generateSamplesInRect(rect.x, rect.y, rect.width, rect.height, minDistance);
        
        // draw rect from which we're sampling
        tinyCanvas.lineStyle(2., BOUNDS_COLOR, .75)
          .drawRect(rect.x, rect.y, rect.width, rect.height);
          
        var drawRadius = minDistance * drawRadiusScales[i];
        drawSamples(tinyCanvas, layers[layer], drawRadius, layerPalette, true);
        
        // trigger merging if all layers are populated
        if (layers.length == numLayers) canvasMergeOnClick();
      }
    
      tinyCanvases[i].canvas.addEventListener("click", canvasOnClick.bind(_, i));
      canvasOnClick(null, i);
    }
    
    tinyCanvasMerge.canvas.addEventListener("click", canvasMergeOnClick);
    canvasMergeOnClick();
  }

  // merge layers by filtering out points
  static function mergeLayers(layers:Array<Array<Point>>, minDistances:Array<Float>):Array<Array<Point>> {
    
    // copy layers
    var filteredLayers = [for (layer in layers) layer.concat([])];
    
    function filterOut(from:Int, into:Int):Void {
      
      filteredLayers[into] = filteredLayers[into].filter(function(p:Point):Bool {
        var minDistance = (minDistances[from] + minDistances[into]) * .5;
        for (q in filteredLayers[from]) {
          if (UpdTools.distanceSquared(q, p) < minDistance * minDistance) return false;
        }
        return true;
      });
    }
    
    var i = filteredLayers.length - 1;
    while (i > 0) {
      var j = i - 1;
      while (j >= 0) {
        filterOut(i, j);
        j--;
      }
      i--;
    }
    
    return filteredLayers;
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
