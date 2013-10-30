isAdmin = ->
  Meteor.user().profile.admin




Template.tournamentDetails.activeTournamentSlug = ->
  return Session.get('active-tournament').slug

Template.tournamentDetails.isAdmin = ->
  isAdmin()

