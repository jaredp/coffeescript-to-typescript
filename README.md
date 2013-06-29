
Whitespacing will not be preserved.  For the most part the spacing should be good, but there will also be many times when you should move the positioning

Funky function signitures may not compile right away.  Rather than have them compile in to semantically equivalent JavaScript, (i.e. what the coffee compiler usually does,) they are often translated to approximate the TypeScript.  For example, ... varags arguments (splats) are compiled to the same in TypeScript, even though tsc rejects them in all but the last place.  Similarly, default parameters are translated to TypeScript default parameters, even though CoffeeScript lets you put them in any order, while TypeScript restricts you to putting optional parameters after all other parameters.  Lastly, there may be some expressions used as default parameter values that are not allowed in TypeScript.
This is done intentionally to force the code to move to idiomatic TypeScript, rather than just compile.

Many unnecessary return statements are generated.  These will typically be something like returning the results of a function that returns void, like `return console.log(...);`. In CoffeeScript, the last expression in a function is automatically returned, so in the generated code, a return is added at every last expression.  These, even where uncessessary or wrong-seeming, are 'correct,' and do not make the program wrong.  You should remove the extranious and wrong-looking ones as part of code clean up.

Bound methods are `us.bind(method, this);` in the constructor.  Typescript methods are unbound, and while TypeScript's lambdas (arrow functions) are binding, they are not used for methods.  For now, we are using the mechanism CoffeeScript uses in the javascript it generates, which is manually binding the methods in the constructor.

Actually, we may be generating ECMAScript6
