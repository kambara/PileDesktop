package piledesktop
{
	import flash.filesystem.File;
	
	public class DirInfo
	{
		private var _dir:File;
		private var files:Array;
		private var images:Array = [];
		private var texts:Array = [];
		private var dirs:Array = [];
		private var mails:Array = [];
		
		public function DirInfo(d:File):void {
			if (!d.exists || !d.isDirectory) {
				throw new Error("No such directory: " + d.nativePath);
			}
			
			this._dir = d;
			this.files = d.getDirectoryListing() || [];
			for each (var f:File in files) {
				if (f.isDirectory) {
					dirs.push(f);
				} else if (isImageFile(f)) {
					images.push(f);
				} else if (isTextFile(f)) {
					texts.push(f);
				} else if (isMailFile(f)) {
					mails.push(f);
				}
			}
		}
		
		
		public function get dir():File {
			return this._dir;
		}
		public function get imageFiles():Array {
			return this.images || [];
		}
		public function get textFiles():Array {
			return this.texts || [];
		}
		public function get subDirs():Array {
			return this.dirs || [];
		}
		public function get mailFiles():Array {
			return this.mails || [];
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
		
		private var _mailFileReg:RegExp;
		private function isMailFile(f:File):Boolean {
			if (!_mailFileReg) {
				_mailFileReg = /\.(mail|sentmail)$/i;
			}
			return _mailFileReg.test(f.nativePath);
		}
	}
}