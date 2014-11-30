Template.myTournamentList.myTournaments = ->
  services.tournamentService.getMyTournaments()

Template.myTournamentList.linkHelper = ->
  tournamentSlug: this.slug
