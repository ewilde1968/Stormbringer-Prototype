package model
{
	public class UserPreferences extends StorableObject
	{
		public var campaign:String;
		public var averageHitPoints:Boolean;
		public var lessSkills:Boolean;
		public var useRandomNations:Boolean;
		public var priestRequiresCult:Boolean;
		public var sorcererRequires16Int:Boolean;
		
		public function UserPreferences( c:String = "Stormhack")
		{
			/* This is a totally hacky, short term way to do user preferences.
			   What is needed instead is a much more flexible way of loading
			   races, rule sets, etc. This solution, including all the model,
			   needs to be rewritten for the next version of the prototype.
			*/
			super();
			
			campaign = c;
			switch( c) {
				case "Young Kingdoms":
					averageHitPoints = false;
					lessSkills = false;
					useRandomNations = false;
					priestRequiresCult = true;
					sorcererRequires16Int = true;
					break;
				case "Stormhack":
					averageHitPoints = true;
					lessSkills = true;
					useRandomNations = true;
					priestRequiresCult = false;
					sorcererRequires16Int = false;
					break;
				default:
					throw Error( "UserPreferences:UserPreferences - invalid campaign string.");
			}
		}
		
		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject(obj);
			
			campaign = obj.campaign;
			averageHitPoints = obj.averageHitPoints;
			lessSkills = obj.lessSkills;
			useRandomNations = obj.useRandomNations;
			priestRequiresCult = obj.priestRequiresCult;
			sorcererRequires16Int = obj.sorcererRequires16Int;
		}
		
		override public function Copy(newObj:StorableObject=null):StorableObject
		{
			var result:UserPreferences = newObj as UserPreferences;
			if( result == null)
				result = new UserPreferences();
			
			super.Copy( result);
			result.averageHitPoints = averageHitPoints;
			result.lessSkills = lessSkills;
			result.useRandomNations = useRandomNations;
			result.priestRequiresCult = priestRequiresCult;
			result.sorcererRequires16Int = sorcererRequires16Int;
			
			return result;
		}
	}
}