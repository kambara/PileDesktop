package piledesktop
{
	import flash.filesystem.*;
	
	public class Config
	{
		public static var xml:XML = new XML();
		
		public static function load(filename:String = "config.xml"):void {
			var f:File = File.applicationDirectory.resolvePath(filename);
			var stream:FileStream = new FileStream();
			try {
				stream.open(f, FileMode.READ);
				var str:String = stream.readMultiByte(stream.bytesAvailable, "shift_jis");
				Config.xml = new XML(str);
			} catch (error:Error) {
				throw new Error("Can not open the config file: " + f.nativePath);
			} finally {
				stream.close();
			}
		}
		
		public static function textFileExtensions():Array {
			return Config.xml.memo.ext.split(/\s+/);
		}
	}
}