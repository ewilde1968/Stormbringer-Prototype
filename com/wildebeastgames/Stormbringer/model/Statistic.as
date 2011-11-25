package model
{
	import controller.Dice;

	public class Statistic extends StorableObject
	{
		private var _name:String = null;
		private var _checked:Boolean = false;
		private var _value:Number = 0;
		public var strVal:String;

		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		public function get checked():Boolean {return _checked;}
		[Bindable] public function set checked(b:Boolean):void {_checked=b;}
		public function get value():Number {return _value;}
		[Bindable] public function set value(n:Number):void {_value=n;}
		
		static public const genders:Array = [ "Female", "Male" ];
		
		public function Statistic()
		{
			super();
		}
		
		static public function Generate( n:String, v:Number = -1, sv:String = ""):Statistic
		{
			var result:Statistic = new Statistic();
			
			result.name = n;
			result.value = (v == -1) ? Dice.Roll(3,6) : v;
			result.strVal = (sv == null) ? "" : sv;

			return result;
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			name = obj[ "name"];
			checked = obj[ "checked"];
			value = obj[ "value"];
			strVal = obj[ "strVal"];
		}
		
		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:Statistic = newObj as Statistic;
			if( result == null)
				result = new Statistic();
			
			super.Copy( result);
			result.name = name;
			result.checked = checked;
			result.value = value;
			result.strVal = strVal;
			
			return result;
		}
	}
}