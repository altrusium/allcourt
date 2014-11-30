@services = @services or {}

services.tournamentService =

  getSortedTournaments: ->
    tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
    list = tournaments.fetch()
    list.sort (t1, t2) ->
      date1 = new Date(t1.days[0])
      date2 = new Date(t2.days[0])
      if date1 < date2 then return -1
      if date1 > date2 then return 1
      return 0
    return list

  userTournaments: (userId) ->
    results = []
    myTournamentIds = Registrants.find({ 'userId': userId },
      fields: 'tournamentId': 1).fetch()
    this.getSortedTournaments().forEach (tournament) ->
      myTournamentIds.forEach (my) ->
        if my.tournamentId is tournament._id
          results.push tournament
    results

  getMyTournaments: ->
    myId = Meteor.userId()
    this.userTournaments myId

  getActiveTournaments: ->
    mine = this.getMyTournaments()
    list = this.getSortedTournaments()
    active = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())
    result = _.reject active, (tournament) ->
      _.find mine, (myT) ->
        myT._id is tournament._id

  getActiveAdminTournaments: ->
    mine = this.getMyTournaments()
    list = this.getSortedTournaments()
    active = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())

  getPreviousTournaments: ->
    list = this.getSortedTournaments()
    result = (t for t in list when new Date(t.days[t.days.length-1]) < new Date())

