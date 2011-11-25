package model
{
	import controller.Dice;

	public class PossessionLoad extends RoleplayingObject
	{
		private var defaultNum:Number;	// the number available at character creation time
		public var defaultDice:Number;
		public var defaultDieSize:Number;
		public var defaultMultiplier:String;
		private var _constraints:Array;
		
		public function get constraints():Array {return _constraints;}
		public function set constraints(a:Array):void {_constraints=a;}

		public function PossessionLoad( xml:XML = null)
		{
			if( xml != null) {
				name = xml.attribute( "name")[0];

				var temp:XMLList = xml.attribute( "value");
				if( temp[0] == "random") {
					defaultDice = xml.attribute( "dice");
					defaultDieSize = xml.attribute( "size");

					temp = xml.attribute( "multiplier");
					defaultMultiplier = temp.length() > 0 ? temp[0] : null;
				} else if( temp.length() > 0)
					defaultNum = temp[0];

				constraints = new Array();
				temp = xml.constraint;
				for each( var x:XML in temp) {
					var c:Constraint = new Constraint( x);
					if( c != null)
						constraints[ c.name] = c;
				}
			}
		}

		public function GetQuantity( char:Character):Number
		{
			var result:Number = defaultDice > 0 ? Dice.Roll( defaultDice, defaultDieSize) : defaultNum;
			if( defaultMultiplier != null) {
				var mul:Number = parseInt( defaultMultiplier);
				if( mul > 0)
					result *= mul as Number;
				else
					result *= char.stats[ defaultMultiplier].value;
			}
	
			if( result == 0)
				result = 1;
			
			return result;
		}
	}
}