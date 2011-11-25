package model
{
	import controller.Dice;

	public class Chance
	{
		public var array:Array;
		public var totalRange:Number;
		
		public function Chance( xl:XMLList)
		{
			array = new Array();	// array of arrays [xmlObject, range]
			totalRange = 0;
			
			for each( var xml:XML in xl) {
				var newArray:Array = new Array();

				var nm:String = xml.name();
				switch( nm) {
					case "StatModifiers":
						var temp:XMLList = xml.children();
						var sm:Modifier = new Modifier( temp[0]);
						newArray[0] = sm;
						break;
					case "string":
						var val:String = xml.attribute( "value");
						newArray[0] = val;
						break;
					case "reroll":
						val = xml.attribute( "reroll");
						newArray[0] = "reroll";
						newArray[2] = val;
						break;
					default:
						throw Error( "Chance:Chance - invalid xmlname " + nm);
				}
				
				var range:Number = xml.attribute( "range");
				newArray[1] = range;
				
				array.push( newArray);
				totalRange += range;
			}
		}
		
		public function Roll():Object
		{
			var roll:Number = Dice.Roll( 1, totalRange);
			for each( var a:Array in array) {
				if( roll <= a[1])
					break;
				roll -= a[1];
			}
			
			if( a[0] == "reroll") {
				var number:Number = Dice.ParseStringResult( a[2]);
				var result:Array = new Array();
				
				while( number--) {
					var newVal:Object = Roll();
					if( newVal is Array) {
						for each( var o:Object in newVal)
							result.push( o);
					} else
						result.push( newVal);
				}
				
				return result;
			}
			
			return a[0];
		}
	}
}