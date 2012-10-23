# ----------------------------------------------------------
#  mws-js • products.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Description soon
# ----------------------------------------------------------

mws = require './core'

# MWS API Group configuration for Order Retrieval
MWS_PRODUCTS = new mws.Service
  name: "Products"
  group: "Products"
  path: "/Products/2011-10-01"
  version: "2011-10-01"
  legacy: false


# Enumeration param definitions
enums = 
  # Only the following item conditions are supported
  ItemCondition: class extends mws.Enum
    constructor: ->
      super('ItemCondition', ['New', 'Used', 'Collectible', 'Refurbished', 'Club'])

# Simple type definitions -- mostly helpful for providing hints through gui
types =
  ServiceStatus: mws.types.ServiceStatus

  MarketplaceId: 
    ATVPDKIKX0DER:  'amazon.com'
    A1F83G8C2ARO7P: 'amazon.co.uk'
    A13V1IB3VIYZZH: 'amazon.fr'
    A1PA6795UKMFR9: 'amazon.de'
    APJ6JRA9NG5V4:  'amazon.it'
    A1RKKUPIHCS9HS: 'amazon.es'

# Product Requests (translated, not tested)
requests = 

  # Requests the operational status of the Products API section.
  GetServiceStatus: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetServiceStatus', [], {}, null, init

  # Returns a list of products and their attributes, ordered by relevancy,
  # based on a search query that you specify
  ListMatchingProducts: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'ListMatchingProducts', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.Param('Query', true),
        new mws.Param('QueryContextId', false),
      ], {}, null, init

  # Returns a list of products and their attributes,
  # based on a list of ASIN values that you specify
  GetMatchingProduct: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetMatchingProduct', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.ParamList('ASINList','ASIN'),
      ], {}, null, init

  # Returns the current competitive pricing of a product,
  # based on the SellerSKU and MarketplaceId that you specify
  GetCompetitivePricingForSKU: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetCompetitivePricingForSKU', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.ParamList('SellerSKUList', 'SellerSKU', true),
      ], {}, null, init

  # Same as above, except that it uses a MarketplaceId and an ASIN to uniquely
  # identify a product, and it does not return the SKUIdentifier element
  GetCompetitivePricingForASIN: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetCompetitivePricingForASIN', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.ParamList('ASINList','ASIN'),
      ], {}, null, init

  # Returns the lowest price offer listings for a specific product by item condition.
  GetLowestOfferListingsForSKU: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetLowestOfferListingsForSKU', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.ParamList('SellerSKUList', 'SellerSKU', true),
        new enums.ItemCondition('ItemCondition'),
      ], {}, null, init

  # Same as above but by a list of ASIN's you provide
  GetLowestOfferListingsForASIN: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetLowestOfferListingsForASIN', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new enums.ItemCondition('ItemCondition'),
        new mws.ParamList('ASINList','ASIN'),
      ], {}, null, init
  
  # Returns the product categories that a product belongs to,
  # including parent categories back to the root for the marketplace
  GetProductCategoriesForSKU: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetProductCategoriesForSKU', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.Param('SellerSKU', true),
      ], {}, null, init

  # Same as above, except that it uses a MarketplaceId and an ASIN to
  # uniquely identify a product.
  GetProductCategoriesForASIN: class extends mws.Request
    constructor: (init) -> 
      super MWS_PRODUCTS, 'GetProductCategoriesForASIN', [
        new mws.ParamList('MarketplaceId', 'Id', true),
        new mws.Param('ASIN', true),
      ], {}, null, init


# The products client notably supports an optional number of marketplaceIds for every
# query (except service status of course), which will default to @marketplaceIds (non-standard)
# or @marketplaceID (standard) before eventually throwing an error for missing required field
# It's easiest to set when calling constructor, me thinks.
class ProductsClient extends mws.Client
  constructor: ->
    super
    @marketplaceIds = if @marketplaceId then [@marketplaceId] else []

  setMarketplaces: (@marketplaceIds...) ->

  getServiceStatus: (cb) ->
    @invoke new requests.GetServiceStatus(), {}, (res) =>
      status = res.result?.Status ? null
      cb status, res

  listMatchingProducts: (query, context, marketplaceIds..., cb) ->
    req = new requests.ListMatchingProducts
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      Query: query
      QueryContextId: context ? undefined
    @invoke req, {}, (res) =>
      cb res

  getMatchingProduct: (asins, marketplaceIds..., cb) ->
    req = new requests.GetMatchingProduct
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      ASINList: asins ? []
    @invoke req, {}, (res) =>
      cb res

  getCompetitivePricingForSKU: (skus, marketplaceIds..., cb) ->
    req = new requests.GetCompetitivePricingForSKU
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      SellerSKUList: skus ? []
    @invoke req, {}, (res) =>
      cb res

  getCompetitivePricingForASIN: (asins, marketplaceIds..., cb) ->
    req = new requests.GetCompetitivePricingForASIN
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      ASINList: asins ? []
    @invoke req, {}, (res) =>
      cb res

  getLowestOfferListingsForSKU: (skus, condition, marketplaceIds..., cb) ->
    req = new requests.GetLowestOfferListingsForSKU
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      SellerSKUList: skus ? []
      ItemCondition: condition ? undefined
    @invoke req, {}, (res) =>
      cb res

  getLowestOfferListingsForASIN: (asins, condition, marketplaceIds..., cb) ->
    req = new requests.GetLowestOfferListingsForASIN
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      ASINList: asins ? []
      ItemCondition: condition ? undefined
    @invoke req, {}, (res) =>
      cb res
  
  getProductCategoriesForSKU: (sku, marketplaceIds..., cb) ->
    req = new requests.GetProductCategoriesForSKU
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      SellerSKU: sku
    @invoke req, {}, (res) =>
      cb res

  getProductCategoriesForASIN: (asin, marketplaceIds..., cb) ->
    req = new requests.GetProductCategoriesForASIN
      MarketplaceId: marketplaceIds ? @marketplaceIds ? @marketplaceId
      ASIN: asin
    @invoke req, {}, (res) =>
      cb res

module.exports = 
  service: MWS_PRODUCTS
  enums: enums
  requests: requests
  Client: ProductsClient