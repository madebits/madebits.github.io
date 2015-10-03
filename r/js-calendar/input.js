/*
function right(e) {
	var msg = "Calendar";
	if (navigator.appName == 'Netscape' && e.which == 3){
		alert(msg); return false;
	} else if (navigator.appName == 'Microsoft Internet Explorer' && event.button==2) {
		alert(msg); return false;
	} return true;
}
document.onmousedown = right;
*/

var header = '<head>'
	+ '<style>'
	+ '<!--'
	+ 'table.month {}'
	+ 'th.month { color: #000066; font-size: 8pt; }'
	+ 'tr.day { background-color: #ffffff; }'
	+ 'td.month { font-size: 8pt; }'
	+ 'caption.month { background-color: #f0f0f0;}'
	+ '#today {color: #008000; border-style: inset; border-width: 1; }'
	+ '#sunday {color: #ff0000; font-weight: bold; }'
	+ 'table.year  { border-color: #000000; border-style: inset; border-width: 1; background-color: #e1e1e1; border-radius: 5px; -moz-border-radius: 5px; -webkit-border-radius: 5px; }'
	+ 'caption.year { color: #ff0000; font-size: 14pt; font-weigth: bold; }'
	+ 'td.year { background-color: #ffffff; }'
	+ 'body {font-family: Verdana; scrollbar-face-color:#green;scrollbar-shadow-color:#grey;scrollbar-highlight-color:#ffdddd; scrollbar-3dlight-color:#000000;scrollbar-darkshadow-color:#000000;scrollbar-arrow-color:white;}'
	+ ' -->'
	+ '</style>'
	+ '</head><body bgcolor="#ffffff">\n';
var footer = '\n<br>';

function setYear(){
	var y = new Date().getYear();
	if(NS) y += 1900;
	document.calendar.year.value = y;
}

setYear();

function generateCal(){
var work = parent.show_f.document;
workDocument = work;
work.open();
work.write(header);
work.write(getYearString(document.calendar.year.value));
work.write(footer);
work.close();
}

function next(mode){
var next = parseInt(document.calendar.year.value);
if(isNaN(next)) return;
if(mode == 1) next++;
else next--;
document.calendar.year.value = next;
generateCal();
}

function generateActiveX(){
	setYear();
	//var cw = window.open("","jswebcal","width=330,height=230,resizable=no,status=no,toolbar=no,menubar=no,alwaysRaised=yes,scrollbars=no");
	//var work = cw.document;
	var work = parent.show_f.document;
	work.open();
	work.write("<title>Microsoft Calendar Control - ActiveX</title>");
	work.write("<body bgcolor='#ffffff'>");
	placeCalendar(work);
	work.close();
	//cw.focus();
	//cw.moveTo(100, 100);
}

function placeCalendar(doc){
	var today = new Date();
	doc.write('<OBJECT CLASSID="clsid:8E27C92B-1264-101C-8A2F-040224009C02" WIDTH=300 HEIGHT=200 BORDER=1 HSPACE=5 ID=calendar>');
	doc.write('<PARAM NAME="Day" VALUE=' + today.getDate() + '>');
	doc.write('<PARAM NAME="Month" VALUE=' + (today.getMonth() + 1) + '>');
	doc.write('<PARAM NAME="Year" VALUE=' + today.getYear() + '>');
	doc.write('</OBJECT>');
}

function printContentPage(){
	if(!window.print){
		alert("Feature not supported!");
		return;
	}
	var cf = parent.show_f;
	cf.focus();
	cf.print();
}
