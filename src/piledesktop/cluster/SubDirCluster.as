package piledesktop.cluster
{
	import flash.filesystem.File;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import piledesktop.*;
	import piledesktop.paper.*;
	
	public class SubDirCluster extends Cluster
	{
		public function SubDirCluster(dirs:Array, container:UIComponent):void {
			super(dirs, container);
		}
		
		override protected function createItem(f:File, pos:Point):Paper {
			var item:Paper = new SubDir(f, pos);
			item.addEventListener(SubDirEvent.OPEN_SUBDIR, function(event:SubDirEvent):void {
				////trace("subdircluster: "+event.dir.nativePath);
				dispatchEvent(event);
			});
			return item;
		}
		
		override protected function appendItem():void {
			// サブディレクトリがすべて表示されたらストップ
			if (index > files.length-1) return;
			super.appendItem();
		}
		
		override protected function getRandomPos():Point {
			if (!container.stage) {
				throw new Error("no stage");
			}
			var margin:int = 150;
			return Util.randPoint(
				margin,
				container.stage.stageWidth - margin,
				container.stage.stageHeight * 2/3,
				container.stage.stageHeight - margin
			);
		}
		
		override protected function next():void {
			if (!loop) return;
			appendItem();
		}
	}
}