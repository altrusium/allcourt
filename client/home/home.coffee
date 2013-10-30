Template.home.created = ->
  Session.set 'active-tournament', null
  
Template.home.isAdmin = ->
	return Meteor.user() && Meteor.user().profile.admin
	
