"use strict"

require "colors"
Hope      = require "hope"
request   = require "request"
qs        = require "querystring"

module.exports = (method, url, parameters={}, headers={}, description="", expected_code=200, callback) ->
  promise = new Hope.Promise()

  ZENrequest.counters.current++

  method = method.toUpperCase()
  options =
    method  : method
    uri     : "http://#{ZENrequest.host}:#{ZENrequest.port}/#{url}"
    headers : headers
    timeout : 30000
  if parameters? and (method is "GET" or method is "DELETE")
    options.uri += "?#{qs.stringify(parameters)}"
  else
    options.form = parameters

  request options, (error, response, body) ->
    if response
      result = JSON.parse body if body?
      if response.statusCode is expected_code
        ZENrequest.counters.success++
        console.log " ✓ ".green, "#{__formatNumber(ZENrequest.counters.current)}".green, description.grey
        if callback? then callback.call callback, result
        promise.done null, result
      else
        console.log " ⚑ ".red, "#{__formatNumber(ZENrequest.counters.current)}".red, description.grey
        method = __formatMethod(method)
        console.log "        #{method}:".grey, "http://#{ZENrequest.host}:#{ZENrequest.port}/#{url}"
        __formatValues parameters

        console.log "        Response  :".grey, "#{response.statusCode}".red
        __formatValues result

        error = code: response.statusCode, message: result.message
        promise.done error, null
    else
      console.error "[HTTPRequestError]".red + " :: No response from server http://#{ZENrequest.host}:#{ZENrequest.port}/#{url}"
      error = code: 404, message: "No response from server"
      promise.done error, null

  return promise


__formatNumber = (number) ->
  number = number.toString()
  number = "0" + number while number.length < 3
  number

__formatMethod = (method) ->
  method = "[#{method}]"
  method += " " while method.length < 10
  method

__formatValues = (obj) ->
  console.log "                    #{value}".grey, "#{obj[value]}" for value of obj
