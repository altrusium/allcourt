Template.myTournamentList.myTournaments = ->
  tournamentService.getMyTournaments()

Template.myTournamentList.linkHelper = ->
  tournamentSlug: this.slug
