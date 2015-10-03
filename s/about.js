(function(mbSecret, mbApp){
"use strict";
	$('.spam').click(function(event) {
		var email = "contact@madebits.git.io"; //:)
		window.prompt("Select and copy shown text",
		mbSecret.encrypt("U2FsdGVkX19E9ehSFqnYIrah5svgMjjCxzcmpXWGKuO2KoTgCksovuhEEdiWzi+U", 
			email, false));
		event.preventDefault();
	});

	(function(){
		var getDPI = function(){
		  var div = document.createElement("div");
		  div.style.width="1in";
		  var body = document.getElementsByTagName("body")[0];
		  body.appendChild(div);
		  var ppi = document.defaultView.getComputedStyle(div, null).getPropertyValue('width');
		  body.removeChild(div);
		  return parseFloat(ppi);
		};
		var clientTable = $('#client');
		var addClientData = function(key, val) {
			if(!val) return;
			var t = val.toString().trim();
			if(!t) return;
			clientTable.append('<tr><td><strong class="text-muted">{0}</strong></td><td>{1}</td></tr>'.format(key, t));
		};
		// $.get("//api.ipify.org?format=json", function(response) {
		// 	addClientData('Ip', response.ip); // + ' <img src="https://api.wipmania.com/myflag.png" width="10" height="10">');
		// }, "json");
		$.get('//freegeoip.net/xml/', null, function(response) {
			try {
				var r = $(response);
				var m = '';
				var ip = r.find('IP').text();
				if(ip) m += 'IP: ' + ip;
				var c = r.find('CountryName').text();
				if(c) m+= ' ' + c;
				var la = r.find('Latitude').text();
				var lo = r.find('Longitude').text();
				if(la && lo) {
					m += ' <i class="fa fa-map-marker"></i> <a href="https://maps.google.com/maps?t=m&q=loc:' + la + '+' + lo + '" target="_blank">' + la + '&deg; ' + lo + '&deg;</a>';
				}
  				if(m) addClientData('Location', m);
  			} catch(e){}
		}, 'xml');

		addClientData('Os', window.navigator.platform);
		if(window.navigator.languages) addClientData('Languages', window.navigator.languages.join(', '));
		addClientData('Browser', window.navigator.userAgent);
		if(window.navigator.vendor) addClientData('Vendor', window.navigator.vendor);
		addClientData('Cookies', window.navigator.cookieEnabled ? 'Supported' : 'Not supported');
		addClientData('Cpus', window.navigator.hardwareConcurrency);
		addClientData('Resolution', 
			'Screen: ' + screen.width + 'x' + screen.height
			+ ', Window: ' + $(window).width() + 'x' + $(window).height()
			+ ', Dpi: ' + getDPI()
			+ (window.devicePixelRatio ? ', Zoom: ' + (window.devicePixelRatio * 100) + '%' : '')
			+ ', Color depth: ' + screen.colorDepth
			);
		try {
			var p = [];
			var mt = navigator.mimeTypes;
			for(var i = 0; i < mt.length; i++) {
				var pname = (mt[i].type || mt[i].description).replace(/^application\//, '');
				if(pname) p.push(pname);	
			} 
			if(p.length) {
				addClientData('Media', p.join(', '));
			}
		} catch(e){}
		try {
			var p = [];
			var mt = navigator.plugins;
			for(var i = 0; i < mt.length; i++) {
				var pname = mt[i].name;
				if(pname) p.push(pname);	
			} 
			if(p.length) {
				addClientData('Plugins', p.join(', '));
			}
		} catch(e){}

		addClientData('Java', window.navigator.javaEnabled() ? 'Supported' : 'Not supported');

		try {
			navigator.getBattery().then(function(b) {
				try {
					if(b && !(
						(b.charging === true) 
						&& (b.chargingTime === 0)
						&& (b.level === 1))) {
						addClientData('Battery', Math.floor(b.level * 100) + '%');
					} 
				} catch(e){}
			});
		} catch(e){}
		if(navigator.doNotTrack && (navigator.doNotTrack == 1)) {
			addClientData('DoNotTrack', 'Active');
		}

		addClientData('Time', new Date().toString());
	})();

	$(function(){
		$('a[role=tab]').click(function(event){
			event.preventDefault();
			mbApp.navigateToHash($(this).attr('href'));
			return false;
		});
	});

	mbApp.setCurrentPageHashHandler(function(h, p, url){
		if(!h) url = p + '#license';
		var t = $('a[href="' + url + '"]');
        if (t && t.length) {
        	t.tab('show');
        	return true;
        } 
		return false;
	});

})(madebits.secret, madebits.app);
