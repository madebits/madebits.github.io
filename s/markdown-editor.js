(function(mbApp, mbStore, mbSecret, mbHtml) {
"use strict";

var lastFile = 'untitled.md';
var lastInputFile = null;
var sessionTextKey = 'meditor';
var textSelected = false;

var setText = function(txt) {
	if(!txt) txt = '';
	mbStore.set(sessionTextKey, txt);
};

var getText = function() {
	var txt = mbStore.get(sessionTextKey) || '';
	return txt;
};

var reloadFile = function() {
	loadInputFile(lastInputFile);
};

var loadInputFile = function(f) {
	if(!f) return;
	lastInputFile = f;
	var reader = new FileReader();
	reader.onload = loadFile;
	reader.readAsText(f, "UTF-8");
};

var loadFile = function(fileObj) {
	var text = fileObj.target.result;
	enableReload(true);
	$('#text').val(text);
	refreshPreview();
	$('#text').focus();
};

// http://thiscouldbebetter.wordpress.com/2012/12/18/loading-editing-and-saving-a-text-file-in-html5-using-javascrip/
var saveFile = function() {
	var textToWrite = $('#text').val();
	var textFileAsBlob = new Blob([textToWrite], {type:'text/plain'});
	var fileNameToSaveAs = lastFile;

	var downloadLink = document.createElement("a");
	downloadLink.download = fileNameToSaveAs;
	downloadLink.innerHTML = "Download File";
	if (window.webkitURL != null) {
		// Chrome allows the link to be clicked
		// without actually adding it to the DOM.
		downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
	}
	else {
		// Firefox requires the link to be added to the DOM
		// before it can be clicked.
		downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
		downloadLink.onclick = function (event) {
				document.body.removeChild(event.target);
			};
		downloadLink.style.display = "none";
		document.body.appendChild(downloadLink);
	}
	downloadLink.click();
	$('#text').focus();
};

var refreshPreview = function() {
	var t = $('#text');
	var tb = t[0];
	var data = t.val();
	setText(data);
	var s = tb.selectionStart;
	var e = tb.selectionEnd;
	if((s != e) && (s >= 0) && (e >= 0)) {
		data = data.substring(s, e);
	}
	data = mbHtml.markup(data);
	$('#preview').html(data);
	mbHtml.applyStyle('#preview');
	mbHtml.addToc(mbApp.pageContainerId(), mbApp.currentPage());
	enableButtons();
};

var encrypt = function(enc) {
	mbSecret.getPass().then(function(pass) {
		var txt = $('#text');
		var data = txt.val();
		data = mbSecret.encrypt(data, pass, enc);
		if(data) {
			txt.val(data);
			refreshPreview();
		}
		else {
			setTimeout(function() {
				encrypt(enc);
			}, 0);
		}
		txt.focus();
	}, function() {
		var txt = $('#text');
		txt.focus();
	});
};

var enableButtons = function() {
	if($('#text').val().length > 0) {
		$('#encrypt').removeAttr('disabled');
		$('#decrypt').removeAttr('disabled');
		$('#savefile').removeAttr('disabled');
	} else {
		$('#encrypt').attr('disabled', true);
		$('#decrypt').attr('disabled', true);
		$('#savefile').attr('disabled', true);
	}
};

var enableReload = function(on) {
	if(on) {
		$('#reload').removeAttr('disabled');
		$('#reload2').removeAttr('disabled');
	}
	else {
		$('#reload').attr('disabled', true);
		$('#reload2').attr('disabled', true);
	}
};

var replaceText = function(text, surround) {
	var t = $('#text');
	t.focus();
	var tb = t[0];
	try {
		if(!text) return;
		var s = tb.selectionStart;
		var e = tb.selectionEnd;
		var v = tb.value;
		if(surround) {
			var c = v.substring(s, e);
			if(!c) c = 'placeholder';
			text = text.format(c);
		}
		if (document.queryCommandSupported && document.queryCommandSupported('insertText')) {
			try{
				document.execCommand('insertText', false, text);
			} catch(e) { 
				tb.value = v.substring(0, s) + text + v.substring(e);
				tb.selectionEnd = s + text.length;
			}
		}
		else {
			tb.value = v.substring(0, s) + text + v.substring(e);
			tb.selectionEnd = s + text.length; 
		}
	} catch(e) {
		console.error(e);
	}
};

var removeEmptyLines = function () {
	var t = $('#text');
	t.focus();
	var v = t.val();
	var l = v.length;
	v = v.replace(/\n{3,}/g, '\n\n').trim() + '\n';
	if (document.queryCommandSupported && document.queryCommandSupported('selectAll')) {
		document.execCommand('selectAll', false, text);
	}
	else {
		var tb = t[0];
		tb.selectionStart = 0;
		tb.selectionEnd = l;
	}
	replaceText(v);
};

var dateNowStr = function() {
	var d = new Date();
	var m = d.getMonth() + 1;
	return '{0}-{1}-{2}'.format(
		d.getFullYear(), 
		(m < 10) ? '0' + m : m.toString(),
		(d.getDate() < 10) ? '0' + d.getDate() : d.getDate().toString()
		);
};

$(function() {
	var isFirefox = (navigator.userAgent.toLowerCase().indexOf('firefox') > -1);
	if(isFirefox) { 
		$('#editButton').hide();
		$('#editButtonMath').hide();
	}

	if(typeof Blob === 'undefined') {
		$('#savefile').hide();
	}

	if(!window.print) {
		$('#print').attr('disabled', true);
	}

	$('#print').click(function(event){
		event.preventDefault();
		window.print();
		$('#text').focus();
	});

	$('#hideshow').click(function(event) {
		var txt = $('#text'); 
		txt.toggle();
		if(txt.is(":visible")) {
			$('#editButtonInner').removeAttr('disabled');
			txt.focus();
		}
		else {
			$('#editButtonInner').attr('disabled', true);
		}
		event.preventDefault();
	});

	$('#goTop').click(function(event) { 
		event.preventDefault();
		$(this).blur();
		window.scrollTo(0, 0);
		$('#text').focus();
		//window.location.replace(mbApp.currentPage().toCssId());
		//window.location.replace(mbApp.currentPage().toCssId() + '#top');
	});

	enableReload(false);
	$('#reload').click(function(event) { 
		reloadFile();
		event.preventDefault();
		$(this).blur();
	});
	$('#reload2').click(function(event) { 
		reloadFile();
		event.preventDefault();
		$(this).blur();
	});

	$('#encrypt').click(function(event) { 
		encrypt(true);
		event.preventDefault();
	});

	$('#decrypt').click(function(event) { 
		encrypt(false);
		event.preventDefault();
	});
	
	$('#savefile').click(function(event) { 
		saveFile();
		event.preventDefault();
	});

	$('#textfile').click(function() {
		$(this).val('');
	});
	
	$('#textfile').on('change', function(event) {
		enableReload(false);
		var fileName = $('#fileName');
		fileName.html('');
		var files = event.target.files;
		if(files && files.length) {
			var f = files[0];
			lastFile = f.name;
			fileName.html('<i class="fa fa-file-text"></i> ' + lastFile);
			loadInputFile(f);
		}
	});

	$('#text').bind('input propertychange', function(){
		refreshPreview();
	});
	$('#text').on( "select", function(){
		textSelected = true;
		refreshPreview();
	});
	$('#text').on("mouseup", function(){
		if(textSelected){
			textSelected = false;
			window.setTimeout(refreshPreview, 500);
    	}
	});

	$('#text').on('keydown', function(event){
		if(isFirefox) return;
		var keyCode = event.keyCode || event.which;
		if(!event.shiftKey && (keyCode === 9)) {
			event.preventDefault();
			replaceText('\t');
			refreshPreview();
		}
	});

	$(".insertAction").click(function(event) {
		event.preventDefault();
		var id = $(this)[0].id;
		switch(id) {
			case "insertH1":
			replaceText('\n\n#{0}\n\n', true);
			break;
			case "insertH2":
			replaceText('\n\n##{0}\n\n', true);
			break;
			case "insertH3":
			replaceText('\n\n###{0}\n\n', true);
			break;
			case "insertList":
			replaceText('\n* {0}\n', true);
			break;
			case "insertNumList":
			replaceText('\n1. {0}\n', true);
			break;
			case "insertCode":
			replaceText('\n\n```\n{0}\n```\n\n', true);
			break;
			case "insertInlineCode":
			replaceText('`{0}`', true);
			break;
			case "insertEmp":
			replaceText('*{0}*', true);
			break;
			case "insertStrongEmp":
			replaceText('**{0}**', true);
			break;
			case "insertEsc":
			replaceText('\\', true);
			break;
			case "insertImage":
			replaceText('![@inline@](url)');
			break;
			case "insertLink":
			replaceText('[{0}](url)', true);
			break;
			case "insertTable":
			replaceText('\n\n|a|b|\n|-|-|\n|c|d|\n\n');
			break;
			case "insertLine":
			replaceText('\n\n---\n\n');
			break;
			case "insertDate":
			replaceText(dateNowStr());
			break;
			case "insertRemoveLines":
			removeEmptyLines();
			break;
			case "insertMathInline":
			replaceText('$$$ {0} $$$', true);
			break;
			case "insertMathInline2":
			replaceText('\\\\( {0} \\\\)', true);
			break;
			case "insertMathBlock":
			replaceText('\n\n$$\n{0}\n$$\n\n', true);
			break;
			case "insertMathFraction":
			replaceText('\\frac{ {0} }{ d }', true);
			break;	
			case "insertMathHat":
			replaceText('\\hat{ {0} }', true);
			break;
			case "insertMathSum":
			replaceText('\\sum\\limits_{i=1}^n x_i');
			break;
			case "insertMathProd":
			replaceText('\\prod\\limits_{i=1}^n x_i');
			break;
			case "insertMathPower":
			replaceText('^{ {0} }', true);
			break;
			case "insertMathSub":
			replaceText('_{ {0} }', true);
			break;
		}
		refreshPreview();
	});

	var txt = getText();
	$('#text').val(txt);
	refreshPreview();
	$('#text').focus();
});

})(madebits.app, madebits.storage, madebits.secret, madebits.html);