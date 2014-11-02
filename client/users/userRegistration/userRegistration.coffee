createEmailAddress = ->
  firstName = $('#firstName').val()
  lastName = $('#lastName').val()
  name = emailHelper.prepareName firstName, lastName
  address = name + emailHelper.addressSuffix

sendUserSearchQuery = (query) ->
  # submitUserSearch is global and defined in app/lib/streams.coffee
  submitUserSearch query, (results) ->
    for user in results
      user.isMale = user.gender is 'male'
      for reg in user.registrations
        reg.slug = user.slug
    Session.set 'search-results', results

emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

setActiveUser = (id) ->
  Session.set 'active-user', Meteor.users.findOne id

setActiveRegistration = (id) ->
  registration = Registrants.findOne id
  Session.set 'active-registration', registration

getUserFormValues = (template) ->
  values =
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value
    function: template.find('#function').value

updateRegistration = (userDetails) ->
  teamId = Session.get('active-team').teamId
  registrantId = Session.get('active-registration')._id
  userDetails.userId = userDetails._id
  userDetails.tournamentId = Session.get('active-tournament')._id
  try
    Meteor.call 'updateRegistrant', userDetails
    Meteor.call 'addTeamToRegistrant', registrantId, teamId
    setActiveUser userDetails._id
    setActiveRegistration registrantId
    Template.userMessages.showMessage
      type: 'info'
      title: 'Success:'
      message: 'User has been successfully registered.'
  catch err
    Template.userMessages.showMessage
      type: 'error'
      title: 'Registration Failed:'
      message: 'An error has occurred. Reason: ' + err.reason

associateUserWithTournament = (userDetails) ->
  details =
    userId: userDetails._id
    addedBy: Meteor.userId()
    function: userDetails.function
    teams: [Session.get('active-team').teamId]
    tournamentId: Session.get('active-tournament')._id
  Meteor.call 'addRegistrant', details, (err, id) ->
    unless err
      Template.userMessages.showMessage
        type: 'info'
        title: 'Success:'
        message: 'User has been successfully registered.'
      setActiveUser userDetails._id
      setActiveRegistration id
    else
      Template.userMessages.showMessage
        type: 'error'
        title: 'Sign-up Failed:'
        message: 'An error occurred while registering user. Please refresh
          the browser and let us know if this continues.'

addNewRegistrant = (template) ->
  userDetails = getUserFormValues template
  userDetails.email = createEmailAddress()
  userDetails.isNew = false
  Meteor.call 'createNewUser', userDetails, (err, id) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The new registrant was not saved successfully. Reason: ' +
          err.reason
    else
      userDetails._id = id
      associateUserWithTournament userDetails

updateActiveRegistrant = (user, template) ->
  userDetails = getUserFormValues template
  userDetails._id = user._id
  userDetails.email = user.profile.email
  userDetails.isNew = user.profile.isNew
  Meteor.call 'updateUser', userDetails, (err) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The user information was not updated. Reason: ' + err.reason
    else
      updateRegistration userDetails




Template.userRegistration.created = ->
  Session.set 'active-tab', 'registered'

Template.userRegistration.rendered = ->
  if Session.get('active-user')?.profile.photoFilename
    $('.photo-placeholder').removeClass 'empty'

Template.userRegistration.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.userRegistration.photoRoot = ->
  return photoHelper.photoRoot

Template.userRegistration.registeredTabIsActive = ->
  if Session.get('active-tab') is 'registered' then return 'active'

Template.userRegistration.notRegisteredTabIsActive = ->
  if Session.get('active-tab') is 'notRegistered' then return 'active'

Template.userRegistration.addEditTabIsActive = ->
  if Session.get('active-tab') is 'addEdit' then return 'active'

Template.userRegistration.users = ->
  Session.get 'search-results'

Template.userRegistration.tournamentName = ->
  return 'Temporary Tournament Name'

Template.userRegistration.roleName = ->
  return 'Temporary Role Name'

Template.userRegistration.teamName = ->
  return 'Temporary Team Name'

Template.userRegistration.registrationDetails = ->
  unless Session.get('active-user') then return {}
  user = Session.get('active-user').profile
  registration = Session.get('active-registration')
  unless (user and registration) then return {}
  user.isMale = user.gender is 'male'
  user.isFemale = user.gender isnt 'male'
  user.function = registration.function
  if user.photoFilename
    user.photoPath = photoHelper.photoRoot + user.photoFilename
  user

Template.userRegistration.userSlug = ->
  Session.get('active-user')?.profile?.slug

Template.userRegistration.tournamentSlug = ->
  Session.get('active-tournament')?.slug



Template.userRegistration.events =

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    if query
      sendUserSearchQuery query
      Session.set 'active-team', null
      Session.set 'active-role', null
      Session.set 'active-tournament', null
    else
      emptySearchResults()
    false

  'click [data-details-link]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    setActiveUser anchor.data 'user-id'
    setActiveRegistration anchor.data 'registrant-id'
    registration = Session.get 'active-registration'
    setActiveTournament registration.tournamentId

    team = (team for team in Session.get('active-tournament').teams \
      when team.teamId is registration.teams[0])[0]
    Session.set 'active-role', roleId: team?.roleId
    Session.set 'active-team', team
    Session.set 'active-tab', 'addEdit'
    emptySearchResults()
    false

  'click .registered-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'registered'

  'click .not-registered-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'notRegistered'

  'click .add-edit-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'addEdit'

  'submit .navbar-search': (evnt, template) ->
    false

  'click #saveRegistrant': (evnt, template) ->
    user = Session.get 'active-user'
    if user
      updateActiveRegistrant user, template
    else
      addNewRegistrant template

  'click #pickPhoto': (evnt, template) ->
    photoHelper.processPhoto()

  'change #femaleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('male').addClass('female')

  'change #maleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('female').addClass('male')

