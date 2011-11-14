package model
{
	import controller.Dice;
	
	import flashx.textLayout.elements.SpecialCharacterElement;
	
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;

	public class Spell extends Skill
	{
		private var _typeA:Array;	// array of strings for type of [Elemental,Demon]
		protected var remainingTypesA:Array;	// array of strings for type of [Elemental,Demon] not yet chosen

		static public const elementalTypesA:Array = [ "Earth", "Air", "Fire", "Water"];
		static public const elementalRulerTypesA:Array = [ "Grome (Earth)", "Lassa (Air)", "Kakatal (Fire)", "Straasha (Water)"];
		static public const demonTypesA:Array = [ "Combat", "Protection", "Knowledge", "Transport", "Desire", "Possession"];

		public function get typeA():Array {return _typeA;}
		[Bindable] public function set typeA(a:Array):void {_typeA=a;}
		
		public function Spell( xml:XML = null)
		{
			if( xml != null) {
				typeA = new Array();

				// Set types of Elements/Demons to choose from
				var nm:String = xml.attribute( "name")[0];
				InitializeRemainingTypes( nm);
			}
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			typeA = obj.typeA;
			remainingTypesA = obj.remainingTypesA;
		}

		private function InitializeRemainingTypes( nm:String):void
		{
			if( nm.indexOf( "Summon") != -1) {
				if( nm.indexOf( "Elemental") != -1)
					remainingTypesA = (nm.indexOf( "Ruler") != -1) ? elementalRulerTypesA.slice() : elementalTypesA.slice();
				else if( nm.indexOf( "Demon") != -1)
					remainingTypesA = demonTypesA.slice();
			}
		}

		override protected function SetInitialLevel( s:SkillLoad):void
		{
			skillLevel = Number.NaN;
			
			typeA = new Array();	// start the choices afresh
			InitializeRemainingTypes( s.name);
		}
		
		override public function Copy(newObj:StorableObject=null):StorableObject
		{
			var result:Spell = newObj as Spell;
			if( result == null)
				result = new Spell();
			
			super.Copy( result);
			result.typeA = (typeA != null) ? typeA.slice() : null;
			result.remainingTypesA = (remainingTypesA != null) ? remainingTypesA.slice() : null;
			
			return result;
		}
	}
}