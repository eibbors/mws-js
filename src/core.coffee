# ----------------------------------------------------------
#  mws-js • core.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Core classes and types required for communication with Amazon's
# MWS services. This mainly includes https client + request + 
# response wrappers with helpers galore and the param schema +
# model classes used to declare services in submodules.
# ----------------------------------------------------------

{EventEmitter} = require "events"
https = require "https"
qs = require "querystring"
crypto = require "crypto"
xml2js = require 'xml2js'

# Constants required by the method used to sign requests
MWS_SIGNATURE_METHOD = 'HmacSHA256'
MWS_SIGNATURE_VERSION = 2

# Constant marketplaceIds are annoying to keep track of so I put them here
MWS_MARKETPLACES = 
  # allow translation to country code 
  ATVPDKIKX0DER: 'US'
  A1F83G8C2ARO7P: 'UK'
  A13V1IB3VIYZZH: 'FR'
  A1PA6795UKMFR9: 'DE'
  APJ6JRA9NG5V4: 'IT'
  A1RKKUPIHCS9HS: 'ES'
  # allow lookup by country code
  US: 'ATVPDKIKX0DER'
  UK: 'A1F83G8C2ARO7P'
  FR: 'A13V1IB3VIYZZH'
  DE: 'A1PA6795UKMFR9'
  IT: 'APJ6JRA9NG5V4'
  ES: 'A1RKKUPIHCS9HS'
  CA: null
  CN: null
  JP: null

# I'm piecing these together from various sources, if you can help, please let me know!
MWS_LOCALES =
  US: { host: "mws.amazonservices.com", country: 'UnitedStates',  domain: 'www.amazon.com',   marketplaceId: MWS_MARKETPLACES.US }
  UK: { host: "mws.amazonservices.co",  country: 'UnitedKingdom', domain: 'www.amazon.co.uk', marketplaceId: MWS_MARKETPLACES.UK }
  FR: { host: "mws.amazonservices.fr",  country: 'France',        domain: 'www.amazon.fr',    marketplaceId: MWS_MARKETPLACES.FR }
  DE: { host: "mws.amazonservices.de",  country: 'Germany',       domain: 'www.amazon.de',    marketplaceId: MWS_MARKETPLACES.DE }
  IT: { host: "mws.amazonservices.it",  country: 'Italy',         domain: 'www.amazon.it',    marketplaceId: MWS_MARKETPLACES.IT }
  ES: { host: "mws.amazonservices.es",  country: 'Spain',         domain: 'www.amazon.es',    marketplaceId: MWS_MARKETPLACES.ES }
  CA: { host: "mws.amazonservices.ca",  country: 'Canada',        domain: 'www.amazon.ca',    marketplaceId: MWS_MARKETPLACES.CA }
  CN: { host: "mws.amazonservices.cn",  country: 'China',         domain: 'www.amazon.cn',    marketplaceId: MWS_MARKETPLACES.CN }
  JP: { host: "mws.amazonservices.jp",  country: 'Japan',         domain: 'www.amazon.jp',    marketplaceId: MWS_MARKETPLACES.JP }
    
# Core and common type definitions -- likely to be moved to a seperate file after
# the Feeds generation module is working, as there's a buttload of them
types = 
  ServiceStatus:
    GREEN: "The service is operating normally."
    GREEN_I: "The service is operating normally + additional info provided"
    YELLOW: "The service is experiencing higher than normal error rates or degraded performance."
    RED: "The service is unabailable or experiencing extremely high error rates."


class MWSClient extends EventEmitter

  constructor: (options = {}, extras...) ->
    for e in extras when typeof e is 'object'
      (options[k] = v) for k,v of e 
    # Load the settings if they pass in one of the MWS_LOCALES or their own
    if options.locale?
      unless typeof options.locale is 'object'
        options.locale = MWS_LOCALES[options.locale] ? null
      @host = options.host ? (options.locale.host ? "mws.amazonservices.com")
      @marketplaceId = options.locale.marketplaceId
      @country = options.locale.country ? undefined
      @domain = options.locale.domain ? undefined
    # Connection settings
    @host = @host ? (options.host ? "mws.amazonservices.com")
    @port = options.port ? 443
    # Credentials required by every request
    @merchantId = options.merchantId ? null
    @accessKeyId = options.accessKeyId ? null
    @secretAccessKey = options.secretAccessKey ? null
    # MarketplaceId required by many requests
    @marketplaceId ?= @marketplaceId ? (options.marketplaceId ? null)
    # Application information
    @appName = options.appName or 'mws-js'
    @appVersion = options.appVersion or "0.2.0"
    @appLanguage = options.appLanguage or "JavaScript"
    @appHost = options.appHost ? undefined
    @appPlatform = options.appPlatform ? undefined
    options

  # Used to sign
  sign: (service, q={}) ->
    path = service.path ? '/'
    hash = crypto.createHmac("sha256", @secretAccessKey)
    # Tack on access params + signature details
    if service.legacy then q['Merchant'] = @merchantId
    else q['SellerId'] = @merchantId
    q['AWSAccessKeyId'] ?= @accessKeyId
    q['SignatureMethod'] = MWS_SIGNATURE_METHOD
    q['SignatureVersion'] = MWS_SIGNATURE_VERSION
    # Sort the nearly complete query string
    sorted = {}
    keys = (k for k,v of q).sort()
    (sorted[k] = q[k] for k in keys) 
    stringToSign = "POST\n#{@host}\n#{path}\n#{qs.stringify(sorted)}"
    # Encode a few possible problem characters
    stringToSign = stringToSign.replace( /'/g, '%27')
    stringToSign = stringToSign.replace(/\*/g, '%2A')
    stringToSign = stringToSign.replace(/\(/g, '%28')
    stringToSign = stringToSign.replace(/\)/g, '%29')
    # Finally we generate and append our signature parameter
    q['Signature'] = hash.update(stringToSign).digest('base64')
    q

  invoke: (request, options, cb) ->
    # Calculate MD5 / Attach options.body as appropriate
    if request?.body then request.md5Calc()
    if options?.body then request.attach options.body, 'text'
    # Load request path + sign query
    options.path ?= request.service?.path ? '/'
    q = @sign(options.service ? request.service ? null, request.query(options.query ? {}))
    # Load request headers
    options.headers ?= {}
    (options.headers[h] = v) for h,v of request.headers
    # Take care of body, whether explicitly defined or defaulting to query
    if request.body or options.body
      options.body ?= request.body
      options.path = "#{options.path}?#{qs.stringify(q)}"
    else
      options.body = qs.stringify(q)
      options.headers['content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
    # Finish off other basic headers
    options.headers['host'] = @host
    agentParams = ["Language=#{@appLanguage}"]
    if @appHost then agentParams.push "Host=#{@appHost}"
    if @appPlatform then agentParams.push "Platform=#{@appPlatform}"    
    options.headers['user-agent'] = "#{@appName}/#{@appVersion} (#{agentParams.join('; ')})"
    options.headers['content-length'] = options.body.length
    # http(s) request options completes the request options
    options.host ?= @host
    options.port ?= @port
    options.method ?= 'POST'
    # Instantiate an http(s) request
    req = https.request options, (res) =>
      # Join chunked data until EOF reached, then parse or pass error
      data = []
      res.on 'data', (chunk) =>
        data.push( chunk )
      res.on 'end', =>
        data = Buffer.concat(data)
        mwsres = new MWSResponse res, data, options
        mwsres.parseHeaders()
        mwsres.parseBody (err, parsed) =>
          if options.nextTokenCall? and (mwsres.result?.NextToken?.length > 0)
            invokeOpts = { nextTokenCall : options.nextTokenCall }
            # on calls that use HasNext parameter, set nextToken only if HasNext is 'true'
            if options.nextTokenCallUseHasNext
              invokeOpts.nextTokenCallUseHasNext = options.nextTokenCallUseHasNext
              mwsres.nextToken = mwsres.result.NextToken if mwsres.result?.HasNext is 'true'
            else
              mwsres.nextToken = mwsres.result.NextToken
            nextRequest = new options.nextTokenCall(NextToken: mwsres.nextToken)
            mwsres.getNext = ()=>
              opts = {}
              for k,v of invokeOpts
                opts[k] = v
              @invoke nextRequest, opts, cb
          @emit 'response', mwsres, parsed
          cb mwsres
      res.on 'error', (err) =>
        @emit 'error', err
        cb err, null, Buffer.concat(data).toString()
    @emit 'request', req, options
    req.write options.body
    req.end()

# Basic Service definition 
class MWSService

  constructor: (options) ->
    (@[k] = v) for k,v of options
    @name ?= null
    @path ?= '/' 
    @version ?= '2009-01-01'
    @legacy ?= false

class MWSRequest

  constructor: (@service, @action, @params=[], @headers={}, @body=null, init={}) ->
    @service ?= new MWSService
    for i,p of @params
      pid = p.name ? i
      if init[pid]? then p.set init[pid]
      @[pid] = @params[i] ? null

  query: (q={}) ->
    for i,p of @params
      val = @[p.name ? i] ? p ? {}
      if val.render? then val.render(q)
      else q[val.name ? i] = val.value ? p
    q['Action'] = @action
    q['Version'] = @service.version ? '2009-01-01'
    q['Timestamp'] = (new Date()).toISOString()
    q

  set: (param, value) ->
    if typeof param is 'object' and value is undefined
      for k, v of param
        @set k, v
    else
      if @[param]?.set?
        @[param].set(value ? null)
      else 
        throw "#{param} is not a valid parameter for this request type"

  attach: (body, format) ->
    @body = body
    @headers['content-type'] = format ? 'text'
    @md5Calc()

  md5Calc: ->
    @headers['content-md5'] = crypto.createHash('md5').update(@body).digest("base64")

class MWSResponse

  # Accepts an http(s) response object and raw response body
  constructor: (response, body, options={}) ->
    @statusCode = response.statusCode
    @headers = response.headers
    @body = body ? null
    @meta = {}
    @options = options
    @allowedContentTypes = options?.allowedContentTypes ? []

  # Looks for x-(ns)-(id) matches within header keys
  # and stores them in @meta[ns][id] where id is camelCase
  # ie: 'x-mws-timestamp'  ~ @meta.mws.timestamp
  #  &  'x-amz-some-thing' ~ @meta.amz.someThing
  parseHeaders: ->
    for header,value of @headers
      xreg = /x-(\w+)-(.*)/gi.exec header
      if xreg
        ns = xreg[1]
        id = xreg[2].replace /(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')
        @meta[ns] ?= {}
        @meta[ns][id] = value

  # Handle xml2js conversion as well as any report formats later on
  parseBody: (cb) ->
    isXml = false
    if @headers['content-type'].indexOf('text/xml') == 0
      @body = @body.toString()
      isXml = true
    else if @headers['content-type'].indexOf('text/plain') == 0
      @body = @body.toString().trim()
      isXml = @body.indexOf('<?xml') == 0
    else if @headers['content-type'].indexOf('application/octet-stream') == 0
      @body = @body.toString().trim()
      isXml = @body.indexOf('<?xml') == 0

    if isXml
      parser = new xml2js.Parser { explicitRoot: true, normalize: false, trim: false }
      parser.parseString @body, (err, res) =>
        if err then throw err
        else
          @response = res ? {}
          # This simply checks the root elements for "#{x}Response" and sets responseType
          for k, v of @response
            rtype = /([A-Z]\w+)Response/.exec k
            if rtype
              @responseType = rtype[1]
              if @responseType is 'Error'
                @error = v.Error ? v
                @requestI
              if v["#{@responseType}Result"]
                @result = v["#{@responseType}Result"]
                # if @result.NextToken? then @nextToken = @result.NextToken
              if v.ResponseMetadata? then @meta.response = v.ResponseMetadata
          cb err, res 
    else if @headers['content-type'] in @allowedContentTypes
      md5 = crypto.createHash('md5').update(@body).digest("base64")
      if @headers['content-md5'] == md5
        @response = @body
        cb null, @body
      else
        @responseType = 'Error'
        @error = 
          Type: {},
          Code: 'Client_WrongMD5',
          Message: "Invalid MD5 on received content: amazon=#{ @headers['content-md5']} , calculated=#{ md5 }"
        @response = null
        @responseWithInvalidMD5 = @body
        cb @error, null
    else
      @responseType = 'Error'
      @error = 
        Type: {},
        Code: 'Client_UknownContent',
        Message: "Unrecognized content format: #{@headers['content-type'] ? 'undefined'}"
      @response = null
      cb @error, null

class MWSParam
  constructor: (@name, @required=false, value) ->
    if value? then @set value

  render: (obj={}) ->
    val = @get()
    if val?
      obj[@name] = @get()
      obj
    else if @required
      throw "Required parameter #{@name} must be defined!"

  get: ->
    @value

  set: (val) ->
    @value = val
    this

# Converts true/false or truthy/not values to literal 'true' or 'false'
class MWSBool extends MWSParam

  get: ->
    if @value then "true"
    else if @value? then "false"
    else undefined

class MWSTimestamp extends MWSParam

  get: ->
    if @value?.constructor is Date
      @value.toISOString()
    else
      @value

  set: (val) ->
    val ?= new Date()
    if val.constructor isnt Date
      try
        @value = new Date(val)
      catch e
        @value = val
    else 
      @value = val
    this

class MWSParamList extends MWSParam
  constructor: (@name, @type, @required, value) ->
    super @name, @required, value ? []
    @list = true

  render: (obj={}) ->
    if @value.length < 1 and @required 
      throw "Required parameter list, #{@name} is empty!"
    for k,v of @get()
      obj[k] = v
    obj

  clear: -> @value = []

  add: (vals...) -> @value = @value.concat vals 
  
  get: (index...) ->
    list = {}
    count = 0
    if index.length < 1
      for v in @value
        list["#{@name}.#{@type}.#{++count}"] = v
    else
      for i in index
        throw "ERROR: INVALID INDEX #{i}" unless @value[i]?
        list["#{@name}.#{@type}.#{++count}"] = @value[i] 
    list

  set: (val) ->
    if Array.isArray val then @value = val
    else @value = [val]


class MWSEnum extends MWSParam 
  constructor: (@name, @members=[], @required=false, value) ->
    @value = null
    if value? then @set value 

  set: (val) ->
    if val in @members
      @value = val
    else if @members[val]?
      @value = @members[val]
    else
      throw "Invalid enumeration value, '#{val}', must be a member or index of #{@members}"

# Model for enum params that accept 
# Is used for enum fields that support multiple values. In other words, 
class MWSEnumList extends MWSParamList

  constructor: (@name, @type, @members, @required=false, initValue) ->
    @list = true 
    @value = {}
    for m in @members
      @value[m] = initValue ? false

  render: (obj={}) ->
    onset = @get()
    if onset.length < 1 and @required 
      throw "Required paremeter list (enum), #{@name} is empty!"
    for k,v of onset
      obj[k] = v
    obj

  enable: (values...) ->
    for v of values when v in @members
      @value[v] = true

  disable: (values...) ->
    for v of values when v in @members
      @value[v] = false

  toggle: (values...) ->
    for v of values when v in @members
      @value[v] = if @value[v] then false else true

  # Resets (disables) all members
  clear: -> @disable @members

  # Enables all members
  all: -> @enable @members

  # Toggles every                    
  invert: -> @toggle @members

  # Can be used to override default behavior and add custom enum members
  add: (value, enabled=true) ->
    @members[value] = enabled
    @value[value] = enabled
    this

  get: ->
    list = {}
    count = 0
    for i of @value
      for k, v of @value[i] when v is true
        list["#{@name}.#{@type}.#{++count}"] = k
    list

class MWSComplexParam extends MWSParam
    constructor: (@name, @params, @required, value) ->
      @params ?= {}
      # @set value

    render: (obj={}) ->
      fields = @get()
      for k,v of fields
        if v is null then throw "Missing required parameter #{k}"
        else obj[k] = v
      obj

    render: (obj={}) ->
      for k,p of @params
        n = p.name ? k
        v = p.get?() ? p.value
        if v? 
          obj["#{@name}.#{n}"] = v
        else if p.required
          throw "Missing required parameter #{@name}.#{n}"
      obj

    get: (field) ->
      if field? and @params[field]? 
        @params[field].get()
      else if not field? 
        obj = {}
        (obj[k] = p) for k,p of @params
      else
        for k,p of @params
          if p.name is field then return p 
        throw  "There is no field, #{field}, in #{@name}"

    set: (field, value) ->
      if arguments.length is 1 and typeof field is 'object'
        for k,v of field
          @set k, v
      else if @params[field]?
        if @params[field].set? then @params[field].set(value)
        else @params[field].value = value
      else
        for k,v of @params
          if v.name.toLowerCase() is field.toLowerCase()
            @set k, value

class MWSComplexList extends MWSParamList
  constructor: (@name, @type, @required, value) ->
    super @name, @required, value ? []
    @list = true

  render: (obj={}) ->
    if @value.length < 1 and @required 
      throw "Required (complex) parameter list, #{@name} is empty!"
    for k,v of @get()
      v.name = k
      v.render(obj)
    obj

# Export all of the juicy goodness!
module.exports = 
  # namespaced constants and definitions
  MARKETPLACES: MWS_MARKETPLACES
  LOCALES: MWS_LOCALES
  types: types
  # core classes used by submodules
  Client: MWSClient
  Request: MWSRequest
  Response: MWSResponse
  Service: MWSService
  Param: MWSParam
  Bool: MWSBool
  Timestamp: MWSTimestamp
  ParamList: MWSParamList
  Enum: MWSEnum
  EnumList: MWSEnumList
  ComplexParam: MWSComplexParam
  ComplexList: MWSComplexList