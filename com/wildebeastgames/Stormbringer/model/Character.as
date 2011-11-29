package model
{
	import controller.BodyFrame;
	import controller.CacheStorageDevice;
	import controller.Dice;
	import controller.SandboxGlobals;
	
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import spark.components.Image;
	
	public class Character extends Creature
	{
		private var _charClass:Array;
		private var _requiresCult:Boolean = false;
		private var _afflictions:Array;
		private var _sorcererRanks:String;
		private var _skills:Array;
		private var _cult:String;
		private var _possessions:Array;
		private var needsDefaultSkills:Boolean = false;
		[Bindable] public var skinDescription:String;
		[Bindable] public var eyesDescription:String;
		[Bindable] public var availableCults:Array;
		[Bindable] public var classString:String;
		
		public var hasChosenWeaponSkill:Boolean = false;
		
		public function get charClass():Array {return _charClass;}
		public function set charClass(a:Array):void {_charClass = a;};
		public function get requiresCult():Boolean {return _requiresCult;}
		[Bindable] public function set requiresCult(b:Boolean):void {_requiresCult=b;}
		public function get afflictions():Array {return _afflictions;}
		[Bindable] public function set afflictions(a:Array):void {_afflictions=a;}
		public function get skills():Array {return _skills;}
		[Bindable] public function set skills(a:Array):void {_skills=a;}
		public function get possessions():Array {return _possessions;}
		[Bindable] public function set possessions(a:Array):void {_possessions=a;}
		public function get sorcererRanks():String {return _sorcererRanks;}
		[Bindable] public function set sorcererRanks(s:String):void {_sorcererRanks=s;}
		public function get cult():String {return _cult;}
		[Bindable] public function set cult(s:String):void {_cult=s;}
		public function get culture():String {return _stats["Culture"].strVal;}
		[Bindable] public function set culture(s:String):void {_stats["Culture"].strVal=s;}
		public function get nation():String {return _stats["Nation"].strVal;}
		[Bindable] public function set nation(s:String):void {_stats["Nation"].strVal=s;}

		static private const defaultSkills:Array = [ "Jump", "Climb", "Dodge", "Balance", "Persuade", "Listen", "Hide"];

		public function Character( /* TODO contraints*/)
		{
			super();
			
			// Set Age to initially 25
			stats["Age"] = Statistic.Generate( "Age", 25);
			
			charClass = new Array();
			afflictions = new Array();
			skills = new Array();
			possessions = new Array();
			availableCults = new Array();
		}

		override public function get identifier():String {return name;}

		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);

			requiresCult = obj.requiresCult;
			sorcererRanks = obj.sorcererRanks;
			cult = obj.cult;
			skinDescription = obj.skinDescription;
			eyesDescription = obj.eyesDescription;

			for each( var o:Object in obj.afflictions) {
				if( o != null) {
					var aff:Affliction = new Affliction();
					aff = aff.Load( o) as Affliction;
					afflictions.push( aff);
				}
			}
			
			for each( o in obj.skills) {
				if( o != null) {
					var sk:Skill = new Skill();
					sk = sk.Load( o) as Skill;
					AddSkill( sk);
				}
			}
						
			for each( o in obj.charClass) {
				if( o != null) {
					var cClass:CharacterClass = new CharacterClass();
					cClass = cClass.Load(o) as CharacterClass;
					charClass[ cClass.name] = cClass;
				}
			}
			
			for each( o in obj.possessions) {
				if( o != null) {
					var p:PhysicalItem = new PhysicalItem();
					p = p.Load( o) as PhysicalItem;
					AddPossession( p);
				}
			}
			
			classString = ClassString();
		}
		
		override public function Save():void
		{
			if( needsDefaultSkills)
				ApplyDefaultSkills();
			needsDefaultSkills = false;
			
			// character name
			if( name == null || name.length < 1)
				throw( Error( "Character must have a name. Please enter a character name."));
			
			// cult
			if( requiresCult && ( cult == null || cult.length < 1))
				throw( Error( "Every priest must have a cult. Please select a cult."));
			
			// all generic skills selected
			for each( var skill:Skill in skills) {
				if( skill != null && !skill.complete)
					throw( Error( "Generic skills still remain. Please select specific skills for all remaining generic skills."));
			}
			
			// all generic items selected
			for each( var possession:PhysicalItem in possessions) {
				if( possession != null && !possession.complete)
					throw( Error( "Generic possessions still remain. Please select specific possessions for all remaining generic possessions."));
			}

			// clear out the stuff we don't want to save
			availableCults = null;
			
			// Whew! Made it. Now save this puppy.
			super.Save();
		}

		public function HasClass( cName:String):Boolean
		{
			return charClass[ cName] != null;
		}

		public function AddClass( c:CharClassLoad, choiceCallback:Function = null):void
		{
			if( HasClass( c.name))
				return;	// character already has this class
			
			var characterClass:CharacterClass = CharacterClass.GetCharacterClass( c.name);
			if( characterClass != null) {
				charClass[ c.name] = characterClass;
				
				if( c.name == "Priest") {
					requiresCult = SandboxGlobals.preferences().priestRequiresCult;
					elan = Dice.Roll( 2, 6);
				}
				
				// Determine Sorcery Ranks, must be before applying skills of class
				if( sorcererRanks == null
					&& (c.name == "Sorcerer" || c.name == "Priest"))
					DetermineSorcererRanks();
				
				// Determine Afflictions
				if( c.name == "Beggar") {
					var numAfflictions:int = Dice.Roll( 1, 4);
					while( numAfflictions--) {
						var affliction:Affliction = Affliction.GenerateAffliction();
						
						if( afflictions.indexOf( affliction) == -1) {
							affliction.ApplyModifiers( this);
							afflictions.push( affliction);
						} else
							affliction.DuplicateAffliction( this);
					}
				}
				
				// Determine attribute modifiers
				characterClass.ApplyModifiers( this);
				
				// Determine Skills
				characterClass.ApplySkills( this);
				
				// Determine Choices
				characterClass.ApplyChoices( this, choiceCallback);

				// Determine Possessions, some possessions require skills to get, so this
				// call should come after ApplySkills
				characterClass.ApplyPossessions( this);
				
				// Update the class string
				classString = ClassString();
			} else
				throw Error( "Character:AddClass - character type didn't exist");
		}

		static public function GenerateRandomCharacter( choiceCallback:Function = null):Character
		{
			var result:Character = new Character();
			result.needsDefaultSkills = true;

			// Generate Stats
			result.stats["Strength"] = Statistic.Generate( "Strength");
			result.stats["Constitution"] = Statistic.Generate( "Constitution");
			result.stats["Size"] = Statistic.Generate( "Size");
			result.stats["Intelligence"] = Statistic.Generate( "Intelligence");
			result.stats["Power"] = Statistic.Generate( "Power");
			result.stats["Dexterity"] = Statistic.Generate( "Dexterity");
			result.stats["Charisma"] = Statistic.Generate( "Charisma");
			result.stats["Elan"] = Statistic.Generate( "Elan", 0);

			// Determine Gender
			result.stats["Gender"] = Statistic.Generate( "Gender", Dice.Roll( 1, 2, -1));
			
			// Determine Nationality/Race
			var n:Nationality = Nationality.GenerateNationality();
			n.ApplyModifiers( result);
			n.ApplyColoring( result);
			result.stats["Nation"] = Statistic.Generate( "Nation", 0, n.name);
			result.stats["Culture"] = Statistic.Generate( "Culture", 0, n.description);
			result.stats["Alignment"] = Statistic.Generate( "Alignment", 0, n.alignment);
			result.availableCults = n.cults;

			// Determine Height/Weight
			var bf:BodyFrame = new BodyFrame( result, n);
			result.stats["Height"] = Statistic.Generate( "Height", bf.height);
			result.stats["Weight"] = Statistic.Generate( "Weight", bf.weight);
			
			// Determine Class
			var cs:CharClassSet = n.GenerateCharClassSet( result);
			for each( var c:CharClassLoad in cs.array)
				result.AddClass( c, choiceCallback);

			// Determine Additional Skills
			var additionalSkills:Number = SandboxGlobals.preferences().lessSkills ?
				Dice.Roll(1, 4, 2) : Dice.Roll(1, 6, 2);
			while( additionalSkills--) {
				var skill:ParentSkill = new ParentSkill();
				skill.name = "Choose a Skill " + (additionalSkills+1).toString();
				result.AddSkill( skill);
			}

			// Determine max hit points
			// use the Stormhack variant rule, should be externalized
			var hpBonus:Bonus = Bonus.Get( "Hit Points");
			var maxHP:int = SandboxGlobals.preferences().averageHitPoints ?
				Math.ceil( (result.constitution+result.size) / 2.0) :
				result.constitution + hpBonus.Value( result);
			result.stats["MaxHitPoints"] = Statistic.Generate( "MaxHitPoints", maxHP);
			result.stats["HitPoints"] = Statistic.Generate( "HitPoints", maxHP);
			
			// Determine Major Wound boundry
			result.stats["MajorWound"] = Statistic.Generate( "MajorWound", Math.ceil(result.hitPoints / 2.0));
			
			// Add nationality possessions last, which could effect LB quantities
			n.ApplyPossessions( result);
			
			return result;
		}

		public function ApplyDefaultSkills():void
		{
			// These skills are at least 10%; or, if already chosen, have +10% to them
			// To be called only after chargen is complete
			for each( var s:String in defaultSkills) {
				if( skills[ s] != null)
					skills[ s].skillLevel += 10;
				else {
					var sk:Skill = Skill.GetSkillByName( s);
					if( sk != null) {
						sk = sk.Copy() as Skill;
						sk.skillLevel = 10;
						
						AddSkill(sk);
					}
				}
			}
		}

		private function DetermineSorcererRanks():void
		{
			// if currently don't qualify for Sorcerer Ranks then make training level I
			var i_p:Number = intelligence + power;
			
			if( i_p >= 32)
				sorcererRanks = "Circle I";

			if( i_p >= 36)
				sorcererRanks = "Circle II";

			if( i_p >= 40)
				sorcererRanks = "Circle III";

			if( i_p >= 44)
				sorcererRanks = "Circle IV";

			if( i_p >= 48)
				sorcererRanks = "Circle V";
		}

		private function ClassString():String
		{
			var result:String = "";
			for each( var c:CharacterClass in charClass) {
				if( result.length > 0)
					result += "-";
				result += c.name;
			}
			
			return result;
		}
		
		public function AddSkill( skill:Skill):void
		{
			if( skill == null)
				throw Error( "Character:AddSkill - null skill");

			if( skills[ skill.name] == null)
				skills[ skill.name] = skill;
			else if( skills[ skill.name].skillLevel < skill.skillLevel)
				skills[ skill.name] = skill;
			
			skill.character = this;
		}
		
		public function GetPossessionByName( s:String):PhysicalItem
		{
			for each( var pi:PhysicalItem in possessions) {
				if( pi.name == s)
					return pi;
			}
			
			return null;
		}

		public function RemoveSkill( skill:Skill):void
		{
			if( skill != null)
				skills[ skill.name] = null;
		}
		
		public function AddPossession( pi:PhysicalItem):void
		{
			if( pi == null)
				throw Error( "Character:AddPossession - null possession");
			
			// does the character already possess the item?
			var p:PhysicalItem = GetPossessionByName( pi.name);
			if( p != null)
				p.quantity += pi.quantity;
			else {
				possessions.push( pi);
				pi.character = this;
			}
		}
		
		public function RemovePossession( pi:PhysicalItem):void
		{
			var index:Number = possessions.indexOf( pi);
			
			if( index != -1)
				possessions.splice( index, 1);
		}
		
		public function GetCash():Number
		{
			var lbI:PhysicalItem = GetPossessionByName( "Large Bronze Pieces");
			if( lbI != null)
				return lbI.quantity;
			
			return 0;
		}
		
		public function IsExcludedSkill( skill:Skill):Boolean
		{
			// return true if this skill is prohibited based on character class
			// - should really only be applicable at character generation time
			// - if any class allows a skill, that skill is not prohibited
			
			var result:Boolean = true;
			for each( var cc:CharacterClass in charClass) {
				var thisClass:Boolean = false;
				
				if( cc.excludedSkills[ skill.name] != null)
					thisClass = true;
				
				if( cc.includedSkills[ skill.name] == true)
					return false;
				
				result = result && thisClass;
			}
			
			return result;
		}
		
		public function NumSkillChoicesRemaining():Number
		{
			var result:Number = 0;
			
			for each( var sk:Skill in skills) {
				if( sk is ParentSkill && !(sk is CraftSkill))
					result++;
			}
			
			return result;
		}
		
		public function GetMeleeDamageModifier():String
		{
			// BOGUS: quick hack in this prototype to just get it to work
			// need to rearchitect on next prototype version
			var compare:Number = strength + size;
			if( compare < 17)
				return "-1d6";
			if( compare < 25)
				return "";
			if( compare < 41)
				return "+1d6";
			if( compare < 51)
				return "+2d6";
			
			return "+3d6";
		}
		
		public function GetRangedDamageModifier():String
		{
			// BOGUS: quick hack in this prototype to just get it to work
			// need to rearchitect on next prototype version
			var compare:Number = strength + size;
			if( compare < 17)
				return "-1d4";
			if( compare < 25)
				return "";
			if( compare < 41)
				return "+1d4";
			if( compare < 51)
				return "+2d4";
			
			return "+3d4";
		}
	}
}