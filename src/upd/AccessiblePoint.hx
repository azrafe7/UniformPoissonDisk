// see:
// https://gist.github.com/andyli/6519310
// http://stackoverflow.com/questions/33094772/is-it-possible-to-use-haxe-type-constraints-with-both-class-fields-and-propertie

package upd;

import haxe.Constraints.Constructible;
import haxe.macro.Expr.ExprOf;


typedef ConstructiblePoint = Constructible<Float->Float->Void>;


/*
 * For compile-time function argument checking with `using`.
 */
abstract AccessiblePoint(Dynamic) 
from { var x:Float; var y:Float; }
from { var x(default, never):Float; var y(default, never):Float; }
from { var x(get, never):Float; var y(get, never):Float; }
{

  macro static public function getx(p1:ExprOf<AccessiblePoint>):ExprOf<Float>
  {
    return macro ($p1.x);
  }
  
  macro static public function gety(p1:ExprOf<AccessiblePoint>):ExprOf<Float>
  {
    return macro ($p1.y);
  }
  
  
  // these will be dynamic accessors on static targets (f.e. cpp)
  
  public var x(get, never):Float;
  inline function get_x():Float {
    return getx(this);
  }
  
  public var y(get, never):Float;
  inline function get_y():Float {
    return gety(this);
  }
}