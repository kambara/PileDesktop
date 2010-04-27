package piledesktop.paper
{
	import caurina.transitions.Tweener;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	
	import piledesktop.*;

	public class Photo extends Paper
	{
		////private var zoomImage:Bitmap;
		private var loader:PhotoLoader;
		protected var thumbWidth:int;
		protected var thumbHeight:int;
		
		public function Photo(f:File, pos:Point):void {
			super(f, pos);
			
			// todo: background
			appendThumbnail();
		}
		
		private function appendThumbnail():void {
			loader = new PhotoLoader();
			//loader.doubleClickEnabled = true;
			
			loader.addEventListener("load_error", function():void {
				dispatchEvent(new Event("load_error"));
			});
			
			loader.addEventListener("load", function():void {
				if (!stage) return;
				loader.x = -loader.width/2;
				loader.y = -loader.height/2;
				addChild(loader);
				moveIn();
			});
			
			loader.load(file,
						parseInt(Config.xml.photo.@width) || 360,
						parseInt(Config.xml.photo.@height) || 360);
		}
		
		override protected function doubleClickHandler(event:MouseEvent):void {
			if (Config.xml.photo
				&& Config.xml.photo.@open_cmd
				&& Config.xml.photo.@open_cmd.toString().length > 0) {
				// mail
				trace("open");
				Server.sendCmd(
					Config.xml.photo.@open_cmd,
					file.nativePath);
					
			} else {
				if (isZoom) {
					this.zoomOut();
				} else {
					this.zoomIn();
				}
			}
		}
		
		private function zoomIn():void {
			dispatchEvent(new Event("zoom_in_start"));
			stopDrag();
			
			this.isZoom = true;
			this.thumbX = this.x;
			this.thumbY = this.y;
			this.thumbWidth = loader.width;
			this.thumbHeight = loader.height;
			
			////var margin:int = 0;
			var padding:int = 70;
			var sw:int = stage.stageWidth - padding*2; 
			var sh:int = stage.stageHeight - 42 - padding*2;
			
			var size:Object = Util.insideSize(loader.bitmap.width,
											loader.bitmap.height,
											sw, sh);
			
			Tweener.addTween(this, {
				x: stage.stageWidth/2,//(sw - size.width) /2 + padding,
				y: (stage.stageHeight - 42)/2,//(sh - size.height) /2 + padding,
				width: size.width,
				height: size.height,
				rotation: 0,
				time: 0.5,
				transition: "easeOutCubic",
				onComplete: function():void {
					dispatchEvent(new Event("zoom_in_complete"));
				}
			});
		}
		
		private function zoomOut():void {
			this.isZoom = false;
			
			Tweener.addTween(this, {
				x: thumbX,
				y: thumbY,
				width: thumbWidth,
				height: thumbHeight,
				rotation: thumbRotation,
				time: 0.5,
				transition: "easeOutCubic",
				onComplete: function():void {
					dispatchEvent(new Event("zoom_out"));
				}
			});
		}
		
		public function shrink():void {
			this.isZoom = false;
			x = thumbX;
			y = thumbY;
			width = thumbWidth;
			height = thumbHeight;
			rotation = thumbRotation;
		}
	}
}
