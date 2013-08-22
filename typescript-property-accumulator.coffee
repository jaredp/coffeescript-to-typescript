fs = require 'fs'
{spawn} = require 'child_process'
us = require 'underscore'
lineStream = require 'line-input-stream'

parseArgs = (options) ->
  argv = postional: []
  for arg in process.argv[2..]
    if arg[0..0] != '-'
      argv.postional.push arg
    else
      argv[options[flag]] = yes for flag in arg[1..]
  return argv

args = parseArgs
  d: 'displayErrcount'
  e: 'printErrors'

tscripts = args.postional
classes = []
realErrorCount = 0

tsc = spawn 'tsc', tscripts
lineStream(tsc.stderr).on('line', (line)=>
  EREGEX = /error TS2094: The property '(.*)' does not exist on value of type '(.*)'\.\n?$/
  if [match, property, type] = line.match(EREGEX) or no
    klass = (classes[type] ||= [])
    klass.push property if property not in klass
  else
    realErrorCount += 1
    console.log line if args.printErrors

).on('end', =>
  console.log "   #{realErrorCount} errors" if args.displayErrcount

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
