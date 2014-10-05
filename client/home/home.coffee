Template.home.created = ->
  Session.set 'active-tournament', null

Template.home.isAdmin = ->
  allcourt.isAdmin()

