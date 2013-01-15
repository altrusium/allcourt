Template.tournamentVolunteerSignup.days = ->
	id = session.get('active-tournament').tournamentid
	tournament = tournaments.findone id, fields: days: 1
	days = tournament.days
	formatteddays = for day in days
		dayofweek: moment(day).format 'ddd'
		dayofmonth: moment(day).format 'do'

Template.tournamentVolunteerSignup.roles = ->
	id = Session.get('active-tournament').tournamentId
	getRoles id

Template.tournamentVolunteerSignup.rendered = ->
	$('#sortableRoles').sortable forcePlaceholderSize: true 
	$('#sortableRoles').disableSelection()