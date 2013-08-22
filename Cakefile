fs            = require 'fs'
path          = require 'path'
{spawn, exec} = require 'child_process'
helpers       = require './lib/coffee-script/helpers'

task 'build:parser', 'rebuild the Jison parser (run build first)', ->
  helpers.extend global, require('util')
  require 'jison'
  parser = require('./lib/coffee-script/grammar').parser
  fs.writeFile 'lib/coffee-script/parser.js', parser.generate()

