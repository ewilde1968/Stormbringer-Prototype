package model
{
	import mx.collections.ArrayList;

	public interface StorageDevice
	{
		function Put( obj:StorableObject):void;
		function Fetch( className:String, rootObj:Object):StorableObject;
		function PreloadAll( callback:Function = null, finished:Function = null):void;
		function Enumerate( className:String):ArrayList;
		function Delete( obj:StorableObject):void;
		function Update( orig:StorableObject, newObj:StorableObject):void;
	}
}