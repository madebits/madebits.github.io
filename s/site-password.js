(function() {
"use strict";
var rounds = 1024;

var calculate = function (pass, site) {
	var hash = CryptoJS.PBKDF2(pass.trim(), site.trim(), { keySize: 256/32, iterations: rounds });
	/*
	var data = pass.trim() + site.trim();
	var hash = CryptoJS.SHA256(data);
	for(var i  = 1; i < rounds; i++) {
		hash = CryptoJS.SHA256(hash);
	}*/
	var hex = hash.toString(CryptoJS.enc.Hex);
	return [hex, hash.toString(CryptoJS.enc.Base64), HexToBase85(hex) ];
};

var init = function () {
	$("#rounds").html(rounds.toString());

	var pc = function(event) {
		var v = $(this).val();
		if(!v) return;
		window.prompt("Select and copy shown text", v);
	};

	$('#b1608').click(pc);
	$('#b1616').click(pc);
	$('#b1632').click(pc);

	$('#b6408').click(pc);
	$('#b6416').click(pc);
	$('#b6432').click(pc);

	$('#b8508').click(pc);
	$('#b8516').click(pc);
	$('#b8532').click(pc);

	$('#genpass').click(function(event) {
		$('#mbg-site-password').hide();
		event.preventDefault();
		var pass = $('#pass').val();
		var site = $('#site').val();
		var error = $('#error');
		error.html('');
		$(this).blur();

		if(!pass){ error.html("Error: master password is required!"); return false; }
		if(!site){ error.html("Error: web site domain is required!"); return false; }

		var h = calculate(pass, site);

		$('#b1608').val(h[0].substr(0, 8));
		$('#b1616').val(h[0].substr(0, 16));
		$('#b1632').val(h[0].substr(0, 32));

		$('#b6408').val(h[1].substr(0, 8));
		$('#b6416').val(h[1].substr(0, 16));
		$('#b6432').val(h[1].substr(0, 32));

		$('#b8508').val(h[2].substr(0, 8));
		$('#b8516').val(h[2].substr(0, 16));
		$('#b8532').val(h[2].substr(0, 32));
	
		
		$('#mbg-site-password').show();
		return false;
	});
}

$(function() {
	init();
});

})();