package ItemRenderers
{
	import controller.ItemRendererContainer;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import model.Skill;
	import model.SummoningSpell;
	
	import mx.events.FlexEvent;
	
	import spark.components.CheckBox;
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	
	import view.ListItemDeleteButton;
	import view.SkillListGroup;
	
	import views.SkillView;
	import views.SkillsView;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class SkillListItemRenderer extends LabelItemRenderer
	{
		private var skill:Skill;
		private var secondLine:StyleableTextField;
		private var secondColumn:StyleableTextField;
		private var deleteB:ListItemDeleteButton;
		private var checkBox:CheckBox;
		private var irc:ItemRendererContainer;

		public function SkillListItemRenderer()
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
			skill = irc.dataObject as Skill;
			labelDisplay.text = skill.name;
			secondLine.text = skill.GetMessage();
			
			if( skill is SummoningSpell) {
				var summon:SummoningSpell = skill as SummoningSpell;
				if( summon.currentA != null && summon.currentA.length > 2)
					secondColumn.text = summon.GetSecondColumnMessage();
			}

			if( deleteB) {
				deleteB.visible = irc.context == "EditCharacter";
				deleteB.enabled = deleteB.visible;
				deleteB.objectToDelete = skill;
				deleteB.deleteF = irc.genericF;
			}
			
			if( checkBox) {
				checkBox.selected = skill.checked;
				checkBox.visible = irc.context == "EditCharacter";
				checkBox.enabled = checkBox.visible;
			}
		} 
		
		private function checkBox_handleChange( event:Event):void
		{
			if( skill)
				skill.checked = event.currentTarget.selected;
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
			secondLine.scaleX = 0.8;
			secondLine.scaleY = 0.8;
			addChild( secondLine);

			if( secondColumn == null)
				secondColumn = new StyleableTextField();
			secondColumn.styleName = this;
			secondColumn.editable = false;
			secondColumn.selectable = false;
			secondColumn.multiline = true;
			secondColumn.wordWrap = false;
			secondColumn.scaleX = 1.2;
			secondColumn.scaleY = 1.2;
			addChild( secondColumn);
			
			if( deleteB == null)
				deleteB = new ListItemDeleteButton();
			addChild( deleteB);

			if( checkBox == null) {
				checkBox = new CheckBox();
				checkBox.addEventListener(Event.CHANGE, checkBox_handleChange);
			}
			addChild( checkBox);
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
			measuredWidth = 250;
			measuredHeight = 100;
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
			var doRed:Boolean = skill ? !skill.complete : false;

			graphics.lineStyle( doRed ? 2 :1, doRed ? 0xff0000 : 0x603937);
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
			
			secondColumn.y = secondLine.y;
			secondColumn.x = 190;
			secondColumn.width = unscaledWidth - 6;
			secondColumn.height = secondLine.height;
			
			deleteB.x = 200;
			deleteB.y = 30;
			deleteB.width = unscaledWidth - 6;
			deleteB.height = labelDisplay.height;
			
			checkBox.x = 360;
			checkBox.y = 30;
			checkBox.width = deleteB.width;
			checkBox.height = deleteB.height;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged( styleProp);
			
			if( secondLine != null)
				secondLine.styleChanged( styleProp);
		}
	}
}