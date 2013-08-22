

bin/coffee : $(patsubst src/%.coffee,lib/%.js,$(wildcard src/*.coffee)) \
						 $(patsubst src/%.litcoffee,lib/%.js,$(wildcard src/*.litcoffee)) \
						 lib/parser.js
	touch bin/coffee

lib/%.js : src/%.coffee
	coffee -cm -o lib $<

lib/%.js : src/%.litcoffee
	coffee -cm -o lib $<

lib/parser.js : lib/grammar.js lib/helpers.js
	node -e "\
		require('underscore').extend(global, require('util')); \
		console.log(require('./lib/grammar').parser.generate()); \
	" > lib/parser.js

.PHONY : clean
clean :
	rm -rf lib/*
