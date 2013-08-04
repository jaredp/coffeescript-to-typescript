us = require 'underscore'

exports.makeFakeblocks = (code) ->
  lastLineIndent = undefined  # iff defined, last line was a comment line
  inRealCommentBlock = false
  rewritten_lines = for line in code.split('\n')
    # isComment if the line is a line with only a comment on it
    # indent is undefined if the line is not a comment-only line
    isComment = [_, indent] = line.match(/^(\s*)#(?!##)/) or no

    ###
    # isSameIndentation is false if the last line was a comment and
    # this line is not, or vice-versa.  It's true if neither this
    # line nor the preceding line are comments.  Lastly, it's true
    # where both this and the preceding line are comments iff they have
    # the same indentation, and should be part of the same fakeblock.
    ###
    isSameIndentation = (indent == lastLineIndent)

    # this is very heuristic-- I'm really assuming there's nothing
    # wierd going on with ###s on a line
    if line.match(/###/g)?.length % 2 == 1
      inRealCommentBlock = !inRealCommentBlock
      rewritten_line = line

    else unless inRealCommentBlock or isSameIndentation
      rewritten_line = [
        if lastLineIndent? then ["#{lastLineIndent}###"] else []
        if isComment then ["#{indent}###fakeblock"] else []
        line
      ]

    else
      rewritten_line = line

    lastLineIndent = indent
    rewritten_line

  return us.flatten(rewritten_lines).join('\n')


exports.unmakeFakeblocks = (code) ->
  code = code.replace /\/\*(([\n\r]|.)*?)\*\//g, (match) ->
    match.replace(/(\n\s*)#/g, "$1//")

  code.replace ///
    [^\S\n]*/\*fakeblock\n
    (([\n\r]|.)*?\n)
    [^\S\n]*\*/\n
  ///g, "$1"
