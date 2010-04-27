package piledesktop.cluster
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import piledesktop.*;
	import piledesktop.paper.*;
	
	public class PhotoCluster extends Cluster
	{
		private var zoomedItem:Paper;
		
		public function PhotoCluster(files:Array, container:UIComponent):void {
			super(files, container);
			
			// todo slideshow
			this.addEventListener("zoom_in_complete", onZoomIn);
		}
		override protected function createItem(f:File, pos:Point):Paper {
			var item:Paper = new Photo(f, pos);
			item.addEventListener("zoom_in_start", function(evt:Event):void {
				zoomedItem = item;
				dispatchEvent(evt);
			});
			item.addEventListener("zoom_in_complete", function(evt:Event):void {
				dispatchEvent(evt);
			});
			item.addEventListener("zoom_out", function():void {
				dispatchEvent(new Event("zoom_out"));
			});
			return item;
		}
		override protected function getRandomPos():Point {
			if (!container.stage) {
				throw new Error("no stage");
			}
			var margin:int = 50;
			return Util.randPoint(
				margin,
				container.stage.stageWidth/2 - margin,
				margin,
				container.stage.stageHeight*2/3 - margin
			);
		}
		
		private function onZoomIn(event:Event):void {
			var slideshow:Slideshow = new Slideshow(files, Photo(zoomedItem));
			slideshow.addEventListener(Event.CLOSE, function(event:Event):void {
				container.removeChild(slideshow);
				Photo(zoomedItem).shrink();
				dispatchEvent(new Event("zoom_out"));
			});
			container.addChild(slideshow);
		}
	}
}