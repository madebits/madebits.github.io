import java.util.Hashtable;
import javax.microedition.lcdui.*;
import javax.microedition.midlet.*;
import javax.microedition.midlet.MIDletStateChangeException;
import mobcon.message.*;
import mobcon.storeables.*;

public abstract class AbstractMobApp extends MIDlet implements CommandListener
{
protected Command exitCommand;
protected Display display;
private Form form;
public static String CID = "6f60ea1de7a3215960b1209c817dad99";
protected String firstForm = "form";
protected String[] listElements;
protected TextBox messageBox;
private TextField textField;

public  AbstractMobApp()
{
exitCommand = new Command("Exit", Command.EXIT, 1);
display = Display.getDisplay(this);
}


public void callForm()
{
form = new Form("Test");
form.addCommand(exitCommand);
form.setCommandListener(this);
callTextField();
form.append(textField);
display.setCurrent(form);
}


public void callMessageBox( String label,  String text)
{
messageBox = new TextBox( label, text, 256, TextField.ANY );
display.setCurrent(messageBox);
}


public void callTextField()
{
String text = "";
text = "Hello World";
textField = new TextField("First Application", text, 256, TextField.ANY);
}


public void callTextField( String text)
{
textField = new TextField("First Application", text, 256, TextField.ANY);
}


public void commandAction( Command command,  Displayable screen)
{
if (command == exitCommand)
{
destroyApp(false);
notifyDestroyed();
}
}


public void destroyApp( boolean unconditional)
{
}


public void pauseApp()
{
}


public void startApp()
{
viewDisplay(firstForm);
}


public void viewDisplay( String displayName)
{
if(displayName.equals("form")) callForm();
}



} //EOC
