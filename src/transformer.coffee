
underscore = require 'underscore'
{ Base, Return, Call, Code, Param, Class, Block,
  For, Value, Access, Literal } = require './nodes'

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


# TODO: add function definitions
# TODO: move AMD defines here

class UseES5MethodsInsteadOfForLoops extends Transformer
  on: (f) => f instanceof For and not (f.index or f.object or f.step or f.pattern or f.jumps())
  transform: (f) =>
    mkMCall = (obj, meth, args) -> new Call(new Value(obj, [new Access new Literal meth]), args)
    mkLam = (exprs) ->
      lam = new Code([new Param f.name], exprs, 'boundfunc')
      lam.undeclaredScope = lam.sharedScope = on
      return lam

    returnsValue = yes    # FIXME: should probably look at if our supernode is Block[]
    mapMeth = if returnsValue then "map" else "forEach"

    comprehension = f.source
    comprehension = mkMCall comprehension, "filter", [mkLam Block.wrap [new Return(f.guard)]] if f.guard
    mkMCall comprehension, mapMeth, [mkLam f.body]

exports.toSAST = toSAST = apply [
    UseES5MethodsInsteadOfForLoops
  ]
