#!/usr/bin/env node

var vm = require('vm');
var fs = require('fs');
var prefix = 'U2FsdGVkX1';

if (typeof String.prototype.startsWith != 'function') {
	String.prototype.startsWith = function (str){
		return this.slice(0, str.length) == str;
	};
}

var readFileText = function(path) {
	var data = fs.readFileSync(path, { encoding: 'utf8' });
    data.replace(/^\uFEFF/, '');
    return data;
};

var loadJs = function(path, ctx) {
	ctx = ctx || {};
	var data = readFileText(path);
  	vm.runInNewContext(data, ctx, path);
  	return ctx;  
};

var CryptoJS = loadJs('./scripts/cryptojs/aes.js').CryptoJS;

var beautify = function(d) {
	if(!d) return '';
	var temp = '', lineLength = 64;
	for(var i = 0; i < d.length; i+= lineLength) {
		temp += d.substr(i, lineLength) + '\n';
	}
	return temp;
};

var encrypt = function (path, pass) {
	var data = readFileText(path);
	var res = CryptoJS.AES.encrypt(data, pass).toString();
	if(res.startsWith(prefix)) {
		res = res.substr(prefix.length);
	}
	console.log(beautify(res));
};

var decrypt = function (path, pass) {
	var data = readFileText(path);
	data = data.replace(/[\t\s\r\n]/g, '');
	if(!data.startsWith(prefix)) {
		data = prefix + data;
	}
	var decrypted = CryptoJS.AES.decrypt(data, pass);
	res = decrypted.toString(CryptoJS.enc.Utf8);
	console.log(res);
};

///////////////////////////////////////////

var file = process.argv[2];
var pass = process.argv[3];
var d = process.argv[4] && (process.argv[4] == 'd');

if(file && pass) {
	if(d) {
		decrypt(file, pass);
	}
	else { 
		encrypt(file, pass);
	}
}
