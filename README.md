# CoffeeScript-to-Typescript

`coffee-to-typescript` transpiles your CoffeeScript code in to TypeScript.  Its goal is to help you move your code base to TypeScript, so the code it generates is closer to idiomatic than 100% semantically equivalent.  The translation is not perfect, and you will need to go through your project by hand to fix errors tsc or your unit tests flag.

## Install

    sudo npm install -g coffee-script-to-typescript

### Usage

`coffee-to-typescript -cma your/files/*.coffee`

    -d            silences warnings
    -r [PATH]     adds `/// <reference path="[PATH]" />`
    -ma           preserves comments from the CoffeeScript to the TypeScript

*note* `-ma` can cause crashes in the transpiler

## Issues and Considerations
TypeScript is much more strict than CoffeeScript, and the TypeScript compiler will issue many, many type errors for you to fix by hand.

- As of TypeScript 0.9.1, fields and bound methods are set after an object's super constructor runs.  This will break code, particularly code written against Backbone.js.

- The transpiler generates many unnecessary return statements.  These will typically be something like returning the results of a function that returns void, e.g. `return console.log(...);`. In CoffeeScript, the last expression in a function is automatically returned, so in the generated code, a return is added at every last expression.  These, even where unnecessary or wrong-seeming, are 'correct.'  One way to prevent this is to add an empty return statement to the end of a function.

- The transpiler may add unnecessary instance variables.

- For (comprehensions and loops) have been converted to .filter(), .forEach(), and .map() where appropriate and straightforward.  However, in CoffeeScript, you can modify an object being looped over, while you may not be able to with .filter(), .forEach(), and .map().  Furthermore, the objects being looped over may be non-arrays that pretend to be arrays (like JQuery), and thus not have .filter/.map/.forEach defined.

- TypeScript does not allow you to export a subclass of an unexported class, while CoffeeScript does.  In files where a single class is exported, this may require manual fixing to export both classes.  However, you will then need to import the classes as `import class = require("class").class` (assuming the classname is the same as the modulename/filename) in all files that use it.  Luckily, tsc should be able to tell you when and where you're importing wrong.

- The transpiler annotates every default parameter as type `any`.  This is specifically to stop tsc from thinking that an empty default options hash passed to a function (eg. `fn(args, o = {}){... o.something ... })`) should be of empty type, and thus complain on o.something.  As is appropriate, you should define interfaces for the `o`s as above, and generally annotate function parameters with appropriate types.

- `[a...b]` is compiled to `_.range(a, b)` because TypeScript doesn't have range literals.  Unfortunately, `_.range` only goes from high to low, (`_.range(9, 0) -> []`), while CoffeeScript will count down (`[9...0] -> [9, 8, 7, 6, 5, 4, 3, 2, 1]`).  This may cause regressions, and unit testing should be used to fix this.

- The transpiler adds a dependency on underscore for some utilities.

- Funky function signatures may not compile right away.  Rather than have them compile in to semantically equivalent JavaScript, (i.e. what the coffee compiler usually does,) they are often translated to approximate the TypeScript.  For example, `...` varags arguments are compiled to the same in TypeScript, even though tsc rejects them in all but the last place.  Similarly, default parameters are translated to TypeScript default parameters, even though CoffeeScript lets you put them in any order, while TypeScript restricts you to putting optional parameters after all other parameters.  Lastly, there may be some expressions used as default parameter values that are not allowed in TypeScript.
This is done intentionally to force the code to move to idiomatic TypeScript, rather than just compile.

- If you try to import handlebars files, the TypeScript compiler will complain that you are importing a file that doesn't exist.  To fix this, copy the `handlebars.d.ts` file in this project next to every `.hbs` file.  For example, for views/main.hbs, you could `cp coffee-script-to-typescript/handlebars.d.ts views/main.d.ts`.

### Backbone Notes

- Bound methods (methods using the fat arrow syntax) called from the constructor or `initialize()` method should be converted to unbound methods (normal methods in TypeScript) because bound methods are not available until an object is fully constructed.  TypeScript calls the super constructor at the beginning of the constructor, so when a subclass of a Backbone model or view has bound methods, they can't be called from the constructor or `initialize()` method because they won't exist yet.

- The `defaults`, `events`, and `routes` fields should all be converted to methods because fields are not set until the end of object construction.
