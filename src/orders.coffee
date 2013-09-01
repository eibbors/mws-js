# ----------------------------------------------------------
#  mws-js • orders.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Provides the formal data structures necessary for working
# with Amazon's order retrieval services. If you need to look
# up details about your orders, you do it with this.
# ----------------------------------------------------------

mws = require './core'

# MWS API Group configuration for Order Retrieval
MWS_ORDERS = new mws.Service
  name: "Orders"
  group: "Order Retrieval"
  path: "/Orders/2011-01-01"
  version: "2011-01-01"
  legacy: false

# Enumeration param definitions
enums = 
  # Order statuses with a little extra verification to help avoid errors
  OrderStatus: class extends mws.EnumList
    constructor: ->
      super('OrderStatus', 'Status', (k for k,v of types.OrderStatus))
    
    render: (obj={}) ->
      if @value.Unshipped isnt @value.PartiallyShipped
        throw "Unshipped & PartiallyShipped must both be enabled on the OrderStatus Param"
      super(obj)
        
  FulfillmentChannel: class extends mws.EnumList
    constructor: ->
      super('FulfillmentChannel', 'Channel', (k for k,v of types.FulfillmentChannel))
    
  PaymentMethod: class extends mws.EnumList
    constructor: ->
      super('PaymentMethod', 'Method', (k for k,v of types.PaymentMethod))

# Simple type definitions -- mostly helpful for providing hints through gui
types =
  ServiceStatus: mws.types.ServiceStatus

  FulfillmentChannel:
    AFN: "Amazon Fulfillment Network"
    MFN: "Merchant's Fulfillment Network"

  OrderStatus:
    Pending: "Order placed but payment not yet authorized. Not ready for shipment."
    Unshipped: "Payment has been authorized. Order ready for shipment, but no items shipped yet. Implies PartiallyShipped."
    PartiallyShipped: "One or more (but not all) items have been shipped. Implies Unshipped."
    Shipped: "All items in the order have been shipped."
    Canceled: "The order was canceled."
    Unfulfillable: "The order cannot be fulfilled. Applies only to Amazon-fulfilled orders not placed on Amazon."

  PaymentMethod:
    COD: "Cash on delivery"
    CVS: "Convenience store payment"
    Other: "Any payment method other than COD or CVS"

  ShipServiceLevelCategory:
    Expedited: "Expedited shipping"
    NextDay: "Overnight shipping"
    SecondDay: "Second-day shipping"
    Standard: "Standard shipping"

# Order Retrieval Request Classes
requests = 

  GetServiceStatus: class extends mws.Request
    constructor: (init) ->
      super MWS_ORDERS, 'GetServiceStatus', [], {}, null, init

  ListOrders: class extends mws.Request
    constructor: (init) ->
      super MWS_ORDERS, 'ListOrders', [
        new mws.Timestamp('CreatedAfter'),
        new mws.Timestamp('CreatedBefore'),
        new mws.Timestamp('LastUpdatedAfter'),
        new mws.Timestamp('LastUpdatedBefore'),
        new mws.ParamList('MarketplaceId', 'Id', true),
        new enums.OrderStatus(),
        new enums.FulfillmentChannel(),
        new enums.PaymentMethod(),
        new mws.Param('BuyerEmail'),
        new mws.Param('SellerOrderId'),
        new mws.Param('MaxResultsPerPage') 
      ], {}, null, init

  ListOrdersByNextToken: class extends mws.Request
    constructor: (init) ->
      super MWS_ORDERS, 'ListOrdersByNextToken', [
        new mws.Param('NextToken', true)
      ], {}, null, init

  GetOrder: class extends mws.Request
    constructor: (init) ->
      super MWS_ORDERS, 'GetOrder', [ 
        new mws.ParamList('AmazonOrderId', 'Id', true)
      ], {}, null, init 

  ListOrderItems: class extends mws.Request 
    constructor: (init) ->
      super MWS_ORDERS, 'ListOrderItems', [
        new mws.Param('AmazonOrderId', true)
        # new mws.ParamList('MarketplaceId', 'Id', true)
      ], {}, null, init

  ListOrderItemsByNextToken: class extends mws.Request
    constructor: (init) ->
      super MWS_ORDERS, 'ListOrderItemsByNextToken', [
        new mws.Param('NextToken', true)
      ], {}, null, init


# New client class providing more convenient access to service via camelCased
# versions of the request as methods.
class OrdersClient extends mws.Client

  # The standard mws GetServiceStatus request. Callback function should be of the form
  # (status, response) -> # ...
  getServiceStatus: (cb) ->
    @invoke new requests.GetServiceStatus(), {}, (res) =>
      status = res.result?.Status ? null
      cb status, res

  # List the orders matching a set of criteria. 
  # See the ListOrders request above for a complete list of 
  # properties available for filtering the results.
  listOrders: (options, cb) ->
    if options.CreatedAfter? or options.LastUpdatedAfter?
      options.MarketplaceId ?= @marketplaceIds ? @marketplaceId
      req = new requests.ListOrders options 
      @invoke req, { nextTokenCall: requests.ListOrdersByNextToken }, (res) =>
        orders = res.result?.Orders?.Order ? null
        cb orders, res
    else 
      throw 'Special Case: requires AT LEAST ONE OF either CreatedAfter or LastUpdatedAfter timestamps be used!'

  # If your query returned more than one page of results, you
  # should receive a token that can be used with this function
  # to query the next chunk of order data.
  listOrdersByNextToken: (token, cb) ->
    req = new requests.ListOrdersByNextToken(NextToken: token)
    @invoke req, { nextTokenCall: requests.ListOrdersByNextToken }, (res) =>
      orders = res.result?.Orders?.Order ? null
      cb orders, res

  # Accepts an array of orderIds or a single orderId
  getOrder: (orderId, cb) ->
    req = new requests.GetOrder(AmazonOrderId: orderId)
    @invoke req, {}, (res) =>
      orders = res.result?.Orders?.Order ? null
      cb orders, res

  # Lists the items ordered for a given order id
  listOrderItems: (orderId, cb) ->
    req = new requests.ListOrderItems(AmazonOrderId: orderId)
    @invoke req, { nextTokenCall: requests.ListOrderItemsByNextToken }, (res) =>
      items = res.result?.OrderItems?.OrderItem ? null
      cb items, res

  # Use to request next set of results from a previous query
  listOrderItemsByNextToken: (token, cb) ->
    req = new requests.ListOrderItemsByNextToken(NextToken: token)
    @invoke req, { nextTokenCall: requests.ListOrderItemsByNextToken }, (res) =>
      items = res.result?.OrderItems?.OrderItem ? null
      cb items, res

module.exports = 
  service: MWS_ORDERS
  enums: enums
  requests: requests
  Client: OrdersClient