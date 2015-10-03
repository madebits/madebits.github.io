1999

#TGen - JDBC Database to Java Code Generator

<!--- tags: java -->

**TGen** is a database to Java code generator. It is lightweight and properly splits the data structures mapping the database tables from the functionality classes used to manipulate the data, making it attractive to process data objects send over the network, e.g., when using Java RMI. 

There are many other tools that map relational database schema to Java objects (object-relational database layers).  When TGen was developed only one similar tool existed for Java, the Joe Carter's [TableGen v1.8](http://freespace.virgin.net/joe.carter/TableGen/). While TGen was influenced by TableGen, there are several aspects that make TGen different. TGen creates a class hierarchy based on database tables and enables thus generic code to be written. Given that TGen is not updated since 2000, newer tools should be used. This page is kept only for historical purposes. TGen is JDK 1.1 compatible.

##Documentation

TGen uses the same file structure as [HDBData](#r/java-hdbdata.md). Place TGen.java into `/org/peoplink/database/` folder. TGen uses `hdb.txt` to specify the database connection parameters. Edit `hdb.txt` to fit your database. TGen also uses `htypes.txt` file on the same directory. TGen requires `HUtils.java` and `HDB.java` in order to compile. They must be under the correct package directory structure and in CLASSPATH, in order for TGen to be successfully compiled.

##Generated Java classes

After started, TGen will scan the database schema, showing progress information in stdout. TGen generates Java classes for connected database specified under the `/org/peolink/database` folder. For every database table, two classes are generated. One is called `<TableName>Data.java` and contains plain data objects, that are used by the other class, `<TableName>.java`. `<TableName>.java` classes have code to access database and return objects to user, and also to update / insert and delete records. They inherits behavior from the abstract TableCode generated class (file `TableCode.java`).

The following methods of `TableCode.java` can be used in code with objects of derived classes:

* `public static String getTGenVersion()`- return TGen version. Normally '1.0'.
* `public void setWhereCondition(String cond)` - set the condition of the SQL statement, that is, the `WHERE` clause, for the SQL statement used by `public Vector getData(Connection con)`, `public Vector getPrimaryKeysData(Connection con)`, and `public void delete(Connection con)` methods (see below). The argument `cond` is the `WHERE` clause of the SQL statement, without `WHERE` (see below for examples).

These abstract methods are overridden in derived `<TableName>.java` classes:

* `public Vector getData(Connection con) throws Exception` - returns a vector of `TableNameData` objects, takes from a `ResultSet`, whose where condition is set by `setWhereCondition()`. If the condition is not set, then all the table data will be returned into a vector. To use the vector elements cast them to the corresponding `TableNameData` class.
* `public Vector getPrimaryKeysData(Connection con) throws Exception` - basically the same as `getData()`, but returns a vector made up of `TableData` objects, with only their variables that are part of the primary key filled up with data. The other variables are set to null, or zeros (the default java initialization for the type). Use this method to get a vector of objects to be used with `int delete(con, pkData)` method. The result can be filtered by setting the `where` clause via `setWhereCondition()` method.
* `public int update2(Connection con, Vector data) throws Exception` - every `TableData` object of data vector is inserted in database if it does not exist, otherwise it is updated.
* `public int update(Connection con, Object obj) throws Exception` - updates/inserts a single object of `TableNameData` type. If the record represented by `TableNameData` object exists, it will be updated based on `data` object data. If data-object does not exist, it will be inserted. Uses `exists()` and `setCurrentRecordData()` methods internally. Used by the generic form `update2()`.
* `public int delete(Connection con, Vector pkData) throws Exception` - deletes a set of rows from the table. The `pkDatav vector is the result of `getPrimaryKeys()` method, or a vector returned by `getData()` method. Use this method with vectors from `getPrimaryKeys()` method, since it is optimized not to read any unnecessary data.
* `public int delete(Connection con) throws Exception` - deletes a set of rows from a table, filtered by the `setWhereCondition()` method. If `setWhereCondition()` is called with "" or null, all records will be deleted.
* `public void setWhereCondition2(Object obj) throws Exception` - uses a dataobject obj of the `TableNameData` class to set the `WHERE` condition. Only primary key attributes are used. Uses `setWhereCondition(String)` internally.
* `public boolean exists(Connection con, Object obj) throws Exception` - returns true if the record represented by `TableNameData` type, `obj` object is found in `TableName` table. This is used by `update()`, but can also be used direclty.
* `public Vector validate(Object obj)` - tests whether the fields of the dataobject `obj` are within the bounds allowed by the database, returns a `Vector` of errors. The code tests currently only the string fields.
* `public Object getCurrentRecordData(ResultSet rs) throws Exception` - reads the current row from a `ResultSet` given as an argument. The result is a `TableNameData` object. This function is used by `getData()`, but if necessary it can also be used directly.
* `public void setCurrentRecordData(PreparedStatement pstmt, Object obj) throws Exception` - fills a `PreparedStatement` object with data form `TableNameData obj` object. Used by `update()`.

The `obj` objects should be of the same type as `TableNameData` objects for a given `TableName` class. TGen uses run-time object checking. A `ClassCastException` will be thrown if wrong type of object `obj` is passed. Some methods have an index `2` added given that `Vector` is a kind of Object, so that no overriding can take place. Some methods like `delete()`, `update()` etc., return an `integer` value which is the row count of the records affected by that operation.

Inheritance of `Table` code classes enables generic (polymorphic) methods to be written, that work with more that a type of data object. The example below is such a method, used to delete data in in both local and remote databases, used in a client (a simplified version is given here):

```
public void deleteObjects(PeoplinkServer server,
 Connection con,
 TableCode tc,
 Vector data)
{
 int tryCount = 0; // try twice in case of a RMI error
 while(tryCount < 2){
  try{
   // calls TGen delete(con, pkData) method
   server.delete(name, password, data);
   tryCount = 3;
  } catch(Exception e){
   SUtils.log(e.getMessage());
   tryCount++;
  }
 }
 // delete local data only if remote delete succeeds
 if(tryCount == 3) tc.delete(con, data);
}
```

The code can be used as:

```
Images im = new Images();
Stories st = new Stories();
Vector data = null;

im.setWhereCondition("ImageKey IN (10001, 10002)");
data = im.getPrimaryKeysData();
deleteObjects(server, con, im, data);

st.setWhereCondition("StoryKey IN (10003, 10004)");
data = st.getPrimaryKeysData();
deleteObjects(server, con, st, data);
```
TGen uses five basic data types internally: `String`, `int`, `boolean`, `double`, `byte[]`. See the appropriate `TableNameData.java` to find how each database table column is mapped. For example, datetime-s are get/set as `String` (correct datetime format is "yyyy-mm-dd hh:nn:ss"), binary types as `byte[]`. Do not rely on the internal arrangement of the columns inside the generated methods. If you need to know the order of the columns (normally this is not needed) use `org.peoplink.hdb.HUtils` methods.

##Application Sample Code

Obtain a JDBC connection object somewhere, it will not be closed by TGen methods.
```
java.sql.Connection con = ...;
```
To retreive data:
```
// get one or more objects and use them

Images im = new Images();</P>
im.setWhereCondition("ImageKey  IN (3, 6)");
java.util.Vector data = im.getData(con);
java.util.Enumeration e = data.elements();

// data.size() has the record count if needed

ImagesData imd = null;
while(e.hasMoreElements()){
 imd = (ImagesData)e.nextElement();
 System.out.println(imd.Description);
 System.out.println(imd.TPCode);
 // use any other fields ...
}
```
To delete data:
```
// to delete the above objects
// or change the set of the objects affected by recalling
// im.setWhereCondition("ImageKey = 2"); \
// call setWhereCondition(""); to effect all records
im.delete(con);
```
To update data - you must have some `ImagesData (imd)` object first:
```
// change some value and update object in database (the record)
imd.Description = "Logo"; // note no set/get methods here
imd.ImageBlob =
   org.peoplink.launcher.LUtils.readFile("./cl.jpg");
// only this call is needed to make an update
im.update(con, imd);
```
To insert data:
```
// build a new object and insert it
// take care to fill in all fields
// that are part of the primary key
ImagesData imd2 = new ImagesData();
imd2.Description = "Image 2";
img2.TPCode = ... // some tp code
img2.ImageKey = 2; // note: it may be an auto-increment field!
img2.ImageBlob =
     org.peoplink.launcher.LUtils.readFile("./launcher.gif");
// It is byte[] type
// this does now an insert!
im.update(con, imd2);
```

TGen was used to support an closed open source project http://sourceforge.net/projects/catgen

