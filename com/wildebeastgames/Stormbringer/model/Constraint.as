package model
{
	import controller.Dice;
	
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.StringUtil;

	public class Constraint extends StorableObject
	{
		private var _name:String;
		private var value:String;
		private var _relation:String;

		public function get name():String {return _name;}
		public function set name(s:String):void {_name=s;}
		public function get relation():String {return _relation;}
		public function set relation(s:String):void {_relation=s;}
		public var failure:PossessionLoad;
		
		public function Constraint( xml:XML = null)
		{
			if( xml != null) {
				var temp:XMLList = xml.attribute( "name");
				name = temp.length() > 0 ? temp[0] : "";
				
				temp = xml.attribute( "relation");
				relation = temp.length() > 0 ? temp[0] : "";
				
				temp = xml.attribute( "value");
				value = temp.length() > 0 ? temp[0] : "0";
				
				// see if there are any failure fallbacks to this constraint
				var chillins:XMLList = xml.failure.children();
				for each( var x:XML in chillins)
					failure = new PossessionLoad( x);	// there should only be one
			}
		}
		
		private function GetCompValue( character:Character):Number
		{
			switch( name) {
				case "PowerAndIntelligence":
					return character.power + character.intelligence;
				case "Strength":
				case "Size":
				case "Constitution":
				case "Intelligence":
				case "Power":
				case "Charisma":
				case "Dexterity":
				case "Gender":
				case "Age":
					return character.stats[ name].value;
				case "training":
					return 0;
				case "Class":
					return character.ClassString().indexOf( value);
				default:
					return character.skills[ name].skillLevel;
					// must be a skill
			}
			
			return 0;	// can't get it, at least at chargen time
		}

		public function MeetsConstraint( character:Character):Boolean
		{
			try {
				var compVal:Number = GetCompValue( character);
				var val:Number = GetValue();

				switch( relation) {
					case "equal":
						if( compVal == val)
							return true;
						return false;
					case "notequal":
						if( compVal != val)
							return true;
						return false;
					case "greater":
						if( compVal > val)
							return true;
						return false;
					case "less":
						if( compVal < val)
							return true;
						return false;
					case "greaterequal":
						if( compVal >= val)
							return true;
						return false;
					case "lessequal":
						if( compVal <= val)
							return true;
						return false;
					case "contains":
						// return value is index, -1 for does not contain
						return compVal > -1;
					case "notcontains":
						return compVal == -1;
					default:
						return true;
				}
			} finally {}
			
			return false;
		}

		override public function Load(rootObj:Object):StorableObject
		{
			StuffGenericObject( rootObj);
			
			return this;
		}

		override public function StuffGenericObject( obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			name = obj.name;
			value = obj.value;
			relation = obj.relation;
			
		}
		
		public function SetValue( n:Number):void
		{
			value = n.toString();
		}

		public function GetValue():Number
		{
			if( value.indexOf( "d") != -1)
				return Dice.ParseStringResult( value); // Must be a dice value

			return Number( value);
		}
	}
}