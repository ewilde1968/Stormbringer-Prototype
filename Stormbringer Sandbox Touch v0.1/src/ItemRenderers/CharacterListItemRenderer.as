package ItemRenderers
{
	import controller.ItemRendererContainer;
	
	import flash.display.Shape;
	
	import model.Character;
	
	import mx.graphics.BitmapFillMode;
	import mx.graphics.BitmapScaleMode;
	
	import spark.components.Image;
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.primitives.BitmapImage;
	
	import view.IconButton;
	import view.ListItemDeleteButton;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class CharacterListItemRenderer extends LabelItemRenderer
	{
		private var secondLine:StyleableTextField;
		private var portrait:Image;
		private var deleteB:ListItemDeleteButton;
		private var irc:ItemRendererContainer;
		private var character:Character;
		
		public function CharacterListItemRenderer()
		{
			//TODO: implement function
			super();
		}
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			irc = value as ItemRendererContainer;
			character = irc.character;

			if( character != null) {
				super.data = character.name;
				
				labelDisplay.text = character.name;
				
				if( secondLine != null)
					secondLine.text = character.nationality.name + ",   " + character.ClassString();

				if( deleteB) {
					deleteB.objectToDelete = character;
					deleteB.deleteF = irc.genericF;
					deleteB.verticalCenter = 0;
				}
				
				if( portrait != null) {
					portrait.source = character.fullPicture;
					portrait.visible = portrait.source;
				}
			}
			// the data has changed.  push these changes down in to the 
			// subcomponents here    		
		} 
		
		/**
		 * @private
		 * 
		 * Override this method to create children for your item renderer 
		 */	
		override protected function createChildren():void
		{
			super.createChildren();
			// create any additional children for your item renderer here
			
			if( secondLine == null)
				secondLine = new StyleableTextField();
			secondLine.styleName = this;	// pick up the parent's style
			secondLine.editable = false;
			secondLine.selectable = false;
			secondLine.multiline = false;
			secondLine.wordWrap = false;
			secondLine.scaleX = labelDisplay.scaleX * 0.8;
			secondLine.scaleY = labelDisplay.scaleY * 0.8;
			addChild( secondLine);
			
			if( portrait == null)
				portrait = new Image();
			portrait.maxHeight = 64;
			portrait.maxWidth = 64;
			portrait.scaleMode = BitmapScaleMode.LETTERBOX;
			portrait.fillMode = BitmapFillMode.SCALE;
			addChild( portrait);
			
			if( deleteB == null)
				deleteB = new ListItemDeleteButton();
			addChild( deleteB);
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the item renderer 
		 * sizes itself. For performance reasons, do not call 
		 * super.measure() unless you need to.
		 */ 
		override protected function measure():void
		{
			super.measure();
			// measure all the subcomponents here and set measuredWidth, measuredHeight, 
			// measuredMinWidth, and measuredMinHeight      		

			labelDisplay.commitStyles();
			secondLine.commitStyles();
			
			// just hard code the width and height for uniform appearance
			measuredWidth = 220;
			measuredHeight = 85;
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the background is drawn for 
		 * item renderer.  For performance reasons, do not call 
		 * super.drawBackground() if you do not need to.
		 */
		override protected function drawBackground(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			// do any drawing for the background of the item renderer here      		
			graphics.lineStyle( 1, 0x603937, 0.7);
			graphics.drawRoundRect( 0, 0, unscaledWidth, unscaledHeight, 5, 5);
		}
		
		/**
		 * @private
		 *  
		 * Override this method to change how the background is drawn for this 
		 * item renderer. For performance reasons, do not call 
		 * super.layoutContents() if you do not need to.
		 */
		override protected function layoutContents(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			// layout all the subcomponents here      		
			
			labelDisplay.commitStyles();
			secondLine.commitStyles();
			
			portrait.x = 3;
			portrait.y = 10;
			portrait.width = 64;
			portrait.height = 64;

			labelDisplay.y = 12;
			labelDisplay.x = portrait.x + portrait.width + 10;
			labelDisplay.width = unscaledWidth - 6;
			labelDisplay.height = labelDisplay.textHeight + 2;
			
			secondLine.y = labelDisplay.y + labelDisplay.height + 4;
			secondLine.x = labelDisplay.x;
			secondLine.width = unscaledWidth - 6;
			secondLine.height = secondLine.textHeight + 2;
			
			deleteB.x = 170;
			deleteB.y = 30;
			deleteB.width = unscaledWidth - 6;
			deleteB.height = labelDisplay.height;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged( styleProp);
			
			if( secondLine != null)
				secondLine.styleChanged( styleProp);
		}
	}
}