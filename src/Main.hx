import upd.AccessiblePoint;
import upd.APoint;
import upd.UniformPoissonDisk;

import upd.UniformPoissonDisk;

using upd.AccessiblePoint;


class Main {
  public static function main() {
    trace("hellp");
    
    var userof = new UserOf();
    var p = new Point(1, 2);
    var str = userof.use(p);
    trace(str);
    trace(p.x, p.y);
    trace(AccessiblePoint.getx(p));
    //trace(ap.__x());
    
    var n = new NPoint(0, -1.2);
    str = userof.use(n);
    trace(str);
    
    var upd = new UniformPoissonDisk<Point>();
  }
  
}

class Point {
  public var x(default, null):Float;
  public var y(default, null):Float;
  
  public function new(x:Float, y:Float):Void {
    this.x = x;
    this.y = y;
  }
}

class NPoint {
  public var x:Float;
  public var y:Float;
  
  public function new(x:Float, y:Float):Void {
    this.x = x;
    this.y = y;
  }
}