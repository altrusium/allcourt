Template.tournaments.created = ->
  Session.set 'active-tournament', null

Template.tournaments.isAdmin = ->
  Meteor.user().profile.admin

Template.tournaments.showMyTournaments = ->
  not Meteor.user().profile.admin

Template.tournaments.showActiveUserTournaments = ->
  not Meteor.user().profile.admin

Template.tournaments.showActiveAdminTournaments = ->
  Meteor.user().profile.admin

Template.tournaments.showPreviousUserTournaments = ->
  not Meteor.user().profile.admin

Template.tournaments.showPreviousAdminTournaments = ->
  Meteor.user().profile.admin
  
