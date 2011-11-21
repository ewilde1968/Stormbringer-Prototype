package model
{
	public class Bonus
	{
		private var _name:String;
		private var stats:Array;	// key,value pairs where value is a multiplier
		private var _physical:Boolean;
		
		static private var bonuses:Array;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		public function get physical():Boolean {return _physical;}
		[Bindable] public function set physical(b:Boolean):void {_physical=b;}
		
		public function Bonus( bonusName:String)
		{
			if( bonuses == null)
				bonuses = new Array();

			if( bonusName != null) {
				name = bonusName;
				stats = new Array();
				bonuses[ name] = this;
			}
		}
		
		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();
			
			// Clear the previous list of bonuses
			bonuses = new Array();
			
			for each( var x:XML in list) {
				var b:Bonus = LoadFromXML( x);
				if( b != null)
					bonuses[ b.name] = b;
			}
		}
		
		static private function LoadFromXML( x:XML):Bonus
		{
			var temp:XMLList = x.attribute( "name");
			var result:Bonus = new Bonus( temp[0]);
			
			var chillins:XMLList = x.children();
			for each( var xml:XML in chillins) {
				var a:Array = new Array();
				
				var tempString:String = xml.name();
				a[0] = tempString;
				
				if( tempString == "Age") {
					// add a key/value pairs to the array [class/multiplier]
					a[1] = new Array();
					
					var classes:XMLList = xml.children();
					for each( var cx:XML in classes) {
						var ca:Array = new Array();
						var cn:String = cx.name();
						ca[0] = cn;
						
						var mn:Number = cx.attribute( "multiplier")[0];
						ca[1] = mn;
						a[1].push( ca);
					}
				} else {
					temp = xml.attribute( "multiplier");
					var n:Number = (temp.length() > 0) ? temp[0] : 1;
					a[1] = n;
				}
				
				result.stats.push( a);
			}
			
			temp = x.attribute( "physical");
			result.physical = (temp.length() > 0) ? temp[0] : false;
			
			return result;
		}

		public function AddAttribute( attributeName:String, multiplier:Number = 1):void
		{
			var a:Array = new Array();
			a[0] = attributeName;
			a[1] = multiplier;
			
			stats.push( a);
		}
		
		private function DetermineAgeValue( char:Character, ca:Array):Number
		{
			var multiplier:Number = 1;
			
			if( ca != null) {
				for each( var a:Array in ca) {
					var className:String = a[0];
					if( char.charClass[ className] != null) {
						// character has a class listing a multiplier
						var newMultiplier:Number = a[1] as Number;
						
						if( Math.abs( newMultiplier) > Math.abs( multiplier))
							multiplier = newMultiplier;
					}
				}
			}
			
			var compAge:Number = (char.age > 40) ? 40 : char.age;
			return multiplier * (compAge - 25);
		}

		public function Value( char:Character):Number
		{
			if( char == null)
				return 0;
			
			var result:Number = 0;
			
			for each( var a:Array in stats) {
				if( a[0] == "Age")
					result += DetermineAgeValue( char, a[1] as Array);
				else {
					var stat:Statistic = char.stats[ a[0]];
					if( stat != null) {
						var addend:Number = 0;
						
						if( stat.value < 9)
							addend = stat.value - 9;
						else if( stat.value > 12)
							addend = stat.value - 12;
						
						result += addend * a[1];
					}
				}
			}
			
			return result;
		}
		
		static public function Get( bonusName:String):Bonus
		{
			return bonuses[ bonusName];
		}
	}
}