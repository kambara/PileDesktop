package piledesctop
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.Socket;
	
	public class Server
	{
		public static function sendCmd(cmd:String, param:String = ""):void {
			Server.send('"' + cmd + '"\n' + param);
		}
		
		public static function send(msg:String):void {
			var socket:Socket = new Socket();
			socket.addEventListener(Event.CONNECT, function():void {
				trace("connect");
				trace("send: " + msg);
				socket.writeUTFBytes(msg);
			});
			socket.addEventListener(Event.CLOSE, function():void {
				trace("connection closed");
			});
			socket.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace("ioErrorHandler: "+event.text);
			});
			
			try {
				socket.connect(
					Config.xml.server.@host || "localhost",
					Config.xml.server.@port);
			} catch(e:Error) {
				trace(e.message);
			}
		}
	}
}