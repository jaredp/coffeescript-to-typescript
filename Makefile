
SRC=$(wildcard src/*.*coffee)
LIB=$(SRC:src/%.coffee=lib/%.js) $(SRC:src/%.litcoffee=lib/%.js) lib/parser.js

bin/coffee : $(LIB)
	touch bin/coffee

lib/%.js : src/%.*coffee
	coffee -cm -o lib $<

lib/parser.js : lib/grammar.js lib/helpers.js
	node -e "console.log(require('./lib/grammar').parser.generate())" > lib/parser.js

browser-debugger/transpiler.js : browser-debugger/browser-debugger.js $(LIB)
	cjsify browser-debugger/browser-debugger.js --ignore-missing 							\
				 -s browser-debugger/transpiler.map -o browser-debugger/transpiler.js

.PHONY : clean
clean :
	rm -rf lib/*
