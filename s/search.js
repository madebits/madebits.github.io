(function(mbApp) {
"use strict";
var cache = { }

, getTags = function(a) {
	var tags = [];
	(a.parent().contents()).filter(function(){ return this.nodeType == 8; }).each(function() {
		var s = this.nodeValue;
		if(s) {
			var parts = s.split(/[,\s]+/g);
			$.each(parts, function(i, v){
				v = v.toLowerCase();
				switch(v) {
					case '':
					case '-':
					case 'tags':
					case 'tags:':
						break;
					default:
						tags.push(v);
						break;
				} 
			});
		}
	});
	if(!tags.length) tags.push('_untagged');
	return tags;
}

, load = function() {
	$.ajax({url: 'noscript.html', cache: true, dataType: 'text' }).done( function(htmlData) {
		var temp = [];
		$(htmlData).find('a').each(function(i, e) {
			var a = $(this);
			var url = a.attr('href');
			if(url.startsWith('index.html#./s/')
				|| url.startsWith('index.html#./index/')
				) return;
			switch(url)
			{
				case 'index.html':
				case 'index.html#index.html':
				case 'index.html#./index.html':
				case 'index.html#./README.md':
				case 'index.html#./sidebarstatic.md':
				case 'index.html#./noscript.html':
				break;
				default:
					if(url.startsWith('index.html#')) url = url.substr('index.html'.length);
					url = url.replace('./', '');
					var text = a.text();
					text = text.replace('./', '');
					text = text.replace('(r/', '(repository/');
					text = text.replace('(r)', '(repository)');
					text = text.replace('(s)', '');
					text = text.replace('(', '');
					text = text.replace('/', ' / ');
					text = text.replace(')', '');
					text = text.replace(/-/g, ' ');
					text = text.trim();
					if(text.startsWith('=>')) text = text.substr('2');
					text = text.trim();
					temp.push({ text: text.toLowerCase(), url: url, orginalText: text, tags: getTags(a) });
					break;
			}
		});
		cache.data = temp;
		cache.tagsIndex = createTagsIndex();
		showTags();
	});
}

, createTagsIndex = function() {
	var t = {};
	for(var i = 0; i < cache.data.length; i++) {
		var ctags = cache.data[i].tags;
		if(ctags && ctags.length) {
			for(var j = 0, l = ctags.length; j < l; ++j){
				var tag = ctags[j];
				if(!t.hasOwnProperty(tag)) {
         			t[tag] = [];
      			}
      			t[tag].push(cache.data[i]);
			}		
		}
	}
	return t;
}

, getMatchesByTag = function(tag) {
	if(!tag || !cache.tagsIndex.hasOwnProperty(tag)) return [];
	return cache.tagsIndex[tag];
}

, getMatches = function(searchText) {
	var res = [];
	if(!searchText) return res;
	var parts = searchText.toLowerCase().split(' ');
	for(var j = 0; j < parts.length; j++) {
		parts[j] = parts[j].trim();
		if(parts[j] === 'c#') parts[j] = 'csharp';
		if(parts[j].startsWith('.')) parts[j] = parts[j].substr(1);
		parts[j] = parts[j].trim();
	}
	for(var i = 0; i < cache.data.length; i++) {
		for(var j = 0; j < parts.length; j++) {
			if(!parts[j]) continue;
			if(cache.data[i].text.indexOf(parts[j]) >= 0) {
				res.push(cache.data[i]);
				break;
			}
		}
	}
	return res;
}

, search = function(searchText) {
	var container = $('#result');
	container.empty();
	var tagSearch = searchText && searchText.startsWith('@');
	var matches = tagSearch ? getMatchesByTag(searchText.substr(1)) : getMatches(searchText);
	matches.sort(function(a, b){
		var s1 = a.text;
		var s2 = b.text;
		return s2.localeCompare(s1); 
	});
	if(!matches || !matches.length) {
		container.append('<li class="list-group-item"><span class="text-muted"><i class="fa fa-ban"></i> Nothing found!</span></li>');
	} else {
		for(var i = 0; i < matches.length; i++) {
			container.append('<li class="list-group-item"><span class="text-muted"><i class="fa fa-chevron-right"></i></span> <a href="{0}">{1}</a></li>'.format(matches[i].url, matches[i].orginalText.capitalizeAll()));
		}
	}
}

, triggerSearch = function() {
	var searchText = $('#search').val();
	mbApp.navigateToHash(searchText);
}

, showTags = function() {
	var tags = [];
	$.each(cache.tagsIndex, function(key, value) {
		if(key != '_untagged' && value && value.length) {
			tags.push(key);	
		}
	});
	tags.sort();
	var container = $('#tags');
	$.each(tags, function (i, t) {
		container.append('<a class="btag" href="#" title="' + t + '"><strong>' 
			+ t 
			+ '</strong></a><sup class="text-muted">'
			+ cache.tagsIndex[t].length.toString() 
			+ '</sup> ');
	});
	$('.btag').on('click', function(event){
		event.preventDefault(); 
		mbApp.navigateToHash('@' + $(this).attr('title'));
	});
}
;

mbApp.setCurrentPageHashHandler(function(h){
	if(h && h.startsWith('#')) h = h.substr(1);
	$('#search').val(h);
	document.title = 'MadeBits - Search: ' + h;
	$('#search').focus();
	madebits.defer([[cache, 'data']], function(){ search(h); });
	return true;
});

$(function() {
	load();
	$('#mbg-search-btn').hide();
	$('#psearch').click(function(event) {
		event.preventDefault();
		triggerSearch();
		return false;
	});
	$('#search').on('keydown', function(event){
		var keyCode = event.keyCode || event.which;
		switch(keyCode) {
			case 13:
				triggerSearch();
				break;
		}			
	});
	$('#search').focus();
});


})(madebits.app);