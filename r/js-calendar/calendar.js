/////////////////////////////////////////////////
// Calendar Script - (c) Vasian CEPA 2001      //
/////////////////////////////////////////////////

// Edit these as necessary:

var months = new Array(
	"January", "February", "March", "April",
	"May", "June", "July", "August", "September",
	"October", "November", "December"
);
var days = new Array("S", "M", "T", "W", "T", "F", "S");

// No need to edit below.

var YEAR_MAX = 9999;
var YEAR_MIN = -1;
var IE_YEAR_MIN = 1600;
var NS_YEAR_MIN = 1970;

// we use sniffing, to find in which browser we are in
myBrowser=navigator.appName;
myVersion=navigator.appVersion;
var version45=(myVersion.indexOf("4.")!=-1||myVersion.indexOf("5.")!=-1||myVersion.indexOf("6.")!=-1);
var NS=(myBrowser.indexOf("Netscape")!=-1 && version45);
var IE=(myBrowser.indexOf("Explorer")!=-1 && version45);

if(NS) YEAR_MIN = NS_YEAR_MIN;
else YEAR_MIN = IE_YEAR_MIN;

var workDocument = document; // refine if used in frames

function writeMonth(month, year){
	if(writeMonth.arguments.length == 1){
		workDocument.write(getMonthString(month));
	} else if(writeMonth.arguments.length == 1){
		workDocument.write(getMonthString(month, year));
	} else {
		workDocument.write(getMonthString());
	}
}

function writeYear(year){
	if(writeYear.arguments.length > 0){
		workDocument.write(getYearString(year));
	} else {
		workDocument.write(getYearString());
	}
}

function getMonthString(month, year){
	var m = -1, y = -1;
	var now = new Date();

	// parse arguments
	if(getMonthString.arguments.length > 0){
		m = Math.abs(parseInt(month));
		if(m > 11) m = now.getMonth();
	}
	if(getMonthString.arguments.length > 1){
		y = Math.abs(parseInt(year));
		if( y < YEAR_MIN || y > YEAR_MAX) return yearOutOfRangeMsg();
	}

	// there is a difference between IE and NS here
	var margin = 0;
	if(IE) margin = 0;
	if(NS) margin = 1900;

	if( m == -1){
		m = now.getMonth(); // this month if month is missing
	}
	if( y == -1){
		y = margin + now.getYear();
	}
	
	var date = new Date(y, m, 1);

	//date table
	var start = "\n<table class='month' name='m" + m + "' >"
	start +="<caption class='month'>" + months[m] + "</caption>"
	start += "\n<tr class='day'>";
	for(var ii = 0; ii < 7; ii ++){
		start += "<th class='month'>" + days[ii] +"</th>";
	}
	start += "</tr>";
	var end = "\n</table>";
	var out = ""; // table body

	// we take care where to start in the right day of week
	var day = date.getDay(); // 0 - sunday, 1- monday, ...
	var count = 0;
	out = "\n<tr>";
	for(var i = 0; i < day; i++){
		count++;
		out += "<td class='month'>&nbsp;</td>"; // add empty cells till we arrive at day
	}
	var i = 1, discount = 0;
	for(; i <= 31; i++){
		date = new Date(y, m , i);
		if(date.getMonth() == m){
			var dd = i;
			if(dateCompare(date, now)){
				dd = "<b><span id='today'>" + i + "</span></b>";
			}
			else if(date.getDay() == 0){
				dd = "<span id='sunday'>" + dd + "</span>";
			}
			out += "<td class='month' name='d"
				+ i + "' align='right'>" + dd + "</td>";
			
			if((count + i) % 7 == 0){
				// once every seven days is a new week,
				// hence a new row of table
				out += "</tr>\n<tr>";
			}
		} else {
			discount++; // i is not used  this 'discount' times
		}
	}


	var r = (count + i - discount - 1) % 7;
	if(r != 0){
		for(var j = r; j < 7; j++){
			out += "<td class='month'>&nbsp;</td>";
		}
		out += "</tr>";	
	}
	return start + out + end;
}

function getYearString(year){
	var y = 0;
	if(getYearString.arguments.length > 0){
		y = parseInt(year);
		if(isNaN(y)){
			return "# Unknown year :o)!";
		}
	} else {
		y = new Date().getYear();
		if(NS) y+= 1900;
	}
	if( y < YEAR_MIN || y > YEAR_MAX) return yearOutOfRangeMsg();

	var start = "\n<table class='year' name='y" + y + "'>"
	start +="<caption class='year'>" + y + "</caption>"
	var end = "</table>";
	var out = "<tr>";

	for(i = 0; i < 12; i++){
		out += "<td class='year' valign='top'>"
			+ getMonthString(i, y) + "</td>";
		if((i + 1) % 3 == 0)
			out += "</tr>\n<tr>"
	}
	out += "</tr>";
	return start + out + end;
}

function dateCompare(d1, d2){
	if(
		d1.getYear() != d2.getYear() ||
		d1.getMonth() != d2.getMonth() ||
		d1.getDate() != d2.getDate()
	  ){
		return false;
	}
	return true;	
}

function yearOutOfRangeMsg(){
	return "# Years outside range (" + YEAR_MIN + " - " + YEAR_MAX +") are not supported!";
}
// END