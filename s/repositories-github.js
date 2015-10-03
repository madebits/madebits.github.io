(function(mbStats, mbGitHub, mbTitle){
	"use strict";
	$('#rconfigtoggle').click(function(event) {
		$('#rconfig').toggle();
		event.preventDefault();
		$(this).blur();
	});

	var showRepos = function() {
		var repos = $('#repos');
		mbGitHub.processRepos(function(data, all) {
			listRepos(data, all);
		});
	};

	var listRepos = function(data, all) {
		if(all) return;
		if(!data) {
			$('#repos').append('<tr><td>Error getting <a href="https://github.com/madebits">GitHub</a> data! GitHub applies <a href="https://developer.github.com/v3/#rate-limiting">limits</a> per IP on these requests.</td><td>&nbsp;</td></tr>');
			mbStats.collectExternal('#repolist');
			return;
		}
		var html = '';
		$.each(data, function(idx, item) {
			html += '<tr><td><span>git clone <a href="{0}" title="Open GitHub repository page">{1}</a></span></td><td><span class="text-muted">#</span> <a href="#r/{2}.md" title="{3}\n{4}">{5}</a></td></tr>'.format(
				item.html_url,
				item.clone_url, 
				item.name,
				item.name,
				item.description,
				mbTitle.formatPageTitle(item.name));
		});
		$('#repos').append(html);
		mbStats.collectExternal('#repolist');
	};

	$(function(){ showRepos(); });
})(madebits.stats, madebits.github, madebits.pageTitle);