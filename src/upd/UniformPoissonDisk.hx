/** 
 * Uniform Poisson Disk Sampler (https://gist.github.com/azrafe7/9b89b6c59dfbe5a28530)
 * 
 * References:
 * 
 * http://theinstructionlimit.com/fast-uniform-poisson-disk-sampling-in-c (by Renaud Bédard)
 * 
 * Which in turn is:
 * 
 * Adapted from java source by Herman Tulleken
 * http://www.luma.co.za/labs/2008/02/27/poisson-disk-sampling/
 * 
 * The algorithm is from the "Fast Poisson Disk Sampling in Arbitrary Dimensions" paper by Robert Bridson
 * http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
 * 
 * And with filtering ideas from:
 * https://github.com/corporateshark/poisson-disk-generator
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


typedef GridIndex = Point;
typedef RejectionFunction = Point->Bool;
typedef MinDistFunction = Point->Bool;


/**
 * ...
 * @author azrafe7
 */
class UniformPoissonDisk {

  static public var DEFAULT_POINTS_PER_ITERATION:Int = 30;

  var pointsPerIteration:Int = DEFAULT_POINTS_PER_ITERATION;
  
  var topLeft:Point;
  var bottomRight:Point;
  var width:Float;
  var height:Float;
  
  var reject:Null<RejectionFunction>;
  var minDistance:Float;
  
  var grid:Array<Array<Point>>; // NB: Grid[y][x]
  var gridWidth:Int; 
  var gridHeight:Int;
  var cellSize:Float;

  var activePoints:Array<Point>;
  var sampledPoints:Array<Point>;

  
  public function new():Void 
  {
    
  }
  
  public function sampleCircle(center:Point, radius:Float, minDistance:Float, ?pointsPerIteration:Int):Array<Point> 
  {
    var topLeft = new Point(center.x - radius, center.y - radius);
    var bottomRight = new Point(center.x + radius, center.y + radius);
    var radiusSquared = radius * radius;
    
    function reject(p:Point):Bool {
      return distanceSquared(center, p) > radiusSquared;
    }
    
    return sample(topLeft, bottomRight, minDistance, reject, pointsPerIteration);
  }

  public function sampleRectangle(topLeft:Point, bottomRight:Point, minDistance:Float, ?pointsPerIteration:Int):Array<Point>
  {
    return sample(topLeft, bottomRight, minDistance, null, pointsPerIteration);
  }

  function init(topLeft:Point, bottomRight:Point, minDistance:Float, ?reject:RejectionFunction, ?pointsPerIteration:Int):Void {
    if (pointsPerIteration == null) this.pointsPerIteration = DEFAULT_POINTS_PER_ITERATION;

    this.topLeft = topLeft;
    this.bottomRight = bottomRight;
    this.minDistance = minDistance;
    this.reject = reject;
    
    this.width = bottomRight.x - topLeft.x;
    this.height = bottomRight.y - topLeft.y;
    this.cellSize = minDistance / Tools.SQUARE_ROOT_TWO;
    
    this.gridWidth = Std.int(width / cellSize) + 1;
    this.gridHeight = Std.int(height / cellSize) + 1;

    this.grid = new Array<Array<Point>>();
    for (y in 0...gridHeight) {
      this.grid.push( [for (x in 0...gridWidth) null] );
    }
    
    this.activePoints = new Array<Point>();
    this.sampledPoints = new Array<Point>();
  }
  
  public function sample(topLeft:Point, bottomRight:Point, minDistance:Float, ?reject:RejectionFunction, ?pointsPerIteration:Int):Array<Point>
  {
    init(topLeft, bottomRight, minDistance, reject, pointsPerIteration);
    
    addFirstPoint();

    while (activePoints.length != 0)
    {
      var randomIndex = Tools.randomInt(activePoints.length);

      var point = activePoints[randomIndex];
      var found = false;

      for (k in 0...this.pointsPerIteration) {
        found = addNextPoint(point);
        if (found) break;
      }

      if (!found)
        activePoints.splice(randomIndex, 1);
    }

    return sampledPoints;
  }

  function addFirstPoint():Void
  {
    var added = false;
    while (!added)
    {
      var d = Tools.randomFloat();
      var xr = topLeft.x + width * d;

      d = Tools.randomFloat();
      var yr = topLeft.y + height * d;

      var p = new Point(xr, yr);
      if (reject != null && reject(p))
        continue;
      
      added = true;

      var index = pointToGridCoords(p, topLeft, cellSize);

      grid[Std.int(index.y)][Std.int(index.x)] = p;

      activePoints.push(p);
      sampledPoints.push(p);
    } 
  }
  
  function isInRectangle(point:Point):Bool {
    return (point.x >= topLeft.x && point.x < bottomRight.x && 
            point.y >= topLeft.y && point.y < bottomRight.y);
  }

  // iterate the grid over a 5x5 square around `point` (identified by `index`)
  function isInNeighbourhood(point:Point, index:GridIndex):Bool {
    var i = Std.int(Math.max(0, index.x - 2));
    while (i < Math.min(gridWidth, index.x + 3))
    {
      //for (var j = (int) Math.Max(0, qIndex.y - 2); j < Math.Min(settings.GridHeight, qIndex.y + 3) && !tooClose; j++)
      var j = Std.int(Math.max(0, index.y - 2));
      while (j < Math.min(gridHeight, index.y + 3))
      {
        if (grid[j][i] != null && distance(grid[j][i], point) < minDistance) {
          return true;
        }
        j++;
      }
      i++;
    }
    return false;
  }
  
  function addPoint(point:Point) {
    var index = pointToGridCoords(point, topLeft, cellSize);
    activePoints.push(point);
    sampledPoints.push(point);
    grid[Std.int(index.y)][Std.int(index.x)] = point;
  }
  
  function addNextPoint(point:Point):Bool
  {
    var found = false;
    var q = randomPointAround(point, minDistance);
    var mustReject = reject != null && reject(q);

    if (isInRectangle(q) && !mustReject)
    {
      var qIndex = pointToGridCoords(q, topLeft, cellSize);
      var tooClose = isInNeighbourhood(q, qIndex);
      
      if (!tooClose)
      {
        found = true;
        activePoints.push(q);
        sampledPoints.push(q);
        grid[Std.int(qIndex.y)][Std.int(qIndex.x)] = q;
      }
    }
    return found;
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
  
  public function pointToGridCoords(point:Point, topLeft:Point, cellSize:Float):Point
  {
    return new Point(Std.int((point.x - topLeft.x) / cellSize), Std.int((point.y - topLeft.y) / cellSize));
  }
  
  public function distanceSquared(p:Point, q:Point):Float 
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