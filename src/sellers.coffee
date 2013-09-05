# ----------------------------------------------------------
#  mws-js • sellers.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Dead simple merchant (seller) query module. Lists marketplaces
# and participations per your account. Das ist all at the moment
# ----------------------------------------------------------

mws = require './core'

# MWS API Group configuration for Order Retrieval
MWS_SELLERS = new mws.Service
  name: "Sellers"
  group: "Sellers Retrieval"
  path: "/Sellers/2011-07-01"
  version: "2011-07-01"
  legacy: false

# Simple types
types =
  ServiceStatus: mws.types.ServiceStatus

requests =

  GetServiceStatus: class extends mws.Request
    constructor: (init) ->
      super MWS_SELLERS, 'GetServiceStatus', [], {}, null, init

  ListMarketplaceParticipations: class extends mws.Request
    constructor: (init) ->
      super MWS_SELLERS, 'ListMarketplaceParticipations', [], {}, null, init 

  ListMarketplaceParticipationsByNextToken: class extends mws.Request
    constructor: (init) ->
      super MWS_SELLERS, 'ListMarketplaceParticipationsByNextToken', [new mws.Param('NextToken', true)], {}, null, init

# Sellers API Client
class SellersClient extends mws.Client

  # The standard mws GetServiceStatus request. Callback function should be of the form
  # (status, response) -> # ...
  getServiceStatus: (cb) ->
    @invoke new requests.GetServiceStatus(), {}, (res) =>
      status = res.result?.Status ? null
      cb status, res

  listMarketplaceParticipations: (cb) ->
    opt = { nextTokenCall: requests.ListMarketplaceParticipationsByNextToken }
    req = new requests.ListMarketplaceParticipations()
    @invoke req, opt, (res) =>
      markets = res?.ListMarketplaces?.Marketplace ? null
      partips = res?.ListParticipations?.Participation ? null
      cb {marketplaces: markets, participations: partips }, res

  listMarketplaceParticipationsByNextToken: (token, cb) ->
    opt = { nextTokenCall: requests.ListMarketplaceParticipationsByNextToken }
    req = new requests.ListMarketplaceParticipationsByNextToken(NextToken: token)
    @invoke req, opt, (res) =>
      markets = res?.ListMarketplaces?.Marketplace ? null
      partips = res?.ListParticipations?.Participation ? null
      cb {marketplaces: markets, participations: partips }, res

module.exports = 
  service: MWS_SELLERS
  types: types
  requests: requests
  Client: SellersClient