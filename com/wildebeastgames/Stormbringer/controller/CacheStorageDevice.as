package controller
{
	import flash.filesystem.StorageVolumeInfo;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import model.StorableObject;
	import model.StorageDevice;
	
	import mx.collections.ArrayList;
	import mx.utils.ObjectUtil;
	
	public class CacheStorageDevice implements StorageDevice
	{
		private var tables:Array = null;
		private var _parent:StorageDevice = null;
		
		public function get parent():StorageDevice {return _parent;}
		public function set parent(sd:StorageDevice):void {_parent=sd;}

		public function CacheStorageDevice()
		{
			tables = new Array();
		}

		public function Put(obj:StorableObject):void
		{
			PreloadPut( obj);
			
			if( parent != null)
				parent.Put( obj);
		}
		
		public function Fetch(className:String, rootObj:Object):StorableObject
		{
			var table:Array = tables[ className];
			if( table != null)
				return table[ rootObj.identifier];

			if( parent != null)
				return parent.Fetch( className, rootObj);
			
			return null;
		}
		
		private function PreloadPut( obj:StorableObject):void
		{
			if( obj.identifier == null)
				throw Error( "CacheStorageDevice:Put - obj.identifier cannot be null.");
			
			var className:String = getQualifiedClassName( obj).replace( "::", "_" );
			if( tables[ className] == null)
				tables[ className] = new Array();
			
			var table:Array = tables[ className];
			table[ obj.identifier] = obj;
		}

		public function PreloadAll( callback:Function = null, finished:Function = null):void
		{
			// do nothing with callback as this is always the highest level storage device
			if( parent != null)
				parent.PreloadAll( PreloadPut, finished);
			else if( finished != null)
				finished();
		}
		
		public function Enumerate( className:String):ArrayList
		{
			var table:Array = tables[ className];
			if( table != null)
				return new ArrayList( table);
			
			if( parent != null)
				return parent.Enumerate( className);
			
			return null;
		}

		private function DeleteInternal( obj:StorableObject):void
		{
			var className:String = getQualifiedClassName( obj).replace( "::", "_" );
			var table:Array = tables[ className];
			var result:Array = new Array();
			for each( var o:StorableObject in table) {
				if( o != obj)
					result[ o.identifier] = o;
			}
			tables[ className] = result;
		}

		public function Delete( obj:StorableObject):void
		{
			DeleteInternal( obj);
			
			if( parent != null)
				parent.Delete( obj);
		}
		
		public function Update( orig:StorableObject, newObj:StorableObject):void
		{
			PreloadPut( newObj);

			if( newObj.identifier != orig.identifier) {
				newObj.clearIdentifier();	// ensure the write happens at all storage devices
				DeleteInternal( orig);
			}
			
			if( parent != null)
				parent.Update( orig, newObj);
		}
	}
}