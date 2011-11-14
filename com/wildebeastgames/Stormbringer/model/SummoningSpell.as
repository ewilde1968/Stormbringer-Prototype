package model
{
	import controller.Dice;

	public class SummoningSpell extends Spell
	{
		private var earnedA:Array;	// array of arrays, one for each circle
		private var initialA:Array;	// array of arrays, one for each circle
		private var _currentA:Array;	// array of arrays, one for each circle
		private var numAvailable:Array;	// only valid for Summon Elemental Ruler

		public function get currentA():Array {return _currentA;}
		[Bindable] public function set currentA(a:Array):void {_currentA=a;}

		public function SummoningSpell(xml:XML=null)
		{
			super(xml);

			initialA = new Array();
			earnedA = new Array();
			numAvailable = new Array();

			if( xml != null) {
				var temp:XMLList = xml.circle;
				for each( var x:XML in temp) {
					var nm:String = x.attribute( "name")[0];
					
					temp = x.attribute( "initialArray");
					if( temp.length() > 0)
						initialA[ nm] = temp[0].split(",", 6);
					
					temp = x.attribute( "earnedArray");
					if( temp.length() > 0)
						earnedA[ nm] = temp[0].split(",", 6);

					temp = x.attribute( "numAvailable");
					if( temp.length() > 0)
						numAvailable[ nm] = temp[0];
				}
			}
		}

		override public function Load(rootObj:Object):StorableObject
		{
			StuffGenericObject( rootObj);
			
			return this;
		}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject(obj);

			currentA = obj.currentA;
		}

		private function SetTypeAndSkillLevel(item:*, index:int, array:Array):void
		{
			// set the demon/elemental type
			var roll:Number = Dice.Roll( 1, remainingTypesA.length, -1);
			typeA[index] = remainingTypesA[ roll];
			remainingTypesA.splice( roll, 1);
			
			// set the skill level
			var s:String = item as String;
			array[index] = Dice.ParseStringResult( s);
		}
		
		private function SetElementalRulerType(item:*, index:int, array:Array):void
		{
			var result:String = remainingTypesA[ elementalTypesA.indexOf( item)];
			array[index] = result;
		}
		
		private function InitializeRulers( summonElemental:SummoningSpell):void
		{
			if( summonElemental != null) {
				var endIndex:Number = numAvailable[ character.sorcererRanks];
				currentA = summonElemental.currentA.slice( 0, endIndex);
				typeA = summonElemental.typeA.slice( 0, endIndex);
				typeA.forEach( SetElementalRulerType);
			} else
				;	// a later addition of Summon Elemental should catch it
		}
		
		override protected function SetInitialLevel( s:SkillLoad):void
		{
			super.SetInitialLevel(s);
			
			// Set the Elemental Ruler type
			if( s.name.indexOf( "Ruler") != -1)
				InitializeRulers( character.skills[ "Summon Elemental"] as SummoningSpell);
			else if( initialA != null) {
				currentA = initialA[ character.sorcererRanks];
				if( currentA != null) {
					currentA = currentA.slice();	// make our own copy
					
					currentA.forEach( SetTypeAndSkillLevel, null);
				}
			}
			
			// If this is SummonElemental, then a prior Summon Elemental Ruler needs initializing
			if( s.name == "Summon Elemental") {
				var serS:SummoningSpell = character.skills[ "Summon Elemental Ruler"];
				if( serS != null)
					serS.InitializeRulers( this);
			}
		}

		override public function Copy(newObj:StorableObject=null):StorableObject
		{
			var result:SummoningSpell = newObj as SummoningSpell;
			if( result == null)
				result = new SummoningSpell();
			
			super.Copy( result);
			result.earnedA = earnedA;
			result.initialA = initialA;
			result.currentA = (currentA != null) ? currentA.slice() : null;
			result.numAvailable = numAvailable;;
			
			return result;
		}
		
		private function GetMessageString( entry:int, limit:int):String
		{
			var result:String = "";
			
			while( entry < limit) {
				if( result.length > 0)
					result += "\r";
				result += typeA[entry] + "   Total: " + currentA[entry++];
			}
			
			return result;
		}
		
		override public function GetMessage():String
		{
			return GetMessageString( 0, Math.ceil( typeA.length / 2.0));
		}
		
		public function GetSecondColumnMessage():String
		{
			// split the subcategories of summonings into two columns
			return GetMessageString( Math.ceil( typeA.length / 2.0), typeA.length);
		}
	}
}