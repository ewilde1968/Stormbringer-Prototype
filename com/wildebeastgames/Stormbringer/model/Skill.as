package model
{
	import controller.Dice;
	
	import mx.collections.ArrayList;
	import mx.utils.ObjectUtil;

	public class Skill extends RoleplayingObject implements GenericObject
	{
		private var beginning:Object;	// value when first learning skill in game
		private var _bonus:Bonus;
		private var _constraints:Array;
		protected var _skillLevel:Number;
		private var _checked:Boolean = false;
		private var _character:Character = null;
		protected var _complete:Boolean = true;
		protected var genericSkills:Array;
		
		[Bindable] override public function set name(s:String):void {super.name=s;}
		public function get bonus():Bonus {return _bonus;}
		[Bindable] public function set bonus(b:Bonus):void {_bonus=b;}
		public function get skillLevel():Number {return _skillLevel;}
		[Bindable] public function set skillLevel(n:Number):void {_skillLevel=n;}
		public function get checked():Boolean {return _checked;}
		[Bindable] public function set checked(b:Boolean):void {_checked=b;}
		public function get character():Character {return _character;}
		[Bindable] public function set character(c:Character):void {_character=c;}
		public function get complete():Boolean {return _complete;}
		[Bindable] public function set complete(b:Boolean):void {_complete=b;}
		public function get constraints():Array {return _constraints;}
		[Bindable] public function set constraints(a:Array):void {_constraints=a;}
		
		static protected var skills:Array;
		
		public function Skill()
		{
			super();

			constraints = new Array();
			if( skills == null)
				skills = new Array();
			genericSkills = skills;
		}

		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();
			
			// Clear the previous list of skills
			skills = new Array();

			for each( var x:XML in list) {
				var s:Skill = LoadFromXML( x);
				if( s != null)
					skills[ s.name] = s;
			}
		}

		static private function LoadFromXML( xml:XML):Skill
		{
			var result:Skill = null;
			var nm:String = xml.attribute("name")[0];
			
			var temp:XMLList = xml.attribute( "bonus");
			if( temp.length() > 0) {
				var typeString:String = temp[0];
				switch( typeString) {
					case "Summoning":
						result = new SummoningSpell( xml);
						break;
					case "Binding":
						result = new BindingSpell( xml);
						break;
					case "Attack":
					case "Parry":
					case "Beggar Mob":
						result = new WeaponSkill( xml);
						break;
					default:
						temp = xml.attribute( "parent");
						if( temp.length() > 0) {
							if( temp[0] == "true" && nm == "Craft")
								result = new CraftSkill(xml);
							else if( temp[0] == "Craft")
								result = new CraftSkill(xml);
							else
								result = new ParentSkill();
						} else
							result = new Skill();
						break;
				}

				result.bonus = Bonus.Get( typeString);
			}
			
			result.name = nm;

			temp = xml.attribute( "beginning");
			result.beginning = temp.length() > 0 ? temp[0] : 0;
			
			temp = xml.constraint;
			for each( var x:XML in temp) {
				var c:Constraint = new Constraint( x);
				if( c != null)
					result.constraints[ c.name] = c;
			}
			
			temp = xml.attribute( "description");
			if( temp.length() > 0) {
				result.description = temp.length() > 0 ? temp[0] : null;
				
				var myPattern:RegExp = /\\n/g;
				result.description = result.description.replace( myPattern, "\n");
			}
			
			return result;
		}
		
		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:Skill = newObj as Skill;
			if( result == null)
				result = new Skill();
			
			super.Copy( result);
			result.beginning = beginning;
			result.bonus = bonus;
			result.constraints = constraints;
			result.skillLevel = skillLevel;
			result.checked = checked;
			result.character = character;
			result.complete = complete;
			result.genericSkills = genericSkills;

			return result;
		}
		
		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject(obj);
			
			beginning = obj.beginning;
			bonus = obj.bonus != null ? Bonus.Get( obj.bonus.name) : null;
			skillLevel = obj.skillLevel;
			checked = obj.checked;
			complete = obj.complete;
			
			for each( var o:Object in obj.constraints) {
				var c:Constraint = new Constraint();
				c = c.Load( o) as Constraint;
				constraints[ c.name] = c;
			}
		}
		
		override public function Load(rootObj:Object):StorableObject
		{
			var result:Skill = null;
			var type:String;
			
			if( rootObj.bonus != null)
				type = rootObj.bonus.name;
			else {
				if( rootObj.name.indexOf( "Summon") == 0)
					type = "Summoning";
				else
					type = "Binding";
			}
			
			switch( type) {
				case "Summoning":
					result = new SummoningSpell();
					result = result.Load( rootObj) as SummoningSpell;
					break;
				case "Binding":
					result = new BindingSpell();
					result = result.Load( rootObj) as BindingSpell;
					break;
				case "Attack":
				case "Parry":
				case "Beggar Mob":
					result = new WeaponSkill();
					result = result.Load( rootObj) as WeaponSkill;
					break;
				default:
					var origSk:Skill = skills[ rootObj.name];
					result = origSk == null ? new Skill() : origSk.Copy() as Skill;
					result.StuffGenericObject( rootObj);
					break;
			}
			
			return result;
		}

		protected function SetInitialLevel( s:SkillLoad):void
		{
			skillLevel = s.GetInitialLevel( character);
		}

		static public function FromSkillLoad( s:SkillLoad, char:Character):Skill
		{
			var skill:Skill = InnerFromSkillLoad( s);
			
			skill = skill.Copy() as Skill;
			skill.character = char;
			skill.name = s.name;	// might change in Inner....
			skill.SetInitialLevel( s);

			return skill;
		}

		static protected function InnerFromSkillLoad( s:SkillLoad):Skill
		{
			if( s.name.indexOf( "Weapon") == 0)
				return skills[ "Weapon"];
			
			var temp:int = s.name.indexOf( "Parry");
			if( temp == 0)
				return skills[ "Parry"];
			else if( temp > 0) {
				// create a new skill for this instance
				var result:WeaponSkill = new WeaponSkill();
				result.name = s.name;
				result.bonus = skills[ "Parry"].bonus;
				result.constraints = skills[ "Parry"].constraints;
				result.weapon = WeaponItem.GetByName( s.name.substr( 0, temp - 1));
				result.complete = true;
					
				return result;
			}

			temp = s.name.indexOf( "Attack");
			if( temp > 0) {
				// create a new skill for this instance
				result = new WeaponSkill();
				result.name = s.name;
				result.bonus = skills[ "Weapon"].bonus;
				result.constraints = skills[ "Weapon"].constraints;
				result.weapon = WeaponItem.GetByName( s.name.substr( 0, temp - 1));
				result.complete = true;
				
				return result;
			}

			if( s.name.indexOf( "Craft ") == 0)
				return skills[ "Craft"];
			
			return skills[ s.name];
		}
		
		private function IsPhysical():Boolean
		{
			if( bonus != null)
				return bonus.physical;
			
			return false;
		}

		public function GetValue():Number
		{
			var result:Number = skillLevel + ( bonus != null ? bonus.Value( character) : 0);
			
			// now adjust for extreme ages
			// NOTE: This is different than the written rules as I feel the written rules are wrong
			if( character.age < 25)
				result -= 5 * (25 - character.age);
			else if( character.age > 40 && IsPhysical())
				result -= (character.age - 40);
			
			return result;
		}
		
		static public function AlphaSort( a:Skill, b:Skill):int
		{
			var aString:String = (a == null) ? null : a.name;
			var bString:String = (b == null) ? null : b.name;

			if( aString < bString)
				return -1;
			
			if( aString > bString)
				return 1;
			
			return 0;
		}
		
		public function GetGenericList():Array
		{
			var result:Array = new Array();
			
			for each( var s:Skill in genericSkills)
				// keep the generic combat skills (Weapon, Parry)
				// choice of a generic skill will result in a need to specify before saving
				if( character.skills[ s.name] == null && !character.IsExcludedSkill( s)
					&& s.name != "Craft") {
					var b:Boolean = true;
					for each( var c:Constraint in s.constraints) {
						if( !c.MeetsConstraint( character))
							b = false;
					}

					if( b)
						result.push( s);
				}

			result.sort( AlphaSort);

			return result;
		}
		
		public function GetMessage():String
		{
			// normal skill
			// bonus, level
			var result:String = bonus ? ( "Bonus: " + bonus.name) : "";
			if( complete && character != null) {
				if( result.length > 0)
					result += " (" + bonus.Value( character) + ")\r";
				result += "Total: " + GetValue();
			}

			return result;
		}
		
		static public function GetSkillByName( s:String):Skill
		{
			return skills[ s];
		}
	}
}