package model
{
	import controller.Dice;

	public class Affliction extends StorableObject
	{
		private var _name:String;
		private var modifiers:Array;

		static private var afflictions:Array;

		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		
		public function Affliction( xml:XML = null)
		{
			modifiers = new Array();
			if( xml != null) {
				name = xml.attribute( "name")[0];
				
				var chillins:XMLList = xml.children();
				for each( var x:XML in chillins) {
					var m:Modifier = new Modifier( x);
					modifiers[ m.name] = m;
				}
			}
			
			if( afflictions == null)
				afflictions = new Array();
		}

		override public function Save():void
		{
			for each( var mo:Modifier in modifiers)
				mo.Save();
				
			super.Save();
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			name = obj.name;
			
			for each( var o:Object in obj.modifiers) {
				var mo:Modifier = new Modifier();
				mo = mo.Load( o) as Modifier;
				modifiers[ mo.name] = mo;
			}
		}

		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();
			
			// Clear the previous list of afflictions
			afflictions = new Array();

			for each( var x:XML in list) {
				var a:Affliction = new Affliction( x);
				afflictions.push( a);
			}
		}
		
		override public function Load(rootObj:Object):StorableObject
		{
			StuffGenericObject( rootObj);
			
			return this;
		}

		static public function GenerateAffliction():Affliction
		{
			return afflictions[ Dice.Roll( 1, afflictions.length, -1)];
		}

		public function ApplyModifiers( char:Character):void
		{
			for each( var m:Modifier in modifiers)
				m.Apply( char);
		}
		
		public function DuplicateAffliction( char:Character):void
		{
			char.strength -= 1;
			char.constitution -= 1;
			char.intelligence -= 1;
			char.power -= 1;
			char.dexterity -= 1;
			char.charisma -= 1;
		}
	}
}