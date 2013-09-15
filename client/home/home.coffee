Template.home.role = ->
	return Meteor.user() && Meteor.user().profile.type

Template.home.isAdmin = ->
	return Meteor.user() && Meteor.user().profile.type is 'admin'
	
