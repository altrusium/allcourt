Template.userSchedule.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.userSchedule.linkHelper = ->
  allcourt.getTournamentLinkHelper()

