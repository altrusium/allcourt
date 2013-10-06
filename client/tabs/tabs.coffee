Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected-tab', tabName 

Template.tabs.role = ->
	return Meteor.user() && Meteor.user().profile.type

Template.tabs.isAdmin = ->
	return Meteor.user() && Meteor.user().profile.type is 'admin'
	
Template.adminTabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.newUserTabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.userRegisteredTabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.userMenu.usersname = ->
	user = Meteor.user().profile
	return user.fullName

Template.userMenu.events
	'click #signOut': (evnt, temlate) ->
		Meteor.logout ->
	    Meteor.Router.to '/'
	'click #goToProfile': (evnt, temlate) ->
	  Meteor.Router.to '/profile'
		false