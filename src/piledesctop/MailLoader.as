package piledesctop
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
	import flash.text.TextFormatAlign;
	
	public class MailLoader extends Sprite
	{
		private var bgLoader:PhotoLoader;
		private var stampLoader:PhotoLoader;
		private var bgWidth:int;
		private var bgHeight:int;
		private var file:File;
		
		[Embed(source="embed/stamp.png")]
		private var stampImage:Class;
		
		public function MailLoader():void {
			this.doubleClickEnabled = true;
		}
		
		public function load(f:File, maxw:int, maxh:int):void {
			this.file = f;
			bgWidth = maxw || parseInt(Config.xml.mail.@width) || 350;
			bgHeight = maxh || parseInt(Config.xml.mail.@height) || 250;
			
			// load background
			//MemoLoader.bgLoader = new PhotoLoader();
			bgLoader = new PhotoLoader();
			bgLoader.addEventListener("load", function():void {
				appendMemo();
			});
			bgLoader.load(new File("app:/assets/letter.png"), bgWidth, bgHeight);
		}
		
		private function appendMemo():void {
			var marginY:int = 5;
			var marginX:int = 20;
			
			// TextField
			var mail:Object = parseMail(readFileText());
			var tf:TextField = new TextField();
			tf.width = bgWidth - marginX*2 - 70;
			tf.height = bgHeight - marginY*2;
			tf.background = true;
			tf.backgroundColor = 0xFFFFFF;
			tf.selectable = false;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.text = mail.body;
			var format:TextFormat = new TextFormat();
			format.size = parseInt(Config.xml.memo.@font_size) || 16;
			format.font = "_sans";
			format.leading = 4;
			tf.setTextFormat(format);
			
			// from
			var fromTf:TextField = new TextField;
			fromTf.width = bgWidth - marginX*2;
			fromTf.selectable = false;
			fromTf.text = mail.from;
			var fromFormat:TextFormat = new TextFormat();
			fromFormat.align = TextFormatAlign.RIGHT;
			fromFormat.color = 0xFF0000;
			fromFormat.size = 14;
			fromTf.setTextFormat(fromFormat);
			
			// subject
			var subjTf:TextField = new TextField;
			subjTf.width = bgWidth - marginX*2 - 50;
			subjTf.selectable = false;
			subjTf.text = mail.subject;
			var subjFormat:TextFormat = new TextFormat();
			subjFormat.bold = true;
			subjFormat.size = parseInt(Config.xml.memo.@font_size) || 16;
			subjTf.setTextFormat(subjFormat);
			
			// stamp
			var stampBmp:Bitmap = new stampImage();
			
			// Matrix
			var fromMatrix:Matrix = new Matrix();
			fromMatrix.translate(marginX, marginY);
			var subjMatrix:Matrix = new Matrix();
			subjMatrix.translate(marginX, marginY+20);
			var bodyMatrix:Matrix = new Matrix();
			bodyMatrix.translate(marginX+10, marginY+50);
			var stampMatrix:Matrix = new Matrix();
			stampMatrix.translate(bgWidth-80, marginY+30);
			
			var bmpData:BitmapData = bgLoader.bitmap.bitmapData;
			bmpData.draw(tf, bodyMatrix, null, BlendMode.DARKEN, null, true);
			bmpData.draw(fromTf, fromMatrix, null, BlendMode.DARKEN, null, true);
			bmpData.draw(subjTf, subjMatrix, null, BlendMode.DARKEN, null, true);
			bmpData.draw(stampBmp, stampMatrix, null, BlendMode.DARKEN, null, true);
			var bmp:Bitmap = new Bitmap(bmpData);
			//bmp.x = -bmp.width/2;a
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
			return str;
		}
		
		private function parseMail(str:String):Object {
			var msg:Object = {
				from: "",
				to: "",
				subject: "",
				body: ""
			};
			str = str.replace(/\r\n/g, "\n");
			var i:int = str.indexOf("\n\n");
			if (i > 0) {
				msg.body = str.substr(i+2, 400);
				String(str.slice(0, i)).split("\n").forEach(function(line:String, index:int, array:Array):void {
					var j:int = line.indexOf(":");
					if (j > 0) {
						var key:String = line.slice(0, j).toLowerCase();
						if (msg.hasOwnProperty(key)) {
							msg[key] = String(line.substr(j+1)).replace(/^\s*(\S.*)$/, "$1");
						}
					}
				});
			} else {
				// No header
				msg.body = str.substr(0, 400);
			}
			return msg;
		}
	}
}