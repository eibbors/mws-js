fba = require '../src/fba'
core = require '../src/core'
# { locales } = require '../src/core'
{ loginInfo, dump, print } = require './cfg'

# client = new fba.inbound.Client(loginInfo)
# p = 
#   id: new core.Param('DisplayableOrderId', true) 
#   dateTime: new core.Timestamp('DisplayableOrderDateTime', false)
#   comment: new core.Param('DisplayableOrderComment', false) 

# cx = new core.ComplexParam('DisplayableOrder',p, true)
dor = new fba.complex.DisplayableOrder( undefined, true, { id: '15555afafaf5555', comment: 'test comment' })
dump dor.get('ASD')
dump dor.render()
# address = fba.complex
# console.log  fba.complex.DisplayableOrder

# dorder = new fba.complex.DisplayableOrder()
# print 'address', address

# # Simple service status check
# client.getServiceStatus (status, res) =>
# 	print "Products service status", status
# 	# Quick verification of optimum service status
# 	unless status in ['GREEN', 'GREEN_I']
# 		throw 'Products service is having issues, aborting...'
		
# 	# client.listMarketplaceParticipations (goodies, res) =>
# 	# 		print "The good stuff", goodies
# 	# 		dump res  