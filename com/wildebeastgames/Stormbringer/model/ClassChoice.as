package model
{
	public class ClassChoice
	{
		public var name:String;
		public var description:String;
		public var bennie:Array;	// list of benefits, classes or skills
		public var type:String;
		public var constraints:Array;
		
		public function ClassChoice( xml:XML)
		{
			name = xml.attribute( "name");
			description = xml.attribute( "description");
			
			type = xml.name();
			switch( type) {
				case "SkillGroup":
					bennie = new Array();
					constraints = new Array();

					var chillins:XMLList = xml.children();
					for each( var x:XML in chillins) {
						var innerType:String = x.name();
						switch( innerType) {
							case "constraint":
								var constraint:Constraint = new Constraint( x);
								if( constraint != null)
									constraints.push( constraint);
								break;
							case "skill":
								var skill:SkillLoad = new SkillLoad( x);
								if( skill != null)
									bennie[ skill.name] = skill;
								break;
						}
					}
					break;
				case "CharacterClass":
					break;
			}
		}
		
		public function MeetsConstraints( char:Character):Boolean
		{
			for each( var c:Constraint in constraints) {
				if( !c.MeetsConstraint( char))
					return false;
			}
			
			return true;
		}
	}
}