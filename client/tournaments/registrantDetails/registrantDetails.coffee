getActiveRegistration = ->
  tournamentId = Session.get('active-tournament')._id
  userId = Session.get('active-user')._id
  registration = Registrants.findOne tournamentId: tournamentId, userId: userId

getTeamName = (teamId) ->
  for team in Session.get('active-tournament').teams
    if team.teamId is teamId
      return team.teamName

Template.registrantDetails.fullName = ->
  Session.get('active-user').profile.fullName

Template.registrantDetails.photoFilename = ->
  allcourt.photoRoot + Session.get('active-user').profile.photoFilename

Template.registrantDetails.function = ->
  registration = getActiveRegistration()
  registration.function || getTeamName registration.teams[0]

Template.registrantDetails.accessCode = ->
  registration = getActiveRegistration()
  registration.accessCode

Template.registrantDetails.events =
  'click [data-save]': (evnt, template) ->
    options = {
      'userId': Session.get('active-user')._id
      'tournamentId': Session.get('active-tournament')._id
      'function': $('#function').val()
      'accessCode': $('#accessCode').val()
    }
    Meteor.call 'updateRegistrant', options, (err) ->
      if err
        Template.userMessages.showMessage
          type: 'error'
          title: 'Uh oh! '
          message: 'The registrants information was not updated successfully.
            Please try again.'
      else
        # show success message
        Template.userMessages.showMessage
          type: 'info'
          title: 'Success. '
          message: 'The registrants information was updated successfully.'
        Router.go 'userDetails',
          userSlug: Session.get('active-user').profile.slug
    false