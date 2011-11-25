package model
{
	import mx.collections.ArrayList;

	public class ArmorItem extends PhysicalItem implements GenericObject
	{
		private var _protection:String;
		
		static private var armors:Array;
		
		public function get protection():String {return _protection;}
		[Bindable] public function set protection(s:String):void {_protection=s;}
		
		public function ArmorItem( xml:XML = null)
		{
			super();
			
			if( xml != null) {
				var temp:XMLList = xml.attribute( "protection");
				protection = ( temp.length() > 0) ? temp[0] : "0";
				
				temp = xml.attribute( "description");
				description = (temp.length() > 0) ? temp[0] : null;
				
				name = xml.attribute( "name")[0];
				if( armors == null)
					armors = new Array();
				armors[ name] = this;
			}
		}

		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:ArmorItem = newObj as ArmorItem;
			if( result == null)
				result = new ArmorItem();
			
			super.Copy( result);
			result.protection = protection;
			
			return result;
		}
		
		override public function GetGenericList():Array
		{
			var result:Array = new Array();
			
			for each( var pi:PhysicalItem in armors)
				result.push( pi);
			
			result.sort( AlphaSort);
			
			return result;
		}
		
		override public function GetMessage():String
		{
			return "Soak: " + protection;
		}

		static public function ClearCache():void
		{
			armors = new Array();
		}
	}
}