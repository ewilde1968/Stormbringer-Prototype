package controller
{
	import flash.data.SQLStatement;
	
	public class DatabaseStoragePreloadStatement extends SQLStatement
	{
		private var _callback:Function = null;
		private var _classObject:Class = null;
		
		public function get callback():Function {return _callback;}
		public function set callback(f:Function):void {_callback=f;}
		public function get classObject():Class {return _classObject;}
		public function set classObject(c:Class):void {_classObject=c;}
		
		public function DatabaseStoragePreloadStatement( loader:Function, c:Class)
		{
			super();
			
			callback = loader;
			classObject = c;
		}
	}
}