

plugins:
	@(export PATH=`pwd`/`echo erts-*/bin`:$$PATH;escript do-plugins.escript)



copy-static:
	@(cp -r deps/nitrogen_core/www/* priv/static//nitrogen/)

