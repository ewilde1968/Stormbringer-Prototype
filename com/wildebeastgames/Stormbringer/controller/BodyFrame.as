package controller
{
	import model.Character;

	public class BodyFrame
	{
		private var typeS:String;
		private var _height:Number;
		private var _weight:Number;
		static private const data:Array = [ "light", "medium", "heavy"];

		public function get height():Number {return _height;}
		public function get weight():Number {return _weight;}
		
		public function BodyFrame( char:Character)
		{
			switch( char.nationality.bodyType) {
				case "light":
					typeS = data[0];
					break;
				case "medium":
					typeS = data[1];
					break;
				case "heavy":
					typeS = data[2];
					break;
				case "!light":
					typeS = data[ Dice.Roll( 1, 2)];
					break;
				case "!medium":
					typeS = data[ Dice.Roll( 1, 2) == 1 ? 0 : 2];
					break;
				case "!heavy":
					typeS = data[ Dice.Roll( 1, 2, -1)];
					break;
				case "all":
				default:
					typeS = data[ Dice.Roll( 1, 3, -1)];
					break;
			}
			
			_height = GenerateHeight( char);
			_weight = GenerateWeight( char);
		}
		
		private function HeightBoundary( val:Number):Number
		{
			switch( val) {
				case 0:
					return 0;
				case 1:
					return 30;
				case 2:
					return 60;
				case 3:
					return 90;
				case 4:
					return 105;
				case 5:
					return 120;
				case 6:
					return 135;
				default:
					return (val < 0) ? 0 : 150 + (val - 7) * 5;
			}
		}

		private function GenerateHeight( char:Character):Number
		{
			var base:Number = HeightBoundary( char.size - 1);
			var range:Number = HeightBoundary( char.size) - base;

			return Dice.Roll( 1, range, base);
		}
		
		private function WeightBoundary( val:Number):Number
		{
			if( val > 0) {
				switch( typeS) {
					case "light":
						return val * 5;
					case "medium":
						return Math.floor( val * 7.5);
					case "heavy":
						return val * 10;
				}
			}
			
			return 0;
		}

		private function GenerateWeight( char:Character):Number
		{
			var base:Number = WeightBoundary( char.size - 1);
			var range:Number = WeightBoundary( char.size) - base;
			
			return Dice.Roll( 1, range, base);
		}
	}
}