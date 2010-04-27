package piledesktop.cluster
{
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
	import piledesktop.*;
	import piledesktop.paper.*;

	public class Cluster extends EventDispatcher 
	{
		protected var index:int = 0;
		protected var files:Array;
		protected var container:UIComponent;
		
		private var maxOnDesk:Number = parseInt(Config.xml.max_on_desk) || 3;
		private var papers:Array;
		
		private var loopTimeoutId:uint;
		protected var loop:Boolean = true;
		
		public function Cluster(files:Array, container:UIComponent):void {
			this.files = files;
			this.container = container;
			this.papers = [];
			
			if (files.length < maxOnDesk) {
				this.maxOnDesk = files.length;
			}
			if (files.length > 0) {
				try {
					delayNext(1000);
				} catch (error:Error) {
					trace("append error");
				}
			}
		}
		
		protected function getRandomPos():Point {
			var x:int = Util.rand(100, container.stage.stageWidth - 100);
			var y:int = Util.rand(100, container.stage.stageHeight - 100);
			return new Point(x, y);
		}
		
		protected function createItem(f:File, pos:Point):Paper {
			return null;
		}
		
		protected function appendItem():void {
			if (index > files.length-1) {
				index = 0;
			}
			
			// Item Position
			var item:Paper;
			try {
				var f:File = File(files[index]);
				item = createItem(f, getRandomPos());
			} catch (error:Error) {
				return;
			}
			
			// Events
			item.addEventListener("move_in", function():void {
				var t:int = (papers.length < maxOnDesk) ? Util.rand(2000, 4000) : Util.rand(7000, 16000);
				delayNext(t);
			});
			item.addEventListener("load_error", function():void {
				delayNext(1000);
			});
			item.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
				container.setChildIndex(item, container.numChildren-1); // move to top
				// sort by depth
				papers = papers.sortOn(function(a:DisplayObject, b:DisplayObject):Number {
					var aIndex:int = container.getChildIndex(a);
					var bIndex:int = container.getChildIndex(b);
					if (a > b) return 1;
					if (a < b) return -1;
					return 0;
				});
			});
			
			// Add
			container.addChild(item);
			papers.push(item);
			index++;
		}
		
		public function stopLoop():void {
			loop = false;
			clearTimeout(loopTimeoutId);
		}
		
		public function restartLoop():void {
			loop = true;
			delayNext(2000);
		}
		
		private function delayNext(msec:int):void {
			loopTimeoutId = setTimeout(next, msec);
		}
		
		protected function next():void {
			if (!loop) return;
			
			if (papers.length >= maxOnDesk) {
				// fadeout and delete
				for each (var p:DisplayObject in papers.splice(0, papers.length - maxOnDesk + 1)) {
					Tweener.addTween(p, {
						time: 3,
						alpha: 0,
						onComplete: function():void {
							try {
								container.removeChild(p);
							} catch (e:Error) {
								trace(e.message);
							}
						}
					});
				}
			}
			appendItem();
		}
	}
}