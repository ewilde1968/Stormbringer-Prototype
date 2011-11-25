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
		private var commands:Array;
		private var alignments:Array;
		private var alignmentRange:Number;
		private var possessions:Array;
		private var chances:Array;
		
		static private var nationalities:Array;
		static private var totalRange:Number;
		static private var randomNames:RandomName;
		static private var randomAttributeDice:String;
		static private var standard:Nationality;
		static private var skinsC:Chance;
		
		public function get name():String {return _name;}
		[Bindable] public function set name(s:String):void {_name=s;}
		public function get bodyType():String {return _bodyType;}
		[Bindable] public function set bodyType(s:String):void {_bodyType=s;}
		public function get cults():Array {return _cults;}
		[Bindable] public function set cults(a:Array):void {_cults=a;}
		[Bindable] public var alignment:String;
		[Bindable] public var description:String;
		
		public function Nationality()
		{
		}

		static private function ClearCachedLoadData():void
		{
			nationalities = new Array();
			randomNames = null;
			skinsC = null;
			standard = null;
		}

		static private function LoadCampaignNations( xml:XML):void
		{
			// a set range of nationalities in the campaign world
			var list:XMLList = xml.children();
			
			totalRange = 0;
			for each( var x:XML in list) {
				if( x.name() == "standardTable") {
					LoadStandardTable( XMLList( x));
				} else {
					var n:Nationality = LoadFromXML( x);
					
					if( n != null) {
						nationalities[ n.name] = n;
						totalRange += n.range;
					}
				}
			}
		}

		static private function LoadFromXML( xml:XML):Nationality
		{
			// TODO see if this can be used for other load as well
			var result:Nationality = new Nationality();
			
			result.name = xml.attribute( "name")[0];
			result.range = xml.attribute( "range")[0];
			
			var chillins:XMLList = xml.children();
			for each( var x:XML in chillins) {
				var nm:String = x.name();
				switch( nm) {
					case "StatModifiers":
						result.statChanges = new Array();
						var subChild:XMLList = x.children();
						for each( var element:XML in subChild) {
							var mod:Modifier = new Modifier( element);
							result.statChanges[ mod.name] = mod;
						}
						break;
					case "CharClasses":
						result.classes = new CharClassSet();
						subChild = x.children();
						for each( element in subChild) {
							var c:CharClassLoad = new CharClassLoad( element);
							if( c != null)
								result.classes.AddCharClass( c);
						}
						break;
					case "Cults":
						result.cults = new Array();
						subChild = x.children();
						for each( element in subChild) {
							var s:String = element.name();
							result.cults.push( s);
						}
						break;
					case "BodyFrame":
						subChild = x.attribute( "value");
						result.bodyType = subChild.length() > 0 ? subChild[0] : "all";
						break;
					case "Commands":
						subChild = x.children();
						result.commands = new Array();
						for each( element in subChild) {
							var str:String = element.name();
							result.commands.push( str);
						}
						break;
					case "Alignment":
						subChild = x.children();
						result.alignments = new Array();
						result.alignmentRange = 0;
						for each( element in subChild) {
							var align:AlignmentLoad = new AlignmentLoad( element);
							result.alignments.push( align);
							result.alignmentRange += align.range;
						}
						break;
					case "Possessions":
						subChild = x.children();
						result.possessions = new Array();
						for each( element in subChild) {
							var pl:PossessionLoad = new PossessionLoad( element);
							if( pl != null)
								result.possessions.push( pl);
						}
						break;
					case "Chance":
						// TODO
						subChild = x.children();
						if( result.chances == null)
							result.chances = new Array();
						
						var ch:Chance = new Chance( subChild);
						result.chances.push( ch);
						break;
				}
			}
			
			return result;
		}

		static private function LoadRandomNations( xml:XML):void
		{
			randomNames = new RandomName( xml);
			
			// load the various nationalities
			var list:XMLList = xml.child( "nationalAttributeTable");
			randomAttributeDice = list.attribute( "count")[0];
			
			totalRange = 0;
			for each( var x:XML in list.children()) {
				var n:Nationality = LoadFromXML( x);
				if( n != null) {
					nationalities[ n.name] = n;
					totalRange += n.range;
				}
			}
		}

		static private function LoadColoringTable( xmlList:XMLList):void
		{
			if( xmlList != null && xmlList.length() > 0)
				skinsC = new Chance( xmlList.Chance.children());
		}
		
		static private function LoadStandardTable( xmlList:XMLList):void
		{
			if( xmlList != null && xmlList.length() > 0)
				standard = LoadFromXML( xmlList[0]);
		}

		static public function Consume( xml:XML):void
		{
			ClearCachedLoadData();
			
			var list:XMLList = xml.random;

			// Clear the previous list of nationalities
			nationalities = new Array();
			
			if( list.length() > 0)
				LoadRandomNations( list[0]);
			else
				LoadCampaignNations( xml);
			
			LoadStandardTable( xml.standardTable);
			LoadColoringTable( xml.coloringTable);
		}

		private function ApplyAttribute( n:Nationality):Boolean
		{
			// return true if must stop
			for each( var str:String in n.commands) {
				switch( str) {
					case "clear":
						statChanges = new Array();
						bodyType = "all";
						break;
					case "stop":
						return true;
				}
			}

			if( statChanges == null)
				statChanges = new Array();
			for each( var mod:Modifier in n.statChanges)
				if( statChanges[ mod.name] == null)
					statChanges[ mod.name] = mod;

			if( classes == null)
				// only do this once for a nation
				classes = n.classes;

			if( alignment == null && n.alignments != null) {
				var roll:Number = Dice.Roll( 1, n.alignmentRange);
				for each( var align:AlignmentLoad in n.alignments) {
					if( roll <= align.range)
						break;
					roll -= align.range;
				}
				
				alignment = align.val;
			}

			if( bodyType == null || bodyType.length < 1 || bodyType == "all")
				bodyType = n.bodyType;
	
			if( cults == null)
				cults = new Array();
			for each( str in n.cults)
				if( cults.indexOf( str) == -1)
					cults.push( str);

			if( possessions == null)
				possessions = new Array();
			for each( var pl:PossessionLoad in n.possessions)
				possessions.push( pl);
				
			if( n.chances != null && n.chances.length > 0) {
				for each( var ch:Chance in n.chances) {
					mod = ch.Roll() as Modifier;
					if( mod != null && statChanges[ mod.name] == null)
						statChanges[ mod.name] = mod;
				}
			}

			return false;	// can continue to next attribute
		}

		static private function GenerateRandomTableBasedNationality():Nationality
		{
			var result:Nationality = new Nationality();
			
			result.name = randomNames.GenerateName();
			result.description = "";

			var numAttributes:Number = Dice.ParseStringResult( randomAttributeDice);
			while( numAttributes--) {
				// roll for nationality attribute
				var roll:Number = Dice.Roll( 1, totalRange);
				for each( var n:Nationality in nationalities) {
					if( roll <= n.range)
						break;
					roll -= n.range;
				}

				// append name
				if( result.description.length > 0)
					result.description += "-";
				result.description += n.name;
				
				// apply attribute
				if( result.ApplyAttribute( n))
					break;	// do no more
			}

			if( result.classes == null)
				// use standarad table
				result.classes = standard.classes;
			
			return result;
		}

		static public function GenerateNationality():Nationality
		{
			if( randomNames != null)
				return GenerateRandomTableBasedNationality();
			
			// use set campaign of nationalities
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
		
		public function ApplyColoring( char:Character):void
		{
			if( skinsC != null) {
				var colorO:Object = skinsC.Roll();
				
				if( colorO is Array) {
					char.skinDescription = "";
					
					for each( var str:String in colorO) {
						if( char.skinDescription.length > 0)
							char.skinDescription += "-";
						
						char.skinDescription += str;
					}
				} else
					char.skinDescription = colorO as String;
			}
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
			if( c.name == "StandardTable")
				c = standard.classes.GenerateCharClassLoad();
			
			var cs:CharClassSet = InnerGenerateCharClassSet( c, char);

			// Nobles with an Int >= 13 get an additional class
			if( char.intelligence >= 13)
				for each( c in cs.array)
					if( c.name == "Noble") {
						c = standard.classes.GenerateCharClassLoad();
						var sc:CharClassSet = InnerGenerateCharClassSet( c, char);
						
						for each( c in sc.array)
							cs.AddCharClass( c);
							
						break;	// only go through this once
					}

			return cs;
		}
		
		public function ApplyPossessions( char:Character):void
		{
			// limit this to cash for the prototype scope
			var cash:PhysicalItem = char.GetPossessionByName( "Large Bronze Pieces");
			if( cash == null)
				return;
			
			for each( var pl:PossessionLoad in possessions)
				if( pl.name == "Large Bronze Pieces") {
					if( pl.defaultMultiplier != null && pl.defaultMultiplier.length > 0)
						cash.quantity = cash.quantity * Number( pl.defaultMultiplier);
					else if( pl.defaultDice != 0 && pl.defaultDieSize != 0)
						cash.quantity += Dice.Roll( pl.defaultDice, pl.defaultDieSize);
				}
		}
	}
}