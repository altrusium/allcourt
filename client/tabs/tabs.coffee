Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected-tab', tabName 

Template.tabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.newUserTabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.userMenu.usersname = ->
	user = Meteor.user().profile
	return user.firstName + ' ' + user.lastName

Template.userMenu.events
	'click #signOut': (evnt, temlate) ->
		Meteor.logout()
		false