package piledesktop.paper
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class SubDirEvent extends Event
	{
		public static const OPEN_SUBDIR:String = "open_subdir";
		private var _dir:File;
		
		public function SubDirEvent(dir:File):void {
			super(SubDirEvent.OPEN_SUBDIR);
			this._dir = dir;
		}
		
		public function get dir():File {
			return this._dir;
		}
		public function set dir(d:File):void {
			this._dir = d;
		}
		
		override public function clone():Event {
            return new SubDirEvent(_dir);
        }
	}
}