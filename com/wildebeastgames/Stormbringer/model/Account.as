package model
{
	public class Account extends StorableObject
	{
		private var _email:String;
		private var _password:String;
		private var _referee:Boolean = false;
		private var _preferences:UserPreferences;

		public function get email():String {return _email;}
		[Bindable] public function set email(s:String):void {_email=s;}
		public function get password():String {return _password;}
		[Bindable] public function set password(s:String):void {_password=s;}
		public function get referee():Boolean {return _referee;}
		[Bindable] public function set referee(b:Boolean):void {_referee=b;}
		public function get preferences():UserPreferences {return _preferences;}
		[Bindable] public function set preferences(up:UserPreferences):void {_preferences=up;}
		
		public function Account()
		{
			super();
			
			preferences = new UserPreferences();
		}
		
		override public function get identifier():String {return email;}
		
		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			email = obj[ "email"];
			password = obj[ "password"];
			referee = obj[ "referee"];
			preferences.StuffGenericObject( obj.preferences);
		}
		
		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:Account = newObj as Account;
			if( result == null)
				result = new Account();
			
			super.Copy( result);
			result.email = email;
			result.password = password;
			result.referee = referee;
			result.preferences = preferences;
			
			return result;
		}
		
		override public function Save():void
		{
			// don't save default or invalid accounts
			if( email && email.length > 0)
				super.Save();
		}
	}
}