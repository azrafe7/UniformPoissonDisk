package ;

import upd.UniformPoissonDisk;


class Main {
  public static function main() {
    
    var c = new Point(0, 0);
    var topLeft = new Point(-8, -8);
    var bottomRight = new Point(8, 8);
    var radius = 10.0;
    var minDist = 5;
    
    var upd = new UniformPoissonDisk();
    
    var samples = upd.sampleCircle(c, radius, minDist);
    trace("points(" + samples.length + ") sampled in circle(c=" + pointToStr(c) + ", r=" + radius + "): \n" + pointArrayToStr(samples) + "\n");
    
    var samples = upd.sampleRectangle(topLeft, bottomRight, minDist);
    trace("points(" + samples.length + ") sampled in rectangle(tl=" + pointToStr(topLeft) + ", br=" + pointToStr(bottomRight) + "): \n" + pointArrayToStr(samples));
  }
  
  static function pointToStr(p:Point, decimals:Int = 2):String {
    var x = p.x;
    var y = p.y;
    if (decimals >= 0) {
      var pow = Math.pow(10, decimals);
      x = Math.fround(x * pow) / pow;
      y = Math.fround(y * pow) / pow;
    }
    return '($x,$y)';
  }
  
  static function pointArrayToStr(points:Array<Point>):String {
    var strArr = [for (p in points) " " + pointToStr(p)];
    return strArr.join("\n");
  }
}

