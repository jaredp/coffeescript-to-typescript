
underscore = require 'underscore'
{ Base, Return, Call, Code, Param, Class, Block,
  For, Value, Access, Literal,
  LEVEL_TOP } = require './nodes'

class Transformer
  on:           (node) -> yes
  stopOn:       (node) -> no
  map:          (node) ->
  transform:    (node) -> @map(node); return node
  runOn: (node) =>
    if node instanceof Base
      return node if @stopOn and @stopOn(node)
      (node[attr] = @runOn(node[attr])) for attr in node.children when node[attr]
      return @transform(node) if not @on or @on(node)
      return node

    else if node instanceof Array
      node.map (e) => @runOn e

    else
      throw "internal compiler error"

apply = (transformers) -> (node) ->
  node = new transformer().runOn(node) for transformer in transformers
  return node

# TODO: add make return
# TODO: add options parameter, like isBlockLevel
# TODO: add function definitions
# TODO: move AMD defines here

class UseES5MethodsInsteadOfForLoops extends Transformer
  on: (f) => f instanceof For and not (f.index or f.object or f.step or f.pattern or f.jumps())
  transform: (f) =>
    mkMCall = (obj, meth, args) -> new Call(new Value(obj, [new Access new Literal meth]), args)
    mkLam = (exprs) ->
      lam = new Code([new Param f.name], Block.wrap([exprs]), 'boundfunc')
      lam.undeclaredScope = lam.sharedScope = on
      return lam

    unless f.guard
      comprehension = f.source
    else
      comprehension = mkMCall f.source, "filter", [mkLam Block.wrap [new Return(f.guard)]]

    new ES5For(comprehension, f.name, f.body)

class ES5For extends Call
  constructor: (@loopSource, name, body) ->
    @forBody = new Code([new Param name], Block.wrap([body]), 'boundfunc')
    @forBody.undeclaredScope = @forBody.sharedScope = on
    super new Value(loopSource, [new Access new Literal "map"]), [@forBody]

  compileNode: (o) ->
    return super unless o.level == LEVEL_TOP
    new Call(
      new Value(@loopSource, [new Access new Literal "forEach"]),
      [@forBody]
    ).compileNode o


exports.toSAST = toSAST = apply [
    UseES5MethodsInsteadOfForLoops
  ]
