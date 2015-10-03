// http://www.privatefiletree.com/Public/program%20help/Program%20Help/JavaScript/Base85.js.htm

// function HexToBase85(sHex)
// function Base85ToHex(sBase85)
// THESE ARE FUNCTIONS TO CONVERT HEX TO BASE85
// AND CONVERT BASE85 TO HEX.
// HEX TAKES UP TWO BYTES PER CHAR.
// BASE85 TAKES UP ONE BYTE PER CHAR.
// 8 HEX DIGITS SHRINK DOWN TO 5 BASE85 DIGITS.
/*
These are the 85 digits:
!#$()*,-.0123456789:;<>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_abcdefghijklmnopqrstuvwxyz{|}~

Notice that I chose to leave out digits that would cause url 
problems such as & ? + % ' " = / \ `
*/
function HexToBase85(sHex)
{
var sBase85String;
var sOutput;
var iCount;
var iLoop;
var sConvert;
var iTotal;
var iHexLoop;
var iValue;
var iChar1;
var iChar2;
var iChar3;
var iChar4; 
sConvert = "0123456789ABCDEFabcdef";
sBase85String = Base85String();
iCount = sHex.length;
sOutput = "";
// LOOP THROUGH THE HEX 8 CHARS AT A TIME.
for(iLoop=0;iLoop<iCount;iLoop+=8)
{
// CONVERT 8 HEX CHARS TO AN INT32.
iTotal = 0;
for (iHexLoop=0;iHexLoop<8;iHexLoop++)
{
iValue = sConvert.indexOf(sHex.charAt(iLoop+iHexLoop));
if (iValue>15)
{
iValue-=6;
}
iTotal = iTotal * 16 + iValue;
} 
// CONVERT THE INT32 INTO 5 CHARS AT BASE 85.
iChar1 = Math.floor(iTotal/52200625);
iTotal -= iChar1 * 52200625;
iChar2 = Math.floor(iTotal/614125);
iTotal -= iChar2 * 614125;
iChar3 = Math.floor(iTotal/7225);
iTotal -= iChar3 * 7225;
iChar4 = Math.floor(iTotal/85);
iTotal -= iChar4 * 85;
sOutput += sBase85String.charAt(iChar1) + sBase85String.charAt(iChar2) + sBase85String.charAt(iChar3) + sBase85String.charAt(iChar4) + sBase85String.charAt(iTotal);
} 
return sOutput;
}
function Base85String()
{
// GENERATE THE BASE85 STRING.
// THIS IS USED TO CREATE A CHAR REPRESENTATION
// OF EACH BYTE.
var iLoop;
var sString;
sString = "!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstu";
/*
for (iLoop = 32; iLoop <= 126; iLoop++)
{
switch (iLoop)
{
case 34: // "
case 37: // %
case 38: // &
case 39: // '
case 43: // +
case 47: // /
case 61: // =
case 63: // ?
case 92: // \
case 96: // `
{
// DON'T ADD THIS CHAR.
break;
}
default:
{
// ADD THIS CHAR.
sString += String.fromCharCode(iLoop);
break;
}
}
}
*/
 
return sString;
}
function Base85ToHex(sBase85)
{
var sBase85String;
var sOutput;
var iCount;
var iLoop;
var sConvert;
var iTotal;
var iHexLoop;
var iValue;
var sTemp;
sConvert = "0123456789ABCDEFabcdef";
sBase85String = Base85String();
iCount = sBase85.length;
sOutput = "";
// LOOP THROUGH THE BASE 85 5 CHARS AT A TIME.
for(iLoop=0;iLoop<iCount;iLoop+=5)
{
// CONVERT 8 HEX CHARS TO AN INT32.
iTotal = 0;
for (iHexLoop=0;iHexLoop<5;iHexLoop++)
{
iValue = sBase85String.indexOf(sBase85.charAt(iLoop+iHexLoop)); 
iTotal = iTotal * 85 + iValue;
}
// CONVERT THE INT32 INTO 5 CHARS AT BASE 85.
sTemp = "";
for (iHexLoop=0;iHexLoop<8;iHexLoop++)
{ 
sTemp += sConvert.charAt(iTotal % 16);
iTotal = Math.floor(iTotal/16);
} 
for (iHexLoop=0;iHexLoop<8;iHexLoop++)
{
sOutput += sTemp.charAt(7-iHexLoop);
} 
} 
return sOutput;
} 
function StringToBase85(sString)
{
var sBase85String;
var sOutput;
var iCount;
var iLoop;
var sConvert;
var iTotal;
var iHexLoop;
var iValue;
var iChar1;
var iChar2;
var iChar3;
var iChar4; 
sBase85String = Base85String();
iCount = sString.length;
sOutput = "";
// LOOP THROUGH THE INPUT 4 CHARS AT A TIME.
for(iLoop=0;iLoop<iCount;iLoop+=4)
{
// CONVERT 4 CHARS TO AN INT32.
iTotal = 0;
for (iHexLoop=0;iHexLoop<4;iHexLoop++)
{
if (iLoop+iHexLoop < iCount)
{	
iValue = sString.charCodeAt(iLoop+iHexLoop);
} else
{
iValue = 0;
}
iTotal = iTotal * 16 + iValue;
} 
// CONVERT THE INT32 INTO 5 CHARS AT BASE 85.
iChar1 = Math.floor(iTotal/52200625);
iTotal -= iChar1 * 52200625;
iChar2 = Math.floor(iTotal/614125);
iTotal -= iChar2 * 614125;
iChar3 = Math.floor(iTotal/7225);
iTotal -= iChar3 * 7225;
iChar4 = Math.floor(iTotal/85);
iTotal -= iChar4 * 85;
sOutput += sBase85String.charAt(iChar1) + sBase85String.charAt(iChar2) + sBase85String.charAt(iChar3) + sBase85String.charAt(iChar4) + sBase85String.charAt(iTotal);
} 
return sOutput;
}