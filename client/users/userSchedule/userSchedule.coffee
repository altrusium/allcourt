Template.userSchedule.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.userSchedule.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.userSchedule.isTeamLead = ->
  tId = Session.get('active-tournament')._id
  uId = Meteor.userId()
  reg = Registrants.findOne tournamentId: tId, userId: uId
  reg.isTeamLead

