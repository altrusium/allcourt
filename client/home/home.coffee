Template.home.role = ->
	return Meteor.user() && Meteor.user().profile.role

Template.home.isAdmin = ->
	return Meteor.user() && Meteor.user().profile.role is 'admin'
	
