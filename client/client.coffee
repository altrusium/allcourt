Meteor.subscribe 'volunteers'
Meteor.subscribe 'tournaments'

Meteor.Router.add
  '/': 'home',
  '/volunteers': 'volunteers',
  '/volunteers/create': 'volunteersCreate',
  '/volunteers/list': 'volunteersList',
  '/shifts': 'shifts',
  '/setup': 'setup',
  '/setup/tournament': 'setupTournament',
  '/setup/roles': 'setupRoles',
  '/setup/shifts': 'setupShifts'

Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected_tab', tabName 

tabIsSelected = (tab) ->
  return tab is Session.get 'selected_tab'

# The Tabs Template
Template.tabs.tabSelected = (tab) ->
  return if tabIsSelected tab then 'active' else ''


