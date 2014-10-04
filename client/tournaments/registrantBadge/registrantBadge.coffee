getActiveRegistration = ->
  tournamentId = Session.get('active-tournament')._id
  userId = Session.get('active-user')._id
  registration = Registrants.findOne tournamentId: tournamentId, userId: userId

getTeamName = (teamId) ->
  for team in Session.get('active-tournament').teams
    if team.teamId is teamId
      return team.teamName

Template.registrantBadge.isASB = ->
  Session.get('active-tournament').tournamentName.indexOf('ASB') >= 0

Template.registrantBadge.isMale = ->
  Session.get('active-user').profile.gender is 'male'

Template.registrantBadge.photoFilename = ->
  photo = Session.get('active-user').profile.photoFilename
  if photo
    return allcourt.photoRoot
  else
    return ''

Template.registrantBadge.fullName = ->
  Session.get('active-user').profile.fullName

Template.registrantBadge.function = ->
  registration = getActiveRegistration()
  registration.function || getTeamName registration.teams[0]

Template.registrantBadge.accessCode = ->
  registration = getActiveRegistration()
  registration.accessCode

