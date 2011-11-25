package model
{
	public class AlignmentLoad
	{
		public var val:String;
		public var range:Number;
		
		public function AlignmentLoad( xml:XML)
		{
			range = xml.attribute( "range")[0];
			val = xml.attribute( "value")[0];
		}
	}
}