package model
{
	import mx.collections.ArrayList;

	public class WeaponSkill extends ParentSkill
	{
		private var _weapon:WeaponItem;
		
		public function get weapon():WeaponItem {return _weapon;}
		[Bindable] public function set weapon(w:WeaponItem):void {_weapon=w;}
		
		public function WeaponSkill( xml:XML = null)
		{
			super();
			
			if( xml != null) {
				// if the name begins with "Weapon" or "Parry" then the specific weapon must still be chosen
				var nm:String = xml.attribute( "name")[0];
				if(( nm.indexOf( "Weapon") == 0) || (nm.indexOf( "Parry") == 0))
					complete = false;
				else
					complete = true;
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
			
			if( obj.weapon != null)
				weapon = WeaponItem.GetByName( obj.weapon.name);
			else
				weapon = null;
		}

		private function AlreadyHasThisSkill( w:WeaponItem):Boolean
		{
			var testName:String = w.name + " " + bonus.name;

			var result:Boolean = character.skills[testName] != null;
			return result;
		}

		override public function GetGenericList():Array
		{
			var temp:Array = new Array();
			var wi:WeaponItem = new WeaponItem();
			
			var al:Array = wi.GetGenericList();
			var excludeNonParryWeapons:Boolean = name.indexOf( "Parry") == 0;
			for each( wi in al) {
				// eliminate duplicate skills
				if( AlreadyHasThisSkill( wi))
					continue;
				
				// if the user chose a Parry skill, exclude melee
				// weapons and others that cannot parry
				if( excludeNonParryWeapons && !wi.CanParry())
					continue;
				
				if( wi.MeetsConstraints( character, "melee")
					|| wi.MeetsConstraints( character, "ranged")) {
					var newSkill:WeaponSkill = this.Copy() as WeaponSkill;
					newSkill.character = null;	// this new skill isn't yet attached to anyone
					newSkill.name = wi.name;
					newSkill.weapon = wi;
					newSkill.complete = true;
					
					temp.push( newSkill);
				}
			}
			
			return temp;
		}

		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:WeaponSkill = newObj as WeaponSkill;
			if( result == null)
				result = new WeaponSkill();
			
			super.Copy( result);
			result.weapon = weapon;
			
			return result;
		}
		
		override public function GetMessage():String
		{
			var result:String = "";
			
			if( weapon != null)
				result += weapon.GetMessage();
			if( complete && character != null) {
				if( result.length > 0)
					result += "\r";
				result += "Total: " + GetValue();
			}
			
			return result;
		}
	}
}