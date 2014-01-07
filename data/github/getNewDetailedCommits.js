
allCommits = []
url = "https://api.github.com/repos/LivelyKernel/LivelyKernel/commits?page=1&per_page=30"
$.get(url).done( function(results) {
	for (var i = results.length - 1; i >= 0; i--) {
		
		commitUrl = "https://api.github.com/repos/LivelyKernel/LivelyKernel/commits/" + results[i].sha;

		$.get(commitUrl).done( function(detailedCommit) {
			allCommits.push(detailedCommit);
		});
	};
})

