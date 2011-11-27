package model
{
	public class BindingSpell extends Spell
	{
		private var statistic:String;
		private var multiplier:int = 0;
		
		public function BindingSpell(xml:XML=null)
		{
			super(xml);

			if( xml != null) {
				var temp:XMLList = xml.attribute( "statistic");
				statistic = temp.length() > 0 ? temp[0] : null;
				
				temp = xml.attribute( "multiplier");
				multiplier = temp.length() > 0 ? temp[0] : 1;
			}
		}
		
		override public function Load(rootObj:Object):StorableObject
		{
			StuffGenericObject( rootObj);
			
			return this;
		}
		
		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			statistic = obj.statistic;
			multiplier = obj.multiplier;
		}

		override public function Copy(newObj:StorableObject=null):StorableObject
		{
			var result:BindingSpell = newObj as BindingSpell;
			if( result == null)
				result = new BindingSpell();
			
			super.Copy( result);
			result.multiplier = multiplier;
			result.statistic = statistic;
			
			return result;
		}
		
		override public function GetMessage( char:Character = null):String
		{
			return "Power vs. Demon Power";
		}
	}
}