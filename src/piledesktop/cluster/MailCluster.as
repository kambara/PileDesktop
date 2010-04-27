package piledesktop.cluster
{
	import flash.filesystem.File;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import piledesktop.Util;
	import piledesktop.paper.Mail;
	import piledesktop.paper.Paper;
	
	public class MailCluster extends Cluster
	{
		public function MailCluster(files:Array, container:UIComponent):void {
			super(files, container);
		}
		override protected function createItem(f:File, pos:Point):Paper {
			return new Mail(f, pos);
		}
		override protected function getRandomPos():Point {
			if (!container.stage) {
				throw new Error("no stage");
			}
			var margin:int = 50;
			return Util.randPoint(
				container.stage.stageWidth/2 + margin,
				container.stage.stageWidth - margin,
				margin,
				container.stage.stageHeight*2/3 - margin
			);
		}
	}
}