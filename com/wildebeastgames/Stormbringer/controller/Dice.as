package controller
{
	public class Dice
	{
		public function Dice()
		{}
		
		static public function Roll( diceNum:int, diceSize:int, mod:Number = 0):Number
		{
			var result:Number = mod;
			var negate:Boolean = diceNum < 0;
			diceNum = Math.abs( diceNum);
			while( diceNum--)
				result += Math.floor( Math.random() * diceSize) + 1;
			
			if( negate)
				result = result * -1;
			
			return result;
		}
		
		static public function ParseStringResult( s:String):Number
		{
			var result:Number = 0;
			
			var split:Array = s.split( "+");
			for each( var subs:String in split) {
				var innerSplit:Array = subs.split( "d", 2);
				if( innerSplit.length == 2 ) {
					var numDice:int = innerSplit[0];
					var size:int = innerSplit[1];
					
					var val:Number = Roll( numDice, size);
					result += val;
				} else if( innerSplit.length == 1) {
					result += innerSplit[0];
				}
			}
			
			return result;
		}
	}
}