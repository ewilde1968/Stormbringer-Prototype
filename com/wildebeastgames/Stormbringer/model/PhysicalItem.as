package model
{
	import mx.collections.ArrayList;

	public class PhysicalItem extends RoleplayingObject implements GenericObject
	{
		private var _cost:Number;	// in Large Bronze pieces
		private var _category:String;
		protected var _complete:Boolean;
		private var _quantity:Number;
		protected var _character:Character;
		
		public function get cost():Number {return _cost;}
		[Bindable] public function set cost(n:Number):void {_cost=n;}
		public function get quantity():Number {return _quantity;}
		[Bindable] public function set quantity(n:Number):void {_quantity=n;}
		public function get category():String {return _category;}
		[Bindable] public function set category(s:String):void {_category=s;}
		public function get complete():Boolean {return _complete;}
		[Bindable] public function set complete(b:Boolean):void {_complete=b;}
		public function get character():Character {return _character;}
		[Bindable] public function set character(c:Character):void {_character=c;}
		
		static private var items:Array;
		
		public function PhysicalItem()
		{
			super();
			
			complete = false;
		}

		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();
			
			// Clear the previous list of items
			// also need to figure out what to do for Weapons
			ClearCache();
			
			for each( var x:XML in list) {
				var pi:PhysicalItem = LoadFromXML( x);
				if( pi != null)
					items[ pi.name] = pi;
			}
		}
		
		static private function LoadFromXML( x:XML):PhysicalItem
		{
			var temp:XMLList = x.attribute( "category");
			var category:String = (temp.length() > 0) ? temp[0] : "General";
			var result:PhysicalItem = null;

			switch( category) {
				case "Weapon":
					result = new WeaponItem(x);
					break;
				case "Armor":
					result = new ArmorItem(x);
					break;
				default:
					result = new PhysicalItem();
					break;
			}
			
			result.name = x.attribute( "name")[0];
			
			temp = x.attribute( "cost");
			result.cost = (temp.length() > 0) ? temp[0] : 0;
			
			temp = x.attribute( "description");
			result.description = (temp.length() > 0) ? temp[0] : null;
			
			temp = x.attribute( "quantity");
			result.quantity = (temp.length() > 0) ? temp[0] : 1;
			
			result.category = category;
			
			return result;
		}

		override public function Load(rootObj:Object):StorableObject
		{
			var result:PhysicalItem = items[ rootObj.name].Copy() as PhysicalItem;
			
			if( result != null)
				result.StuffGenericObject( rootObj);
			
			return result;
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			cost = obj.cost;
			category = obj.category;
			complete = obj.complete;
			quantity = obj.quantity;
			
			if( obj.character != null) {
				character = new Character();
				character = character.Load( obj.character) as Character;
			}
		}
		
		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:PhysicalItem = newObj as PhysicalItem;
			if( result == null)
				result = new PhysicalItem();
			
			super.Copy( result);
			result.cost = cost;
			result.category = category;
			result.complete = complete;
			result.quantity = quantity;
			result.description = description;
			
			return result;
		}
		
		public function AddItem( pi:PhysicalItem):void
		{
			items[ pi.name] = pi;
		}

		static public function GetPhysicalItemByName( n:String):PhysicalItem
		{
			var result:PhysicalItem = items[ n];
			
			return result;
		}
		
		static public function GetPhysicalItem( pil:PossessionLoad):PhysicalItem
		{
			var result:PhysicalItem = items[ pil.name];
			
			if( result == null) {
				// generic object
				if( pil.name.indexOf( "Weapon") == 0)
					result = new WeaponItem();
				else if( pil.name.indexOf( "Armor") == 0)
					result = new ArmorItem();
				else
					result = new PhysicalItem();
				
				result.name = pil.name;
				result.complete = false;
			} else
				result.complete = true;
			
			result.quantity = 1;
			
			return result;
		}
		
		static public function AlphaSort( a:PhysicalItem, b:PhysicalItem):int
		{
			var aString:String = (a == null) ? null : (a.category + a.name);
			var bString:String = (b == null) ? null : (b.category + b.name);
			
			if( aString < bString)
				return -1;
			
			if( aString > bString)
				return 1;
			
			return 0;
		}

		public function GetGenericList():Array
		{
			var result:Array = new Array();
			
			for each( var pi:PhysicalItem in items)
				if( pi.cost > 0)
					result.push( pi);
			
			result.sort( AlphaSort);
			
			return result;
		}
		
		public function GetMessage():String
		{
			return "";
		}
		
		static public function ClearCache():void
		{
			// there has to be a better way
			items = new Array();
			WeaponItem.ClearCache();
		}
	}
}