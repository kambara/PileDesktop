package piledesktop
{
	import flash.geom.Point;
	
	public class Util
	{
		public static function rand(min:int, max:int):int {
			var n:Number = min + Math.random() * (max - min);
			return Math.round(n);
		}
		
		public static function randPoint(left:int, right:int, top:int, bottom:int):Point {
			var x:int = Util.rand(left, right);
			var y:int = Util.rand(top, bottom);
			return new Point(x, y);
		}
		
		public static function insideSize(w:int, h:int, maxWidth:int, maxHeight:int):Object {
			// increse if small
			if (w < maxWidth && h < maxHeight) {
				h = h * maxWidth/w;
				w = maxWidth;
			}
			
			// shrink
			if (w > maxWidth) {
				h = h * maxWidth/w;
				w = maxWidth;
			}
			if (h > maxHeight) {
				w = w * maxHeight/h;
				h = maxHeight;
			}
			return {
				width: w,
				height: h
			};
		}
	}
}