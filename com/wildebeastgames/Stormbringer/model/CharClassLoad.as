package model
{
	import controller.Dice;

	public class CharClassLoad
	{
		private var _name:String;
		private var additionalClasses:Array;	// array of trio [classname,chance, constraint]
		private var _range:Number;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		public function get range():Number {return _range;}
		[Bindable] public function set range(n:Number):void {_range=n;}
		
		public function CharClassLoad( x:XML = null)
		{
			additionalClasses = new Array();

			if( x != null) {
				name = x.name();

				var temp:XMLList = x.attribute( "range");
				range = temp[0];

				var chillins:XMLList = x.children();
				for each( var xml:XML in chillins) {
					// subclasses
					var subclass:Array = new Array();

					var nm:String = xml.name().localName;
					additionalClasses[ nm] = subclass;
					subclass[0] = nm;

					subclass[1] = xml.attribute( "range")[0];	// % chance
					
					// any constraints?
					temp = xml.constraint;
					subclass[2] = new Array();
					for each( var constraint:XML in temp) {
						var c:Constraint = new Constraint( constraint);
						
						subclass[2][ c.name] = c;
					}
				}
			}
		}
		
		private function MeetsSubclassConstraints( a:Array, char:Character):Boolean
		{
			for each( var c:Constraint in a) {
				if( !c.MeetsConstraint( char))
					return false;
			}
			
			return true;
		}

		private function SpecialCases( a:Array, char:Character):Boolean
		{
			switch( a[0]) {
				case "Noble":
					if( name == "Noble")
						a[0] = "Royalty";
					break;
				case "Sorcerer":
				case "Priest":
					if( char.intelligence < 16 || (char.intelligence + char.power < 32))
						return false;
					break;
				case "Officer":
					if( Dice.Roll( 1, 2, -1) == 0)
						a[0] = "Mate";
					else
						a[0] = "Captain";
					break;
			}
			
			return true;
		}

		public function GenerateSubclasses( char:Character):CharClassSet
		{
			var result:CharClassSet = new CharClassSet();
			
			for each( var a:Array in additionalClasses) {
				if( Dice.Roll( 1, 100) <= a[1]					// % roll to get this subclass
					&& MeetsSubclassConstraints( a[2], char)	// constraints
					&& SpecialCases( a, char)					// Special case the Noble, Priest, Sorcerer and Officer
				) {
					var c:CharClassLoad = new CharClassLoad();
					c.name = a[0];
					
					result.AddCharClass( c);
				}
			}
			
			return result;
		}
	}
}