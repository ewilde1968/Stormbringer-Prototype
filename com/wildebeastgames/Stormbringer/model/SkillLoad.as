package model
{
	import controller.Dice;

	public class SkillLoad extends RoleplayingObject
	{
		private var _skillLevel:Number;
		private var _constraints:Array;
		private var range:Number;	// % chance to get the skill at character creation time
		private var _sorcery:Boolean = false;
		private var dice:int = 0;
		private var size:int = 0;
		
		static private var skills:Array;
		
		[Bindable] override public function set name(s:String):void {super.name=s; skills[s]=this;}
		public function get skillLevel():Number {return _skillLevel;}
		[Bindable] public function set skillLevel(n:Number):void {_skillLevel=n;}
		public function get constraints():Array {return _constraints;}
		public function set constraints(a:Array):void {_constraints=a;}
		public function get sorcery():Boolean {return _sorcery;}
		public function set sorcery(b:Boolean):void {_sorcery=b;}

		public function SkillLoad( xml:XML = null)
		{
			if( skills == null)
				skills = new Array();
			constraints = new Array();
			
			if( xml != null) {
				name = xml.attribute( "name")[0];			// adds to skills array

				var temp:XMLList = xml.attribute( "value");
				if( temp.length() > 0) {
					if( temp[0] == "random") {
						dice = xml.attribute( "dice")[0];
						size = xml.attribute( "size")[0];
					} else
						skillLevel = temp[0];
				}
				
				
				temp = xml.attribute( "range");
				range = temp.length() > 0 ? temp[0] : 0;
				
				temp = xml.attribute( "sorcery");
				sorcery = temp.length() > 0 ? ( temp[0] == "true") : false;
				
				temp = xml.constraint;
				for each( var x:XML in temp) {
					var c:Constraint = new Constraint( x);
					if( c != null)
						constraints[ c.name] = c;
				}
			}
		}
		
		public function GetInitialLevel():Number
		{
			if( dice > 0)
				return Dice.Roll( dice, size);

			return skillLevel;
		}
	}
}