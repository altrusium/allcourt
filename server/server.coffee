Meteor.publish 'volunteers', ->
	return Volunteers.find()