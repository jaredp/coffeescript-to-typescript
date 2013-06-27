
Whitespacing will not be preserved.  For the most part the spacing should be good, but there will also be many times when you should move the positioning

Funky function signitures may not compile right away.  Rather than have them compile in to semantically equivalent JavaScript, (i.e. what the coffee compiler usually does,) they are often translated to approximate the TypeScript.  For example, ... varags arguments (splats) are compiled to the same in TypeScript, even though tsc rejects them in all but the last place.  Similarly, default parameters are translated to TypeScript default parameters, even though CoffeeScript lets you put them in any order, while TypeScript restricts you to putting optional parameters after all other parameters.  Lastly, there may be some expressions used as default parameter values that are not allowed in TypeScript.

This is done intentionally to force the code to move to idiomatic TypeScript, rather than just compile.

Actually, we may be generating ECMAScript6
