package model
{
	import controller.BodyFrame;
	import controller.Dice;
	
	import flash.xml.XMLNode;
	
	import mx.rpc.xml.SimpleXMLDecoder;

	public class Nationality extends StorableObject
	{
		private var _name:String;
		private var range:Number;
		private var statChanges:Array;
		private var _bodyType:String;
		private var classes:CharClassSet;
		private var _cults:Array;
		
		static private var nationalities:Array;
		static private var totalRange:Number;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		public function get bodyType():String {return _bodyType;}
		[Bindable] public function set bodyType(s:String):void {_bodyType=s;}
		public function get cults():Array {return _cults;}
		[Bindable] public function set cults(a:Array):void {_cults=a;}
		
		public function Nationality()
		{
			statChanges = new Array();
			classes = new CharClassSet();
			cults = new Array();
			if( nationalities == null)
				nationalities = new Array();
		}
		
		static public function Consume( xml:XML):void
		{
			var list:XMLList = xml.children();

			// Clear the previous list of nationalities
			nationalities = new Array();

			totalRange = 0;
			for each( var x:XML in list) {
				var n:Nationality = LoadFromXML( x);
				if( n != null)
					nationalities[ n.name] = n;
				
				totalRange += n.range;
			}
		}

		static private function LoadFromXML( x:XML):Nationality
		{
			var result:Nationality = new Nationality();
			
			result.name = x.attribute( "name")[0];
			result.range = x.attribute( "range")[0];
			
			var chillins:XMLList = x.StatModifiers.children();
			for each( var xml:XML in chillins) {
				var mod:Modifier = new Modifier( xml);
				result.statChanges[ mod.name] = mod;
			}
			
			var temp:XMLList = x.BodyFrame.attribute( "value");
			result.bodyType = temp.length() > 0 ? temp[0] : "all";

			chillins = x.CharClasses.children();
			if( chillins.length() > 0)
				for each( xml in chillins) {
					var c:CharClassLoad = new CharClassLoad( xml);
					if( c != null)
						result.classes.AddCharClass( c);
				}

			chillins = x.Cults.children();
			if( chillins.length() > 0)
				for each( xml in chillins) {
					var s:String = xml.name();
					result.cults.push( s);
				}
			return result;
		}
		
		static public function GenerateNationality():Nationality
		{
			var roll:Number = Dice.Roll( 1, totalRange);
			
			for each( var n:Nationality in nationalities) {
				if( roll <= n.range)
					return n;
				roll -= n.range;
			}
			
			throw Error( "Nationality:GenerateNationality - invalid roll");
		}

		public function ApplyModifiers( char:Character):void
		{
			for each( var m:Modifier in statChanges)
				m.Apply( char);
		}

		override public function Load(rootObj:Object):StorableObject
		{
			return nationalities[ rootObj.name];
		}
		
		public function InnerGenerateCharClassSet( c:CharClassLoad, char:Character):CharClassSet
		{
			var result:CharClassSet = new CharClassSet();
			
			if( c != null) {
				result.AddCharClass( c);
				var sc:CharClassSet = c.GenerateSubclasses( char);
				
				for each( c in sc.array)
					if( c != null)
						result.AddCharClass( c);	// overwrites existing instances with same name
			}
			
			return result;
		}

		public function GenerateCharClassSet( char:Character):CharClassSet
		{
			var c:CharClassLoad = classes.GenerateCharClassLoad();
			var cs:CharClassSet = InnerGenerateCharClassSet( c, char);
			
			// Nobles with an Int >= 13 get an additional class
			if( char.intelligence >= 13)
				for each( c in cs.array)
					if( c.name == "Noble") {
						c = nationalities[ "Vilmir"].classes.GenerateCharClassLoad();	// TODO use default table instead of Vilmir table
						var sc:CharClassSet = InnerGenerateCharClassSet( c, char);
						
						trace( "Noble Classes")
						for each( c in sc.array) {
							trace( c.name);
							cs.AddCharClass( c);
						}
							
						break;	// only go through this once
					}

			return cs;
		}
	}
}