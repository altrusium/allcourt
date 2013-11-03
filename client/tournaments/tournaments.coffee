Template.tournaments.created = ->
  Session.set 'active-tournament', null

Template.tournaments.isAdmin = ->
  allcourt.isAdmin()

Template.tournaments.showMyTournaments = ->
  not allcourt.isAdmin()

Template.tournaments.showActiveUserTournaments = ->
  not allcourt.isAdmin()

Template.tournaments.showActiveAdminTournaments = ->
  allcourt.isAdmin()

Template.tournaments.showPreviousUserTournaments = ->
  not allcourt.isAdmin()

Template.tournaments.showPreviousAdminTournaments = ->
  allcourt.isAdmin()
  
