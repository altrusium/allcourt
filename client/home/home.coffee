Template.home.role = ->
	return Meteor.user() && Meteor.user().type