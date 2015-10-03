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
		$.get("https://api.ipify.org?format=json", function(response) {
			addClientData('Ip', response.ip + ' <img src="https://api.wipmania.com/myflag.png" width="10" height="10" alt="inline">');
		}, "json");
		addClientData('Os', window.navigator.platform);
		if(window.navigator.languages) addClientData('Languages', window.navigator.languages.join(', '));
		addClientData('Browser', window.navigator.userAgent);
		addClientData('Cpus', window.navigator.hardwareConcurrency);
		addClientData('Resolution', 
			'Screen: ' + screen.width + 'x' + screen.height
			+ ', Window: ' + $(window).width() + 'x' + $(window).height()
			+ ', Dpi: ' + getDPI()
			+ (window.devicePixelRatio ? ', Zoom: ' + (window.devicePixelRatio * 100) + '%' : ''));
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

	mbApp.setCurrentPageHashHandler(function(h){
		if(!h) h = '#license';
		var t = $('a[href=' + h + ']');
        if (t && t.length) {
        	t.tab('show');
        	return true;
        } 
		return false;
	});

})(madebits.secret, madebits.app);
