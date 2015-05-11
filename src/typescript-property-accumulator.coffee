#!/usr/bin/env coffee

fs = require 'fs'
{spawn} = require 'child_process'
us = require 'underscore'
lineStream = require 'line-input-stream'

addProperties = (tscripts) ->
  classes = []
  realErrorCount = 0

  tsc = spawn __dirname + '/../node_modules/typescript/bin/tsc', tscripts
  lineStream(tsc.stderr).on('line', (line)=>
    EREGEX = /error TS2094: The property '(.*)' does not exist on value of type '(.*)'\.\n?$/
    if [match, property, type] = line.match(EREGEX) or no
      klass = (classes[type] ||= [])
      klass.push property if property not in klass
    else
      realErrorCount += 1

  ).on('end', =>
    for file in tscripts then do (file) ->
      fs.readFile file, 'utf8', (err, data) ->
        if err then throw err
        lines = data.split('\n')

        CDEFREGEX = /^(\s*)(export )?class ([a-zA-Z_$][a-zA-Z_$0-9]*) ([^{}]*){/
        for line, i in lines when [_, spacing, _, className] = (line.match(CDEFREGEX) or no)
          if properties = classes[className]
            spacing += '    '
            decls = ("#{spacing}public #{prop};" for prop in properties)
            decls.unshift line
            decls.push ''
            lines[i] = decls

        newData = us.flatten(lines).join('\n')
        fs.writeFile(file, newData)
  )

module.exports = addProperties
if require.main == module then addProperties process.argv[2..]
