(function(mbStats, mbGitHub, mbTitle){
	var showRepos = function() {
		var repos = $('#repos');
		mbGitHub.processRepos(function(data, all) {
			listRepos(data, all);
		});
	};

	var listRepos = function(data, all) {
		if(all) return;
		var rl = $('#rloading');
		if(rl.length) rl.remove();
		if(!data) {
			$('#repos').append('<li class="list-group-item">Error getting <a href="https://github.com/madebits">GitHub</a> data! GitHub applies <a href="https://developer.github.com/v3/#rate-limiting">limits</a> per IP on these requests.</li>');
			mbStats.collectExternal('#repolist');
			return;
		}
		var html = '';
		$.each(data, function(idx, item) {
			if(item.fork) return;
			var link = '#r/{0}'.format(item.name);
			var linkText = mbTitle.formatPageTitle(item.name);
			var year = '*';
			var desc = item.description.trim(); 
			var idx = desc.indexOf(' ');
			if(idx == 4) {
				year = desc.substr(0, idx);
				desc = desc.substr(idx).trim();
			}
			html += '<li class="list-group-item"><span class="text-muted"><i class="fa fa-chevron-right"></i></span> <a href="{0}.md"><strong>{1}</strong></a> <div class="mbg-repo-desc"><span><em>{2}</em></span> <span class="text-muted pull-right">({3})</span></div></li>\n'.format(
				link, linkText, desc, year);
		});
		$('#repos').append(html);
		mbStats.collectExternal('#repolist');
	};

	$(function(){ showRepos(); });
})(madebits.stats, madebits.github, madebits.pageTitle);
