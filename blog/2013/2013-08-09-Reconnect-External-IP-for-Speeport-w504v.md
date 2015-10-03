#Script to Reconnect External IP for Speeport w504v

2013-08-09

<!--- tags: router -->

I wanted to be able to reset my external IP address for my Speedport w504v DSL router via command-line in Lubuntu. After googling I found, a [jdownloader](http://jdownloader.org/) [reconnect](http://board.jdownloader.org/showthread.php?t=17281) script for Speedport w504v and w503v:

```
[[[HSRC]]]
[[[STEP]]]
[[[REQUEST https="true"]]]
POST /cgi-bin/login.cgi?pws=%%%pass%%% HTTP/1.1
Host: %%%routerip%%%
[[[/REQUEST]]]
[[[/STEP]]]
[[[STEP]]]
[[[REQUEST https="true"]]]
GET /cgi-bin/disconnect.exe HTTP/1.1
Host: %%%routerip%%%
Cookie: %%%Set-Cookie%%%
[[[/REQUEST]]]
[[[/STEP]]]
[[[STEP]]][[[WAIT seconds="3"/]]][[[/STEP]]]
[[[STEP]]]
[[[REQUEST https="true"]]]
GET /cgi-bin/connect.exe HTTP/1.1
Host: %%%routerip%%%
Cookie: %%%Set-Cookie%%%
[[[/REQUEST]]]
[[[/STEP]]]
[[[STEP]]]
[[[REQUEST https="true"]]]
POST **** External Links are only visible to supporters **** HTTP/1.1
Host: %%%routerip%%%
Cookie: %%%Set-Cookie%%%
[[[/REQUEST]]]
[[[/STEP]]]
[[[/HSRC]]]
```

I know from a previous test in another machine this jdownloader script works, but I wanted something that works without needing jdownloader. And then I found, a `curl` script similar to what I wanted for [Speedport W 722W](http://blog.plee.me/tag/speedport/).

Combining the two, after some testing, and a hint to get the [external ip](http://askubuntu.com/questions/145012/how-can-i-find-my-public-ip-using-the-terminal) from command-line, I got the final script (replace `1234` with your router's password):

```
curl http://ipecho.net/plain ; echo
curl -k https://speedport.ip/cgi-bin/login.cgi -d "pws=1234" -e "https://speedport.ip/hcti_start_passwort.stm" -c "routercookies.txt"
curl -k https://speedport.ip/cgi-bin/disconnect.exe -e "https://speedport.ip/hcti_startseite.stm"  -b "routercookies.txt"
sleep 5
curl -k https://speedport.ip/cgi-bin/connect.exe -e "https://speedport.ip/hcti_startseite.stm"  -b "routercookies.txt"
curl -k https://speedport.ip/cgi-bin/logoutall.cgi -e "https://speedport.ip/hcti_startseite.stm" -b "routercookies.txt"
curl http://ipecho.net/plain ; echo
rm -f "routercookies.txt"
```

At the moment this seems to work ok for me to reconnect Speedport w504v DSL router via command-line in Lubuntu. There are some HTTP 302 redirect codes printed on console, but apart of that, it works.


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-08-14-MComix-on-Lubuntu.md'>MComix on Lubuntu</a> <a id='fnext' href='#blog/2013/2013-08-05-Skippy-XD-on-Lubuntu.md'>Skippy XD on Lubuntu</a></ins>
