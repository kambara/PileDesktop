package piledesktop
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	public class PhotoLoader extends Sprite
	{
		// 画像を読み込んである大きさに縮小する
		private var thumb:Bitmap;
		private var loader:Loader;
		private var maxWidth:int;
		private var maxHeight:int;
		
		public function PhotoLoader():void {
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void {
				dispatchEvent(new Event("load_error"));
			});
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			this.doubleClickEnabled = true;
		}
		
		public function load(file:File, maxw:int, maxh:int):void {
			this.maxWidth = maxw;
			this.maxHeight = maxh;
			loader.load(new URLRequest(file.nativePath));
		}
		
		public function get bitmap():Bitmap {
			return this.thumb;
		}
			
		private function onLoad(event:Event):void {
			if (maxWidth && maxHeight) {
				var origBmp:Bitmap = Bitmap(loader.content);
				thumb = this.resizeInsideBitmap(origBmp, maxWidth, maxHeight);

				// dispose
				origBmp.bitmapData.dispose();
				loader.unload();
			} else {
				thumb = Bitmap(loader.content);
			}
			thumb.smoothing = true;
			addChild(thumb);
			dispatchEvent(new Event("load"));
		}
		
		private function resizeInsideBitmap(origBmp:Bitmap, maxw:int, maxh:int):Bitmap {
			var thumbSize:Object = Util.insideSize(origBmp.bitmapData.width,
													origBmp.bitmapData.height,
													maxw,
													maxh);
			return resizeBitmap(origBmp, thumbSize.width, thumbSize.height);
		}
		
		private function resizeBitmap(bmp:Bitmap, w:int, h:int):Bitmap {
			var matrix:Matrix = new Matrix();
			matrix.scale(w/bmp.bitmapData.width, h/bmp.bitmapData.height);
			var newBmpData:BitmapData = new BitmapData(w, h);
			newBmpData.draw(bmp.bitmapData, matrix, null, null, null, true);
			return new Bitmap(newBmpData);
		}
	}
}