package model
{
	import mx.collections.ArrayList;

	public class CraftSkill extends ParentSkill
	{
		static private var craftSkillList:Array;
		
		public function CraftSkill( xml:XML = null)
		{
			super();
			
			if( craftSkillList == null)
				craftSkillList = new Array();
			genericSkills = craftSkillList;
			
			if( xml != null && xml.attribute( "parent")[0] == "Craft") {
				var nm:String = xml.attribute("name")[0];
				
				complete = true;
				craftSkillList[ nm] = this;
			}
		}
		
		override public function Copy(newObj:StorableObject=null):StorableObject
		{
			var result:CraftSkill = newObj as CraftSkill;
			if( result == null)
				result = new CraftSkill();
			
			super.Copy( result);
			
			return result;
		}
	}
}