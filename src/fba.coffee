# ----------------------------------------------------------
#  mws-js • fba.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Description Soon
# ----------------------------------------------------------

mws = require './core'

# Larger service definition than most other modules, be sure to
# note the difference in format MWS_FBA(DOT)(GROUP)
MWS_FBA_INBOUND = new mws.Service
    name: 'Fulfillment'
    group: 'Inbound Shipments'
    path: '/FulfillmentInboundShipment/2010-10-01'
    version: '2010-10-01'
    legacy: false 
MWS_FBA_OUTBOUND = new mws.Service
    name: 'Fulfillment'
    group: 'Outbound Shipments'
    path: '/FulfillmentOutboundShipment/2010-10-01'
    version: '2010-10-01'
    legacy: false 
MWS_FBA_INVENTORY = new mws.Service
    name: 'Fulfillment'
    group: 'Inventory'
    path: '/FulfillmentInventory/2010-10-01'
    version: '2010-10-01'
    legacy: false 


# Complex Parameters are those which contain child parameters 
complex = 

  DisplayableOrder: class extends mws.ComplexParam
    constructor: (@name='DisplayableOrder', @required=false, init) ->
      @params = 
        id: new mws.Param('DisplayableOrderId', true) 
        dateTime: new mws.Timestamp('DisplayableOrderDateTime', false)
        comment: new mws.Param('DisplayableOrderComment', false) 
      if init? then @set init

  Address: class extends mws.ComplexParam
    constructor: (@name='Address', @required=false, init) ->
      @params = 
        name: new mws.Param('Name')
        line1: new mws.Param('Line1')
        line2: new mws.Param('Line2')
        line3: new mws.Param('Line3')
        city: new mws.Param('City')
        state: new mws.Param('StateOrProvinceCode')
        zip: new mws.Param('PostalCode')
        district: new mws.Param('DistrictOrCounty')
        country: new mws.Param('CountryCode')
        phone: new mws.Param('PhoneNumber')
      if init? then @set init

  LineItem: class extends mws.ComplexParam
    constructor: (init) ->
      @params = 
        comment: new mws.Param('DisplayableComment')
        giftMessage: new mws.Param('GiftMessage')
        declaredValue: new mws.Param('PerUnitDeclaredValue.Value')
        declaredCurrency: new mws.Param('PerUnitDeclaredValue.CurrencyCode')
        quantity: new mws.Param('Quantity')
        itemId: new mws.Param('SellerFulfillmentOrderItemId')
        sku: new mws.Param('SellerSKU')
      if init? then @set init

  LineItems: class extends mws.ComplexList

    addItem: (itemId, sku, quantity, declaredValue, declaredCurrency, giftMessage, comment) ->
      if arguments.length is 1 and typeof itemId is 'object'
        if itemId.render? then @value.push itemId
        else @value.push new complex.LineItem
      else
        @value.push new complex.LineItem {itemId, sku, quantity, declaredValue, declaredCurrency, giftMessage, comment} 
              
enums =
  # Not exactly screaming for an enum class, but the only two values
  # # currently allowed as part of the inventory api
  ResponseGroup: class extends mws.Enum 
    constructor: (options={}) ->
      super('ResponseGroup', [ 'Basic', 'Detailed' ], options.required ? false)

  ShippingSpeedCategory: class extends mws.Enum
    constructor: (options={}) ->
      super('ShippingSpeedCategory', [ 'Standard', 'Expedited', 'Priority'], options.required ? false)

  ShippingSpeedCategories: class extends mws.EnumList
    constructor: (options={}) ->
      super('ShippingSpeedCategories', 'member', [ 'Standard', 'Expedited', 'Priority'], options.required ? false)

  FulfillmentPolicy: class extends mws.Enum 
    constructor: (options={}) ->
      super('FulfillmentPolicy', [ 'FillOrKill', 'FillAll', 'FillAllAvailable' ], options.required ? false)


# Simple types
types = 
  ServiceStatus: mws.types.ServiceStatus


requests = 
  inbound:
    GetServiceStatus: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'GetServiceStatus', [], {}, null, init

  outbound:
    GetServiceStatus: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'GetServiceStatus', [], {}, null, init

    CancelFulfillmentOrder: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'CancelFulfillmentOrder', [
          new mws.Param('SellerFulfillmentOrderId', true)
        ], {}, null, init

    CreateFulfillmentOrder: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'CreateFulfillmentOrder', [
          new mws.Param('SellerFulfillmentOrderId', true)
          new enums.ShippingSpeedCategory(required: true)
          new enums.FulfillmentPolicy()
          new mws.Param('FulfillmentMethod')
          new mws.ParamList('NotificationEmailList', 'member')
          new complex.Address('DestinationAddress')
          new complex.LineItems()
        ], {}, null, init

    GetFulfillmentOrder: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'GetFulfillmentOrder', [
          new mws.Param('SellerFulfillmentOrderId', true)
        ], {}, null, init

    GetFulfillmentPreview: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'GetFulfillmentPreview', [
          new complex.Address('Address')
          new complex.LineItems('LineItems')
          new enums.ShippingSpeedCategories()
        ], {}, null, init

    ListAllFulfillmentOrders: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'ListAllFulfillmentOrders', [
          new mws.Timestamp('QueryStartDateTime', true),
          new mws.ParamList('FulfillmentMethod', 'member')
        ], {}, null, init

    ListAllFulfillmentOrdersByNextToken: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_OUTBOUND, 'ListAllFulfillmentOrdersByNextToken', [
          new mws.Param('NextToken', true)      
        ], {}, null, init

  inventory: 
    GetServiceStatus: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INVENTORY, 'GetServiceStatus', [], {}, null, init

    ListInventorySupply: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INVENTORY, 'ListInventorySupply', [
          new mws.ParamList('SellerSkus', 'member'),
          new mws.Timestamp('QueryStartDateTime'),
          new enums.ResponseGroup()
        ], {}, null, init

    ListInventorySupplyByNextToken: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INVENTORY, 'ListInventorySupplyByNextToken', [
          new mws.Param('NextToken', true)
        ], {}, null, init

class FBAInboundClient extends mws.Client

  getServiceStatus: (cb) ->
    @invoke new requests.inbound.GetServiceStatus(), {}, (res) =>
      status = res.result?.Status ? null
      cb status, res

class FBAOutboundClient extends mws.Client

    getServiceStatus: (cb) ->
      @invoke new requests.outbound.GetServiceStatus(), {}, (res) =>
        status = res.result?.Status ? null
        cb status, res

class FBAInventoryClient extends mws.Client

    getServiceStatus: (cb) ->
      @invoke new requests.inventory.GetServiceStatus(), {}, (res) =>
        status = res.result?.Status ? null
        cb status, res



module.exports = 
  inbound:
    service: MWS_FBA_INBOUND
    requests: requests.inbound
    Client: FBAInboundClient
  outbound:
    service: MWS_FBA_OUTBOUND
    requests: requests.outbound
    Client: FBAOutboundClient
  inventory:
    service: MWS_FBA_INVENTORY
    requests: requests.inventory
    Client: FBAInventoryClient
  complex: complex
  types: types
  requests: requests