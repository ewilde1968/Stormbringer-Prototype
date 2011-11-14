package model
{
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayList;

	public class StorableObject
	{
		private static var storage:StorageDevice = null;
		private var _index:Number = 0;	// unique Number of this StorableObject

		public function get index():Number {return _index;}
		public function set index(n:Number):void {_index=n;}
		public function get identifier():String {return index.toString();}
		public function clearIdentifier():void {_index=0;}
		
		public function StorableObject()
		{}

		public function Load( rootObj:Object):StorableObject
		{
			var className:String = getQualifiedClassName( this).replace( "::", "_" );

			return storage.Fetch( className, rootObj);
		}
		
		public function Save():void
		{
			storage.Put( this);
		}
		
		public function Delete():void
		{
			storage.Delete( this);
		}
		
		public function Update( obj:StorableObject):void
		{
			storage.Update( this, obj);
		}
		
		public function Copy( newObj:StorableObject = null):StorableObject
		{
			if( newObj == null)
				newObj = new StorableObject();
			
			newObj.index = index;
			
			return newObj;
		}

		public function SetAccess( username:String, access:String):void
		{
			// TODO
		}
		
		public function StuffGenericObject( obj:Object):void
		{
			index = obj.index;
		}
		
		static public function AddStorageDevice( device:StorageDevice):void
		{
			if( storage != null)
				device[ "parent"] = storage;
			storage = device;
		}
	}
}