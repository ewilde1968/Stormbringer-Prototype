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
	
	import mx.utils.XMLUtil;

	public class SandboxGlobals
	{
		[Bindable] public var cache:CacheStorageDevice;
		[Bindable] public var finishedPreloading:Boolean = false;
		[Bindable] public var loggedIn:Account;
		[Bindable] public var versionString:String;
		private var defaultXMLA:Array;

		private function GetXMLFromFile( type:String):XML
		{
			// currently will have a filesize limit; but, that should be OK for now
			var filename:String = "configuration/" + type + ".xml";
			var file:File = File.applicationStorageDirectory.resolvePath( filename);
			var filestream:FileStream = new FileStream();
			
			if( !file.exists)
				return defaultXMLA[ type];

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
	}
}