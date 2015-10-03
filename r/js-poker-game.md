2001

#Poker Game in JavaScript

<!--- tags: javascript -->

Poker game written in JavaScript 1.2. It runs on both Internet Explorer 4+ and Netscape 4+ browsers, and it is tested with both of them. To my surprise, this game still runs in recent browsers, but it lacks the sophistication of modern JavaScript interfaces.

The core of this Javascript implementation originates from converting an old C++ implementation (since 1997) that I have lost. The code is well factorized with classes (the JavaScript's prototype object model is similar to Self, an OO language developed in the 1980s), but does not use the new HTML DOM features, as it is written before complete dynamic DOM support was widely available in the browsers.

##Game

Poker can be a marvelous game, but it cannot be played alone. In this implementation, the player plays against the computer. The game settings and difficulty are controlled by several parameters. In a real example, the pages where the game parameters are changed, or where the player credit is set, should be HTTP password protected.

![](r/js-poker-game/demo.gif)

##References

* http://www.pvv.ntnu.no/~nsaa/poker.html - A good reference on poker probabilities and poker links.

* http://www.pokerpages.com/pokerinfo/rank/index.htm - Poker hand ranks. This web site has also a good history of poker in US. The background image of the Poker game is taken from this site.

* http://www.kimberg.com/poker/dictionary.html - Dan Poker Dictionary.

* http://www.waste.org/~oxymoron/cards/ - The set of cards used in the Poker game comes from here. The 'b.gif' is modified and 'j.gif' is not distributed.