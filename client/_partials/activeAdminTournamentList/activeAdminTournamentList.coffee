Template.activeAdminTournamentList.activeTournaments = ->
  services.tournamentService.getActiveAdminTournaments()

Template.activeAdminTournamentList.linkHelper = ->
  tournamentSlug: this.slug
