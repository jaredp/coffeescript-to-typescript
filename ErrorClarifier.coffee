fs = require 'fs'
{spawn} = require 'child_process'
us = require 'underscore'
lineStream = require 'line-input-stream'

parseArgs = (options) ->
  argv = postional: []
  realargs = process.argv[2..]
  argi = 0
  while argi < realargs.length
    arg = realargs[argi]
    if arg[0..0] != '-'
      argv.postional.push arg
    else
      for flag in arg[1..]
        optname = options[flag]
        if us.isArray(optname)  # takes parameter
          argv[optname[0]] = realargs[++argi]
        else
          argv[optname] = yes
    argi++
  return argv

args = parseArgs
  a: ['all']

getTSCErrors = (map, reduce = ()->) ->
  tscripts = args.postional
  tsc = spawn 'tsc', tscripts
  lineStream(tsc.stderr).on('line', (line)=>
    EREGEX = /([a-zA-Z0-9_\.\/]*)\((\d*),(\d*)\): error (TS\d*): (.*)/
    if [_, path, line, offset, errcode, msg] = line.match(EREGEX) or no
      map(errcode, msg, path, line, offset)
  ).on('end', => reduce())

if tserr = args.all
  getTSCErrors (errcode, msg, path, line, offset) ->
    console.log "#{path}:#{line}  #{msg}" if errcode is tserr

else
  errorMap = {}
  totalErrors = 0
  getTSCErrors ((errcode, msg, path, line, offset) ->
    bucket = (errorMap[errcode] ?= {count: 0, msg: ''})
    bucket.count += 1
    bucket.msg = msg
    totalErrors += 1
  ), () -> (
    errors = us.sortBy(us.pairs(errorMap), (e)->-e[1].count)
    for [error, {count, msg}] in errors
      console.log "#{count} errors #{error}: #{msg}"
    console.log "#{totalErrors} total"
  )
