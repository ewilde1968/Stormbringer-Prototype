package model
{
	import controller.Dice;

	public class RandomName
	{
		private var structures:Array;
		private var totalStructures:Number;
		private var otherTables:Array;	// array of arrays of xml objects
		private var totalOthers:Array;	// array of numbers
		
		private function LoadStructureTable( xml:XML, types:Array):void
		{
			structures = new Array();
			totalStructures = 0;
			
			var list:XMLList = xml.structure;
			for each( var x:XML in list) {
				var ss:SyllableStructure = new SyllableStructure( x, types);
				structures.push(ss);
				totalStructures += ss.range;
			}
		}

		public function RandomName( xml:XML)
		{
			var types:Array = new Array();
			var list:XMLList = xml.structureTable;
			if( list != null)
				LoadStructureTable( list[0], types);

			otherTables = new Array();
			totalOthers = new Array();
			for each( var str:String in types) {
				var lookup:String = str + "Table";
				list = xml.child( lookup);
				
				if( list != null && list.length() > 0) {
					otherTables[ str] = new Array();
					totalOthers[ str] = Number( 0);

					var table:Array = otherTables[ str];
					for each( var x:XML in list.children()) {
						table.push( x);
						
						var temp:XMLList = x.attribute( "range");
						if( temp && temp.length() > 0)
							totalOthers[ str] = Number( totalOthers[str]) + Number( temp[0]);
					}
				}
			}
		}
		
		private function GetTableValue( str:String):String
		{
			var a:Array = otherTables[str];
			if( a != null) {
				var roll:Number = Dice.Roll( 1, totalOthers[str]);
				for each( var xml:XML in a) {
					var range:Number = xml.attribute( "range");
					if( roll <= range) {
						var result:String = "";
						
						var rl:XMLList = xml.attribute( "reroll");
						if( rl != null && rl.length() > 0) {
							var rr:Number = xml.attribute( "reroll");
							while( rr--)
								result += GetTableValue( str);
						} else
							result = xml.attribute( "value");

						return result;
					}
					roll -= range;
				}
			}
			
			return "";
		}

		public function GenerateName():String
		{
			var result:String = "";
			
			var roll:Number = Dice.Roll( 1, totalStructures);
			for each( var ss:SyllableStructure in structures) {
				if( roll <= ss.range)
					break;	// this is the one
				roll -= ss.range;
			}
			
			for each( var str:String in ss.elements) {
				if( str.indexOf( "userdefinedsyllabletype:") != -1) {
					var ts:String = GetTableValue( str.substr( SyllableStructure.identifier.length));

					// check to see if it is a second syllable in a row
					if( str.indexOf( "userdefinedsyllabletype:syllable") != -1) {
						var st:String = result.charAt( result.length - 1);
						if( st.length > 0 && st != "-" && st != " ")
							ts = ts.toLocaleLowerCase();
					}
					
					result += ts;
				} else
					result += str;
			}
			
			return result;
		}
	}
}