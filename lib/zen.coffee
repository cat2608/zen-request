"use strict"

fs          = require "fs"
Hope        = require "hope"
yaml        = require "js-yaml"
path        = require "path"

# Configuration
folder      = "../../../"
test_path   = path.join __dirname, "#{folder}zen.test.yml"
global.test = yaml.safeLoad(fs.readFileSync(test_path, 'utf8'))

module.exports =
  start: ->
    tests = []
    for file in test.files
      tests = tests.concat do require("#{folder}/test/#{file}")

    test.counters = total: tests.length, success: 0, current: 0
    Hope.chain(tests).then (error, result) ->
      coverage = ((test.counters.success * 100) / test.counters.total).toFixed(2)
      failed = test.counters.total - test.counters.success
      console.log('================================================================================'.rainbow);
      console.log (if coverage >= 95 then "[\u2713]".green else "[x]".red) ,"TEST COVERAGE:", "#{coverage}%"[if coverage < 95 then "red" else "green"], " (".grey, "#{failed}".red, "/ #{test.counters.total} )".grey
      console.log('================================================================================'.rainbow);
