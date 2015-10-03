/**
 * Roman Numerals Parsing Demo.
 * Copyright 2001 - by Vasian CEPA
 *
 * Methods:
 *
 * 1. toRoman(arabicNumber) -> return a roman numeral string
 * 	from an arabic numeral string or number
 * 2 .toArabic(romanNumberAsString) -> return an arabic numeral
 * 	string from a roman numeral string
 *
 */

// Range 1 - 9999 only is supported by now.
var _s_index = 0;
var _romanSymbolsAsRange = new Array();
_romanSymbolsAsRange[_s_index++] = ['I', 'V', 'X']; // 1-9
_romanSymbolsAsRange[_s_index++] = ['X', 'L', 'C']; // 10-99
_romanSymbolsAsRange[_s_index++] = ['C', 'D', 'M']; // 100-999
_romanSymbolsAsRange[_s_index++] = ['M', 'Q', 'T']; // 1000-9999
// To grow range add more lines here as necessary!!! E.g.:
//_romanSymbolsAsRange[_s_index++] = ['W', 'Y', 'Z']; // ...-...
delete _s_index;

// returned when wrong string or number passed as argument
var UNKNOWN_NUMBER = "????"; // const

// private conversion table
var _roman = _buildConversionTable();

/** converts an arabic decimal number into a roman numeral string */

function toRoman(arabicNumber){
	var result = "";
	var ns = String(arabicNumber).replace(/\./g, '_');
	var tempNum = Number(ns);
	if(isNaN(tempNum) || tempNum <= 0) return UNKNOWN_NUMBER; 	
	var delta = ns.length - 1;
	if(delta > _roman.length - 1) return UNKNOWN_NUMBER; // too big
	for(var i = delta; i >= 0; i--){
		if(ns.charAt(i) != '0'){
			result = _roman[delta - i][parseInt(ns.charAt(i)) - 1]
				+ result;
		}
	}
	return result;
}

/** converts a roman numeral string into an arabic decimal number string */

function toArabic(romanNumberAsString){
	var ns = String(romanNumberAsString).toUpperCase().replace(/\./g, '_');
	ns = ns.replace(/[0-9]/g, '_');
	var delta = ns.length - 1;
	for(var i = 0; i < _roman.length; i++){
		var pI = -1, pJ = -1;
		for(j = 0; j < 9; j++){
			var token = _roman[i][j];
			if(ns.indexOf(token) != -1){
				if((pI < 0 && pJ < 0) ||
				(token.length >	_roman[pI][pJ].length)){
					pI = i, pJ = j;
				}
			}
		}
		if(pI >= 0 && pJ >= 0){
			ns = ns.replace(_roman[pI][pJ],
					_indexToNumericString(pI, pJ +1));
			//alert("i,j: " + i + "," + j + " -> " + ns);
		}
	}
	/* use this with navigator.appVersion = 5.0 browsers
	try{
		return eval(ns).toString();
	} catch(e) {
		return UNKNOWN_NUMBER;
	}
	*/
	/* use this with all browsers */
	return _validateRomanNumber(ns);
}

///////////////////////////////////////////////////////////////
// internal functions used by the former two methods.
// do not use directly in code.
///////////////////////////////////////////////////////////////

function _validateRomanNumber(ns){
	// ns should be a string of form '+n1+n2+n3+...+ni'
	// where n1 > n2 > n3 > ... > ni belong to N
	var result = 0, previousNumber = Number.MAX_NUMBER;
	var numbers = ns.split('+');
	for(var i = 0; i < numbers.length; i++){
		// ignore first null string
		if(i == 0 && numbers[0] == "") continue;
		var tempNum = Number(numbers[i]);
		if(isNaN(tempNum) || tempNum >= previousNumber)
			return UNKNOWN_NUMBER;
		else result += tempNum;
		previousNumber = tempNum;
	}
	return result.toString();
}

function _indexToNumericString(pI, pJ){
	var result = "+" + pJ;
	for(var i = 0; i < pI; i++){
		result += "0";
	}
	return result;
}

function _buildConversionTable(){
	var rsr = _romanSymbolsAsRange;
	var ct = new Array(rsr.length);
	for(i = 0; i < rsr.length; i++){
		ct[i] = _buildRange(rsr[i][0], rsr[i][1], rsr[i][2]);
	}
	return ct;
}

function _buildRange(start, middle, end){
	var r = new Array(9);
	r[0] = start;
	r[3] = start + middle;	
	r[4] = middle;
	r[8] = start + end;
	for(var i = 1; i <= 7; i++){
		if(i == 3 || i == 4) continue;
		else r[i] = r[i - 1] + start;
	}
	return r;
}

///////////////////////////////////////////////////////////////
// end roman number
///////////////////////////////////////////////////////////////
