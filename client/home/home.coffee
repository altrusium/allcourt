Template.home.isAdmin = ->
	return Meteor.user() && Meteor.user().profile.admin
	
