package piledesktop.paper
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import piledesktop.*;
	
	public class SubDir extends Paper
	{
		private var dirInfo:DirInfo;
		
		public function SubDir(d:File, pos:Point):void {
			super(d, pos);
			
			dirInfo = new DirInfo(d);
			if (dirInfo.imageFiles.length
				+ dirInfo.textFiles.length
				+ dirInfo.mailFiles.length == 0) {
				throw new Error("no files");
			}
			
			this.thumbRotation = Util.rand(-5, 5);
			this.scaleY = 0.9;

			// クリップ
			var clipLoader:Loader = new Loader();
			clipLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void {
				var bmp:Bitmap = Bitmap(clipLoader.content);
				bmp.smoothing = true;
				bmp.x = 10;
				bmp.y = -5;
				bmp.rotation = 10;
				addChild(bmp);
			});
			clipLoader.load(new URLRequest("app:/assets/clip.png"));
			
			// 写真優先で表示
			pileImages(0, 4);
			//moveIn();
		}
		
		override protected function doubleClickHandler(event:MouseEvent):void {
			var e:SubDirEvent = new SubDirEvent(this.dirInfo.dir);
			dispatchEvent(e);
		}
		
		private function pileMails(index:int, max:int, upper:DisplayObject = null):void {
			if (index >= max || !dirInfo.mailFiles[index]) {
				moveIn();
				return;
			}
			
			var mailLoader:MailLoader = new MailLoader();
			mailLoader.addEventListener("load", function(event:Event):void {
				place(index, mailLoader, upper);
				setTimeout(function():void {
					pileMemos(index + 1, max, mailLoader);
				}, 500);
			});
			mailLoader.load(dirInfo.mailFiles[index], 250, 250);
		}
		
		private function pileMemos(index:int, max:int, upper:DisplayObject = null):void {
			if (index >= max) {
				moveIn();
				return;
			}
			if (!dirInfo.textFiles[index]) {
				pileMails(0, max-index, upper);
				return;
			}
			
			var memoLoader:MemoLoader = new MemoLoader();
			memoLoader.addEventListener("load", function(event:Event):void {
				place(index, memoLoader, upper);
				setTimeout(function():void {
					pileMemos(index + 1, max, memoLoader);
				}, 500);
			});
			memoLoader.load(dirInfo.textFiles[index], 250, 250);
		}
		
		private function pileImages(index:int, max:int, upper:DisplayObject = null):void {
			if (index >= max) {
				moveIn();
				return;
			}
			if (!dirInfo.imageFiles[index]) {
				pileMemos(0, max-index, upper);
				return;
			}
			
			var photoLoader:PhotoLoader = new PhotoLoader();
			photoLoader.addEventListener("load", function(event:Event):void {
				place(index, photoLoader, upper);
				setTimeout(function():void {
					pileImages(index + 1, max, photoLoader);
				}, 500);
			});
			photoLoader.load(dirInfo.imageFiles[index], 300, 200);
		}
		
		private function place(index:int, paper:DisplayObject, upper:DisplayObject = null):void {
			if (upper) {
				paper.x = upper.x - 10 + index*2;
				paper.y = upper.y + 10 - index*2;
				paper.rotation = upper.rotation + 15 - index*3;
			} else {
				paper.rotation = 15;
			}
			// drop shadow
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.alpha = 0.8;
			shadow.distance = 2;
			shadow.angle = 90;
			paper.filters = [shadow];
			
			// add at bottom
			addChildAt(paper, 0);
		}
	}
}