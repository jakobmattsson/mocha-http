_ = require("underscore")
isPrimitive = (arg) ->
  type = typeof arg
  not arg? or (type isnt "object" and type isnt "function")

exports.cmp = (obj, expected) ->
  return null  if _.isEqual(obj, expected)
  if isPrimitive(obj) or isPrimitive(expected)
    if obj isnt expected
      return JSON.stringify(obj) + " but expected " + JSON.stringify(expected)
    else
      return null
  if Array.isArray(obj)
    return ["The checked object is an array, but expected " + typeof expected]  unless Array.isArray(expected)
    return _(obj).zip(expected).map((pair) ->
      exports.cmp.apply null, pair
    ).join("\n")
  err = []
  okeys = Object.keys(obj).sort()
  ekeys = Object.keys(expected).sort()
  unexpected = _.difference(okeys, ekeys)
  missing = _.difference(ekeys, okeys)
  intersection = _.intersection(ekeys, okeys)
  err.push "Encountered the following unexpected keys: " + unexpected.join(", ")  if unexpected.length > 0
  err.push "Missed the following keys: " + missing.join(", ")  if missing.length > 0
  unless _(obj).isArray()
    intersection.forEach (key) ->
      err.push "Invalid value of '" + key + "': " + JSON.stringify(obj[key]) + " but expected " + JSON.stringify(expected[key]) + " (" + typeof obj[key] + " and " + typeof expected[key] + ")"  unless _.isEqual(obj[key], expected[key])

  err.join "\n"

exports.cmpcnt = (obj, expected) ->
  return null  if _.isEqual(obj, expected)
  err = []
  okeys = Object.keys(obj).sort()
  ekeys = Object.keys(expected).sort()
  missing = _.difference(ekeys, okeys)
  intersection = _.intersection(ekeys, okeys)
  err.push "Missed the following keys: " + missing.join(", ")  if missing.length > 0
  intersection.forEach (key) ->
    err.push "Invalid value of '" + key + "': " + JSON.stringify(obj[key]) + " but expected " + JSON.stringify(expected[key]) + " (" + typeof obj[key] + " and " + typeof expected[key] + ")"  unless _.isEqual(obj[key], expected[key])

  err.join "\n"