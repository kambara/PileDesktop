package piledesktop.paper
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import piledesktop.*;
	
	public class Mail extends Paper
	{
		private var bgWidth:int;
		private var bgHeight:int;
		
		public function Mail(f:File, pos:Point):void {
			super(f, pos);
			//trace("load txt: " + f.nativePath);
			
			var replyButton:Loader = new Loader();
			replyButton.load(new URLRequest("app:/assets/Return_Arrow_32.png"));
			replyButton.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void {
				Bitmap(replyButton.content).smoothing = true;
			});
			replyButton.addEventListener(MouseEvent.CLICK, function():void {
				if (Config.xml.mail && Config.xml.mail.@reply_cmd) {
					// mail
					Server.sendCmd(
						Config.xml.mail.@reply_cmd,
						file.nativePath);
				}
			});
			
			bgWidth = parseInt(Config.xml.mail.@width) || 250;
			bgHeight = parseInt(Config.xml.mail.@height) || 350;
			
			var ml:MailLoader = new MailLoader();
			ml.addEventListener("load", function():void {
				ml.x = -ml.width/2;
				ml.y = -ml.height/2;
				addChild(ml);
				moveIn();
				
				// addButton
				addChild(replyButton);
				replyButton.x = ml.width/2 - 10;
				replyButton.y = -ml.height/2 - 10;
			});
			ml.load(f, bgWidth, bgHeight);
		}
		
		override protected function doubleClickHandler(event:MouseEvent):void {
			// invoke application
			if (Config.xml.mail && Config.xml.mail.@open_cmd) {
				// mail
				Server.sendCmd(
					Config.xml.mail.@open_cmd,
					file.nativePath);
			} else {
				Server.send(file.nativePath);
			}
			////navigateToURL(new URLRequest(this.file.nativePath));
		}
	}
}