package controller
{
	import model.Character;
	
	import view.CharactersListGroup;

	public class ItemRendererContainer
	{
		[Bindable] public var dataObject:Object;
		public var context:String;
		public var character:Character;
		[Bindable] public var genericF:Function;	// for any kind of generic callback (e.g. delete button in list renderer
		
		// used to get at the root data for a particular object
		public function ItemRendererContainer( d:Object,
											   con:String,
											   ch:Character,
											   genF:Function)
		{
			dataObject = d;
			context = con;
			character = ch;
			genericF = genF;
		}
	}
}