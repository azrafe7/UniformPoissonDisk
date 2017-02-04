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


typedef Settings = {
  var topLeft:Point;
  var bottomRight:Point;
  var center:Point;
  var dimensions:Point;
  var rejectionSqDistance:Null<Float>;
  var minimumDistance:Float;
  var cellSize:Float;
  var gridWidth:Int; 
  var gridHeight:Int;
}

typedef State = {
  var grid:Array<Array<Point>>; // NB: Grid[y][x]
  var activePoints:Array<Point>;
  var points:Array<Point>;
}


/**
 * ...
 * @author azrafe7
 */
class UniformPoissonDisk {

  public var DEFAULT_POINTS_PER_ITERATION:Int = 30;

  
  public function new():Void 
  {
    
  }
  
  public function sampleCircle(center:Point, radius:Float, minimumDistance:Float, ?pointsPerIteration:Int):Array<Point> 
  {
    if (pointsPerIteration == null) pointsPerIteration = DEFAULT_POINTS_PER_ITERATION;

    var topLeft = new Point(center.x - radius, center.y - radius);
    var bottomRight = new Point(center.x + radius, center.y + radius);
    return sample(topLeft, bottomRight, radius, minimumDistance, pointsPerIteration);
  }

  public function sampleRectangle(topLeft:Point, bottomRight:Point, minimumDistance:Float, ?pointsPerIteration:Int):Array<Point>
  {
    if (pointsPerIteration == null) pointsPerIteration = DEFAULT_POINTS_PER_ITERATION;

    return sample(topLeft, bottomRight, null, minimumDistance, pointsPerIteration);
  }

  
  function sample(topLeft:Point, bottomRight:Point, ?rejectionDistance:Float, minimumDistance:Float, pointsPerIteration:Int):Array<Point>
  {
    var dimensions = new Point(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
    var cellSize = minimumDistance / Tools.SQUARE_ROOT_TWO;
    
    var settings:Settings = 
    {
      topLeft : topLeft, bottomRight : bottomRight,
      dimensions : dimensions,
      center : new Point((topLeft.x + bottomRight.x) / 2, (topLeft.y + bottomRight.y) / 2),
      cellSize : cellSize,
      minimumDistance : minimumDistance,
      rejectionSqDistance : rejectionDistance == null ? null : rejectionDistance * rejectionDistance,
      gridWidth : Std.int(dimensions.x / cellSize) + 1,
      gridHeight : Std.int(dimensions.y / cellSize) + 1,
    };

    var grid = new Array<Array<Point>>();
    for (y in 0...settings.gridHeight) {
      grid.push( [for (x in 0...settings.gridWidth) null] );
    }
    
    var state:State = 
    {
      activePoints : new Array<Point>(),
      points : new Array<Point>(),
      grid : grid,
    };

    addFirstPoint(settings, state);

    while (state.activePoints.length != 0)
    {
      var listIndex = Tools.randomInt(state.activePoints.length);

      var point = state.activePoints[listIndex];
      var found = false;

      for (k in 0...pointsPerIteration)
        found = found || addNextPoint(point, settings, state);

      if (!found)
        state.activePoints.splice(listIndex, 1);
    }

    return state.points;
  }

  function addFirstPoint(settings:Settings, state:State):Void
  {
    var added = false;
    while (!added)
    {
      var d = Tools.randomFloat();
      var xr = settings.topLeft.x + settings.dimensions.x * d;

      d = Tools.randomFloat();
      var yr = settings.topLeft.y + settings.dimensions.y * d;

      var p = new Point(xr, yr);
      if (settings.rejectionSqDistance != null && distanceSquared(settings.center, p) > settings.rejectionSqDistance)
        continue;
      
      added = true;

      var index = denormalize(p, settings.topLeft, settings.cellSize);

      state.grid[Std.int(index.y)][Std.int(index.x)] = p;

      state.activePoints.push(p);
      state.points.push(p);
    } 
  }
  
  function addNextPoint(point:Point, settings:Settings, state:State):Bool
  {
    var found = false;
    var q = randomPointAround(point, settings.minimumDistance);

    if (q.x >= settings.topLeft.x && q.x < settings.bottomRight.x && 
        q.y > settings.topLeft.y && q.y < settings.bottomRight.y &&
        (settings.rejectionSqDistance == null || distanceSquared(settings.center, q) <= settings.rejectionSqDistance))
    {
      var qIndex = denormalize(q, settings.topLeft, settings.cellSize);
      var tooClose = false;

      //for (var i = (int) Math.Max(0, qIndex.x - 2); i < Math.Min(settings.GridWidth, qIndex.x + 3) && !tooClose; i++)
      var i = Std.int(Math.max(0, qIndex.x - 2));
      while (i < Math.min(settings.gridWidth, qIndex.x + 3) && !tooClose)
      {
        //for (var j = (int) Math.Max(0, qIndex.y - 2); j < Math.Min(settings.GridHeight, qIndex.y + 3) && !tooClose; j++)
        var j = Std.int(Math.max(0, qIndex.y - 2));
        while (j < Math.min(settings.gridHeight, qIndex.y + 3) && !tooClose)
        {
          if (state.grid[j][i] != null && distance(state.grid[j][i], q) < settings.minimumDistance) {
            tooClose = true;
          }
          j++;
        }
        i++;
      }

      if (!tooClose)
      {
        found = true;
        state.activePoints.push(q);
        state.points.push(q);
        state.grid[Std.int(qIndex.y)][Std.int(qIndex.x)] = q;
      }
    }
    return found;
  }
  
  public function randomPointAround(center:Point, minimumDistance:Float):Point
  {
    var d = Tools.randomFloat();
    var radius = minimumDistance + minimumDistance * d;

    d = Tools.randomFloat();
    var angle = Tools.TWO_PI * d;

    var newX = radius * Math.sin(angle);
    var newY = radius * Math.cos(angle);

    return new Point((center.x + newX), (center.y + newY));
  }
  
  public function denormalize(point:Point, origin:Point, cellSize:Float):Point
  {
    return new Point(Std.int((point.x - origin.x) / cellSize), Std.int((point.y - origin.y) / cellSize));
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