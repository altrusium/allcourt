allcourt.getSortedTournaments = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    if date1 > date2 then return -1
    if date1 < date2 then return 1
    return 0
  return list

allcourt.getMyTournaments = ->
  results = []
  myId = Meteor.userId()
  myTournamentIds = Registrants.find({ 'userId': myId }, fields: 'tournamentId': 1).fetch()
  allcourt.getSortedTournaments().forEach (tournament) ->
    myTournamentIds.forEach (my) ->
      if my.tournamentId is tournament._id
        results.push tournament
  results

allcourt.getActiveTournaments = ->
  mine = allcourt.getMyTournaments()
  list = allcourt.getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())
  result = _.reject result, (tournament) ->
    _.find mine, (myT) ->
      myT._id is tournament._id

allcourt.getPreviousTournaments = ->
  list = allcourt.getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) < new Date())




Template.myTournamentList.myTournaments = ->
  allcourt.getMyTournaments()

Template.myTournamentList.linkHelper = ->
  tournamentSlug: this.slug

Template.activeUserTournamentList.activeTournaments = ->
  allcourt.getActiveTournaments()

Template.activeAdminTournamentList.activeTournaments = ->
  allcourt.getActiveTournaments()

Template.activeAdminTournamentList.linkHelper = ->
  tournamentSlug: this.slug

Template.previousUserTournamentList.previousTournaments = ->
  allcourt.getPreviousTournaments()

Template.previousAdminTournamentList.previousTournaments = ->
  allcourt.getPreviousTournaments()

