package piledesctop
{
	
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.filesystem.*;
	
	import mx.core.UIComponent;
	
	import piledesctop.cluster.*;
	import piledesctop.paper.SubDirEvent;

	public class Desktop extends UIComponent
	{
		public static var config:XML;
		private var clusters:Array = [];
		
		public function Desktop(dir:File) {
			// open dir
			if (!dir.exists || !dir.isDirectory) {
				throw new Error("No such directory: " + dir.nativePath);
			}
			
			// create cluster
			var self:UIComponent = this;
			callLater(function():void {
				self.stage.addEventListener(Event.RESIZE, resizeHandler);
				resizeHandler(null);
				
				var dirInfo:DirInfo = new DirInfo(dir);
				if (dirInfo.imageFiles.length) {
					var pc:PhotoCluster = new PhotoCluster(dirInfo.imageFiles, self);
					pc.addEventListener("zoom_in_start", onZoomInStart);
					pc.addEventListener("zoom_out", onZoomOut);
					clusters.push(pc);
				}
				if (dirInfo.textFiles.length) {
					var mc:MemoCluster = new MemoCluster(dirInfo.textFiles, self);
					clusters.push(mc);
				}
				if (dirInfo.mailFiles.length) {
					var mailc:MailCluster = new MailCluster(dirInfo.mailFiles, self);
					clusters.push(mailc);
				}
				if (dirInfo.subDirs.length) {
					var sdc:SubDirCluster = new SubDirCluster(dirInfo.subDirs, self);
					sdc.addEventListener(SubDirEvent.OPEN_SUBDIR, function(event:SubDirEvent):void {
						dispatchEvent(event);
					});
					clusters.push(sdc);
				}
			});
		}
		
		private function onZoomInStart(event:Event):void {
			for each (var c:Cluster in clusters) {
				c.stopLoop();
			}
		}
		private function onZoomOut(event:Event):void {
			for each (var c:Cluster in clusters) {
				c.restartLoop();
			}
		}
		
		private var _defaultWindowWidth:Number;
		private var _defaultWindowHeight:Number;
		private function resizeHandler(event:Event):void {
			if (!this.stage) return;
			if (!_defaultWindowWidth) {
				_defaultWindowWidth = parseInt(Config.xml.window.@width);
			}
			if (!_defaultWindowHeight) {
				_defaultWindowHeight = parseInt(Config.xml.window.@height);
			}
			
			var win:NativeWindow = this.stage.nativeWindow;
			var wrate:Number = win.width / _defaultWindowWidth;
			var hrate:Number = win.height / _defaultWindowHeight;
			if (wrate < 1 || hrate < 1) {
				if (wrate > hrate) {
					this.scaleX = hrate;
					this.scaleY = hrate;
				} else {
					this.scaleX = wrate;
					this.scaleY = wrate;
				}
			}
		}
		
		/****
		private function classifyFiles(dir:File):Object {
			var result:Object = {
				images: [],
				texts:  [],
				dirs:   []
			};
			for each (var f:File in dir.getDirectoryListing()) {
				if (f.isDirectory) {
					result.dirs.push(f);
				} else if (isImageFile(f)) {
					result.images.push(f);
				} else if (isTextFile(f)) {
					result.texts.push(f);
				}
			}
			return result;
		}
		
		private var _imgFileReg:RegExp;
		private function isImageFile(f:File):Boolean {
			if (!_imgFileReg) {
				_imgFileReg = /\.(jpg|jpeg|png|gif)$/i;
			}
			return _imgFileReg.test(f.nativePath);
		}
		
		private var _textFileReg:RegExp;
		private function isTextFile(f:File):Boolean {
			if (!_textFileReg) {
				_textFileReg = new RegExp("\\.("
											+ Config.textFileExtensions().join("|")
											+ ")$",
											"i");
			}
			return _textFileReg.test(f.nativePath);
		}
		
		private function extractImageFiles(dir:File):Array {
			var reg:RegExp = /\.(jpg|jpeg|png|gif)$/i;
			var files:Array = dir.getDirectoryListing().filter(function(f:File, index:int, array:Array):Boolean {
				return reg.test(f.nativePath);
			}, this);
			return files;
		}
		*****/
		
		/****
		private function dateToDirPath(date:Date):String {
			// YYYY/YYYYMM/YYYY_MMDD
			function formatDate(format:String, date:Date):String {
				var formatter:DateFormatter = new DateFormatter();
				formatter.formatString = format;
				return formatter.format(date);
			}
			var d:String = formatDate("YYYY_MMDD", date);
			var m:String = formatDate("YYYYMM", date);
			var y:String = formatDate("YYYY", date);
			var path:String = y + "/" + m + "/" + d;
			return path;
		}
		******/
	}
}