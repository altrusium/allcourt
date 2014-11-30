Template.activeAdminTournamentList.activeTournaments = ->
  services.tournamentService.getAllActiveTournaments()

Template.activeAdminTournamentList.linkHelper = ->
  tournamentSlug: this.slug
