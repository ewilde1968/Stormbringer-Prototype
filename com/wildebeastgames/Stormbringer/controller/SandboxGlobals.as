package controller
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import model.Account;
	import model.Affliction;
	import model.Bonus;
	import model.CharacterClass;
	import model.Nationality;
	import model.PhysicalItem;
	import model.Skill;
	import model.StorableObject;
	import model.UserPreferences;
	
	import mx.utils.XMLUtil;

	public class SandboxGlobals
	{
		[Bindable] public var cache:CacheStorageDevice;
		[Bindable] public var finishedPreloading:Boolean = false;
		[Bindable] public var loggedIn:Account;
		[Bindable] public var versionString:String;
		private var defaultXMLA:Array;
		private static var defaultAccount:Account = new Account();

		[Bindable] public static var singleton:SandboxGlobals;
		public static function preferences():UserPreferences {return singleton.loggedIn.preferences;}
		
		private function GetXMLFromFile( type:String):XML
		{
			// currently will have a filesize limit; but, that should be OK for now
			var filename:String = loggedIn.preferences.campaign + "/configuration/" + type + ".xml";
			var file:File = File.applicationStorageDirectory.resolvePath( filename);
			var filestream:FileStream = new FileStream();
			
			if( !file.exists)
				return defaultXMLA[ filename];

			filestream.open( file, FileMode.READ);

			var byteArray:ByteArray = new ByteArray();
			filestream.readBytes( byteArray);
			
			return new XML( byteArray);
		}

		private function ConsumeInstanceXMLFiles():void
		{
			// do not change order
			Bonus.Consume( GetXMLFromFile( "abilities"));
			Nationality.Consume( GetXMLFromFile( "nationalities"));
			CharacterClass.Consume( GetXMLFromFile( "characterclasses"));
			Skill.Consume( GetXMLFromFile( "skills"));
			Affliction.Consume( GetXMLFromFile( "afflictions"));
			PhysicalItem.Consume( GetXMLFromFile( "physicalitems"));
		}

		private function FinishedPreloading():void
		{
			finishedPreloading = true;
		}
		
		public function SandboxGlobals( defaultA:Array)
		{
			if( singleton == null)
				singleton = this;
			
			loggedIn = defaultAccount;
			defaultXMLA = defaultA;
			
			var db:DatabaseStorageDevice = new DatabaseStorageDevice( "defaultDB");
			cache = new CacheStorageDevice();

			StorableObject.AddStorageDevice( db);
			StorableObject.AddStorageDevice( cache);
		}
		
		public function ApplicationComplete():void
		{
			ConsumeInstanceXMLFiles();
			cache.PreloadAll( null, FinishedPreloading);
		}
		
		public function ChangeCampaign( newCampaign:String):void
		{
			if( loggedIn.preferences.campaign != newCampaign) {
				loggedIn.preferences = new UserPreferences( newCampaign);
				loggedIn.Save();
				
				ConsumeInstanceXMLFiles();
			}
		}
		
		public function LogIn( a:Account):void
		{
			var refresh:Boolean = false;
			if( a.preferences.campaign != loggedIn.preferences.campaign)
				refresh = true;
			
			loggedIn = a;
			
			// clear chargen storage, would be broader clear in future app
			ConsumeInstanceXMLFiles();
		}
		
		public function LogOut():void
		{
			// is there any cache or storage to clear or change?
			loggedIn = defaultAccount;
		}
	}
}