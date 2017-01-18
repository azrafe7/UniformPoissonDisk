package upd;

import upd.AccessiblePoint;
using upd.AccessiblePoint;


class UserOf {
  public function new():Void {
    
  }
  
  @:generic
  public function use< T:(AccessiblePoint, ConstructiblePoint) >(q:T):String {
    var p = new T(q.y, q.getx());
    return p.getx() + "," + p.gety();
  }
}