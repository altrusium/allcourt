# Globals
profileForm = null
volunteerForm = null

initializeControls = ->
  $('#birthdate').datepicker format: 'dd M yyyy', autoclose: true

getUserFormValues = (template) ->
  return values =
    _id: Meteor.userId()
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    email: template.find('#email').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value
    isNew: Meteor.user().profile.isNew
    admin: allcourt.isAdmin()

getVolunteerFormValues = (template) ->
  return values =
    _id: Meteor.userId()
    shirtSize: template.find('#shirtSize').value
    birthdate: template.find('#birthdate').value
    homePhone: template.find('#homePhone').value
    mobilePhone: template.find('#mobilePhone').value
    address: template.find('#address').value
    suburb: template.find('#suburb').value
    city: template.find('#city').value
    postalCode: template.find('#postalCode').value
    tennisClub: template.find('#tennisClub').value

showSuccess = (msg) ->
  Template.userMessages.showMessage
    type: 'info',
    title: 'Success!',
    message: msg

showError = (msg, err) ->
  Template.userMessages.showMessage
    type: 'error',
    title: 'Uh oh!',
    message: msg + ' Reason: ' + err.reason

showResultOfProfileUpdate = (err) ->
  if err
    showError 'Your profile details were not saved.', err
  else
    showSuccess 'Your profile details were saved successfully.'




Template.profileDetails.details = ->
  user = Meteor.user()
  details = user.profile || {}
  if details.photoFilename
    details.photoFile = allcourt.photoRoot + details.photoFilename
  details.isMale = details.gender is 'male'
  details.isFemale = details.gender isnt 'male'
  return details || {}

Template.profileDetails.availableTournamentsExist = ->
  tournaments = Template.profileDetails.availableTournaments()
  # return tournaments.length > 0
  return false

Template.profileDetails.availableTournaments = ->
  tournaments = Tournaments.find({}, fields: {tournamentName:1, days:1}).fetch()
  futureTournaments = for tournament in tournaments
    tournamentStartDate = new Date tournament.days[0]
    tournament if new Date() - tournamentStartDate < 0

Template.profileDetails.myTournamentsExist = ->
  return false

Template.profileDetails.myTournaments = ->
  return []

Template.profileDetails.events =
  'click #editProfile': (evnt, template) ->
    Router.go 'profileEdit'



Template.profileEdit.rendered = ->
  initializeControls()
  profileForm = $('#profileForm').parsley trigger: 'change'
  volunteerForm = $('#volunteerForm').parsley trigger: 'change'
  $('#birthdate').datepicker format: 'dd M yyyy'
  $('#birthdateIcon').click ->
    $('#birthdate').datepicker 'show'
  if Meteor.user().profile.photoFile
    $('.photo-placeholder').removeClass 'empty'

Template.profileEdit.details = ->
  user = Meteor.user()
  details = user.profile || {}
  details.isMale = details.gender is 'male'
  details.isFemale = details.gender is 'female'
  if details.photoFilename
    details.photoFile = allcourt.photoRoot + details.photoFilename
  return details

Template.profileEdit.isSelected = (value, constant) ->
  value == constant

Template.profileEdit.volunteerDetails = ->
  return Volunteers.findOne Meteor.userId()

Template.profileEdit.photoFilename = ->
  return Meteor.user().profile.photoFilename

Template.profileEdit.events
  'click #saveProfile': (event, template) ->
    userOptions = getUserFormValues template
    unless profileForm and profileForm.validate() then return false
    # Todo: add exception handling for these 2 calls
    Meteor.call 'updateUser', userOptions, (err) ->
      showResultOfProfileUpdate err
    if Volunteers.findOne Meteor.userId()
      unless volunteerForm and volunteerForm.validate() then return false
      volunteerOptions = getVolunteerFormValues template
      Meteor.call 'updateVolunteer', volunteerOptions, (err) ->
        showResultOfProfileUpdate err
    Router.go 'profileDetails'

  'click #pickPhoto': (evnt, template) ->
    photoHelper.processPhoto()

  'change #femaleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('male').addClass('female')

  'change #maleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('female').addClass('male')

