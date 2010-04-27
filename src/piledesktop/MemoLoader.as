package piledesktop
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class MemoLoader extends Sprite
	{
		//public static var bgLoader:PhotoLoader;
		//public static var bgCache:BitmapData;
		//public static var bgFileCache:File;
		private var bgLoader:PhotoLoader;
		private var bgWidth:int;
		private var bgHeight:int;
		private var file:File;
		
		public function MemoLoader():void {
			this.doubleClickEnabled = true;
		}
		
		public function load(f:File, maxw:int, maxh:int):void {
			this.file = f;
			bgWidth = maxw || parseInt(Config.xml.memo.@width) || 250;
			bgHeight = maxh || parseInt(Config.xml.memo.@height) || 350;
			
			// load background
			//MemoLoader.bgLoader = new PhotoLoader();
			bgLoader = new PhotoLoader();
			bgLoader.addEventListener("load", function():void {
				appendMemo();
			});
			bgLoader.load(new File("app:/assets/paper.png"), bgWidth, bgHeight);
		}
		
		private function appendMemo():void {
			var margin:int = 15;
			
			// TextField
			var str:String = readFileText();
			var tf:TextField = new TextField();
			tf.width = bgWidth - margin*2;
			tf.height = bgHeight - margin*2;
			tf.background = true;
			tf.backgroundColor = 0xFFFFFF;
			tf.selectable = false;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.text = str;
			var format:TextFormat = new TextFormat();
			format.size = parseInt(Config.xml.memo.@font_size) || 16;
			format.font = "_sans";
			format.leading = 4;
			tf.setTextFormat(format);
			
			// Bitmap
			var matrix:Matrix = new Matrix();
			matrix.translate(margin, margin);
			var bmpData:BitmapData = bgLoader.bitmap.bitmapData;
			bmpData.draw(tf, matrix, null, BlendMode.DARKEN, null, true);
			var bmp:Bitmap = new Bitmap(bmpData);
			//bmp.x = -bmp.width/2;
			//bmp.y = -bmp.height/2;
			bmp.smoothing = true;
			addChild(bmp);
			
			dispatchEvent(new Event("load"));
		}

		private function readFileText():String {
			var charset:String = Config.xml.memo.@charset || File.systemCharset;
			var stream:FileStream = new FileStream();
			var str:String = "";
			try {
				stream.open(file, FileMode.READ);
				str = stream.readMultiByte(stream.bytesAvailable, charset);
			} catch (error:Error) {
				trace(error.message);
			} finally {
				stream.close();
			}
			str = str.substr(0, 500).replace(/\r\n/g, "\n");
			return str;
		}
	}
}