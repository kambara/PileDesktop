package piledesctop.paper
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import piledesctop.*;

	public class Paper extends Sprite
	{
		protected var thumbX:int;
		protected var thumbY:int;
		protected var thumbRotation:int;
		
		protected var isZoom:Boolean = false;
		protected var _file:File;
		
		public function Paper(f:File, pos:Point) {
			this._file = f;
			this.thumbX = pos.x;
			this.thumbY = pos.y;
			this.thumbRotation = Util.rand(-10, 10);
			
			this.x = -1000;
			this.y = -1000;
			
			// drop shadow
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.alpha = 0.6;
			shadow.blurX = 10;
			shadow.blurY = 10;
			shadow.distance = 2;
			this.filters = [shadow];
			
			// events
			this.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
				this.doubleClickEnabled = true;
				if (!isZoom) {
					startDrag(false);
				}
			});
			this.addEventListener(MouseEvent.MOUSE_UP, function():void {
				stopDrag();
			});
			
			//this.doubleClickEnabled = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
		}
		
		public function get file():File {
			return this._file;
		}
		
		protected function doubleClickHandler(event:MouseEvent):void {
		}
		
		protected function moveIn():void {
			var theta:Number = Math.random() * Math.PI * 2;
			var dx:int = Math.round(Math.cos(theta) * 40);
			var dy:int = Math.round(Math.sin(theta) * 40);
			
			// start position
			this.alpha = 0;
			this.x = this.thumbX - dx;
			this.y = this.thumbY - dy;
			
			Tweener.addTween(this, {
				x: this.thumbX,
				y: this.thumbY,
				rotation: this.thumbRotation,
				time: 0.5,
				alpha: 1,
				transition: "easeOutCubic",
				onComplete: function():void {
					dispatchEvent(new Event("move_in"));
				}
			});
		}
	}
}