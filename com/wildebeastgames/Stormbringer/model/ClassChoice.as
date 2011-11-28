package model
{
	public class ClassChoice
	{
		public var name:String;
		public var description:String;
		public var bennie:Array;	// list of benefits, classes or skills
		public var type:String;
		
		public function ClassChoice( xml:XML)
		{
			name = xml.attribute( "name");
			description = xml.attribute( "description");
			
			type = xml.name();
			switch( type) {
				case "SkillGroup":
					bennie = new Array();
					
					var chillins:XMLList = xml.children();
					for each( var x:XML in chillins) {
						var skill:SkillLoad = new SkillLoad( x);
						if( skill != null)
							bennie[ skill.name] = skill;
					}
					break;
				case "CharacterClass":
					break;
			}
		}
	}
}