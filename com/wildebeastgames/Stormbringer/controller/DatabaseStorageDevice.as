package controller
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import model.StorableObject;
	import model.StorageDevice;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;

	public class DatabaseStorageDevice implements StorageDevice
	{
		private var conn:SQLConnection;
		private var ready:Boolean = false;
		private var queue:Vector.<SQLStatement> = null;
		protected var tables:Array = null;
		private static const MAXBATCHSIZE:int = 500;
		private var _parent:StorageDevice = null;
		private var lastTable:Class = null;
		private var preloadFunction:Function = null;
		
		public function get parent():StorageDevice {return _parent;}
		public function set parent(sd:StorageDevice):void {_parent=sd;}
				
		public function DatabaseStorageDevice( dbName:String)
		{
			queue = new Vector.<SQLStatement>();
			conn = new SQLConnection();
			tables = new Array();
			
			conn.addEventListener( SQLEvent.OPEN, OnDatabaseOpen);
			conn.addEventListener( SQLErrorEvent.ERROR, ErrorHandler);

			var dbFile:File = File.applicationStorageDirectory.resolvePath( dbName);
			conn.openAsync( dbFile);
		}
		
		protected function ErrorHandler( event:SQLErrorEvent):void
		{
			trace( "DatabaseStorageDevice:ErrorHandler - ErrorID: ", event.error.errorID);
			trace( "DatabaseStorageDevice:ErrorHandler - Details: ", event.error.message);
		}
		
		protected function OnDatabaseOpen( event:SQLEvent):void
		{
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.sqlConnection = conn;
			sqlStatement.addEventListener(SQLEvent.RESULT, PreloadTableTypes);
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS tables (id INTEGER PRIMARY KEY AUTOINCREMENT, tableName STRING)";
			sqlStatement.execute();
		}

		protected function QueueStatement( stmnt:SQLStatement):void
		{
			queue.unshift( stmnt);
			
			if( ready && !conn.inTransaction) {
				var sqlStatement:SQLStatement = queue.pop();
				sqlStatement.execute();
			}
		}

		protected function statementResult(event:SQLEvent):void
		{
			if( !conn.inTransaction && queue.length > 0) {
				conn.begin();
				
				var count:int = ( queue.length > MAXBATCHSIZE) ? MAXBATCHSIZE : queue.length;
				while( count--) {
					var sqlStatement:SQLStatement = queue.pop();
					sqlStatement.execute();
				}
				
				conn.commit();
			}
		}
		
		protected function insertResult( event:SQLEvent):void
		{
			var so:StorableObject = event.currentTarget.parameters[":val"] as StorableObject;
			
			if( so != null)
				so.index = event.currentTarget.sqlConnection.lastInsertRowID;
			
			statementResult( event);
		}
		
		protected function CreateTable( tableName:String):void
		{
			// TODO tableName could be a security vulnerability
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.sqlConnection = conn;
			sqlStatement.addEventListener(SQLEvent.RESULT, statementResult);
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS " + tableName + " (id INTEGER PRIMARY KEY AUTOINCREMENT, val OBJECT)";
			sqlStatement.execute();
			
			var addStatement:SQLStatement = new SQLStatement();
			addStatement.sqlConnection = conn;
			addStatement.parameters[":tableName"] = tableName;
			addStatement.addEventListener(SQLEvent.RESULT, statementResult);
			addStatement.text = "INSERT INTO tables (tableName) VALUES (:tableName)";
			QueueStatement( addStatement);

			tables.push( tableName);
		}
		
		protected function PreloadTableTypes( event:SQLEvent):void
		{
			ready = true;	// if we got here, then the database is open and the table exists
		
			var getStatement:SQLStatement = new SQLStatement();
			getStatement.addEventListener( SQLEvent.RESULT, LoadTableType);
			getStatement.sqlConnection = conn;
			getStatement.text = "SELECT * FROM tables";
		
			QueueStatement( getStatement);
		}

		protected function LoadTableType( event:SQLEvent):void
		{
			var sqlResult:SQLResult = (event.target as SQLStatement).getResult();
			
			// start up the queue again
			statementResult(event);
			
			if( sqlResult.data != null) {
				for each( var obj:Object in sqlResult.data) {
					var s:String = obj["tableName"] as String;
					if( s != null)
						tables.push( s);
				}
			}
		}

		public function Put(obj:StorableObject):void
		{
			PreloadPut( obj);
			
			if( parent != null)
				parent.Put( obj);
		}

		public function Fetch( className:String, rootObj:Object):StorableObject
		{
			if( parent != null)
				return parent.Fetch( className, rootObj);
			
			return null;	// no individual fetching from the local database
		}
		
		private function PreloadPut( obj:StorableObject):void
		{
			var sqlQuery:String = "";
			var addStatement:SQLStatement = new SQLStatement();
			addStatement.sqlConnection = conn;
			addStatement.parameters[":val"] = obj;
			
			var className:String = getQualifiedClassName( obj).replace( "::", "_" );
			
			if( obj.index == 0) {
				// new object, see if the table already exists
				if( tables.indexOf( className) == -1)
					CreateTable( className);
				
				sqlQuery = "INSERT INTO " + className + " (val) VALUES (:val)";
				addStatement.addEventListener(SQLEvent.RESULT, insertResult);
			} else {
				sqlQuery = "UPDATE " + className + " SET val= :val WHERE id= :dbID";
				addStatement.parameters[":dbID"] = obj.index;
				addStatement.addEventListener(SQLEvent.RESULT, statementResult);
			}
			
			addStatement.text = sqlQuery;
			QueueStatement( addStatement);
			trace( sqlQuery);
		}

		protected function preloadResult( event:SQLEvent):void
		{
			var target:DatabaseStoragePreloadStatement = event.target as DatabaseStoragePreloadStatement;
			var sqlResult:SQLResult = target.getResult();
			
			// start up the queue again
			statementResult(event);

			var lastOne:Boolean = false;
			if( sqlResult.data != null) {
				for each( var obj:Object in sqlResult.data) {
					var o:Object = obj["val"];
					if( o != null) {
						var classReference:Class = target.classObject;
						var instance:Object = new classReference();
						if( classReference == lastTable)
							lastOne= true;
						instance.index = obj.id;
						o.index = instance.index;
						instance.StuffGenericObject( o);
						target.callback( instance);
					}
				}
			}
			
			if( lastOne && preloadFunction != null)
				preloadFunction();
		}
		
		public function PreloadAll( callback:Function = null, finished:Function = null):void
		{
			for each( var table:String in tables) {
				var tempClassName:String = table.replace("_",".")
				var objClass:Class = getDefinitionByName( tempClassName ) as Class;
				
				var getStatement:DatabaseStoragePreloadStatement = new DatabaseStoragePreloadStatement( callback, objClass);
				getStatement.addEventListener( SQLEvent.RESULT, preloadResult);
				getStatement.sqlConnection = conn;
				getStatement.text = "SELECT * FROM " + table;
				
				QueueStatement( getStatement);
				
				if( parent != null)
					parent.PreloadAll( PreloadPut, finished);
			}
			
			lastTable = objClass;
			preloadFunction = finished;
		}
		
		public function Enumerate( className:String):ArrayList
		{
			if( parent != null)
				return parent.Enumerate( className);

			// cannot fetch all preloaded items synchronously
			return null;
		}
		
		public function Delete( obj:StorableObject):void
		{
			var tableName:String = getQualifiedClassName( obj).replace( "::", "_" );

			var deleteStatement:SQLStatement = new SQLStatement();
			deleteStatement.addEventListener(SQLEvent.RESULT, statementResult);
			deleteStatement.sqlConnection = conn;
			deleteStatement.text = "DELETE FROM " + tableName + " WHERE id= :dbID";
			deleteStatement.parameters[":dbID"] = obj.index;

			QueueStatement( deleteStatement);
			
			if( parent != null)
				parent.Delete( obj);
		}

		public function Update( orig:StorableObject, newObj:StorableObject):void
		{
			Put( newObj);

			if( orig.index != newObj.index)
				Delete( orig);
		}
	}
}