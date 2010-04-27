package piledesctop.paper
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import piledesctop.*;

	public class Memo extends Paper
	{
		////public static var bgLoader:PhotoLoader;
		private var bgWidth:int;
		private var bgHeight:int;
		
		public function Memo(f:File, pos:Point):void {
			super(f, pos);
			//trace("load txt: " + f.nativePath);
			
			bgWidth = parseInt(Config.xml.memo.@width) || 250;
			bgHeight = parseInt(Config.xml.memo.@height) || 350;
			
			var ml:MemoLoader = new MemoLoader();
			ml.addEventListener("load", function():void {
				ml.x = -ml.width/2;
				ml.y = -ml.height/2;
				addChild(ml);
				moveIn();
			});
			ml.load(f, bgWidth, bgHeight);
		}
		
		override protected function doubleClickHandler(event:MouseEvent):void {
			// invoke application
			Server.send(file.nativePath);
			////navigateToURL(new URLRequest(this.file.nativePath));
		}
	}
}