package model
{
	import mx.collections.ArrayList;

	public class WeaponItem extends PhysicalItem implements GenericObject
	{
		private var meleeStrength:Constraint;
		private var meleeDexterity:Constraint;
		private var rangedStrength:Constraint;
		private var rangedDexterity:Constraint;
		private var _reach:Number;
		private var _meleeDamage:String;
		private var _hands:Number;
		private var _range:Number;
		private var _rangedDamage:String;
		
		static private var weapons:Array;
		
		public function get reach():Number {return _reach;}
		[Bindable] public function set reach(n:Number):void {_reach=n;}
		public function get meleeDamage():String {return _meleeDamage;}
		[Bindable] public function set meleeDamage(s:String):void {_meleeDamage=s;}
		public function get hands():Number {return _hands;}
		[Bindable] public function set hands(n:Number):void {_hands=n;}
		public function get range():Number {return _range;}
		[Bindable] public function set range(n:Number):void {_range=n;}
		public function get rangedDamage():String {return _rangedDamage;}
		[Bindable] public function set rangedDamage(s:String):void {_rangedDamage=s;}
		
		public function WeaponItem( xml:XML = null)
		{
			super();
			
			if( xml != null) {
				var melee:XMLList = xml.melee;
				if( melee != null) {
					var temp:XMLList = melee.attribute( "strength");
					meleeStrength = new Constraint();
					meleeStrength.name = "Strength";
					meleeStrength.relation = "greaterequal";
					meleeStrength.SetValue( (temp.length() > 0) ? temp[0] : 1);
					
					temp = melee.attribute( "dexterity");
					meleeDexterity = new Constraint();
					meleeDexterity.name = "Dexterity";
					meleeDexterity.relation = "greaterequal";
					meleeDexterity.SetValue( (temp.length() > 0) ? temp[0] : 1);
					
					temp = melee.attribute( "length");
					reach = (temp.length() > 0) ? temp[0] : 0;
					
					meleeDamage = melee.attribute( "damage")[0];
					
					temp = melee.attribute( "hands");
					hands = (temp.length() > 0) ? temp[0] : 1;
				}
				
				var ranged:XMLList = xml.ranged;
				if( ranged != null) {
					temp = ranged.attribute( "strength");
					rangedStrength = new Constraint();
					rangedStrength.name = "Strength";
					rangedStrength.relation = "greaterequal";
					rangedStrength.SetValue( (temp.length() > 0) ? temp[0] : 1);
					
					temp = ranged.attribute( "dexterity");
					rangedDexterity = new Constraint();
					rangedDexterity.name = "Dexterity";
					rangedDexterity.relation = "greaterequal";
					rangedDexterity.SetValue( (temp.length() > 0) ? temp[0] : 1);
					
					temp = ranged.attribute( "range");
					range = (temp.length() > 0) ? temp[0] : 0;
					
					rangedDamage = ranged.attribute( "damage")[0];
				}
				
				if( weapons == null)
					weapons = new Array();
				name = xml.attribute( "name")[0];
				weapons[ name] = this;
			}
		}

		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:WeaponItem = newObj as WeaponItem;
			if( result == null)
				result = new WeaponItem();
			
			super.Copy( result);
			result.meleeStrength = meleeStrength;
			result.meleeDexterity = meleeDexterity;
			result.rangedStrength = rangedStrength;
			result.rangedDexterity = rangedDexterity;
			result.reach = reach;
			result.meleeDamage = meleeDamage;
			result.hands = hands;
			result.range = range;
			result.rangedDamage = rangedDamage;
			
			return result;
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject(obj);
			
			meleeStrength = (obj.meleeStrength != null) ? new Constraint() : null;
			if( meleeStrength != null)
				meleeStrength.StuffGenericObject( obj.meleeStrength);

			rangedStrength = (obj.rangedStrength != null) ? new Constraint() : null;
			if( rangedStrength != null)
				rangedStrength.StuffGenericObject( obj.rangedStrength);

			meleeDexterity = (obj.meleeDexterity != null) ? new Constraint() : null;
			if( meleeDexterity != null)
				meleeDexterity.StuffGenericObject( obj.meleeDexterity);

			rangedDexterity = (obj.rangedDexterity != null) ? new Constraint() : null;
			if( rangedDexterity != null)
				rangedDexterity.StuffGenericObject( obj.rangedDexterity);

			reach = obj.reach;
			meleeDamage = obj.meleeDamage;
			hands = obj.hands;
			range = obj.range;
			rangedDamage = obj.rangedDamage;
		}

		public function MeetsConstraints( char:Character, type:String):Boolean
		{
			switch( type) {
				case "melee":
					if( meleeDamage == null || meleeDamage.length == 0)
						return false;
					if( meleeStrength && !meleeStrength.MeetsConstraint( char))
						return false;
					if( meleeDexterity && !meleeDexterity.MeetsConstraint( char))
						return false;
					break;
				case "ranged":
					if( rangedDamage == null || rangedDamage.length == 0)
						return false;
					if( rangedStrength && !rangedStrength.MeetsConstraint( char))
						return false;
					if( rangedDexterity && !rangedDexterity.MeetsConstraint( char))
						return false;
					break;
			}

			return true;
		}

		override public function GetGenericList():Array
		{
			var result:Array = new Array();
			
			for each( var pi:PhysicalItem in weapons)
				result.push( pi);
			
			result.sort( AlphaSort);
			
			return result;
		}
		
		override public function GetMessage():String
		{
			var result:String = "";
			
			var needCR:Boolean = false;
			if( meleeDamage != null && meleeDamage.length > 0) {
				// show melee weapon
				needCR = true;
				
				result += "Melee:     ";
				result += (hands == 2) ? "(Two-handed)  " : "";
				result += "reach: " + reach + "cm  ";
				result += "damage: " + meleeDamage;
			}
			
			if( rangedDamage != null && rangedDamage.length > 0) {
				if( needCR)
					result += "\r";
				
				result += "Ranged:  ";
				result += "range: " + range + "m  ";
				result += "damage: " + rangedDamage;
			}

			return result;
		}
		
		public function CanParry():Boolean
		{
			return meleeDamage != null && meleeDamage.length > 0;
		}
		
		static public function GetByName( name:String):WeaponItem
		{
			return weapons[ name];
		}
		
		static public function ClearCache():void
		{
			weapons = new Array();
		}
	}
}