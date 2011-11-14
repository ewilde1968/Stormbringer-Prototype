package model
{
	import spark.components.Image;
	
	public class RoleplayingObject extends StorableObject
	{
		private var _name:String = null;
		private var _fullPicture:Object = null;
		private var _description:String = null;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		public function get fullPicture():Object {return _fullPicture;}
		[Bindable] public function set fullPicture(o:Object):void {_fullPicture=o;}
		public function get description():String {return _description;}
		[Bindable] public function set description(s:String):void {_description=s;}
		
		public function RoleplayingObject()
		{
			super();
		}
		
		public function Edit():void
		{
			// TODO
		}
		
		override public function StuffGenericObject(obj:Object):void
		{
			super.StuffGenericObject( obj);
			
			name = obj[ "name"];
			fullPicture = obj[ "fullPicture"];
			description = obj[ "description"];
		}
		
		override public function Copy( newObj:StorableObject=null):StorableObject
		{
			var result:RoleplayingObject = newObj as RoleplayingObject;
			if( result == null)
				result = new RoleplayingObject();
			
			super.Copy( result);
			result.name = name;
			result.fullPicture = fullPicture;
			result.description = description;
			
			return result;
		}
	}
}