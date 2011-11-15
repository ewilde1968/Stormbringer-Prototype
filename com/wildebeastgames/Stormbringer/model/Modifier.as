package model
{
	import controller.Dice;
	
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLDecoder;

	public class Modifier extends StorableObject
	{
		private var _name:String;
		private var diceNum:int;
		private var diceSize:int;
		private var offset:Number;
		private var increment:Number;
		private var multiplier:Number;
		private var constraint:Constraint;
		
		public function get name():String {return _name;}
		public function set name(s:String):void {_name=s;}
		
		public function Modifier( xml:XML = null)
		{
			name = xml.name();
			
			var temp:XMLList = xml.attribute( "dice");
			diceNum = temp.length() > 0 ? temp[0] : 0;
			
			temp = xml.attribute( "size");
			diceSize = temp.length() > 0 ? temp[0] : 0;
			
			temp = xml.attribute( "modifier");
			offset = temp.length() > 0 ? temp[0] : 0;
			
			temp = xml.attribute( "multiplier");
			multiplier = temp.length() > 0 ? temp[0] : 0;
			
			temp = xml.attribute( "increment");
			increment = temp.length() > 0 ? temp[0] : 0;
			
			temp = xml.constraint;
			constraint = temp.length() > 0 ? new Constraint( temp[0]) : null;
		}
		
		override public function Save():void
		{
			constraint.Save();
			
			super.Save();
		}
		
		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);

			name = obj.name;
			diceNum = obj.diceNum;
			diceSize = obj.diceSize;
			offset = obj.offset;
			increment = obj.increment;
			multiplier = obj.multiplier;
			
			constraint = new Constraint();
			constraint = constraint.Load( obj.constraint) as Constraint;
		}

		public function Apply( char:Character):void
		{
			if( constraint == null || constraint.MeetsConstraint( char)) {
				if( diceNum > 0)
					char.stats[ name].value += Dice.Roll( diceNum, diceSize, offset);
				else if( diceNum < 0 && char.stats[ name].value > 9)
					char.stats[ name].value -= Dice.Roll( -diceNum, diceSize, offset);
				else if( increment > 0)
					char.stats[ name].value += (char.stats[name].value - constraint.GetValue()) * increment;
				else if( offset != 0)
					char.stats[ name].value += offset;
				else if( multiplier != 0)
					char.stats[ name].value = Math.floor( char.stats[ name].value * multiplier);
			}
		}
	}
}