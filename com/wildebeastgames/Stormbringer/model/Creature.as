package model
{
	public class Creature extends RoleplayingObject
	{
		private var _stats:Array;
		
		static public const FEMALE:Number = 0;
		static public const MALE:Number = 1;
		
		public function get stats():Array {return _stats;}
		[Bindable] public function set stats(a:Array):void {_stats=a;}
		public function get strength():Number {return _stats["Strength"].value;}
		public function get constitution():Number {return _stats["Constitution"].value;}
		public function get size():Number {return _stats["Size"].value;}
		public function get intelligence():Number {return _stats["Intelligence"].value;}
		public function get power():Number {return _stats["Power"].value;}
		public function get dexterity():Number {return _stats["Dexterity"].value;}
		public function get charisma():Number {return _stats["Charisma"].value;}
		public function get gender():Number {return _stats["Gender"].value;}
		public function get height():Number {return _stats["Height"].value;}
		public function get weight():Number {return _stats["Weight"].value;}
		[Bindable] public function set strength(n:Number):void {_stats["Strength"].value=n;}
		[Bindable] public function set constitution(n:Number):void {_stats["Constitution"].value=n;}
		[Bindable] public function set size(n:Number):void {_stats["Size"].value=n;}
		[Bindable] public function set intelligence(n:Number):void {_stats["Intelligence"].value=n;}
		[Bindable] public function set power(n:Number):void {_stats["Power"].value=n;}
		[Bindable] public function set dexterity(n:Number):void {_stats["Dexterity"].value=n;}
		[Bindable] public function set charisma(n:Number):void {_stats["Charisma"].value=n;}
		[Bindable] public function set gender(n:Number):void {_stats["Gender"].value=n;}
		[Bindable] public function set height(n:Number):void {_stats["Height"].value=n;}
		[Bindable] public function set weight(n:Number):void {_stats["Weight"].value=n;}
		public function get maxHitPoints():Number {return _stats["MaxHitPoints"].value;}
		[Bindable] public function set maxHitPoints(n:Number):void {_stats["MaxHitPoints"].value=n;}
		public function get hitPoints():Number {return _stats["HitPoints"].value;}
		[Bindable] public function set hitPoints(n:Number):void {_stats["HitPoints"].value=n;}
		public function get age():Number {return _stats["Age"].value;}
		[Bindable] public function set age(n:Number):void {_stats["Age"].value=n;}
		public function get elan():Number {return _stats["Elan"].value;}
		[Bindable] public function set elan(n:Number):void {_stats["Elan"].value=n;}
		public function get majorWound():Number {return _stats["MajorWound"].value;}
		[Bindable] public function set majorWound(n:Number):void {_stats["MajorWound"].value=n;}
		
		public function Creature()
		{
			super();
			
			stats = new Array();
		}
		
		override public function Edit():void
		{
			// TODO
		}
		
		public function Train():void
		{
			// TODO
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			stats = new Array();
			for each( var o:Object in obj["stats"]) {
				var s:Statistic = new Statistic();
				s.StuffGenericObject( o);
				stats[ s.name] = s;
			}
		}
		
		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:Creature = newObj as Creature;
			if( result == null)
				result = new Creature();
			
			super.Copy( result);
			result.stats = stats.slice();
			
			return result;
		}
	}
}