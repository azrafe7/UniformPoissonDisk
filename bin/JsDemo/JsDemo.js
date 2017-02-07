// Generated by Haxe 3.4.0 (git build development @ d3955c6)
(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var JsDemo = function() { };
JsDemo.main = function() {
	var tinyCanvasRect = new TinyCanvas(JsDemo.WIDTH,JsDemo.HEIGHT,"canvas-samplerect");
	window.document.body.appendChild(tinyCanvasRect.canvas);
	JsDemo.initTinyCanvas(tinyCanvasRect,JsDemo.X,JsDemo.Y);
	var canvasRectOnClick = function(event) {
		var minDist = 15;
		var drawRadius = minDist * .85;
		var rect_y;
		var rect_x;
		var rect_width;
		var rect_height;
		rect_x = 15;
		rect_y = 15;
		rect_width = tinyCanvasRect.canvas.width - 30;
		rect_height = tinyCanvasRect.canvas.height - 30;
		if(event != null) {
			var rect = event.target.getBoundingClientRect();
			JsDemo.mousePos = new upd_SimplePoint(event.clientX - rect.left,event.clientY - rect.top);
		}
		var samples = JsDemo.generateCustomSamples(rect_x,rect_y,rect_width,rect_height,minDist);
		JsDemo.clearCanvas(tinyCanvasRect,JsDemo.rectPalette);
		TinyCanvas.drawRect(TinyCanvas.lineStyle(tinyCanvasRect,2.,JsDemo.BOUNDS_COLOR,.75),rect_x,rect_y,rect_width,rect_height);
		JsDemo.drawSamples(tinyCanvasRect,samples,drawRadius,JsDemo.rectPalette);
	};
	tinyCanvasRect.canvas.addEventListener("click",canvasRectOnClick);
	canvasRectOnClick();
	var tinyCanvasCircle = new TinyCanvas(JsDemo.WIDTH,JsDemo.HEIGHT,"canvas-samplecircle");
	window.document.body.appendChild(tinyCanvasCircle.canvas);
	JsDemo.initTinyCanvas(tinyCanvasCircle,JsDemo.X + JsDemo.WIDTH + JsDemo.SPACE,JsDemo.Y);
	var canvasCircleOnClick = function(event1) {
		var minDist1 = 15;
		var radius = tinyCanvasCircle.canvas.width * .45;
		var drawRadius1 = minDist1 * .75;
		var center_y;
		var center_x = tinyCanvasCircle.canvas.width * .5;
		center_y = tinyCanvasCircle.canvas.height * .5;
		var samples1 = JsDemo.generateSamplesInCircle(center_x,center_y,radius,minDist1);
		JsDemo.clearCanvas(tinyCanvasCircle,JsDemo.circlePalette);
		TinyCanvas.drawCircle(TinyCanvas.lineStyle(tinyCanvasCircle,2.,JsDemo.BOUNDS_COLOR,.75),center_x,center_y,radius);
		JsDemo.drawSamples(tinyCanvasCircle,samples1,drawRadius1,JsDemo.circlePalette);
	};
	tinyCanvasCircle.canvas.addEventListener("click",canvasCircleOnClick);
	canvasCircleOnClick();
};
JsDemo.initTinyCanvas = function(tinyCanvas,x,y) {
	var style = tinyCanvas.canvas.style;
	style.backgroundColor = "#000000";
	style.position = "absolute";
	style.left = x == null ? "null" : "" + x;
	style.top = y == null ? "null" : "" + y;
	style.cursor = "hand";
};
JsDemo.generateSamplesInRect = function(x,y,width,height,minDist) {
	var topLeft = new upd_SimplePoint(x,y);
	var bottomRight = new upd_SimplePoint(x + width,y + height);
	var upd1 = new upd_UniformPoissonDisk();
	return upd1.sampleRectangle(topLeft,bottomRight,minDist,JsDemo.OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
};
JsDemo.generateSamplesInCircle = function(cx,cy,radius,minDist) {
	var center = new upd_SimplePoint(cx,cy);
	var upd1 = new upd_UniformPoissonDisk();
	return upd1.sampleCircle(center,radius,minDist,JsDemo.OVERRIDE_DEFAULT_POINTS_PER_ITERATION);
};
JsDemo.generateCustomSamples = function(x,y,width,height,minDist) {
	var topLeft = new upd_SimplePoint(x,y);
	var bottomRight = new upd_SimplePoint(x + width,y + height);
	var upd1 = new upd_UniformPoissonDisk();
	var reject = function(p) {
		if(!(p.x < width * .5 && p.y < height * .5)) {
			if(p.x > width * .5) {
				return p.y > height * .5;
			} else {
				return false;
			}
		} else {
			return true;
		}
	};
	var minDistanceFunc = function(p1) {
		var dist = Math.random();
		var dist1 = minDist * dist;
		var min = upd_UniformPoissonDisk.MIN_DISTANCE_THRESHOLD;
		if(dist1 < min) {
			return min;
		} else if(dist1 > minDist) {
			return minDist;
		} else {
			return dist1;
		}
	};
	return upd1.sample(topLeft,bottomRight,minDistanceFunc,minDist,null,JsDemo.OVERRIDE_DEFAULT_POINTS_PER_ITERATION,JsDemo.mousePos);
};
JsDemo.drawSamples = function(tinyCanvas,samples,radius,palette) {
	var color = palette != null ? palette[0] : 16711680;
	var fillAlpha = .8;
	var p = samples[0];
	TinyCanvas.lineStyle(tinyCanvas,1.5,color,1);
	TinyCanvas.beginFill(tinyCanvas,color,fillAlpha);
	TinyCanvas.drawCircle(tinyCanvas,p.x,p.y,.25);
	TinyCanvas.drawCircle(tinyCanvas,p.x,p.y,radius);
	TinyCanvas.endFill(tinyCanvas);
	var _g = 0;
	while(_g < samples.length) {
		var p1 = samples[_g];
		++_g;
		color = JsDemo.getRandomColorFrom(palette,color);
		TinyCanvas.lineStyle(tinyCanvas,1.5,color,1);
		TinyCanvas.drawCircle(tinyCanvas,p1.x,p1.y,.25);
	}
};
JsDemo.clearCanvas = function(tinyCanvas,palette) {
	var color = palette != null ? palette[0] : 16711680;
	TinyCanvas.drawRect(TinyCanvas.lineStyle(TinyCanvas.clear(tinyCanvas),3,color,1),0,0,tinyCanvas.canvas.width,tinyCanvas.canvas.height);
};
JsDemo.getRandomColorFrom = function(palette,defaultColor) {
	if(palette == null || palette.length == 0) {
		return defaultColor;
	} else {
		return palette[Std.random(palette.length)];
	}
};
JsDemo.clamp = function(value,min,max) {
	if(value < min) {
		return min;
	} else if(value > max) {
		return max;
	} else {
		return value;
	}
};
JsDemo.grabMousePos = function(mouseEvent) {
	if(mouseEvent != null) {
		var rect = mouseEvent.target.getBoundingClientRect();
		JsDemo.mousePos = new upd_SimplePoint(mouseEvent.clientX - rect.left,mouseEvent.clientY - rect.top);
	}
};
var Std = function() { };
Std.random = function(x) {
	if(x <= 0) {
		return 0;
	} else {
		return Math.floor(Math.random() * x);
	}
};
var TinyCanvas = function(width,height,id,useThisCanvas) {
	if(useThisCanvas == null) {
		this.canvas = window.document.createElement("canvas");
	} else {
		this.canvas = useThisCanvas;
	}
	this.canvas.width = width;
	this.canvas.height = height;
	this.canvas.id = id;
	this.context = this.canvas.getContext("2d",null);
};
TinyCanvas.intToRgb = function(color) {
	return { r : color >> 16 & 255, g : color >> 8 & 255, b : color & 255};
};
TinyCanvas.clear = function(tinyCanvas) {
	var ctx = tinyCanvas.context;
	ctx.clearRect(0,0,tinyCanvas.canvas.width,tinyCanvas.canvas.height);
	return tinyCanvas;
};
TinyCanvas.lineStyle = function(tinyCanvas,thickness,color,alpha) {
	if(alpha == null) {
		alpha = 1.;
	}
	var ctx = tinyCanvas.context;
	ctx.lineWidth = thickness;
	var rgb_r;
	var rgb_g;
	var rgb_b;
	rgb_r = color >> 16 & 255;
	rgb_g = color >> 8 & 255;
	rgb_b = color & 255;
	if(alpha != 1.0) {
		ctx.strokeStyle = "rgba(" + rgb_r + ", " + rgb_g + ", " + rgb_b + ", " + alpha + ")";
	} else {
		ctx.strokeStyle = "rgb(" + rgb_r + ", " + rgb_g + ", " + rgb_b + ")";
	}
	return tinyCanvas;
};
TinyCanvas.beginFill = function(tinyCanvas,color,alpha) {
	if(alpha == null) {
		alpha = 1.;
	}
	var ctx = tinyCanvas.context;
	var rgb_r;
	var rgb_g;
	var rgb_b;
	rgb_r = color >> 16 & 255;
	rgb_g = color >> 8 & 255;
	rgb_b = color & 255;
	if(alpha != 1.0) {
		ctx.fillStyle = "rgba(" + rgb_r + ", " + rgb_g + ", " + rgb_b + ", " + alpha + ")";
	} else {
		ctx.fillStyle = "rgb(" + rgb_r + ", " + rgb_g + ", " + rgb_b + ")";
	}
	return tinyCanvas;
};
TinyCanvas.endFill = function(tinyCanvas) {
	var ctx = tinyCanvas.context;
	ctx.fill();
	return tinyCanvas;
};
TinyCanvas.moveTo = function(tinyCanvas,x,y) {
	var ctx = tinyCanvas.context;
	ctx.beginPath();
	ctx.moveTo(x,y);
	return tinyCanvas;
};
TinyCanvas.lineTo = function(tinyCanvas,x,y) {
	var ctx = tinyCanvas.context;
	ctx.lineTo(x,y);
	return tinyCanvas;
};
TinyCanvas.quadTo = function(tinyCanvas,cx,cy,ax,ay) {
	var ctx = tinyCanvas.context;
	ctx.quadraticCurveTo(cx,cy,ax,ay);
	return tinyCanvas;
};
TinyCanvas.stroke = function(tinyCanvas,closePath) {
	if(closePath == null) {
		closePath = true;
	}
	var ctx = tinyCanvas.context;
	ctx.stroke();
	if(closePath) {
		ctx.closePath();
	}
	return tinyCanvas;
};
TinyCanvas.drawCircle = function(tinyCanvas,x,y,radius) {
	var ctx = tinyCanvas.context;
	ctx.beginPath();
	ctx.arc(x,y,radius,0,2 * Math.PI,false);
	ctx.stroke();
	ctx.closePath();
	return tinyCanvas;
};
TinyCanvas.drawRect = function(tinyCanvas,x,y,width,height) {
	var ctx = tinyCanvas.context;
	ctx.beginPath();
	ctx.moveTo(x,y);
	ctx.lineTo(x + width,y);
	ctx.lineTo(x + width,y + height);
	ctx.lineTo(x,y + height);
	ctx.lineTo(x,y);
	ctx.stroke();
	ctx.closePath();
	return tinyCanvas;
};
TinyCanvas.main = function() {
	var tinyCanvas = new TinyCanvas(300,300,"canvas");
	window.document.body.appendChild(tinyCanvas.canvas);
	TinyCanvas.lineStyle(tinyCanvas,0,0,0);
	TinyCanvas.beginFill(tinyCanvas,65280);
	TinyCanvas.drawCircle(tinyCanvas,40,40,40);
	TinyCanvas.endFill(tinyCanvas);
	TinyCanvas.drawRect(TinyCanvas.lineStyle(TinyCanvas.endFill(TinyCanvas.drawRect(TinyCanvas.beginFill(tinyCanvas,16776960),0,0,40,40)),2.,16711680,1),0,0,40,40);
	TinyCanvas.quadTo(TinyCanvas.lineTo(TinyCanvas.lineTo(TinyCanvas.lineTo(TinyCanvas.moveTo(TinyCanvas.stroke(TinyCanvas.lineTo(TinyCanvas.moveTo(TinyCanvas.lineStyle(tinyCanvas,5,16777215,.5),0,0),50,50)),100,100),30,70),80,20),60,60),80,60,80,80);
	TinyCanvas.stroke(tinyCanvas);
	TinyCanvas.endFill(tinyCanvas);
};
TinyCanvas.prototype = {
	get_width: function() {
		return this.canvas.width;
	}
	,get_height: function() {
		return this.canvas.height;
	}
	,get_id: function() {
		return this.canvas.id;
	}
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var upd_SimplePoint = function(x,y) {
	this.x = x;
	this.y = y;
};
var upd_UniformPoissonDisk = function() {
	this.pointsPerIteration = upd_UniformPoissonDisk.DEFAULT_POINTS_PER_ITERATION;
	this.maxPointsReached = false;
};
upd_UniformPoissonDisk.makeConstMinDistance = function(minDistance) {
	return function(p) {
		return minDistance;
	};
};
upd_UniformPoissonDisk.prototype = {
	sampleCircle: function(center,radius,minDistance,pointsPerIteration) {
		var _gthis = this;
		var topLeft = new upd_SimplePoint(center.x - radius,center.y - radius);
		var bottomRight = new upd_SimplePoint(center.x + radius,center.y + radius);
		var radiusSquared = radius * radius;
		var reject = function(p) {
			var dx = center.x - p.x;
			var dy = center.y - p.y;
			return dx * dx + dy * dy > radiusSquared;
		};
		var minDistance1 = minDistance;
		return this.sample(topLeft,bottomRight,function(p1) {
			return minDistance1;
		},minDistance,reject,pointsPerIteration);
	}
	,sampleRectangle: function(topLeft,bottomRight,minDistance,pointsPerIteration) {
		var minDistance1 = minDistance;
		return this.sample(topLeft,bottomRight,function(p) {
			return minDistance1;
		},minDistance,null,pointsPerIteration);
	}
	,init: function(topLeft,bottomRight,minDistanceFunc,maxDistance,reject,pointsPerIteration) {
		if(pointsPerIteration == null) {
			this.pointsPerIteration = upd_UniformPoissonDisk.DEFAULT_POINTS_PER_ITERATION;
		}
		this.topLeft = topLeft;
		this.bottomRight = bottomRight;
		this.minDistanceFunc = minDistanceFunc;
		this.maxDistance = maxDistance;
		this.currMinDistance = 0;
		this.reject = reject;
		this.width = bottomRight.x - topLeft.x;
		this.height = bottomRight.y - topLeft.y;
		this.cellSize = maxDistance / upd_Tools.SQUARE_ROOT_TWO;
		this.gridWidth = (this.width / this.cellSize | 0) + 1;
		this.gridHeight = (this.height / this.cellSize | 0) + 1;
		this.grid = [];
		var _g1 = 0;
		var _g = this.gridHeight;
		while(_g1 < _g) {
			var y = _g1++;
			var tmp = this.grid;
			var _g2 = [];
			var _g4 = 0;
			var _g3 = this.gridWidth;
			while(_g4 < _g3) {
				var x = _g4++;
				_g2.push(null);
			}
			tmp.push(_g2);
		}
		this.activePoints = [];
		this.sampledPoints = [];
	}
	,sample: function(topLeft,bottomRight,minDistanceFunc,maxDistance,reject,pointsPerIteration,firstPoint) {
		this.init(topLeft,bottomRight,minDistanceFunc,maxDistance,reject,pointsPerIteration);
		this.addFirstPoint(firstPoint);
		while(this.activePoints.length != 0 && !this.maxPointsReached) {
			var randomIndex = Std.random(this.activePoints.length);
			var point = this.activePoints[randomIndex];
			var found = false;
			this.currMinDistance = minDistanceFunc(point);
			if(this.currMinDistance < upd_UniformPoissonDisk.MIN_DISTANCE_THRESHOLD) {
				throw new js__$Boot_HaxeError("Error: minDistance(" + this.currMinDistance + ") is below the threshold(" + upd_UniformPoissonDisk.MIN_DISTANCE_THRESHOLD + ")!");
			}
			if(this.currMinDistance > maxDistance) {
				throw new js__$Boot_HaxeError("Error: minDistance(" + this.currMinDistance + ") is greater than maxDistance(" + maxDistance + ")!");
			}
			var _g1 = 0;
			var _g = this.pointsPerIteration;
			while(_g1 < _g) {
				var k = _g1++;
				found = this.addNextPointAround(point);
				if(found) {
					break;
				}
			}
			if(!found) {
				this.activePoints.splice(randomIndex,1);
			}
		}
		return this.sampledPoints;
	}
	,addFirstPoint: function(firstPoint) {
		if(firstPoint != null) {
			var index = this.pointToGridCoords(firstPoint,this.topLeft,this.cellSize);
			this.addSampledPoint(firstPoint,index);
			return;
		}
		var added = false;
		var tries = upd_UniformPoissonDisk.FIRST_POINT_TRIES;
		while(!added && tries > 0) {
			--tries;
			var rndX = this.topLeft.x + this.width * Math.random();
			var rndY = this.topLeft.y + this.height * Math.random();
			var p = new upd_SimplePoint(rndX,rndY);
			if(this.reject != null && this.reject(p)) {
				continue;
			}
			added = true;
			var index1 = this.pointToGridCoords(p,this.topLeft,this.cellSize);
			this.addSampledPoint(p,index1);
		}
	}
	,addNextPointAround: function(point) {
		var q = this.randomPointAround(point,this.currMinDistance);
		var mustReject = this.reject != null && this.reject(q);
		if(q.x >= this.topLeft.x && q.x < this.bottomRight.x && q.y >= this.topLeft.y && q.y < this.bottomRight.y && !mustReject) {
			var qIndex = this.pointToGridCoords(q,this.topLeft,this.cellSize);
			if(!this.isInNeighbourhood(q,qIndex)) {
				this.addSampledPoint(q,qIndex);
				return true;
			}
		}
		return false;
	}
	,isInRectangle: function(point) {
		if(point.x >= this.topLeft.x && point.x < this.bottomRight.x && point.y >= this.topLeft.y) {
			return point.y < this.bottomRight.y;
		} else {
			return false;
		}
	}
	,isInNeighbourhood: function(point,index) {
		var currMinDistanceSquared = this.currMinDistance * this.currMinDistance;
		var col = Math.max(0,index.col - 2) | 0;
		while(col < Math.min(this.gridWidth,index.col + 3)) {
			var row = Math.max(0,index.row - 2) | 0;
			while(row < Math.min(this.gridHeight,index.row + 3)) {
				var cell = this.grid[row][col];
				if(cell != null) {
					var _g = 0;
					while(_g < cell.length) {
						var p = cell[_g];
						++_g;
						var tmp;
						if(cell != null) {
							var dx = p.x - point.x;
							var dy = p.y - point.y;
							tmp = dx * dx + dy * dy < currMinDistanceSquared;
						} else {
							tmp = false;
						}
						if(tmp) {
							return true;
						}
					}
				}
				++row;
			}
			++col;
		}
		return false;
	}
	,addSampledPoint: function(point,index) {
		this.activePoints.push(point);
		this.sampledPoints.push(point);
		var cell = this.grid[index.row][index.col];
		if(cell != null) {
			cell.push(point);
		} else {
			cell = [point];
			this.grid[index.row][index.col] = cell;
		}
		if(this.sampledPoints.length > upd_UniformPoissonDisk.MAX_POINTS) {
			this.maxPointsReached = true;
			console.log("Generated more than MAX_POINTS(" + upd_UniformPoissonDisk.MAX_POINTS + ")!");
		}
	}
	,randomPointAround: function(center,minDistance) {
		var d = Math.random();
		var radius = minDistance + minDistance * d;
		d = Math.random();
		var angle = upd_Tools.TWO_PI * d;
		var x = radius * Math.sin(angle);
		var y = radius * Math.cos(angle);
		return new upd_SimplePoint(center.x + x,center.y + y);
	}
	,pointToGridCoords: function(point,topLeft,cellSize) {
		return { row : (point.x - topLeft.x) / cellSize | 0, col : (point.y - topLeft.y) / cellSize | 0};
	}
	,distanceSquared: function(p,q) {
		var dx = p.x - q.x;
		var dy = p.y - q.y;
		return dx * dx + dy * dy;
	}
	,distance: function(p,q) {
		var dx = p.x - q.x;
		var dy = p.y - q.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
};
var upd_Tools = function() { };
upd_Tools.randomInt = function(upperBound) {
	return Std.random(upperBound);
};
upd_Tools.randomFloat = function(upperBound) {
	if(upperBound == null) {
		upperBound = 1.0;
	}
	return Math.random() * upperBound;
};
JsDemo.X = 15;
JsDemo.Y = 15;
JsDemo.SPACE = 15;
JsDemo.WIDTH = 200;
JsDemo.HEIGHT = 200;
JsDemo.BOUNDS_COLOR = 12632256;
JsDemo.RED_PALETTE = [16711680,16064512,14685461,16723984];
JsDemo.GREEN_PALETTE = [65280,62752,1433621,1113904];
JsDemo.FIRE_PALETTE = [16601145,16610051,16620879,16638337,16598019,16601145,16610051,16620879];
JsDemo.GRASS_PALETTE = [11137665,12249985,8181122,4116355,55684,5894785,12245889,8189314];
JsDemo.rectPalette = JsDemo.FIRE_PALETTE;
JsDemo.circlePalette = JsDemo.GRASS_PALETTE;
upd_UniformPoissonDisk.DEFAULT_POINTS_PER_ITERATION = 30;
upd_UniformPoissonDisk.FIRST_POINT_TRIES = 1000;
upd_UniformPoissonDisk.MAX_POINTS = 100;
upd_UniformPoissonDisk.MIN_DISTANCE_THRESHOLD = 1;
upd_Tools.PI = Math.PI;
upd_Tools.HALF_PI = Math.PI / 2;
upd_Tools.TWO_PI = Math.PI * 2;
upd_Tools.SQUARE_ROOT_TWO = Math.sqrt(2);
JsDemo.main();
})();

//# sourceMappingURL=JsDemo.js.map