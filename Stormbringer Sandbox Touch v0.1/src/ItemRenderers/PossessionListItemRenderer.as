package ItemRenderers
{
	import controller.ItemRendererContainer;
	
	import flash.display.Shape;
	
	import model.Character;
	import model.PhysicalItem;
	
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.primitives.BitmapImage;
	
	import view.IconButton;
	import view.ListItemDeleteButton;
	import view.PossessionChoiceGroup;
	import view.PossessionListGroup;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class PossessionListItemRenderer extends LabelItemRenderer
	{
		private var secondLine:StyleableTextField;
		private var deleteB:ListItemDeleteButton;
		private var itemPI:PhysicalItem;
		private var context:String;
		private var character:Character;
		private var irc:ItemRendererContainer;
		
		public function PossessionListItemRenderer()
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
			super.data = value;
			
			// the data has changed.  push these changes down in to the 
			// subcomponents here
			irc = value as ItemRendererContainer;
			itemPI = irc.dataObject as PhysicalItem;
			labelDisplay.text = itemPI.name + " (" + itemPI.quantity + ")";
			secondLine.text = itemPI.GetMessage() + "\rCost: " + itemPI.cost;

			SetContext();
		}
		
		private function SetContext():void
		{
			context = irc.context;
			character = irc.character;

			if( deleteB) {
				deleteB.objectToDelete = itemPI;
				deleteB.visible = itemPI ? itemPI.character : false;
				deleteB.enabled = deleteB.visible;
				deleteB.deleteF = irc.genericF;
				deleteB.verticalCenter = 0;
			}
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
			secondLine.multiline = true;
			secondLine.wordWrap = false;
			secondLine.scaleX = labelDisplay.scaleX * 0.8;
			secondLine.scaleY = labelDisplay.scaleY * 0.8;
			addChild( secondLine);
			
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
			var doRed:Boolean;
			switch( context) {
				case "GenerateCharacter":
					if( itemPI && !itemPI.complete)
						doRed = true;
					break;
				case "PurchaseItem":
					if( itemPI && character && itemPI.cost > character.GetCash())
						doRed = true;	// can't afford the item
					break;
				default:
					break;
			}

			graphics.lineStyle( doRed ? 2 : 1, doRed ? 0xff0000 : 0x603937);
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
			
			labelDisplay.y = 2;
			labelDisplay.x = 10;
			labelDisplay.width = unscaledWidth - 6;
			labelDisplay.height = labelDisplay.textHeight + 2;
			
			secondLine.y = labelDisplay.y + labelDisplay.height + 4;
			secondLine.x = labelDisplay.x;
			secondLine.width = unscaledWidth - 6;
			secondLine.height = secondLine.textHeight*3 + 6;
			
			if( deleteB) {
				deleteB.x = 170;
				deleteB.y = 30;
				deleteB.width = unscaledWidth - 6;
				deleteB.height = labelDisplay.height;
			}
		}
		
	}
}