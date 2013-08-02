
var sourceMap = require('source-map'),
    fs = require('fs'),
    us = require('underscore'),
    path = require('path');

//TODO: could be a grunt plugin

exports.reAddAndWrite = function(mapfile) {
  var commented = exports.reAddWithMapFile(mapfile);
  fs.writeFileSync(commented.generatedFile, commented.code);
}

exports.reAddWithMapFile = function(mappath) {
  var mapfile = fs.readFileSync(mappath, 'utf8');
  var mapdict = JSON.parse(mapfile);
  return exports.reAddWithMap(mapdict, path.dirname(mappath));
}

exports.reAddWithMap = function(mapdict, genDir) {
  var map = new sourceMap.SourceMapConsumer(mapdict);
  var genPath = path.join(genDir, mapdict.file);
  var genLines = fs.readFileSync(genPath, 'utf8').split('\n');
  var srcRoot = path.resolve(genDir, mapdict.sourceRoot);

  mapdict.sources.forEach(function(source){
    var srcPath = path.resolve(srcRoot, source);
    var srcLines = fs.readFileSync(srcPath, 'utf8').split('\n');
    addCommentsTo(genLines, srcLines, map, source);
  });

  return {code: us.flatten(genLines).join('\n'), generatedFile: genPath};
}

exports.reAddComments = function(generatedCode, sourceCode, mapdict) {
  var genLines = generatedCode.split('\n');
  var srcMap = new sourceMap.SourceMapConsumer(mapdict);
  addCommentsTo(genLines, sourceCode.split('\n'), srcMap, mapdict.sources[0]);
  return us.flatten(genLines).join('\n');
}

function addCommentsTo(generatedLines, sourceLines, srcMap, sourcePath) {
  var isInBlockComment =  false;

  for (var srcLineNum = 0; srcLineNum < sourceLines.length; srcLineNum++) {
    var srcLine = sourceLines[srcLineNum];

    //FIXME: this just doesn't take in to account strings with ### in them
    if ((srcLine.match(/###/g)||[]).length % 2 === 1) {
      isInBlockComment = !isInBlockComment;
    }
    if (isInBlockComment) continue;

    //TODO: fix on ### block comment ### #comment
    //FIXME: what about "#"
    var comment_match = srcLine.match(/^(?:[^#"]|"(?:[^"\\]|\\.)*")*#(#[^#]?|[^#].*)$/);

    if (comment_match === null) continue;
    var comment = comment_match[1];
    var comment_start = srcLine.length - comment.length - 1;
    var commentIsOnOwnLine = !!srcLine.match(/^\s*#/);

    var genLine = srcMap.generatedPositionFor({
      source: sourcePath,
      line: srcLineNum + 1,         // file lines are 1-indexed
      column: comment_start + 1     // file columns are 1-indexed
    }).line - 1;                    // file lines are 1-indexed

    var firstCommentOnLine = false;
    if (!us.isArray(generatedLines[genLine])) {
      firstCommentOnLine = true;
      generatedLines[genLine] = [generatedLines[genLine]];
    }

    if (firstCommentOnLine && !commentIsOnOwnLine) {
      generatedLines[genLine] += '  //' + comment;
    } else {
      var indent = generatedLines[genLine][0].match(/^(\s*)/)[1];
      generatedLines[genLine].push(indent + '//'+ comment);
    }
  }
}

