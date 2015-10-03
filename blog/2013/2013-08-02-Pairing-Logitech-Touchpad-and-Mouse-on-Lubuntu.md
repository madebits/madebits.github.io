#Pairing Logitech Touchpad and Mouse on Lubuntu

2013-08-02

<!--- tags: linux -->

I have never been a big fan of computer touchpads. They are too inaccurate in comparison to a mouse, at least for me. After reading an answer to stackoverflow (I have lost the link :( suggesting of switching between different input devices once a while to avoid RSI taking the temporary lose of productivity into account (logical :), I decided to try an dedicated external touchpad device.

I bought an external Logitech Touchpad. I have still to get used with it in my desk, thought it looks much more promising on the first day that the one build in the laptops.

I [found](http://askubuntu.com/questions/113984/is-logitechs-unifying-receiver-supported) also some nice software [Solaar](http://pwr.github.io/Solaar/) to unify my Logitech wireless mouse (M325) with the Logitech Touchpad 910-002444, so that they both share same USB receiver to use one USB port for both. Solaar worked for me quite good on Lubuntu (13.04). I installed it as follows:
```
sudo add-apt-repository ppa:daniel.pavel/solaar   
sudo apt-get update   
sudo apt-get install solaar
```

It shows up as a menu in Accessories and has a nice UI that guides to pair, or unpair devices and to see some of their properties, such as, battery usage level.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-08-05-Skippy-XD-on-Lubuntu.md'>Skippy XD on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-08-02-CSharp-Obtaining-Method-Parameter-Names.md'>CSharp Obtaining Method Parameter Names</a></ins>
