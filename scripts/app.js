////////////////////////////////////////////////////////////////////////////////

$.ajaxPrefilter(function( options, original_Options, jqXHR ) {
    options.async = true;
});

window.onerror = function (msg, url, line, col, error) {
	console.error(msg + ' ' + url + ' ' + line + ' ' + col);
};

if (typeof String.prototype.startsWith != 'function') {
	String.prototype.startsWith = function (str){
		return this.slice(0, str.length) == str;
	};
}

if (typeof String.prototype.endsWith != 'function') {
	String.prototype.endsWith = function (str) {
		return this.slice(-str.length) == str;
	};
}

if (typeof String.prototype.format != 'function') {
	String.prototype.format = function () {
		var _this = this, _arguments = arguments;
		return _this.replace(/\{(\d+)\}/g, function (match, group, pos) {
		if (pos && (_this.charAt(pos - 1) === '{')) return match.substr(1);
			return _arguments[parseInt(group)];
		});
	};
}

if (typeof String.prototype.capitalize != 'function') {
	String.prototype.capitalize = function() {
	    return this.charAt(0).toUpperCase() + this.slice(1);
	}
}

if (typeof String.prototype.capitalizeAll != 'function') {
	String.prototype.capitalizeAll = function() {
	    return this.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
	};
}

if (typeof String.prototype.toCssId != 'function') {
	String.prototype.toCssId = function () {
		if(this.length && (this[0] !== '#')) {
			return ('#' + this).toString();
		}
		return this.toString();
	};
}

////////////////////////////////////////////////////////////////////////////////

var madebits = { 
	  constName: 'madebits'
	, constDomain: 'madebits.github.io'
	, constDomain2: 'madebits.com'
	, onPageLoad: function() {
		if(parent.frames.length > 0) { parent.location.href = self.location.href; }
	}
	, toDeferred: function(conditionObjects, func, timeOut, maxTries, funFail) {
		_self = this;
		return function() {
			_arguments = arguments;
			_self.defer(conditionObjects, function() {
				func(_arguments);
			}, timeOut, maxTries, 0, funFail);
		}
	} 
	, defer: function(conditionObjects, func, timeOut, maxTries, currentTries, funFail) {
		_self = this;
		try	{
			if(!conditionObjects || (conditionObjects.length <= 0)) {
				if(func) func();
				return;
			}
			if(!func) return;
			timeOut = timeOut || 1000;
			maxTries = maxTries || 120;
			currentTries = (currentTries || 0) + 1;
			if((maxTries > 0) && (currentTries > maxTries)) {
				if(funFail) funFail();
				else console.log('defer gave up: ' + conditionObjects);
				return;
			}
			for(var i = 0; i < conditionObjects.length; i++) {
				var obj = conditionObjects[i][0] || window;
				if(typeof obj[conditionObjects[i][1]] === 'undefined') {
					setTimeout(function() { _self.defer(conditionObjects, func, timeOut, maxTries, currentTries, funFail); }, timeOut);
					return;
				}
			}
			func();
		} catch(e) {
			console.error(e);
		}
	}
	//http://stackoverflow.com/questions/7718935/load-scripts-asynchronously
	, loadScript: function (src, callback) {
		var s,
	      r,
	      t;
		r = false;
		s = document.createElement('script');
		s.type = 'text/javascript';
		s.src = src;
		if(callback) {
			s.onload = s.onreadystatechange = function() {
			if ( !r && (!this.readyState || this.readyState == 'complete') ) {
				r = true;
				callback();
			}
		  };
		}
		t = document.getElementsByTagName('script')[0];
		t.parentNode.insertBefore(s, t);
	}
};

madebits.onPageLoad();

////////////////////////////////////////////////////////////////////////////////

madebits.storage = {
	 get: function(key) {
		if(typeof(Storage) === 'undefined') return '';
		var val = null;
		try{ 
			var txt = sessionStorage.getItem(key);
			val = JSON.parse(txt);
		} catch(e) { console.error(e); }
		return val;
	}
	, set : function(key, val) {
		if(typeof(Storage) === 'undefined') return;
		try {
			var txt = JSON.stringify(val);
			sessionStorage.setItem(key, txt);
		} catch(e) { console.error(e); }
	}
};

////////////////////////////////////////////////////////////////////////////////

madebits.stats = (function() {
"use strict";

var	goa = null
, collect = function(url) {
	if(!goa || !url) return;
	try {
		goa('send', 'pageview', url);
	} catch(e) { }
}

, startsWithAny = function(str, prefixes) {
	if(!str || !prefixes) return false;
	return prefixes.some(function(p) {
		return str.startsWith(p); 
	});
}

, endsWithAny = function(str, suffixes) {
	if(!str || !suffixes) return false;
	return suffixes.some(function(p) { 
		return str.endsWith(p); 
	});
}

, collectExternal = function(containerId) {
	$(containerId + ' a[href]').each(function(i, e) {
		var _this =$(this);
		var href = $(this).attr('href').toLowerCase();
		var processed = $(this).data('mbgce') || false;
		if(!processed 
			&& href)
		{
			$(this).data('mbgce', true);
			if(startsWithAny(href, ['http:', 'https:', 'ftp:'])) {
				if(!pageData || !pageData.isSecret) { 
					$(this).click(function(){
						collect($(this).attr('href'));
					});
				}

				if(!startsWithAny(href, ['https://' + madebits.constDomain, 'http://' + madebits.constDomain, 
					'https://' + madebits.constDomain2, 'http://' + madebits.constDomain2])
					&& !endsWithAny(href, ['.zip', '.tar', '.jar', '.deb', '.xpi', '.7z', '.msi', '.exe'])
					&& !(href.indexOf('zipball') > 0)) {
					$(this).attr('target', '_blank');
					$(this).attr('rel', 'noreferrer noopener');
				}
			}
			if(href.startsWith('@@@')) {
				var h = window.location.hash;
				if(h) {
					var idx = h.lastIndexOf('/');
					if(idx >= 0) {
						h = h.substr(0, idx + 1);
						href = h + href.substr(3);
						_this.attr('href', href);
					}
				}
			}
			else if(href.startsWith('#')) {
				if(document.getElementById(href.substr(1))) {
					var h = window.location.hash;
					if(h) {
						var idx = h.indexOf('#', 1);
						if(idx > 0) h = h.substr(0, idx);
						href = h + href;
						_this.attr('href', href);	
					}
				}
			}
		}
	});
}

, collectStats = function() {
	if(navigator.doNotTrack && (navigator.doNotTrack == 1)) {
		goa = null;
		return;
	}

	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','//www.google-analytics.com/analytics.js','__gaTracker');

	__gaTracker('create', 'UA-56302308-1', 'auto');
	__gaTracker('require', 'displayfeatures');
	__gaTracker('require', 'linkid', 'linkid.js');
	__gaTracker('send', 'pageview');

	goa = __gaTracker;

	$(document).ajaxSend(function(event, xhr, settings){
		try {
			if(!pageData || !pageData.isSecret) {
			__gaTracker('send', 'pageview', settings.url);
			}
		} catch(e) { }
	});
}

, pageData = null	
;

return {
	  init: collectStats
	, collectExternal: collectExternal
	, setPageData: function(pd) {
		pageData = pd;
	}
};

})();

////////////////////////////////////////////////////////////////////////////////

madebits.github = (function (mbStorage) {
"use strict";

var user = madebits.constName
, repos = null
, repoAssets = {}

, getPage =function(cb, page) {
	var api = 'https://api.github.com/users/{0}/repos?page={1}'.format(user, page.toString());
	$.get(api).success(function(data) {
		if(data && data.length) {
			cb(data, false);
			repos = repos.concat(data);
			setTimeout(function() { getPage(cb, page + 1); }, 0);
		}
		else {	
			mbStorage.set('repos', repos);
			cb(repos, true);
		}
	})
	.fail(function(jqXHR, textStatus, errorThrown) {
		repos = null;
		console.error(errorThrown);
		cb(null);
	});
}

, processRepos = function (cb, refresh) {
	if(refresh || !repos) {
		repos = [];
		getPage(cb, 1);
	}
	else {
		cb(repos);
	}
}

, processRelease = function(repo, cb, refresh){
	function bytesToSize(bytes) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
		if (bytes <= 0) return '';
		var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
		return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
	};
	if(!repo) cb(null);
	if(refresh || !repoAssets[repo]) {
		var assets = [];
		var latestSrc = 'https://github.com/{0}/{1}/archive/master.zip'.format(user, repo);
		var api = 'https://api.github.com/repos/{0}/{1}/releases'.format(user, repo);
		assets.push({ name: 'latest source (zip)', url: latestSrc, size: '' });
		$.get(api)
		.success(function(data) {
			var version = '';
			var release = null;
			if(data && data.length) {
				release = data[0]; // latest published is the first
			}
			if(release) {
				version = release.tag_name || '';
				if(release.zipball_url) {
					assets.push({ name: 'release source (zip)', url: release.zipball_url, size: '' });
				}
				if(release.assets && (release.assets.length > 0)) {
					$.each(release.assets, function(aidx, aitem) {
						if(aitem.name && aitem.browser_download_url && aitem.size) {
							assets.push({ name: aitem.name, url: aitem.browser_download_url, size: '~' + bytesToSize(aitem.size)});
						}
					});
				}
			}
			repoAssets[repo] = { assets: assets, version: version };
			mbStorage.set('repo.assets', repoAssets);
			cb(assets, version);
		})
		.fail(function(jqXHR, textStatus, errorThrown) {
			console.error(errorThrown);
			cb(null);
		});
	}
	else {
		cb(repoAssets[repo].assets, repoAssets[repo].version);
	}
}

, fillAssetsList = function(container, assets, version) {
	if(!container) return;
	if(assets && assets.length) {
		var text = '<ul class="list-group"></ul>';
		if(version) text = '<strong>' + version + '</strong><br>' + text;
		var list = container.append(text).find('ul');
		$.each(assets, function(idx, item) {
			list.append('<li class="list-group-item"><span class="text-success"><i class="fa fa-arrow-circle-o-down"></i></span> <a href="{0}" title="Download"><strong>{1}</strong></a> {2}</li>'.format(item.url, item.name, item.size));
		});
	}
	else {
		container.append('<p>Failed to find any source or binary data!</p>');
	}		
}

, loadData = function() {
	repos = mbStorage.get('repos');
	repoAssets = mbStorage.get('repo.assets') || {};
}
;

loadData();

return {
	  processRepos: processRepos
	, processRelease: processRelease
	, fillAssetsList: fillAssetsList
};

})(madebits.storage);

////////////////////////////////////////////////////////////////////////////////

madebits.pageTitle = (function(){
"use strict";

var title = document.title || madebits.constName

, getFileName = function(page) {
	var si = page.lastIndexOf('/');
	if(si < 0) si = 0;
	else si++;
	var ei = page.lastIndexOf('.');
	if(ei < 0) ei = page.length - 1;
	if(ei < si) ei = page.length;
	return page.substring(si, ei);
}

, getPageTitlePath = function(page) {
	var si = page.lastIndexOf('/');
	if(si < 0) return '';
	var path = page.substr(0, si + 1);
	path = path.replace(/\\/g, '/');
	path = path.toLowerCase();
	if(path.startsWith('r/')) path = path.substr('r/'.length);
	else if(path.startsWith('s/')) path = path.substr('s/'.length);
	else if(path.startsWith('blog/')) path = '';
	else if((path === 'p') || path.startsWith('p/')) path = ''
	return path;
}

, formatPageTitle = function(pageTitle) {
	if(!pageTitle) return '';
	var res = pageTitle;
	res = res.replace(/^\d{4}-\d{2}-\d{2}/, '');
	res = res.replace(/[-|\\|/|_]/g, ' ');
	res = res.capitalizeAll();
	return res.trim();
}

, setPageTitle = function(pageData) {
	var filePath = '';
	var fileName = '';
	if(pageData.isEntryPage) {
		fileName = 'Homepage - Welcome';
	}
	else if(pageData.isExternal) {
		filePath = 'External:';
		fileName = pageData.page;
	}
	else if(pageData.isBlogIndex) {
		filePath = 'Blog';
		fileName = (pageData.isBlogIndexEntry ? '' : formatPageTitle(getFileName(pageData.page)));
	}
	else {
		filePath = formatPageTitle(getPageTitlePath(pageData.page));
		fileName = pageData.isSecret ? '' : formatPageTitle(getFileName(pageData.page));
	}

	if(pageData.isSecret) {
		filePath = 'Protected Content ' + filePath;
	}

	document.title = title
		+ ' - '
		+ (filePath
		+ ' ' 
		+ fileName).trim();
}
;

return {
	  getFileName: getFileName
	, formatPageTitle: formatPageTitle
	, setPageTitle: setPageTitle
};

})();

////////////////////////////////////////////////////////////////////////////////

madebits.secret = (function(){
"use strict";

var getPass = function () {
	var deferred = $.Deferred();
	madebits.defer([[null, 'bootbox']], function() {
		getPassInner(deferred);
	}, 500, -1);
	return deferred;
}

, getPassInner = function (deferred) {
	var dialog = null;
	var onCancel = function() {
		dialog.modal('hide');
		deferred.reject('failed!');
	};
	var onOk = function() {
		var pass = $('#pass').val().trim();
		dialog.modal('hide');
		setTimeout(function() {
			deferred.resolve(pass); 
		}, 0);
	};
	var options = {
		show: false,
		title: '<span class="text-muted"><i class="fa fa-key"></i></span> Protected content',
		message: '<div class="input-group"><input id="pass" name="pass" class="form-control" type="password" placeholder="Enter password (required)">'
			+ '<div id="ptoggle" class="input-group-addon" title="Toggle password visibility" style="cursor: pointer;"><i class="fa fa-eye-slash"></i></div></div>',
		onEscape: onCancel,
		buttons: {
			main: { label: '<i class="fa fa-check"></i> OK', className: "btn-primary", callback: onOk },
			danger: { label: 'Cancel', className: "btn-default", callback: onCancel }
		}
	};
	dialog = bootbox.dialog(options);
	dialog.on("shown.bs.modal", function() {
 		$('#pass').focus();
		$(dialog).on('keydown', function(event){
			var keyCode = event.keyCode || event.which;
			switch(keyCode) {
				case 13:
					onOk();
					break;
				case 27:
					onCancel();
					break;
			}			
		});
 		$('#ptoggle').click(function(){
 			var typeVal = ($('#pass').attr('type') === 'text') ? 'password' : 'text';
 			$('#pass').attr('type', typeVal);
 			$('#pass').focus();
 		});
	});
	dialog.modal('show');
	return deferred.promise(); 
}

, encrypt = function(data, pass, encrypt) {
	var res = '';
	var prefix = 'U2FsdGVkX1';
	if(!data || !pass) return res;
	try {
		if(encrypt) {
			var beautify = function(d) {
				if(!d) return '';
				var temp = '', lineLength = 64;
				for(var i = 0; i < d.length; i+= lineLength) {
					temp += d.substr(i, lineLength) + '\n';
				}
				return temp;
			};
			var encrypted = CryptoJS.AES.encrypt(data, pass);
			res = encrypted.toString();
			if(res.startsWith(prefix)) {
				res = res.substr(prefix.length);
			}
			res = beautify(res);
		}
		else {
			data = data.replace(/[\t\s\r\n]/g, '');
			if(!data.startsWith(prefix)) {
				data = prefix + data;
			}
			var decrypted = CryptoJS.AES.decrypt(data, pass);
			res = decrypted.toString(CryptoJS.enc.Utf8);
		}
	} catch(e) {
		res = '';
		console.error(e);
	}
	return res;
}
;

return {
	  getPass: getPass
	, encrypt: encrypt
};

})();

////////////////////////////////////////////////////////////////////////////////

madebits.comments = (function(){
"use strict";

var lastPage = null
, disqLoaded = false

, showComments = function(pageData) {
	lastPage = pageData.page;
	if(!pageData.isBlogContent){
			$('#mbg-comments').hide();
			$('#mbg-comments').empty();
			return;
	}
	$('#mbg-comments').html('<nav><ul class="pager"><li id="mbg-showComments" class="next"><a href="#"><i class="fa fa-comment-o"></i> Comments</a></li></ul></nav>');
	$('#mbg-showComments').click(function(event) {
		event.preventDefault();
		$(this).hide();
		$('#mbg-comments').html('<div id="mbg-dsq-loading"><small><span class="text-muted"><i class="fa fa-spinner fa-spin fa-3x fa-fw" style="font-size:17px;"></i> <i>Loading <strong>DISQUS</strong> comments ...</i></span></small></div>');
		loadDisq();
		disqReset();
	});
	$('#mbg-comments').show();
}

, loadDisq = function() {
	if(disqLoaded) return;
	disqLoaded = true;
	madebits.loadScript('//madebits.disqus.com/embed.js'); //ie issue workaround
}

, disqReset = madebits.toDeferred([[null, 'DISQUS']], function(page) {
	if(!page) page = lastPage;
	if(!page) return;
	try {
		var pageTitle = document.title;
		$('#mbg-comments').html('<div id="disqus_thread"></div>');
		DISQUS.reset({
		  reload: true,
		  config: function () {  
			this.page.identifier = 'id:' + page;  
			this.page.url = window.location.href.replace('#', '#!');
			this.page.title = pageTitle;
			this.language = 'en';
		  }
		});
	}
	catch(e) {
		$('#mbg-comments').hide();
		console.error(e);
	}
}, 2000, 10, function() {
	if($('#mbg-dsq-loading').length) {
		$('#mbg-comments').html('<div><small><span class="text-muted"><i class="fa fa-exclamation-circle" aria-hidden="true"></i> <i>Cannot load <em>DISQUS</em> comments.</i></span></small></div>');
	}
})
;

return {
	showComments: showComments
};	

})();


////////////////////////////////////////////////////////////////////////////////

madebits.html = (function(mbStats, mbGitHub, mbTitle, mbComments, marked){
"use strict";

var applyStyle = function(containerId) {
  	containerId = containerId.toCssId();

	$(containerId + ' table').each(function(i, e) {
		$(this).addClass('table table-condensed table-hover');
	});

	$(containerId + ' .mb-ulgroup').each(function(i, e) {
		var ul = $(this).next('ul').first();
		ulToListGroup(ul, true);
	});

	var dataUriSupported = !($('html').hasClass('no-data-uri'));
	$(containerId + ' img').each(function(i, e) {
		var m = $(this);
		handleImage(m, dataUriSupported, i);
	});
	mbStats.collectExternal(containerId);
	$('a').click(function(){
		this.blur();
	});
	applyHl();
	//mermaid.init();
	applyMath();
}

, applyHl = madebits.toDeferred([[null, 'hljs']], function() {
	hljs.configure({
		tabReplace: '  ',
		//languages: []
	});
	$('pre code').each(function(i, block) {
		var hasLanguage = false;
		var classes = $(this).attr('class');
		if(classes) {
			$(this).attr('class', classes);
			classes = classes.split(' ');
			for (var i = 0; i < classes.length; i++) {
				var matches = /^lang\-(.+)/.exec(classes[i]);
				if (matches != null) {
					hasLanguage = true;
					break;
				}
			}
		}
		if($(this).hasClass('lang-nohl')) hasLanguage = false;
		if(!hasLanguage) $(this).addClass('nohighlight');
		hljs.highlightBlock(block);
	});
})

, applyMath = madebits.toDeferred([[null, 'MathJax']], function() {
	MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
})

, dataImgSaveCount = 0

, handleImage = function(m, dataUriSupported, i) {
	var alt = m.attr('alt');

	if(alt && (alt.indexOf('@left@') >= 0)) {
		m.addClass('pull-left padded');
	}

	if(alt && (alt.indexOf('@thumb@') >= 0)) {
		m.addClass('img-thumbnail');
	}
	else {
		if(!alt || (alt.indexOf('@noround@') < 0)) {
			m.addClass('img-rounded');
		}
	}

	if(!alt || (alt && !(alt.endsWith('inline') || (alt.indexOf('@inline@') >= 0) ))) {
		m.addClass('img-responsive center-block');
		// data links
		var src = m.attr('src');
		var processed = m.data('dimg') || false;
		if(src.startsWith('data:') && !processed) {
			if(!alt) alt = '';
			m.data('dimg', true);
			if(!dataUriSupported) {
				m.replaceWith('<div class="text-danger hidden-print"><i class="fa fa-picture-o"></i> Not supported in your browser!</div>');
				return;
			}

			var saveMatch = alt.match(/@save((.)*)@/);
			if(!(m.hasClass('save') || saveMatch)) {
				return;
			}

			var suffix = 'jpg';
			if(src.indexOf('image/png') > 0) suffix = 'png';
			else if(src.indexOf('image/gif') > 0) suffix = 'gif';

			dataImgSaveCount++;
			var idx = '';
			if(saveMatch[1]) idx = saveMatch[1];
			else {
				idx =  dataImgSaveCount;
				var pad = '';
				if(dataImgSaveCount < 10) pad = '000';
				else if(dataImgSaveCount < 100) pad = '00';
				else if(dataImgSaveCount < 1000) pad = '0';
				idx = pad + idx;
			}

			if(!alt) m.attr('alt', idx);
			var aWrapper = $('<br><div class="hidden-print pull-right"><nav><ul class="pager"><li class="previous"><a download="image' + idx +'.' + suffix + '"><i class="fa fa-arrow-circle-o-down"></i> Save</a></li></ul></nav></div>');
			//var aWrapper = $('<br><div class="hidden-print pull-right"><a class="btn btn-default" download="image' + idx +'.' + suffix + '"><i class="fa fa-arrow-circle-o-down"></i> Save</a></div>');
			var a = aWrapper.find('a').first();
			if ((typeof a[0].download !== 'undefined') && (typeof URL !== 'undefined') && !!URL.createObjectURL) { // browser check
				//a.attr('href', m.attr('src'));
				a.on('click', function(e) {
					if(!a.attr('href')) {
						var arr = m.attr('src').split(','), mime = arr[0].match(/:(.*?);/)[1];
						var byteString = atob(arr[1]);

						var ab = new ArrayBuffer(byteString.length);
	  					var ia = new Uint8Array(ab);
	  					for (var i = 0; i < byteString.length; i++) {
	      					ia[i] = byteString.charCodeAt(i);
	  					}

	    				var blob = new Blob([ia], { type: mime }); 
						a.attr('href', URL.createObjectURL(blob));
					}
				});

				var parentTag = m.parent().get(0).tagName;
				if(parentTag.toLowerCase() === 'a') {
					m.parent().after(aWrapper);
				}
				else m.after(aWrapper);
			}			
		}
	}
}

, addToc = function(containerId, page) {
	if(!containerId || !page) return;
	var container = $(containerId.toCssId());
	var toc = container.find('#toc');
	if(toc.length){
		toc.empty();
		toc.addClass('hidden-print');
		var list = toc.append('<div class="panel panel-default"><div class="panel-heading"><strong><i class="fa fa-bookmark"></i> Contents</strong></div><div class="panel-body"><ul></ul></div></div>').find('ul');
		$(':header').each(function(i, e) {
			var id = $(this).attr('id');
			var tagLevel = parseInt($(this).prop("tagName").substr(1));
			if(id) {
				var text = $(this).text();
				if(tagLevel === 1) {
					text = '<strong>' + text + '</strong>'
				}
				list.append('<li><span class="text-muted"><strong style="margin-left:{0}px;">{1}</strong></span> <a href="#{2}#{3}">{4}</a></li>'.format((tagLevel*15),Array(tagLevel).join('&rsaquo;'), page, id, text));
			}
		});
	}
	var bg = container.find('#mbg-background');
	var bgUrl = null;
	if(bg.length) {
		bgUrl = bg.data('url');
	}
	$('body').css('background', 'url(' + bgUrl + ') no-repeat center center fixed').css('background-size', 'cover');
}

, markup = function(data) {
	try {
		data = marked(data);
	} catch(e) {
		console.error(e);
		return null;
	}
	return data;
}

, preProcessPage = function(pageData) {
	if(!pageData.isContentContainer) return;
	mbTitle.setPageTitle(pageData);
	var show = !pageData.isSecret;
	if(show) {
			setInterval(function () {
				$('.adsbygoogle').each(function(i, e) {
					// 	var adsbygoogle = window.adsbygoogle || [];
					// 	adsbygoogle.push({});
					if($(this).children().length <= 0) {
						$(this).css('display', 'none');
						if(pageData.isBlogContent) {
							$('#mbg-comments').hide();
						}
					}
					else { 
						$(this).css('display', 'inline-block');
						if(pageData.isBlogContent) {
							$('#mbg-comments').show();
						}
					}
				});
			}, 2000); // give some time to ads blockers
	}
	$('.mbg-ad').each(function(){
		if(show) {
			$(this).show();
		}
		else {
			$(this).hide();	
		}
		
	});
	if(show) {
		$('#mbg-nav').show();
		//$('#mbg-side').show();
		//$('#contentholder').removeClass('col-md-12');
		//$('#contentholder').addClass('col-md-10');
		$('#mbg-footer').show();
	}
	else
	{
		$('#mbg-nav').hide();
		//$('#mbg-side').hide();
		//$('#contentholder').removeClass('col-md-10');
		//$('#contentholder').addClass('col-md-12');
		$('#mbg-comments').hide();
		$('#mbg-comments').empty();
		$('#mbg-footer').hide();
	}
	if(pageData.isSecret) {
		pageData.container.html('<br><div><span class="label label-default"><i class="fa fa-cloud-download"></i> Loading data, please wait ... <span id="progress"></span></span></div>');
	}
	navBarActivate(pageData);
}

, navBarActivate = function(pageData) {
	$('.nmenu li').removeClass('active');
	if(pageData.navIsRepo) {
		$('#nrep').addClass('active');
	} else if (pageData.navIsBlog) {
		$('#nblog').addClass('active');
	} else if (pageData.navIsAbout) {
		$('#nabout').addClass('active');
	}
}

, postProcessPage = function(pageData) {
	if(!pageData.isContentContainer) {
		if(pageData.isSideBarContainer) {
			toListGroup(pageData.container);
			var ul = pageData.container.find('ul');
			pageData.container.replaceWith(ul);
		}
		applyStyle(pageData.containerId);
		return;
	}

	if(pageData.isRepoPage) {
		var fileName = mbTitle.getFileName(pageData.page);
		processRepoPage(fileName, pageData.container);
	}

	if(pageData.isExternal && !pageData.isSecret) {
		pageData.container.prepend('<div class="hidden-print"><span class="label label-warning"><i class="fa fa-exclamation-triangle"></i> External content: ' + pageData.page + '</span></div>');
	}

	addToc(pageData.containerId, pageData.page);
	if(pageData.isBlogContent) processBlogNav(pageData.page);

	if(pageData.isBlogIndex) {
		if(pageData.isBlogIndexEntry) {
			$('h1').first().prepend('<i class="fa fa-comments"></i> ');
			$('.bloglinks a').wrapInner('<strong></strong>').prepend('<span class="text-muted"><i class="fa fa-chevron-right"></i></span> ').wrap('<li class="list-group-item"></li>');
			$('.bloglinks').wrapAll('<ul class="list-group"></ui>');
		}
		else {
			showBlogActivity(pageData);
			toListGroup(pageData.container);
		}
	}

	applyStyle(pageData.containerId);
	mbComments.showComments(pageData);
	pageData.scroll();
}

, toListGroup =function(container) {
	var ul = container.find('ul');
	ulToListGroup(ul);
}

, ulToListGroup =function(ul, addMarker) {
	if(!ul) return;
	ul.each(function(i, e) { 
		$(this).addClass('list-group');
		var li = $(this).find('li');
		li.each(function(i, e) { 
			$(this).addClass('list-group-item');
			if(addMarker) {
				$(this).prepend('<span class="text-muted"><i class="fa fa-chevron-right"></i></span> ');
			}
		});
	});
	
}

, showBlogActivity = function(pageData) {
	var data = [];
	$('#content li').clone().children().remove().end().each(function(i, e) {
		var d = $(this).text().trim();
		if(d.match(/^\d{4}-\d{2}-\d{2}/)) {
			data.push([new Date(d), 1]);
		}
	});
	if(data.length) {
		var range = [];
		var year = data[0][0].getFullYear();
		range.push([new Date(year, 0, 0), 0]);
		range.push([new Date(year, 11, 30), 0]);
		$.getScript('scripts/flotr2.min.js');	
		pageData.container.find('h1').after('<div id="fgraph" style="width: 100%; height: 50px;"></div>');
		var options = {
			//title: 'Activity'
			 xaxis : {
				mode : 'time',
			}
			, yaxis: {
				ticks: [[1, '']]
				, min: 0.5
				, max: 1.5	
			}
			, points: {show: true}
			, grid: { horizontalLines: false }
	    };	

	    var fn = function() {
	    	try{
				var g = pageData.container.find('#fgraph').first();
				if(!g.length) return;
				if(!g.is(":visible")) {
					setTimeout(fn, 200);
					return;
				}
				madebits.defer([[null, 'Flotr']], function() {
					Flotr.draw(g[0], [data, range], options);
					$('.flotr-canvas').css('width', '100%');
					$('.flotr-overlay').css('width', '100%')
					$('.flotr-canvas').css('height', 'auto');
					$('.flotr-overlay').css('height', 'auto');			
				});	   
			} catch(e) {
				console.error(e);
			}	
	    }
	    setTimeout(fn, 0);
	}
}

, processBlogNav = function(page) {
	var footer = $('.nfooter').first();
	if(footer.length) {
		footer.wrapInner('<nav><ul class="pager"></ul></nav>');
		var title = mbTitle.getFileName(page);
		var year = title.match(/^\d{4}/)[0];
		var nav = '';
		if(year) {
			nav = '<li><a title="{0} Archives" href="#index/{1}.md"><span class="text-muted"><i class="fa fa-th-list"></i></span></a></li>'.format(year, year);
		}
		footer.addClass('hidden-print');
		var fprev = $('#fprev');
		var fnext = $('#fnext');
		if(fprev.length) {
			fprev.prepend('<i class="fa fa-chevron-left"></i> ');
			fprev.wrap('<li class="previous"></li>');	
			fprev.attr('title', 'Previous');
			var fhref = fprev.attr('href');
			fprev.hide();
			nav = '<li><a href="{0}" title="{1}"><i class="fa fa-chevron-left"></i></a></li>'.format(fhref, fprev.text()) + nav;
		}
		if(fnext.length) {
			fnext.append(' <i class="fa fa-chevron-right"></i>');
			fnext.wrap('<li class="next"></li>');
			fnext.attr('title', 'Next');
			var fhref = fnext.attr('href');
			fnext.hide();
			nav += '<li><a href="{0}"" title="{1}"><i class="fa fa-chevron-right"></i></a></li>'.format(fhref, fnext.text())
		}
		var h1 = $('h1:first');
		if(h1.length) {
			h1.before('<div class="pull-right hidden-print mbg-nheader" role="group">{0}</div>'.format('<nav><ul class="pagination">' + nav + '</ul></nav>'));
		}
		var p1 = h1.next('p');
		//console.log(p1.text());
		if(p1.length && p1.text().trim().match(/^\d{4}-\d{2}-\d{2}/)) {
			try{
				var monthNames = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
  					"JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
					];
 				var d = new Date(p1.text().trim());
 				var text = d.getDate() + ' ' + monthNames[d.getMonth()] + ' ' + d.getFullYear();
 				p1.text(text);
			}catch(e){}
			
			p1.addClass('text-muted');
			p1.wrapInner('<small></small>');
			p1.prepend('<i class="fa fa-calendar"></i> ');
		}
	}	
}

, processRepoPage = function(repo, container) {
	mbGitHub.processRelease(repo, function(assets, version) {
		var relsWrapper = $('<div id="pageReleases" class="panel panel-default hidden-print"><div class="panel-heading"><h3 class="panel-title"><span class="text-info"><i class="fa fa-cloud-download"></i></span> Download Available Sources / Binaries:</h3></div><div class="panel-body"></div><div class="panel-footer"></div></div>');
		var rels = relsWrapper.find('.panel-body').first();
		var relsFooter = relsWrapper.find('.panel-footer').first();
		if(assets && assets.length) {
			mbGitHub.fillAssetsList(rels, assets, version);
		}
		else {
			rels.append('<p>Ops! No releases found at this time. Refresh the page to retry!</p>');
		}
		relsFooter.append('<small><strong class="text-muted">GitHub:</strong> <a title="Open GitHub repository page" href="https://github.com/{0}/{1}">{2}</small>'.format(
			madebits.constName, repo, mbTitle.formatPageTitle(repo)));
		container.append('<br>');
		container.append(relsWrapper);
		//container.append('<div class="hidden-print"><nav><ul class="pager"><li class="previous"><a href="#s/repositories.html"><i class="fa fa-chevron-left"></i> Repositories</a></li></ul></nav></div>');
		applyStyle('#pageReleases');
	});
}

, scrollToId = function(id) {
	if(!id) { 
		window.scrollTo(0, 0);
		return;
	}
	id = id.toCssId();
	var eid = $(id);
	if(!eid.length) {
		window.scrollTo(0, 0);
		return;
	}
	setTimeout(function() {
		eid[0].scrollIntoView(true);
		var top  = window.pageYOffset || document.documentElement.scrollTop;
		var paddingTop = parseInt($('body').css('padding-top'));
		if(paddingTop > 0) window.scrollTo(0, top - paddingTop);
	}, 100);
}
;

return {
	  applyStyle: applyStyle
	, addToc: addToc
	, markup: markup
	, preProcessPage: preProcessPage
	, postProcessPage: postProcessPage
	, scrollToId: scrollToId
};

})(madebits.stats, madebits.github, madebits.pageTitle, madebits.comments, marked);

////////////////////////////////////////////////////////////////////////////////

madebits.app = (function(mbGitHub
	, mbStats
	, mbSecret
	, mbHtml
	, mbSearch) {
"use strict";

var lastPage = null
, lastPageHashHandler = null
, contentContainerId = '#content'
, entryPage = 's/index.html'
, appSessionKeys = {}

, preProcessPage = function(page) {
	if(!page) return false;
	if(page.startsWith('#')) return false;
	if(page.startsWith('!')) page = page.substr(1);
	if(page.startsWith('./')) page = page.substr(2);
	// special links
	var specialMap = {
		  'blog': homeUrl.toCssId()
		, 'index': entryPage.toCssId()
		, 'index.html': entryPage.toCssId()
		, 's/index.md': entryPage.toCssId()
	};
	var id = 'NSisyRKpHzwUJUw99Z/x5fdJGG5buElvU78zyumzlWdB/IekAktZIcmWO5lq';
	specialMap[mbSecret.encrypt('U2FsdGVkX1/DRBDT9LWsQTGsp6+ua1T4XCtUGJZM+c4=', id, false)] = mbSecret.encrypt('U2FsdGVkX1/mWuXkd6vkxNlPqWiirX11Sf5u6c9fXBUAIBUlmbbPMaBjYwPyRWXIcgNrsp4MpToS0we02UsxLIzmth7YunWAlunYa+chb/c=', id, false).toCssId();
	var specialLink = specialMap[page.toLowerCase()];
	if(specialLink) {
		window.location.replace(specialLink);
		return false;
	}
	return page;
}

, handleScrollId = function(scrollId) {
	try{
		if(!lastPageHashHandler || !lastPageHashHandler(scrollId, lastPage.toCssId(), lastPage.toCssId() + scrollId.toCssId())) {
			mbHtml.scrollToId(scrollId);
		} else mbHtml.scrollToId(null);
	} catch(e) {
		console.error(e);
		mbHtml.scrollToId(scrollId);
	}
}

, getPageData = function(page, containerId) {
	var pageData = { 
		  page: preProcessPage(page) 
		, containerId: containerId || contentContainerId
		, scrollId: ''
		, scroll: function() {
			handleScrollId(this.scrollId);
		}
	};
	if(!pageData.page) return null;
	pageData.container = $(pageData.containerId);
	if(!pageData.container.length) return null;
	pageData.isContentContainer = (pageData.containerId.toCssId() === contentContainerId);
	pageData.isSideBarContainer = pageData.container.hasClass('mbg-sidebar');

	if(pageData.isContentContainer) {
		var ai = page.indexOf('#');
		if(ai > 0) {
			pageData.scrollId = pageData.page.substr(ai);
			if(pageData.scrollId.startsWith('#!')) pageData.scrollId = '#' + pageData.scrollId.substr(2);
			pageData.page = pageData.page.substr(0, ai);
		}
		pageData.isSecret = pageData.page.endsWith('.dx');
		if(pageData.page.startsWith(':dx:')) {
			pageData.isSecret = true;
			pageData.page = pageData.page.substr(4);
		}
		pageData.isSearch = pageData.page.startsWith('s/search.html');
		pageData.isEntryPage = (pageData.page === entryPage);
		pageData.isRepoPage = (pageData.page.startsWith('r/')
			&& pageData.page.endsWith('.md') 
			&& (pageData.page.indexOf('/', 2) < 0));
		pageData.isBlogIndexEntry = (pageData.page === 'index/contents.md');
		pageData.isBlogIndex = pageData.page.startsWith('index/');
		pageData.isBlogContent = pageData.page.startsWith('blog/');
		if(pageData.page.startsWith('r/') || (pageData.page === 's/repositories.html')) {
			pageData.navIsRepo = true;
		} else if (pageData.page.startsWith('blog/') || pageData.page.startsWith('index/')) {
			pageData.navIsBlog = true;
		} else if (pageData.page === 's/about.html') {
			pageData.navIsAbout = true;
		}		
	}
	pageData.isMarkdown = pageData.page.endsWith('.md') || pageData.page.endsWith('.mx');
	pageData.isHtml = pageData.page.endsWith('.html')
	if(pageData.page.startsWith(':md:')) {
		pageData.isMarkdown = true;
		pageData.page = pageData.page.substr(4);
	}
	pageData.isExternal = (pageData.page.toLowerCase().startsWith('http://') || pageData.page.toLowerCase().startsWith('https://'));

	pageData.pageDir = '';
	var dirIdx = pageData.page.lastIndexOf('/');
	if(dirIdx >= 0) pageData.pageDir = pageData.page.substr(0, dirIdx);
	if(pageData.pageDir.startsWith('https://dl.dropboxusercontent.com/s/')) {
		pageData.pageDir = 'https://dl.dropboxusercontent.com/s/';
	}

	if(page.endsWith('/') || page.endsWith('\\')) { 
		window.location.replace(window.location.href + 'index.md');
		return null;
	}
	if(!(pageData.isSecret || pageData.isMarkdown || pageData.isHtml) && !pageData.scrollId) {
		window.location.replace(window.location.href + '/index.md');
		return null;
	}

	if(pageData.isContentContainer) {
		mbStats.setPageData(pageData);
	}	

	return pageData;
}

, onPageError = function(pageData) {
	$('#mbg-comments').hide();
	pageData.container.html('<br><div class="well"><h1 style="text-transform: none;"><span class="text-danger"><i class="fa fa-exclamation-circle"></i></span> Page Load Error</h1><p class="text-danger">' 
		+ (pageData.errorStatus ? pageData.errorStatus : ''	) + ' '
		+ (pageData.errorStatusText ? pageData.errorStatusText : 'Nothing found')
		+ '</p><br><a href="#' + entryPage + '" class="btn btn-primary">Continue to home page <i class="fa fa-chevron-right"></i></a></div>'); //<p>Not found!</p>
	mbHtml.scrollToId();
}

, setPageData = function(pageData, data) {
	//pageData.container.html(data);
	if((data === null) || (typeof data === 'undefined')) {
		pageData.errorStatus = '431';
		pageData.errorStatusText = 'Something went wrong!';
		onPageError(pageData);
		return;
	}

	if(!pageData.isSearch) $('#mbg-search-btn').show();

	//pageData.container.fadeOut(function() {
		pageData.container.html(data);
		mbHtml.postProcessPage(pageData);
		//pageData.container.fadeIn("fast");
	//});
}

, setPageDataEnc = function(pageData, data) {
	if(!pageData.pageDir) pageData.pageDir = '';
	var keys = appSessionKeys[pageData.pageDir] || [];
	var addKey = function(key) {
		if(keys.indexOf(key) >= 0) return;
		keys.push(key);
		if(pageData.pageDir) {
			appSessionKeys[pageData.pageDir] = keys;
		}
	}

	if(pageData.scrollId && pageData.scrollId.startsWith('#key-')) {
		var pass = pageData.scrollId.substr('#key-'.length);
		pageData.scrollId = null;
		addKey(pass);
	}

	for(var keyIdx = 0; keyIdx < keys.length; keyIdx++) {
		var pdata = mbSecret.encrypt(data, keys[keyIdx], false);
		if(pdata) {
			pdata = mbHtml.markup(pdata);
			setPageData(pageData, pdata);
			return;
		}
	}

	mbSecret.getPass().then(function(pass) {
		var pdata = mbSecret.encrypt(data, pass, false);
		if(!pdata) {
			// some rec
			setTimeout(function(){
				setPageDataEnc(pageData, data);
			}, 0);
			return;
		} 
		addKey(pass);
		pdata = mbHtml.markup(pdata);
		setPageData(pageData, pdata);
	}, function() {
		data = '<br><i class="fa fa-refresh"></i> Refresh page to retry or [leave](#index).';
		data = mbHtml.markup(data);
		setPageData(pageData, data);
	});	
}

, getLoadPageOptions = function(pageData) {
	var options = {
		  dataType: 'text'
		, url: pageData.page
		, cache: false
	};
	if(pageData.isSecret && window.XMLHttpRequest) {
		options.xhr = function () {
			var xhr = new window.XMLHttpRequest();
			if(xhr.addEventListener) {
				xhr.addEventListener("progress", function (evt) {
					if (evt.lengthComputable && evt.total) {
						var percentComplete = evt.loaded / evt.total;
						var p = $('#progress');
						if(p.length) p.html(Math.round(percentComplete * 100) + "%");
					}
				}, false);
			}
			return xhr;
		}
	}
	return options;
}

, loadPage = function(page, containerId) {
	var pageData = getPageData(page, containerId);
	if(!pageData) return;

	if(pageData.isContentContainer) {
		if(pageData.page === lastPage) {
			pageData.scroll();
			return;
		}
		lastPage = pageData.page;
		lastPageHashHandler = null;
	}
	mbHtml.preProcessPage(pageData);

	var query = getLoadPageOptions(pageData);
	var onDone = function (data) {
		if(pageData.isSecret) {
			setPageDataEnc(pageData, data);
			return;
		}
		if(pageData.isMarkdown) {
			data = mbHtml.markup(data);
		}
		setPageData(pageData, data);
	};

	$.ajax(query).done(onDone).fail(function() {
		//retry
		setTimeout(function () {
			$.ajax(query).done(onDone).fail(function(jqXHR, textStatus, errorThrown) {
				if(jqXHR) {
					pageData.errorStatus = jqXHR.status;
					pageData.errorStatusText = jqXHR.statusText;
				}
				onPageError(pageData);
			});
		}, 2000);
	});
}

, goto = function(page) {
	if(!page) page = entryPage;
	window.location.hash = page.toCssId();
}

, goHome = function() {
	goto(entryPage);
	return false;
}

, loadSideBars = function() {
	// $('.mbg-sidebar').each(function (i, e) {
	// 	var id = $(this).attr('id');
	// 	var url = id.replace('-', '/');
	// 	loadPage(url + '.md', '#' + id);
	// });
}

, app = Sammy(function () {
	this.notFound = function () {
		//onPageError();
	};

	this.get(/\#(.*)/, function() {
		//var sp = this.params.splat[0];
		var sp = this.path;
		if(sp.startsWith('/#')) sp = sp.substr(2);
		else { 
			window.location.pathname = '';
			return;
		}
		if(sp.startsWith('!')) sp = sp.substr(1);
		loadPage(sp);
	});
})

// https://weston.ruter.net/2009/05/07/detecting-support-for-data-uris/
, dataUriTest = function() {
	var data = new Image();
	data.onload = data.onerror = function(){
		if(this.width != 1 || this.height != 1){
			$('html').addClass('no-data-uri');
		}
		else $('html').addClass('yes-data-uri');;
	}
	data.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
}

, showCookieBar = madebits.toDeferred([[$, 'cookieBar']], function() {
	$.cookieBar({ 
		  message: 'By using this site you agree to the use of its <strong>cookies</strong> for usage tracking.'
		, fixed: true
		, bottom: true
		, zindex: '999' });
})

, triggerSearch = function() {
	var searchText = $('#mbg-search').val();
	//if(!searchText) return;
	$('#mbg-search').val('');
	$('#mbg-search').blur();
	window.location.replace('#s/search.html#' + searchText);
}

, hideMenu = function() {
	//http://stackoverflow.com/questions/18896591/make-bootstrap-3-0-navbar-content-always-collapsed
	if ($(".navbar-collapse").is(":visible") && $(".navbar-toggle").is(":visible") ) {
        $('.navbar-collapse').collapse('toggle');
    }
}
;

$(function() {
	$('.nav a').on('click', function(){
    	hideMenu();
	});

	$(contentContainerId).empty();
	if ((window.location.host.startsWith(madebits.constDomain) || window.location.host.startsWith(madebits.constDomain2)) 
		&& (window.location.protocol != 'https:')) {
		window.location.protocol = 'https';
	}
	app.run();
	if (!window.location.hash) { 
		goHome();
	}
	var d = new Date();
	$('#mbg-year').html(d.getFullYear());
	loadSideBars();
	mbStats.init();
	dataUriTest();
	//showCookieBar();

	// $('#mbg-psearch').click(function(event) {
	// 	event.preventDefault();
	// 	triggerSearch();
	// 	hideMenu();
	// 	return false;
	// });
	$('#mbg-search').on('keydown', function(event){
		var keyCode = event.keyCode || event.which;
		switch(keyCode) {
			case 13:
				triggerSearch();
				hideMenu();
				break;
		}			
	});

	$(window).scroll(function(){
        if($(window).scrollTop() != 0) {
        	$('#mbg-fixed-top').show();
        }
        else $('#mbg-fixed-top').hide(); 
    });
	$('.mbg-top').click(function(event) { 
		event.preventDefault();
		window.scrollTo(0, 0);
	});

});

return {
	  pageContainerId: function() { return contentContainerId; }
	, currentPage: function() { return lastPage; }
	, setCurrentPageHashHandler: function(cb) { lastPageHashHandler = cb; }
	, navigateToHash: function(hash) { 
		if(hash === undefined) return;
		var url = hash || lastPage.toCssId();
		if(hash && !hash.startsWith(lastPage.toCssId() + '#')) {
			url = '{0}{1}'.format(lastPage.toCssId(), hash.toCssId());
		}
		window.location.replace(url); 
	}
};

})(madebits.github
, madebits.stats
, madebits.secret
, madebits.html);

////////////////////////////////////////////////////////////////////////////////