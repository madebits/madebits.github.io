2010

NMEA GPS Parser in C#
=====

<!--- tags: csharp gps -->

Moved (in GitHub) from https://code.google.com/p/nmeasharp/

An (incomplete, but still useful) easily extensible NMEA GPS output message parser in C#. At the moment it parses most of: GGA, RMC, GLL, GSA, GSV. I use no generics here, so you can use it also with older .NET versions before 2.0.

##Setup

Create a parser instance, connect to ```NewMessage``` event, set up the source ```System.IO.Stream``` and start the parser. The parser has its own thread to read bytes from the source ```Stream```.

```csharp
gps.parser.Nmea parser = new gps.parser.Nmea();
parser.NewMessage += new gps.parser.Nmea.NewMessageEventHandler(HandleNewMessage);
parser.Source = System.IO.File.OpenRead(file); // you may want to buffer
parser.Start();
```

## Processing events

You are notified for each full parsed message, and can access data from it as shown:

```csharp
private void HandleNewMessage(gps.parser.NmeaMsg msg)
{
 gps.parser.Field f = null;
 switch(msg.id)
 {
 case gps.parser.NmeaMessage.MsgType.GGA:
  ...
  f = (gps.parser.Field)msg.Fields[gps.parser.GGA.FieldIds.X];
  if((f != null) && f.HasValue)
  {
   double longitude = f.GetDouble(position.x);
   ...
  }
  ...
  break;
 case gps.parser.NmeaMessage.MsgType.Done:
  ... // done
  break;
 }
}
```

Look at Field class for more details, on how to discover data type of variables at run-time (if ever needed).

##For the very lazy

I provide an easy to use ```MinimalNmeaPositionNotifier``` wrapper around the raw parser events. The wrapper reports only the most useful GPS position data once per new position (GGA and RMC only):

```csharp
gps.parser.Nmea parser = new gps.parser.Nmea();
gps.parser.MinimalNmeaPositionNotifier minimal = new gps.parser.MinimalNmeaPositionNotifier();
minimal.Init(parser);
minimal.NewGspPosition += new gps.parser.MinimalNmeaPositionNotifier.NewGspPositionEventHandler(NewGspPosition);
parser.Source = System.IO.File.OpenRead(file); // you may wanto to buffer
parser.Start(); //async
```

The new gps position event is fired on every new position and looks like:

```csharp
private void NewGspPosition(gps.parser.GpsPosition pos)
{
 // access: pos.x, pos.y, pos.speed, pos.course, pos.hdop, etc.
 // all data are in metric system
 ...
}
```

You can write your own other wrappers or extend the provided one.

##More information


Data source of the parser is a ```System.IO.Stream```. The parser uses only ```CanRead``` and ```ReadByte``` methods of the stream, so you can easily inherit from ```System.IO.Stream``` and wrap as stream any data source, such as a serial port (infinite stream), or even delay file input to simulate various baud rates.

Extending the parser to process a new NMEA output message type is very easy. Look at GGA, GGL, etc classes for more details. You need to create a class like the one shown next, and register it as ```parser.MessageHandler.Add(new GGL());``` (like this you can even replace existing message parsers):

```csharp
public class GLL : NmeaMsg
{
public class FieldIds
{
 public static readonly int X = 2; // longitude
...
}//EOC

public GLL()
{
 id = NmeaMsg.MsgType.GLL;
 Field f = null;

 f = new Field(Field.ValueType.GEODEGREES);
 f.index = new int[] { 3, 4 }; // field indexes in message
 fields.Add(FieldIds.X, f);
 ...

}

public override bool CanHandle(string[] nmea)
{
 return nmea[0].Trim().Equals("$GPGLL");
}

public override NmeaMsg CreateEmpty()
{
 return new GLL();
}
}//EOC
```

Have a look at ```gps2coords.cs``` for a complete command-line example, that parses an input NMEA text file and outputs another file made of floating coordinates.

There are no bugs as far as I know, but feel free to find any and fix them, or extend the parser. Do not expect much support thought.
