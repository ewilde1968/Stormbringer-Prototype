package model
{
	public class SyllableStructure
	{
		public var elements:Array;
		public var range:Number;
		
		static public const identifier:String = "userdefinedsyllabletype:";
		
		public function SyllableStructure( xml:XML, types:Array)
		{
			range = xml.attribute( "range")[0];
			elements = new Array();
			
			var chillins:XMLList = xml.children();
			for each( var x:XML in chillins) {
				var nm:String = x.name();
				
				switch( nm) {
					case "string":
						var val:String = x.attribute( "value")[0];
						elements.push( val);
						break;
					default:
						// add it to the list of tables to look for
						if( types[nm] == null)
							types[nm] = nm;
						
						nm = identifier + nm;
						elements.push( nm);

						break;
				}
			}
		}
	}
}