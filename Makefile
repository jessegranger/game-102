
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

