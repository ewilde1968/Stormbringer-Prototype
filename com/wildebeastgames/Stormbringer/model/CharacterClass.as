package model
{
	import controller.Dice;
	
	import mx.utils.ObjectUtil;

	public class CharacterClass extends StorableObject
	{
		private var _name:String;
		private var skills:Array;
		private var possessions:Array;
		private var statistics:Array;
		public var excludedSkills:Array;	// some classes are excluded from certain weapons or skills
		public var includedSkills:Array;	// explicitly included weapons or skills, to be used when generic skill excluded
		
		static private var classes:Array;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		
		public function CharacterClass()
		{
			skills = new Array();
			possessions = new Array();
			statistics = new Array();
			excludedSkills = new Array();
			includedSkills = new Array();
			
			if( classes == null)
				classes = new Array();
		}
		
		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();
			
			// Clear the previous list of classes
			classes = new Array();

			for each( var x:XML in list) {
				var c:CharacterClass = LoadFromXML( x);
				if( c != null)
					classes[ c.name] = c;
			}
		}
		
		static private function LoadFromXML( x:XML):CharacterClass
		{
			var result:CharacterClass = new CharacterClass();

			result.name = x.attribute( "name")[0];
			
			var chillins:XMLList = x.Skills.children();
			for each( var xml:XML in chillins) {
				var tempS:String = xml.name();
				switch( tempS) {
					case "skill":
						var skill:SkillLoad = new SkillLoad( xml);
						result.skills[ skill.name] = skill;
						break;
					case "exclusion":
						// a skill that is not allowed at character generation time
						tempS = xml.attribute( "name")[0];
						result.excludedSkills[ tempS] = true;
						
						// if this is a generic Weapon exclusion, there may be exceptions
						if( tempS == "Weapon") {
							var exceptionXML:XMLList = xml.exception;
							for each( var eXML:XML in exceptionXML) {
								tempS = eXML.attribute( "name")[0];
								result.includedSkills[ tempS] = true;
							}
						}
						break;
					default:
						break;
				}
			}
			
			chillins = x.Possessions.children();
			for each( xml in chillins) {
				var p:PossessionLoad = new PossessionLoad( xml);
				result.possessions[ p.name] = p;
			}

			chillins = x.Statistics.children();
			for each( xml in chillins) {
				var s:Modifier = new Modifier( xml);
				result.statistics[ s.name] = s;
			}

			return result;
		}
		
		override public function Load(rootObj:Object):StorableObject
		{
			var result:CharacterClass = GetCharacterClass( rootObj.name);
			
			return result;
		}

		static public function GetCharacterClass( s:String):CharacterClass
		{
			return classes[ s];
		}
		
		public function ApplyModifiers( char:Character):void
		{
			for each( var m:Modifier in statistics)
				m.Apply( char);
		}

		public function ApplySkills( char:Character):void
		{
			for each( var s:SkillLoad in skills) {
				var skill:Skill = Skill.FromSkillLoad( s, char);

				var meetsConstraints:Boolean = true;
				for each( var constraint:Constraint in s.constraints)
					if( !constraint.MeetsConstraint( char)) {
						meetsConstraints = false;
						break;
					}

				if( meetsConstraints) {
					char.AddSkill( skill);
					
					// If this is the Credit skill, add money per credit rules
					if( skill.name == "Credit") {
						if( Dice.Roll(1,100) <= skill.skillLevel) {
							var lbs:PhysicalItem = PhysicalItem.GetPhysicalItemByName( "Large Bronze Pieces");
							if( Dice.Roll(1,6) < 6)
								lbs.quantity = Dice.Roll(1,100) * 5;
							else
								lbs.quantity = Dice.Roll(1,100) * 10;
							
							char.AddPossession( lbs);
						}
					}
				}
			}
		}
		
		public function ApplyPossessions( char:Character):void
		{
			for each( var pl:PossessionLoad in possessions) {
				var pi:PhysicalItem = PhysicalItem.GetPhysicalItem( pl).Copy() as PhysicalItem;
				
				var meetsConstraints:Boolean = true;
				for each( var constraint:Constraint in pl.constraints)
					if( !constraint.MeetsConstraint( char)) {
						// there could be a consequence for failure, such as
						// gaining a replacement item. For example, a Merchant gets
						// to roll under his Credit skill to get any armor of choice
						// or get leather instead
						if( constraint.failure)
							pi = PhysicalItem.GetPhysicalItem( constraint.failure).Copy() as PhysicalItem;
						else
							meetsConstraints = false;

						break;
					}
				
				// only one of the generic weapon types per index
				if( pi.name.indexOf( "Weapon") == 0 && char.GetPossessionByName( pi.name) != null)
					meetsConstraints = false;
				
				if( meetsConstraints) {
					pi.quantity = pl.GetQuantity( char);
					char.AddPossession( pi);
				}
			}
		}
	}
}