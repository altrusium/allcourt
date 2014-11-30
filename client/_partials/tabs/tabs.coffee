Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected-tab', tabName

Template.tabs.isAdmin = ->
  allcourt.isAdmin()

Template.adminTabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.userTabs.tabSelected = (tab) ->
  return if tab is Session.get 'selected-tab' then 'active' else ''

Template.userMenu.usersname = ->
  return Meteor.user().profile.fullName

Template.userMenu.events
  'click #signOut': (evnt, temlate) ->
    Meteor.logout ->
      Session.set 'active-tournament', null
      Router.go 'home'
    false
