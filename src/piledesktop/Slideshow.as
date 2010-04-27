package piledesktop
{
	import caurina.transitions.Tweener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	
	import piledesktop.paper.Photo;
	
	public class Slideshow extends UIComponent
	{
		private var photoFiles:Array;
		private var currentIndex:int;
		
		private var bg:Sprite;
		private var photoLoaderCache:Object = {}; // filename -> photoloader
		
		[Embed(source="embed/24-arrow-next.png")]
		private var nextCursor:Class;
		[Embed(source="embed/24-arrow-previous.png")]
		private var prevCursor:Class;
		
		public function Slideshow(files:Array, photo:Photo):void {
			this.photoFiles = files;
			currentIndex = getIndexOfFile(photo.file);
			
			callLater(function():void {
				appendNewPhoto();
				stage.addEventListener(Event.RESIZE, onWindowResize);
			});
			
			this.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void {
				switch (event.keyCode) {
					case Keyboard.RIGHT:
						nextPhoto();
						break;
					case Keyboard.LEFT:
						prevPhoto();
						break;
				}
			});
			this.setFocus();
		}
		
		private function getIndexOfFile(f:File):int {
			for (var i:int = 0; i < photoFiles.length; i++) {
				var p:File = photoFiles[i];
				if (p.name == f.name) return i;
			}
			return 0;
		}
		
		private function fadeInBackground():void {
			if (bg) return;
			
			bg = new Sprite();
			bg.graphics.beginFill(0x000000, 0.5);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			bg.graphics.endFill();
			bg.addEventListener(MouseEvent.MOUSE_DOWN, function():void {
				dispatchEvent(new Event(Event.CLOSE));
			});
			/*
			bg.addEventListener(MouseEvent.MOUSE_OVER, function():void {
				updatePhotos();
			});
			*/
			
			bg.alpha = 0;
			addChildAt(bg, 0);
			Tweener.addTween(bg, {
				alpha:1,
				time:1
			});
		}

		private function appendNewPhoto():void {
			//trace((currentIndex+1) + "/" +photoFiles.length);
			var f:File = photoFiles[currentIndex];
			
			// use cache
			if (photoLoaderCache[f.name]) {
				updatePhotos();
				return;
			}
			
			// create
			var photoLoader:PhotoLoader = new PhotoLoader();
			photoLoader.addEventListener("load", function():void {
				if (!bg) fadeInBackground();
				updatePhotos();
				onWindowResize(null);
			});
			photoLoader.addEventListener("load_error", function():void {
				dispatchEvent(new Event(Event.CLOSE));
			});
			
			var i:int = currentIndex;
			photoLoader.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				event.stopPropagation();
				if (i == currentIndex) {
					// top right photo
					if (event.localX > event.target.width / 2) {
						nextPhoto();
					} else {
						prevPhoto();
					}
				} else {
					// not top photo
					currentIndex = i;
					appendNewPhoto();
				}
			});
			
			var cursorID:Number;
			var cursorType:Number = 0; // -1, 0, 1
			function changePrevCursor():void {
				if (cursorType == -1) return;
				CursorManager.removeCursor(cursorID);
				cursorID = CursorManager.setCursor(prevCursor);
				cursorType = -1;
			}
			function changeNextCursor():void {
				if (cursorType == 1) return;
				CursorManager.removeCursor(cursorID);
				cursorID = CursorManager.setCursor(nextCursor);
				cursorType = 1;
			}
			function clearCursor():void {
				if (cursorType == 0) return;
				CursorManager.removeAllCursors();
				cursorType = 0;
			}
			photoLoader.addEventListener(MouseEvent.MOUSE_OVER, function(event:MouseEvent):void {
				setChildIndex(PhotoLoader(event.target), numChildren-1);
				
				// change cursor
				if (i == currentIndex) {
					// top right photo
					if (event.localX > event.target.width / 2) {
						changeNextCursor();
					} else {
						changePrevCursor();
					}
				}
			});
			photoLoader.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				//event.stopPropagation();
				if (i == currentIndex) {
					// top right photo
					if (event.localX > event.target.width / 2) {
						changeNextCursor();
					} else {
						changePrevCursor();
					}
				} else {
					// not top photo
					clearCursor();
				}
			});
			photoLoader.addEventListener(MouseEvent.MOUSE_OUT, function():void {
				clearCursor();
			});
			
			// dropshadow
			var shadow:DropShadowFilter = new DropShadowFilter();
			shadow.alpha = 0.6;
			shadow.distance = 2;
			shadow.angle = 135;
			photoLoader.filters = [shadow];
			
			photoLoaderCache[f.name] = photoLoader;
			photoLoader.load(f, stage.width, stage.height);
		}
		
		private function updatePhotos():void {
			var count:int = 0;
			var topRect:Rectangle;
			
			for (var i:int = photoFiles.length-1; i >= 0; i--) {
				var f:File = photoFiles[i];
				if (!this.photoLoaderCache[f.name]) continue;
				
				var pl:PhotoLoader = this.photoLoaderCache[f.name];
				
				if (i <= currentIndex && count < 7) {
					// depth
					if (this.contains(pl)) {
						this.setChildIndex(pl, 1);
					} else {
						addChildAt(pl, 1);
					}
					
					// position
					if (count == 0) {
						topRect = getPhotoRect(pl);
					}
					pl.x = topRect.x - 10 * count;
					pl.y = topRect.y + 3 * count;
					
					count += 1;
				} else if (this.contains(pl)) {
					removeChild(pl);
				}
			}
		}
		
		private function nextPhoto():void {
			if (currentIndex >= photoFiles.length - 1) {
				currentIndex = 0;
			} else {
				currentIndex += 1;
			}
			appendNewPhoto();
		}
		
		private function prevPhoto():void {
			if (currentIndex <= 0) {
				currentIndex = photoFiles.length - 1;
			} else {
				currentIndex -= 1;
			}
			appendNewPhoto();
		}
		
		private function onWindowResize(event:Event):void {
			if (!stage) return;
			
			if (!bg) return;
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			
			for each (var photoLoader:PhotoLoader in photoLoaderCache) {
				if (!photoLoader) continue;
				
				var rect:Rectangle = getPhotoRect(photoLoader);				
				photoLoader.width = rect.width;
				photoLoader.height = rect.height;
				//photoLoader.x = (sw - size.width) /2 + padding;
				//photoLoader.y = (sh - size.height) /2 + padding;
			}
		}
		
		private function getPhotoRect(photoLoader:PhotoLoader):Rectangle {
			if (!stage) return null;
			var padding:int = 70;
			var sw:int = stage.stageWidth - padding*2; 
			var sh:int = stage.stageHeight - 42 - padding*2;
			
			var size:Object = Util.insideSize(photoLoader.bitmap.width,
													photoLoader.bitmap.height,
													sw, sh);
			var x:int = (sw - size.width) /2 + padding;
			var y:int = (sh - size.height) /2 + padding;
			return new Rectangle(x, y, size.width, size.height);
		}
	}
}