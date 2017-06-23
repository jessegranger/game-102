
GPP=gpp
GPP_OPTS=-U '' '' '(' ',' ')' '(' ')' '\#' '' \
	-M '\#' '\n' ' ' ' ' '\n' '(' ')' \
	+c '\# ' '\n' \
	+c '\#\#\#' '\#\#\#' \
	+s '"' '"' "\\" \
	+s "'" "'" "\\" -n
GPP_FILTER=sed -E 's/^	*\# .*$$//g' | $(GPP) $(GPP_OPTS)

all: lib/index.js

lib/index.js: src/index.coffee src/brain.coffee src/unit-types.coffee
	@mkdir -p ./lib
	@cat src/index.coffee | $(GPP_FILTER) | coffee -sc > $@

publish: .remote/lib/index.js .remote/index.html .remote/js/synaptic.js .remote/js/bling.js

.remote/%: %
	mkdir -p `dirname $@`
	echo scp -Cr $< jldailey@blingjs.com:Projects/games/102/$<
	touch $@
