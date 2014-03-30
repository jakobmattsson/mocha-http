chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
sinonChai = require 'sinon-chai'
Z = require 'z-std-pack'

{cmp} = require './cmp'


chai.use(sinonChai)
chai.use(chaiAsPromised)
chai.should()



# equal override; resolves argument as a promise before comparing
chai.use (_chai, utils) ->
  overrides = ['eql', 'equals']

  overrides.forEach (methodName) ->
    utils.overwriteMethod chai.Assertion.prototype, methodName, (superMethod) ->
      (expectancy) ->
        Z(expectancy).then (resolvedExpectancy) =>

          # Should be able to do something with plugins to show a better diff....
          # Maybe in mocha or with a mocha plugin?
          obj = utils.flag(this, 'object')
          diff = cmp(obj, resolvedExpectancy)
          if diff
            console.log("DIFF")
            console.log("----")
            console.log(diff)

          superMethod.call(this, resolvedExpectancy)







exports.Z = Z

exports.createMethods = (met, methods) ->
  methods ?= ['get', 'post', 'put', 'del', 'head', 'trace', 'options', 'connect', 'patch']

  pMet = Z.bindAsync(met)

  converter = (who, isLowLevel, blockers) ->
    res = {
      as: (who) -> converter(who, isLowLevel, blockers)
      lowlevel: -> converter(who, true, blockers)
      highlevel: -> converter(who, false, blockers)
    }
    methods.forEach (method) ->
      res[method] = (path, body, headers) ->
        Z(blockers).then ->
          pMet({ method, path, isLowLevel, headers, who, body })
    res

  return {
    req: converter(null, false, [])
    after: (blockers...) -> converter(null, false, blockers)
  }
