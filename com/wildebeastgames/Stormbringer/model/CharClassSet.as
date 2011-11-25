package model
{
	import controller.Dice;

	public class CharClassSet
	{
		private var totalRange:Number;
		private var _array:Array;

		public function get array():Array {return _array;}
		[Bindable] public function set array(a:Array):void {_array=a;}
		
		public function CharClassSet()
		{
			array = new Array();
			totalRange = 0;
		}

		public function AddCharClass( c:CharClassLoad):void
		{
			if( array[c.name] != null)
				totalRange -= (array[c.name] as CharClassLoad).range;

			array[ c.name] = c;
			totalRange += c.range;
		}
		
		public function GenerateCharClassLoad():CharClassLoad
		{
			var roll:Number = Dice.Roll( 1, totalRange);
			
			for each( var c:CharClassLoad in array) {
				if( roll <= c.range)
					return c;
				roll -= c.range;
			}
			
			throw Error( "CharClassSet:GenerateCharClass - invalid roll");
		}
	}
}