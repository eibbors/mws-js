 /**
 * Fulfillment API requests and definitions for Amazon's MWS web services.
 * Currently untested, for the most part because I don't have an account
 * with Fulfillment By Amazon services.
 * 
 * @author Robert Saunders
 */
var mws = require('./mws');

/**
 * Construct a mws fulfillment api request for mws.Client.invoke()
 * @param {String} group  Group name (category) of request
 * @param {String} path   Path of associated group
 * @param {String} action Action request will be calling
 * @param {Object} params Schema of possible request parameters
 */
function FulfillmentRequest(group, path, action, params) {
    var opts = {
        name: 'Fulfillment',
        group: group,
        path: path,
        version: '2010-10-01',
        legacy: false,
        action: action,
        params: params
    };
    return new mws.Request(opts);
}

function FbaInboundRequest(action, params) {
    return FulfillmentRequest('Inbound Shipments', '/FulfillmentInboundShipment/2010-10-01', action, params);
}

function FbaInventoryRequest(action, params) {
    return FulfillmentRequest('Inventory', '/FulfillmentInventory/2010-10-01', action, params);
}

function FbaOutboundRequest(action, params) {
    return FulfillmentRequest('Outbound Shipments', '/FulfillmentOutboundShipment/2010-10-01', action, params);
}

/**
 * Initialize and create an add function for ComplexList parameters. You can create your
 * own custom complex parameters by making an object with an appendTo function that takes
 * an object as input and directly sets all of the associated values manually. 
 * 
 * @type {Object}
 */
var complex = exports.complex = {

    /**
     * Complex List used for CreateInboundShipment & UpdateInboundShipment requests
     */
    InboundShipmentItems: function() {
        var obj = new mws.ComplexList('InboundShipmentItems.member');
        obj.add = function(quantityShipped, sellerSku) {
            obj.members.push({'QuantityShipped': quantityShipped, 'SellerSKU': sellerSku});
            return obj;
        };
        return obj;
    },
    
    /**
     * Complex List used for CreateInboundShipmentPlan request
     */
    InboundShipmentPlanRequestItems: function() {
        var obj = new mws.ComplexList('InboundShipmentPlanRequestItems.member');
        obj.add = function(sellerSku, asin, quantity, condition) {
            obj.members.push({'SellerSKU': sellerSku, 'ASIN': asin, 'Quantity': quantity, 'Condition': condition});
            return obj;
        };
        return obj;
    },

    /**
     * The mac-daddy of ComplexListTypes... Used for CreateFulfillmentOrder request
     */
    CreateLineItems: function() {
        var obj = new mws.ComplexList('Items.member');
        obj.add = function(comment, giftMessage, decUnitValue, decValueCurrency, quantity, orderItemId, sellerSku) {
            obj.members.push({
                'DisplayableComment': comment, 
                'GiftMessage': giftMessage, 
                'PerUnitDeclaredValue.Value': decUnitValue,
                'PerUnitDeclaredValue.CurrencyCode': decValueCurrency, 
                'Quantity': quantity, 
                'SellerFulfillmentOrderItemId': orderItemId,
                'SellerSKU': sellerSku
            });
            return obj;
        };
        return obj;
    },

    /**
     * The step child of above, used for GetFulfillmentPreview
     */
    PreviewLineItems: function() {
        var obj = new mws.ComplexList('Items.member');
        obj.add = function(quantity, orderItemId, sellerSku, estShipWeight, weightCalcMethod) {
            obj.members.push({
                'Quantity': quantity, 
                'SellerFulfillmentOrderItemId': orderItemId,
                'SellerSKU': sellerSku,
                'EstimatedShippingWeight': estShipWeight,
                'ShippingWeightCalculationMethod': weightCalcMethod
            });
            return obj;
        };
        return obj;
    }

};

/**
 * Ojects to represent enum collections used by some request(s)
 * @type {Object}
 */
var enums = exports.enums = {

    ResponseGroups:  function() { 
        return new mws.Enum(['Basic', 'Detailed']); 
    },

    ShippingSpeedCategories:  function() { 
        return new mws.Enum(['Standard', 'Expedited', 'Priority']);
    },

    FulfillmentPolicies:  function() { 
        return new mws.Enum(['FillOrKill', 'FillAll', 'FillAllAvailable']);
    }

};

/**
 * A collection of currently supported request constructors. Once created and 
 * configured, the returned requests can be passed to an mws client `invoke` call
 * @type {Object}
 */
var calls = exports.requests = {

    // Inbound Shipments
    inbound: {

        GetServiceStatus: function() {
            return new FbaInboundRequest('GetServiceStatus', {});
        },                
        
        CreateInboundShipment: function() {
            return new FbaInboundRequest('CreateInboundShipment', {             
                ShipmentId: { name: 'ShipmentId', required: true}, 
                Shipmentname: { name: 'InboundShipmentHeader.ShipmentName', required: true },
                ShipFromName: { name: 'InboundShipmentHeader.ShipFromAddress.Name', required: true },
                ShipFromAddressLine1: { name: 'InboundShipmentHeader.ShipFromAddress.AddressLine1', required: true },
                ShipFromAddressLine2: { name: 'InboundShipmentHeader.ShipFromAddress.AddressLine2', required: false },
                ShipFromAddressCity: { name: 'InboundShipmentHeader.ShipFromAddress.City', required: true },
                ShipFromDistrictOrCounty: { name: 'InboundShipmentHeader.ShipFromAddress.DistrictOrCounty', required: false },
                ShipFromStateOrProvince: { name: 'InboundShipmentHeader.ShipFromAddress.StateOrProvinceCode', required: true },
                ShipFromPostalCode: { name: 'InboundShipmentHeader.ShipFromAddress.PostalCode', required: true },
                ShipFromCountryCode: { name: 'InboundShipmentHeader.ShipFromAddress.CountryCode', required: true },
                DestinationFulfillmentCenterId: { name: 'InboundShipmentHeader.DestinationFulfillmentCenterId', required: true },
                ShipmentStatus: { name: 'InboundShipmentHeader.ShipmentStatus' },
                LabelPrepPreference: { name: 'InboundShipmentHeader.LabelPrepPreference' },
                InboundShipmentItems: { name: 'InboundShipmentItems', type: 'Complex', required: true, construct: complex.InboundShipmentItems }
            });
        },

        CreateInboundShipmentPlan: function() {
            return new FbaInboundRequest('CreateInboundShipmentPlan', {
                LabelPrepPreference: { name: 'LabelPrepPreference', required: true },
                ShipFromName: { name: 'ShipFromAddress.Name' },
                ShipFromAddressLine1: { name: 'ShipFromAddress.AddressLine1' },
                ShipFromCity: { name: 'ShipFromAddress.City' },
                ShipFromStateOrProvince: { name: 'ShipFromAddress.StateOrProvinceCode' },
                ShipFromPostalCode: { name: 'ShipFromAddress.PostalCode' },
                ShipFromCountryCode: { name: 'ShipFromAddress.CountryCode' },
                ShipFromAddressLine2: { name: 'ShipFromAddress.AddressLine2' },
                ShipFromDistrictOrCounty: { name: 'ShipFromAddress.DistrictOrCounty' },
                InboundShipmentPlanRequestItems: { name: 'InboundShipmentPlanRequestItems', type: 'Complex', required: true, construct: complex.InboundShipmentPlanRequestItems }
            });
        },

        ListInboundShipmentItems: function() {
            return new FbaInboundRequest('ListInboundShipmentItems', {
                ShipmentId: { name: 'ShipmentId', required: true },
                LastUpdatedAfter: { name: 'LastUpdatedAfter', type: 'Timestamp' },
                LastUpdatedAfter: { name: 'LastUpdatedBefore', type: 'Timestamp' }
            });
        },

        ListInboundShipmentItemsByNextToken: function() {
            return new FbaInboundRequest('ListInboundShipmentItemsByNextToken', {
                NextToken: { name: 'NextToken', required: true }
            });
        },

        ListInboundShipments: function() {
            return new FbaInboundRequest('ListInboundShipments', {
                ShipmentStatuses: { name: 'ShipmentStatusList.member', list: true, required: false },
                ShipmentIds: { name: 'ShipmentIdList.member', list: true, required: false },
                LastUpdatedAfter: { name: 'LastUpdatedAfter', type: 'Timestamp' },
                LastUpdatedBefore: { name: 'LastUpdatedBefore', type: 'Timestamp' }
            });
        },

        ListInboundShipmentsByNextToken: function() {
            return new FbaInboundRequest('ListInboundShipmentsByNextToken', { 
                NextToken: { name: 'NextToken', required: true }
            });
        },

        UpdateInboundShipment: function() {
            return new FbaInboundRequest('UpdateInboundShipment', {
                ShipmentId: { name: 'ShipmentId', required: true },
                ShipmentName: { name: 'InboundShipmentHeader.ShipmentName', required: true },
                ShipFromName: { name: 'InboundShipmentHeader.ShipFromAddress.Name', required: true },
                ShipFromAddressLine1: { name: 'InboundShipmentHeader.ShipFromAddress.AddressLine1', required: true },
                ShipFromAddressLine2: { name: 'InboundShipmentHeader.ShipFromAddress.AddressLine2', required: false },
                ShipFromAddressCity: { name: 'InboundShipmentHeader.ShipFromAddress.City', required: true },
                ShipFromDistrictOrCounty: { name: 'InboundShipmentHeader.ShipFromAddress.DistrictOrCounty', required: false },
                ShipFromStateOrProvince: { name: 'InboundShipmentHeader.ShipFromAddress.StateOrProvinceCode', required: true },
                ShipFromPostalCode: { name: 'InboundShipmentHeader.ShipFromAddress.PostalCode', required: true },
                ShipFromCountryCode: { name: 'InboundShipmentHeader.ShipFromAddress.CountryCode', required: true },
                DestinationFulfillmentCenterId: { name: 'InboundShipmentHeader.DestinationFulfillmentCenterId', required: true },
                ShipmentStatus: { name: 'InboundShipmentHeader.ShipmentStatus' },
                LabelPrepPreference: { name: 'InboundShipmentHeader.LabelPrepPreference' },
                InboundShipmentItems: { name: 'InboundShipmentItems', type: 'Complex', required: true, construct: complex.InboundShipmentItems }
            });
        }

    },

    // Inventory
    inventory: {
        
        GetServiceStatus: function() {
            return new FbaInventoryRequest('GetServiceStatus', {});
        },

        ListInventorySupply: function() {
            return new FbaInventoryRequest('ListInventorySupply', {                 
                SellerSkus: { name: 'SellerSkus.member', list: true },
                QueryStartDateTime: { name: 'QueryStartDateTime', type: 'Timestamp' },
                ResponseGroup: { name: 'ResponseGroup' }
            });
        },
        
        ListInventorySupplyByNextToken: function() {
            return new FbaInventoryRequest('ListInventorySupplyByNextToken', {
                NextToken: { name: 'NextToken', required: true }
            });
        }

    },

    // Outbound Shipments
    outbound: {

        GetServiceStatus: function() {
            return new FbaOutboundRequest('GetServiceStatus', {});
        },

        CancelFulfillmentOrder: function() {
            return new FbaOutboundRequest('CancelFulfillmentOrder', {
                SellerFulfillmentOrderId: { name: 'SellerFulfillmentOrderId', required: true }
            });
        },

        CreateFulfillmentOrder: function() {
            return new FbaOutboundRequest('CreateFulfillmentOrder', {
                SellerFulfillmentOrderId: { name: 'SellerFulfillmentOrderId', required: true },
                ShippingSpeedCategory: { name: 'ShippingSpeedCategory', required: true, type: 'fba.ShippingSpeedCategory' },
                DisplayableOrderId: { name: 'DisplayableOrder.DisplayableOrderId', required: true },
                DisplayableOrderDateTime: { name: 'DisplayableOrder.DisplayableOrderDateTime', type: 'Timestamp' },
                DisplayableOrderComment: { name: 'DisplayableOrder.DisplayableOrderComment' },
                FulfillmentPolicy: { name: 'FulfillmentPolicy', required: false, type: 'fba.FulfillmentPolicy' },
                FulfillmentMethod: { name: 'FulfillmentMethod', required: false },
                NotificationEmails: { name: 'NotificationEmailList.member', required: false, list: true },
                DestName: { name: 'DestinationAddress.Name' },
                DestAddressLine1: { name: 'DestinationAddress.Line1' },
                DestAddressLine2: { name: 'DestinationAddress.Line2' },
                DestAddressLine3: { name: 'DestinationAddress.Line3' },
                DestCity: { name: 'DestinationAddress.City' },
                DestStateOrProvince: { name: 'DestinationAddress.StateOrProvinceCode' },
                DestPostalCode: { name: 'DestinationAddress.PostalCode' },
                DestCountryCode: { name: 'DestinationAddress.CountryCode' },
                DestDistrictOrCounty: { name: 'DestinationAddress.DistrictOrCounty' },
                DestPhoneNumber: { name: 'DestinationAddress.PhoneNumber' },
                LineItems: { name: 'LineItems', type: 'Complex', required: true, construct: complex.CreateLineItems }
            });
        },

        GetFulfillmentOrder: function() {
            return new FbaOutboundRequest('GetFulfillmentOrder', {
                SellerFulfillmentOrderId: { name: 'SellerFulfillmentOrderId', required: true }
            });
        },

        GetFulfillmentPreview: function() {
            return new FbaOutboundRequest('GetFulfillmentPreview', {
                ToName: { name: 'Address.Name' },
                ToAddressLine1: { name: 'Address.Line1' },
                ToAddressLine2: { name: 'Address.Line2' },
                ToAddressLine3: { name: 'Address.Line3' },
                ToCity: { name: 'Address.City' },
                ToStateOrProvince: { name: 'Address.StateOrProvinceCode' },
                ToPostalCode: { name: 'Address.PostalCode' },
                ToCountry: { name: 'Address.CountryCode' },
                ToDistrictOrCounty: { name: 'Address.DistrictOrCounty' },
                ToPhoneNumber: { name: 'Address.PhoneNumber' },
                LineItems: { name: 'LineItems', type: 'Complex', required: true, construct: complex.PreviewLineItems },
                ShippingSpeeds: { name: 'ShippingSpeedCategories.member', list: true, type: 'fba.ShippingSpeedCategory' }
             });
        },

        ListAllFulfillmentOrders: function() {
            return new FbaOutboundRequest('ListAllFulfillmentOrders', {
                QueryStartDateTime: { name: 'QueryStartDateTime', required: true, type: 'Timestamp' },
                FulfillentMethods: { name: 'FulfillmentMethod.member', list: true } 
            });
        },

        ListAllFulfillmentOrdersByNextToken: function() {
            return new FbaOutboundRequest('ListAllFulfillmentOrdersByNextToken', {
                NextToken: { name: 'NextToken', required: true }
            });
        }

    }

};
