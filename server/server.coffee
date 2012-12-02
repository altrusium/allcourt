Meteor.publish 'volunteers', ->
	return Volunteers.find()
	
Meteor.publish 'tournaments', ->
	return Tournaments.find()