
[ ] TypeScript requrires members to be declared
  [ ] read tsc's errors to find undeclared members... maybe this should be a separate tool...
  [ ] tsc doesn't try to guess the types of the members... for now maybe we should just use `any`

[X] sourcemaped error support for coffee-typer (debugging blind at the moment)

[X] class definitions

[ ] function definitions
  [ ] pull out if in Assign
[X] method definitions
  [ ] default parameters
  [ ] overloads
  [ ] constructors (CS&TS treat them the same, just make them normal mehtods)
  [ ] varargs (splats -> spreads, args... -> ...args)
[ ] static methods
  [ ] `this` refers to the class object...?

[ ] fat/thin arrow lambdas
  [ ] _this = this to capture this is done in TS as well...

[ ] for loop / comprehensions (.filter lam*, .map lam)
  [ ] arrays use: for value(, index) in array
  [ ] hashes use: for (own) key, value of dict


[ ] do construct (should be annonymous function closure + invocation)
[ ] in operator
  [ ] should add Array.prototype.contains / Object.prototype.in, but should ask how okay that is

[ ] remove uses of _ref wherever possible
  [ ] existential operator [?]
  [ ] desugaring assignment [what did I mean by this?]

[ ] super (only calls current method on immediate super)
  [ ] w/o arg: applies current args
  [ ] consider static methods

[ ] :: (prototype extension... I think just warn on this)
[ ] handle code in class block...
  [ ] assignment to property: static variable
  [ ] warn on everything else

[ ] @warn: log message, line of code, line numbers

[ ] check out best practices for ts org

[ ] literal javascript

[ ] module imports

[ ] stop predeclaring variables...

[ ] Actually, we may be generating ECMAScript6
