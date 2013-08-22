coffee-script-to-typescript transpiles your coffeescript code in to TypeScript.  Its goal is to help you move your code base to TypeScript, so the code it generates is closer to idiomatic than 100% semantically equivalent.  The translation is not perfect, and you will need to go through your project by hand to fix errors tsc or your unit tests flag.

## Issues/Considerations


Funky function signatures may not compile right away.  Rather than have them compile in to semantically equivalent JavaScript, (i.e. what the coffee compiler usually does,) they are often translated to approximate the TypeScript.  For example, ... varags arguments (splats) are compiled to the same in TypeScript, even though tsc rejects them in all but the last place.  Similarly, default parameters are translated to TypeScript default parameters, even though CoffeeScript lets you put them in any order, while TypeScript restricts you to putting optional parameters after all other parameters.  Lastly, there may be some expressions used as default parameter values that are not allowed in TypeScript.
This is done intentionally to force the code to move to idiomatic TypeScript, rather than just compile.

Many unnecessary return statements are generated.  These will typically be something like returning the results of a function that returns void, like `return console.log(...);`. In CoffeeScript, the last expression in a function is automatically returned, so in the generated code, a return is added at every last expression.  These, even where unnecessary or wrong-seeming, are 'correct,' and do not make the program wrong.  One way to prevent this is to add an empty return statement to the end of a function.

TypeScript requires all members to be declared on a class, and will throw a compile-time error when you try to access a member that is not declared.  Because members are typically not declared in CoffeeScript, as part of the porting process, one of our tools looks at all the missing property errors tsc throws, and adds them to classes of the appropriate name.  However, some classes have the same name, so they will get each other's properties.  Additionally, we don't try to guess the types of the members, so you will have to manually add the appropriate types to them.  While doing so, remove members that do not seem to belong to the class.  tsc will tell you if you've made a mistake.

For (comprehensions and loops) have been converted to .filter(), .forEach(), and .map() where appropriate and straightforward.  However, in CoffeeScript, you can modify an object being looped over, while you may not be able to with .filter(), .forEach(), and .map().

TypeScript requires constructors to make calls to super in a constructor as the first statement, while CoffeeScript does not.

TypeScript does not allow you to export a subclass of an unexported class, while CoffeeScript does.  In files where a single class is exported, this may require manual fixing to export both classes.  However, you will then need to import the classes as import class = require("class").class (assuming the classname is the same as the modulename/filename) in all files that use it.  Luckily, tsc should be able to tell you when and where you're importing wrong.

The transpiler annotates every default parameter as type `any`.  This is specifically to stop tsc from thinking that an empty default options hash passed to a function
 (eg. fn(args, o = {}){... o.something ... }))
should be of empty type, and thus complain on o.something.  As is appropriate, you should define interfaces for the `o`s as above, and generally annotate function parameters with appropriate types.

Exports are kind of weird -- I'll explain them later.

Some classes of errors are:
_.range
class constants
jquery-plugins/underscore.string .d.ts
implicit returns of render
defaults is a property/method
bound methods

