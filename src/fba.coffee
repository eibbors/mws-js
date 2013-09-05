# ----------------------------------------------------------
#  mws-js • fba.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Module containing Amazon's newer Fulfillment service APIs
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

  Address: class Address_Base extends mws.ComplexParam
    constructor: (@name='Address', @required=false, init) ->
      @params = 
        name: new mws.Param('Name', true)
        line1: new mws.Param('Line1', true)
        line2: new mws.Param('Line2', false)
        line3: new mws.Param('Line3', false)
        city: new mws.Param('City', true)
        county: new mws.Param('DistrictOrCounty', false)
        state: new mws.Param('StateOrProvinceCode', true)
        zip: new mws.Param('PostalCode', true)
        country: new mws.Param('CountryCode', true)
        phone: new mws.Param('PhoneNumber', false)
      if init? then @set init

  DestinationAddress: class extends Address_Base
    constructor: (required, init) ->
      super 'DestinationAddress', required,  init

  ShipFromAddress: class extends mws.ComplexParam
    constructor: (@required=false, init) ->
      @name = 'ShipFromAddress'
      @params = 
        name: new mws.Param('Name', true)
        line1: new mws.Param('AddressLine1', true)
        line2: new mws.Param('AddressLine2', false)
        city: new mws.Param('City', true)
        county: new mws.Param('DistrictOrCounty', false)
        state: new mws.Param('StateOrProvinceCode', true)
        zip: new mws.Param('PostalCode', true)
        country: new mws.Param('CountryCode', true)
      if init? then @set init

  InboundShipmentHeader: class extends mws.ComplexParam
    constructor: (@required=false,init) ->
      @name = 'InboundShipmentHeader'
      @params =
        shipmentName: new mws.Param('ShipmentName', true)
        shipFromAddress: new complex.ShipFromAddress(true)
        destFCID: new mws.Param('DestinationFulfillmentCenterId', true)
        shipmentStatus: new mws.Param('ShipmentStatus', false)
        labelPrepPref: new mws.Param('LabelPrepPreference',false)

  # The following classes pertain to the various Item lists (plural classes)
  # and their child classes (optional if you use the addItem function)

  # Child parameter of LineItems
  LineItem: class extends mws.ComplexParam
    constructor: (@required=false, init) ->
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
    constructor: (init) ->
      super 'Items', 'member'
    # Constructs (unless you pass a single object) and stores a LineItem instance
    addItem: (itemId, sku, quantity, declaredValue, declaredCurrency, giftMessage, comment) ->
      if arguments.length is 1 and typeof itemId is 'object'
        if itemId.render? then @value.push itemId
        else @value.push new complex.LineItem itemId
      else
        @value.push new complex.LineItem {itemId, sku, quantity, declaredValue, declaredCurrency, giftMessage, comment} 
  
  # Child parameter of InboundShipmentItems < InboundShipmentHeader
  InboundShipmentItem: class extends mws.ComplexParam
    constructor: (init) ->
      @params = 
        quantity: new mws.Param('QuantityShipped')
        sku: new mws.Param('SellerSKU')
      if init? then @set init

  # Stores a set of InboundShipmentItem instances for request params
  InboundShipmentItems: class extends mws.ComplexList
    constructor: (required, init) ->
      super 'InboundShipmentItems', 'member', required, init

    # Add additional InboundShipmentItem via quantity/sku or existing instance
    addItem: (quantity, sku) ->
      if arguments.length is 1 and typeof quantity is 'object'
        if quantity.render? then @value.push itemId
        else @value.push new complex.InboundShipmentItem quantity
      @value.push new complex.InboundShipmentItem { quantity, sku }

  InboundShipmentPlanRequestItem: class extends mws.ComplexParam
    constructor: (init) ->
      @params = 
        quantity: new mws.Param('Quantity')
        sku: new mws.Param('SellerSKU')
        asin: new mws.Param('ASIN')
        condition: new mws.Param('Condition')
      if init? then @set init

  InboundShipmentPlanRequestItems: class extends mws.ComplexList
    constructor: (required, init) ->
      super 'InboundShipmentPlanRequestItems', 'member', required, init

    # Add additional InboundShipmentItem via quantity/sku or existing instance
    addItem: (quantity, sku, asin, condition) ->
      if arguments.length is 1 and typeof quantity is 'object'
        if quantity.render? then @value.push itemId
        else @value.push new complex.InboundShipmentPlanRequestItem quantity
      @value.push new complex.InboundShipmentPlanRequestItem { quantity, sku, asin, condition }


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

    CreateInboundShipment: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'CreateInboundShipment',[             
          new mws.Param('ShipmentId', true),
          new complex.InboundShipmentHeader(true),
          new complex.InboundShipmentItems(true)
        ], {}, null, init 

    CreateInboundShipmentPlan: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'CreateInboundShipmentPlan',[
          new mws.Param('LabelPrepPreference', true),
          new mws.Param(new mws.Param),
          new complex.ShipFromAddress(true),
          new mws.Param('InboundShipmentPlanRequestItems', true)
        ], {}, null, init

    ListInboundShipmentItems: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'ListInboundShipmentItems',[
          new mws.Param('ShipmentId', required: true),
          new mws.Timestamp('LastUpdatedAfter'),
          new mws.Timestamp('LastUpdatedBefore')
        ], {}, null, init

    ListInboundShipmentItemsByNextToken: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'ListInboundShipmentItemsByNextToken',[
          new mws.Param('NextToken', true)
        ], {}, null, init

    ListInboundShipments: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'ListInboundShipments',[
          new mws.ParamList('ShipmentStatusList', 'member') 
          new mws.ParamList('ShipmentIdList', 'member'),
          new mws.Timestamp('LastUpdatedAfter'),
          new mws.Timestamp('LastUpdatedBefore')
        ], {}, null, init

    ListInboundShipmentsByNextToken: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'ListInboundShipmentsByNextToken',[ 
          new mws.Param('NextToken', true)
        ], {}, null, init

    UpdateInboundShipment: class extends mws.Request
      constructor: (init) ->
        super MWS_FBA_INBOUND, 'UpdateInboundShipment',[
          new mws.Param('ShipmentId', true)
          new complex.InboundShipmentHeader(true)
          new complex.InboundShipmentItems(true)
        ], {}, null, init

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
          new complex.DestinationAddress()
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

  listInboundShipments: (options, cb) ->
    if options.ShipmentStatusList and options.ShipmentIdList
      req = new requests.inbound.ListInboundShipments options

      @invoke req, { nextTokenCall: requests.ListInboundShipmentsByNextToken }, (res) ->
        shipments = res.result?.ShipmentData ? null
        if typeof cb is 'function' then cb shipments, res  
    else
      throw 'Special Case: requires either ShipmentStatusList list or ShipmentIdList list be used!'

  listInboundShipmentItems: (options, cb) ->
    if options.ShipmentId or (options.LastUpdatedAfter and options.LastUpdatedBefore)
      req = new requests.inbound.ListInboundShipmentItems options;
      @invoke req, { nextTokenCall: requests.ListInboundShipmentItemsByNextToken }, (res) ->
        items = res.result?.ItemData ? null
        if typeof cb is 'function' then cb items, res
    else
      throw 'Special Case: requires either ShipmentId number or LastUpdatedAfter and LastUpdatedBefore timestamps be used!';

class FBAOutboundClient extends mws.Client

    getServiceStatus: (cb) ->
      @invoke new requests.outbound.GetServiceStatus(), {}, (res) =>
        status = res.result?.Status ? null
        if typeof cb is 'function' then cb status, res

class FBAInventoryClient extends mws.Client
 
    getServiceStatus: (cb) ->
      @invoke new requests.inventory.GetServiceStatus(), {}, (res) =>
        status = res.result?.Status ? null
        if typeof cb is 'function' then cb status, res

    listInventorySupply: (options, cb) ->
      if (options.SellerSkus and not options.QueryStartDateTime or options.QueryStartDateTime)
        req = new requests.inventory.ListInventorySupply options

        @invoke req, { nextTokenCall: requests.ListInventorySupplyByNextToken }, (res) ->
          inventory = res.result?.InventorySupplyList ? null
          if typeof cb is 'function' then cb inventory, res
      else
        throw 'Special Case: requires EXCLUSIVELY either SellerSkus list or QueryStartDateTime timestamp be used!'

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