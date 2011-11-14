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
		
		static private var classes:Array;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		
		public function CharacterClass()
		{
			skills = new Array();
			possessions = new Array();
			statistics = new Array();
			
			if( classes == null)
				classes = new Array();
		}
		
		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();
			
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
				var skill:SkillLoad = new SkillLoad( xml);
				result.skills[ skill.name] = skill;
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

				if( meetsConstraints)
					char.AddSkill( skill);
			}
		}
		
		public function ApplyPossessions( char:Character):void
		{
			for each( var pl:PossessionLoad in possessions) {
				var pi:PhysicalItem = PhysicalItem.GetPhysicalItem( pl).Copy() as PhysicalItem;
				
				var meetsConstraints:Boolean = true;
				for each( var constraint:Constraint in pl.constraints)
					if( !constraint.MeetsConstraint( char)) {
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