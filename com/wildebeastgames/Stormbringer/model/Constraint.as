package model
{
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLDecoder;

	public class Constraint extends StorableObject
	{
		private var _name:String;
		private var _value:Number;
		private var _relation:String;

		public function get name():String {return _name;}
		public function set name(s:String):void {_name=s;}
		public function get value():Number {return _value;}
		public function set value(n:Number):void {_value=n;}
		public function get relation():String {return _relation;}
		public function set relation(s:String):void {_relation=s;}
		
		public function Constraint( xml:XML = null)
		{
			if( xml != null) {
				var temp:XMLList = xml.attribute( "name");
				name = temp.length() > 0 ? temp[0] : "";
				
				temp = xml.attribute( "value");
				value = temp.length() > 0 ? temp[0] : 0;
				
				temp = xml.attribute( "relation");
				relation = temp.length() > 0 ? temp[0] : "";
			}
		}
		
		private function GetCompValue( character:Character):Number
		{
			if( name == "PowerAndIntelligence")
				return character.power + character.intelligence;
			else if( name == "training")
				return 0;
			else
				return character.stats[ name].value;
		}

		public function MeetsConstraint( character:Character):Boolean
		{
			try {
				var compVal:Number = GetCompValue( character);

				switch( relation) {
					case "equal":
						if( compVal == value)
							return true;
						return false;
					case "notequal":
						if( compVal != value)
							return true;
						return false;
					case "greater":
						if( compVal > value)
							return true;
						return false;
					case "less":
						if( compVal < value)
							return true;
						return false;
					case "greaterequal":
						if( compVal >= value)
							return true;
						return false;
					case "lessequal":
						if( compVal <= value)
							return true;
						return false;
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
	}
}