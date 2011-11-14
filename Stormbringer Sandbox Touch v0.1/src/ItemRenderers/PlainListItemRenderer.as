package ItemRenderers
{
	import controller.ItemRendererContainer;
	
	import flash.display.Shape;
	
	import model.Character;
	import model.PhysicalItem;
	import model.Skill;
	
	import mx.controls.Spacer;
	import mx.graphics.Stroke;
	
	import spark.components.Label;
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.primitives.Rect;
	
	import view.CharacterGroup;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class PlainListItemRenderer extends LabelItemRenderer
	{
		private var gt:StyleableTextField;
		private var irc:ItemRendererContainer;
		
		public function PlainListItemRenderer()
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
			// the data has changed.  push these changes down in to the 
			// subcomponents here
			irc = value as ItemRendererContainer;
			labelDisplay.text = irc.dataObject as String;

			super.data = irc.dataObject as String;
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
			if( gt == null)
				gt = new StyleableTextField();
			gt.styleName = this;	// pick up the parent's style
			gt.editable = false;
			gt.selectable = false;
			gt.multiline = false;
			gt.wordWrap = false;
			gt.text = ">"
			addChild( gt);
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
			gt.commitStyles();

			// Becasue of the way the player calculates text widths and heights, 
			// define extra padding around the text to prevent clipping.
			const TEXT_WIDTH_PADDING:int = 5;
			const TEXT_HEIGHT_PADDING:int = 4;
			
			// Calculate the measured width and height of the item renderer, 
			// including text paddding. 
			// Include 6 pixels of extra space around the width, and 10 around 
			// the heiht of the item renderer.
			measuredWidth = labelDisplay.textWidth + gt.textWidth +
				TEXT_WIDTH_PADDING + 6;
			measuredHeight = Math.max( labelDisplay.textHeight, gt.textHeight) +
				TEXT_HEIGHT_PADDING + 10;
			
			// Set the minimum width and height of the item renderer.
			measuredMinWidth = 6;
			measuredMinHeight = 10;
		}
		
		private function IsComplete( character:Character):Boolean
		{
			switch( data) {
				case "Skills":
					for each( var sk:Skill in character.skills)
						if( sk && !sk.complete)
							return false;
					break;
				case "Possessions":
					for each( var pi:PhysicalItem in character.possessions)
						if( pi && !pi.complete)
							return false;
					break;
				default:
					break;
			}
			
			return true;
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
			var redB:Boolean = irc.character && !IsComplete( irc.character);
			
			graphics.lineStyle( redB ? 2 : 1, redB ? 0xff0000 : 0x603937);
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
			gt.commitStyles();
			
			labelDisplay.y = 10;
			labelDisplay.x = 10;
			labelDisplay.width = unscaledWidth - 6;
			labelDisplay.height = labelDisplay.textHeight + 2;
			
			gt.y = labelDisplay.y;
			gt.x = unscaledWidth - 6 - gt.textWidth - 15;
			gt.width = unscaledWidth - 6;
			gt.height = gt.textHeight + 2;
		}

		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged( styleProp);
			
			if( gt != null)
				gt.styleChanged( styleProp);
		}
	}
}