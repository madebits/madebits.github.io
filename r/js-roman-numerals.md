2001

#Roman Numerals

<!--- tags: javascript -->

Roman numerals, such as `XIII`, use a different encoding from the Arabic numerals used nowadays. There is still some usage for the roman numerals, e.g., to enumerate nested numeric bulled lists, or just to look classically cool.

Small roman numerals are easy to decode, but the bigger the numbers become, the more difficult it is for a human to parse them. The code implements a full Roman to Arabic and vice-versa numerals converter built in JavaScript.

##Details

The JavaScript parser is somehow interesting. It uses a predefined symbol table to match the input string in order to try different lookahead lengths. The symbol ranges can be easily extended to allow numbers larger than 9999.

The code uses a different encoding for Roman numerals bigger than '4999' than the Romans did, as illustrated by the table below. Two additional symbols are used 'Q' for '5000', and 'T' for '10000'. The reason for this is that no Unicode encoding exists for the real over-lined Roman symbols.

Roman symbols use a over-line to multiply by 1000

|Roman Symbol|Symbol Used Here|Decimal
|-|-|-|
|<span style="text-decoration: overline;">V</span>|Q|5000| 
|<span style="text-decoration: overline;">X</span>|T|10000|
|<span style="text-decoration: overline;">L</span>|?|50000| 
|<span style="text-decoration: overline;">C</span>|?|100000| 
|<span style="text-decoration: overline;">D</span>|?|500000| 
|<span style="text-decoration: overline;">M</span>|?|1000000|

Try on-line [demo](#r/js-roman-numerals/index.html).

