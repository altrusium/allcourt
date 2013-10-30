getSortedTournaments = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    if date1 > date2 then return -1
    if date1 < date2 then return 1
    return 0
  return list

getMyTournaments = ->
  results = []
  myId = Meteor.userId()
  myTournamentIds = Registrants.find({ 'userId': myId }, fields: 'tournamentId': 1).fetch()
  getSortedTournaments().forEach (tournament) ->
    myTournamentIds.forEach (my) ->
      if my.tournamentId is tournament._id
        results.push tournament
  results

getActiveTournaments = ->
  mine = getMyTournaments()
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())
  result = _.reject result, (tournament) ->
    _.find mine, (myT) ->
      myT._id is tournament._id

getPreviousTournaments = ->
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) < new Date())

isAdmin = ->
  Meteor.user().profile.admin

notAdmin = ->
  not Meteor.user().profile.admin




Template.tournaments.created = ->
  Session.set 'active-tournament', null

Template.tournaments.isAdmin = ->
  isAdmin()

Template.tournaments.notAdmin = ->
  notAdmin()

Template.tournaments.myTournaments = ->
  notAdmin() and getMyTournaments()

Template.tournaments.showActiveUserTournaments = ->
  notAdmin() and getActiveTournaments()

Template.tournaments.showActiveAdminTournaments = ->
  isAdmin() and getActiveTournaments()

Template.tournaments.activeTournaments = ->
  getActiveTournaments()

Template.tournaments.showPreviousUserTournaments = ->
  notAdmin() and getPreviousTournaments()

Template.tournaments.showPreviousAdminTournaments = ->
  isAdmin() and getPreviousTournaments()
  
Template.tournaments.previousTournaments = ->
  getPreviousTournaments()
