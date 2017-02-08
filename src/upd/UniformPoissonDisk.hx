/** 
 * Uniform Poisson Disk Sampler (https://gist.github.com/azrafe7/9b89b6c59dfbe5a28530)
 * 
 * References:
 * 
 * http://devmag.org.za/2009/05/03/poisson-disk-sampling/
 * http://theinstructionlimit.com/fast-uniform-poisson-disk-sampling-in-c (by Renaud Bédard)
 * 
 * The algorithm is from the "Fast Poisson Disk Sampling in Arbitrary Dimensions" paper by Robert Bridson
 * http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
 */   
 
package upd;

/* Make this typedef reference the real Point class (e.g. flash.geom.Point), 
 * which should implement this pseudo-interface:
 * 
 * interface {
 *   public var x(get, never):Float;
 *   public var y(get, never):Float;
 * 
 *   public function new(x:Float, y:Float):Void;
 * }
 */
typedef Point = SimplePoint;


typedef GridIndex = { row:Int, col:Int };
typedef PointArray = Array<Point>;
typedef RejectionFunction = Point->Bool;
typedef MinDistanceFunction = Point->Float;


/**
 * ...
 * @author azrafe7
 */
class UniformPoissonDisk {

  static public var DEFAULT_POINTS_PER_ITERATION:Int = 30;
  static public var FIRST_POINT_TRIES:Int = 1000;
  static public var MAX_POINTS = 100000;
  
  // debug only
  static public var MIN_DISTANCE_THRESHOLD = 1;
  
  var maxPointsReached:Bool = false;
  
  var pointsPerIteration:Int = DEFAULT_POINTS_PER_ITERATION;
  
  var topLeft:Point;
  var bottomRight:Point;
  var width:Float;
  var height:Float;
  
  var reject:Null<RejectionFunction>;
  var minDistanceFunc:MinDistanceFunction;
  var currMinDistance:Float;
  var maxDistance:Float;
  
  var grid:Array<Array<PointArray>>; // NB: Grid[y][x]
  var gridWidth:Int; 
  var gridHeight:Int;
  var cellSize:Float;

  var activePoints:Array<Point>;
  var sampledPoints:Array<Point>;
  
  public var firstPoint:Point;
  
  
  public function new(?firstPoint):Void 
  {
    if (firstPoint != null) this.firstPoint = firstPoint;
  }
  
  inline static public function makeConstMinDistance(minDistance:Float):MinDistanceFunction 
  {
    return function (p:Point):Float {
      return minDistance;
    }
  }
  
  public function sampleTriangle( triangle: Triangle, minDistance: Float, ?pointsPerIteration: Int):Array<Point>{
     return sample( triangle.topLeft, triangle.bottomRight, minDistance: Float, triangle.hitTest, pointsPerIteration );
  }
 
  public function sampleCircle(center:Point, radius:Float, minDistance:Float, ?pointsPerIteration:Int):Array<Point> 
  {
    var topLeft = new Point(center.x - radius, center.y - radius);
    var bottomRight = new Point(center.x + radius, center.y + radius);
    var radiusSquared = radius * radius;
    
    function reject(p:Point):Bool {
      return distanceSquared(center, p) > radiusSquared;
    }
    
    return sample(topLeft, bottomRight, makeConstMinDistance(minDistance), minDistance, reject, pointsPerIteration);
  }

  public function sampleRectangle(topLeft:Point, bottomRight:Point, minDistance:Float, ?pointsPerIteration:Int):Array<Point>
  {
    return sample(topLeft, bottomRight, makeConstMinDistance(minDistance), minDistance, null, pointsPerIteration);
  }

  function init(topLeft:Point, bottomRight:Point, minDistanceFunc:MinDistanceFunction, maxDistance:Float, ?reject:RejectionFunction, ?pointsPerIteration:Int):Void 
  {
    if (pointsPerIteration == null) this.pointsPerIteration = DEFAULT_POINTS_PER_ITERATION;
    else this.pointsPerIteration = pointsPerIteration;

    this.topLeft = topLeft;
    this.bottomRight = bottomRight;
    this.minDistanceFunc = minDistanceFunc;
    this.maxDistance = maxDistance;
    this.currMinDistance = 0;
    this.reject = reject;
    
    this.width = bottomRight.x - topLeft.x;
    this.height = bottomRight.y - topLeft.y;
    this.cellSize = maxDistance / Tools.SQUARE_ROOT_TWO;
    
    this.gridWidth = Std.int(width / cellSize) + 1;
    this.gridHeight = Std.int(height / cellSize) + 1;

    this.grid = new Array<Array<PointArray>>();
    for (y in 0...gridHeight) {
      this.grid.push( [for (x in 0...gridWidth) null] );
    }
    
    this.activePoints = new Array<Point>();
    this.sampledPoints = new Array<Point>();
  }
  
  // this is the workhorse
  public function sample(topLeft:Point, bottomRight:Point, minDistanceFunc:MinDistanceFunction, maxDistance:Float, ?reject:RejectionFunction, ?pointsPerIteration:Int):Array<Point>
  {
    init(topLeft, bottomRight, minDistanceFunc, maxDistance, reject, pointsPerIteration);
    
    addFirstPoint();

    while (activePoints.length != 0 && !maxPointsReached)
    {
      var randomIndex = Tools.randomInt(activePoints.length);

      var point = activePoints[randomIndex];
      var found = false;
      
      currMinDistance = minDistanceFunc(point);
  
    #if (debug)
      if (currMinDistance < MIN_DISTANCE_THRESHOLD) 
        throw 'Error: minDistance($currMinDistance) is below the threshold($MIN_DISTANCE_THRESHOLD)!';
      if (currMinDistance > maxDistance) 
        throw 'Error: minDistance($currMinDistance) is greater than maxDistance($maxDistance)!';
    #end

      for (k in 0...this.pointsPerIteration) {
        found = addNextPointAround(point);
        if (found) break;
      }

      if (!found) // remove point
        activePoints.splice(randomIndex, 1);
    }

    return sampledPoints;
  }

  function addFirstPoint():Void
  {
    // add a custom first point instead of finding a random one
    if (this.firstPoint != null) {
      var index = pointToGridCoords(firstPoint, topLeft, cellSize);
      addSampledPoint(firstPoint, index);
      return;
    }

    var added = false;
    var tries = FIRST_POINT_TRIES;
    
    while (!added && tries > 0)
    {
      tries--;

      var rndX = topLeft.x + width * Tools.randomFloat();
      var rndY = topLeft.y + height * Tools.randomFloat();

      var p = new Point(rndX, rndY);
      if (reject != null && reject(p))
        continue;
      
      added = true;

      var index = pointToGridCoords(p, topLeft, cellSize);
      addSampledPoint(p, index);
    } 
  }
  
  function addNextPointAround(point:Point):Bool
  {
    var q = randomPointAround(point, currMinDistance);
    var mustReject = (reject != null && reject(q));

    if (isInRectangle(q) && !mustReject)
    {
      var qIndex = pointToGridCoords(q, topLeft, cellSize);
      if (!isInNeighbourhood(q, qIndex))
      {
        addSampledPoint(q, qIndex);
        return true;
      }
    }
    return false;
  }
  
  inline function isInRectangle(point:Point):Bool 
  {
    return (point.x >= topLeft.x && point.x < bottomRight.x && 
            point.y >= topLeft.y && point.y < bottomRight.y);
  }

  // iterate the grid over a 5x5 square around `point` (identified by `index`)
  function isInNeighbourhood(point:Point, index:GridIndex):Bool 
  {
    var currMinDistanceSquared = currMinDistance * currMinDistance;
    
    var col = Std.int(Math.max(0, index.col - 2));
    while (col < Math.min(gridWidth, index.col + 3))
    {
      var row = Std.int(Math.max(0, index.row - 2));
      while (row < Math.min(gridHeight, index.row + 3))
      {
        var cell = grid[row][col];
        if (cell != null) {
          for (p in cell) {
            if (cell != null && distanceSquared(p, point) < currMinDistanceSquared) {
              return true;
            }
          }
        }
        row++;
      }
      col++;
    }
    return false;
  }
  
  function addSampledPoint(point:Point, index:GridIndex):Void
  {
    activePoints.push(point);
    sampledPoints.push(point);
    var cell = grid[index.row][index.col];
    if (cell != null) {
      cell.push(point);
    } else {
      cell = [point];
      grid[index.row][index.col] = cell;
    }
    
    if (sampledPoints.length > MAX_POINTS) {
      maxPointsReached = true;
      trace('Generated more than MAX_POINTS($MAX_POINTS)!');
    }
  }
  
  // random point in the annulus centered at `center` and with `minRadius = minDistance` and `maxRadius = 2 * minDistance`
  public function randomPointAround(center:Point, minDistance:Float):Point
  {
    var d = Tools.randomFloat();
    var radius = minDistance + minDistance * d;

    d = Tools.randomFloat();
    var angle = Tools.TWO_PI * d;

    var x = radius * Math.sin(angle);
    var y = radius * Math.cos(angle);

    return new Point((center.x + x), (center.y + y));
  }
  
  function pointToGridCoords(point:Point, topLeft:Point, cellSize:Float):GridIndex
  {
    return {
      row: Std.int((point.y - topLeft.y) / cellSize), 
      col: Std.int((point.x - topLeft.x) / cellSize)
    }
  }
  
  inline public function distanceSquared(p:Point, q:Point):Float 
  {
    var dx = p.x - q.x;
    var dy = p.y - q.y;
    return dx * dx + dy * dy;
  }
  
  inline public function distance(p:Point, q:Point):Float 
  {
    return Math.sqrt(distanceSquared(p, q));
  }
}


class Tools
{
  static public var PI(default, never):Float = Math.PI;
  static public var HALF_PI(default, never):Float = (Math.PI / 2);
  static public var TWO_PI(default, never):Float = (Math.PI * 2);
  static public var SQUARE_ROOT_TWO(default, never):Float = Math.sqrt(2);
  
  inline static public function randomInt(upperBound:Int):Int 
  {
    return Std.random(upperBound);
  }
  
  inline static public function randomFloat(upperBound:Float = 1.0):Float 
  {
    return Math.random() * upperBound;
  }
}
