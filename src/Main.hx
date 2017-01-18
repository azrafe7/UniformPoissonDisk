package ;

import upd.UniformPoissonDisk;

using upd.AccessiblePoint;


class Main {
  public static function main() {
    
    var c = new CustomPoint(0, 0);
    var topLeft = new CustomPoint(-8, -8);
    var bottomRight = new CustomPoint(8, 8);
    var radius = 10.0;
    var minDist = 5;
    
    var upd = new UniformPoissonDisk<CustomPoint>();
    
    var samples = upd.sampleCircle(c, radius, minDist);
    trace("points(" + samples.length + ") sampled in circle(c=" + pointToStr(c) + ", r=" + radius + "): \n" + pointArrayToStr(samples) + "\n");
    
    var samples = upd.sampleRectangle(topLeft, bottomRight, minDist);
    trace("points(" + samples.length + ") sampled in rectangle(tl=" + pointToStr(topLeft) + ", br=" + pointToStr(bottomRight) + "): \n" + pointArrayToStr(samples));
  }
  
  @:generic
  static function pointToStr<P:AccessiblePoint>(p:P, decimals:Int = 2):String {
    var x = p.x;
    var y = p.y;
    if (decimals >= 0) {
      var pow = Math.pow(10, decimals);
      x = Math.fround(x * pow) / pow;
      y = Math.fround(y * pow) / pow;
    }
    return '($x,$y)';
  }
  
  @:generic
  static function pointArrayToStr<P:AccessiblePoint>(points:Array<P>):String {
    var strArr = [for (p in points) " " + pointToStr(p)];
    return strArr.join("\n");
  }
}

class CustomPoint {
  public var x(default, null):Float;
  public var y(default, null):Float;
  
  public function new(x:Float, y:Float):Void {
    this.x = x;
    this.y = y;
  }
}