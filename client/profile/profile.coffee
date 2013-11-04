@photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'



updatePage = (file) ->
  $('#photoImg').fadeIn(400).attr 'src', photoRoot + file.key
  $('#photoPlaceholder').removeClass('empty').find('h4, p, .loading').remove()
  $('#photoFilename').val file.key
  $('#pickPhoto').removeAttr 'disabled'

storePhoto = (file) ->
  filepicker.store file
  , (storedFile) ->
    updatePage storedFile
  , (err) ->
    console.log err
    Template.userMessages.showMessage 
      type: 'error',
      title: 'Photo upload error',
      message: 'Please refresh the page and start over. We apologise for the inconvenience.'

resizePhoto = (file) ->
  filepicker.convert file,
    {width: 200, height: 200, align: 'faces', format: 'png', fit: 'crop'}
    , (convertedFile) ->
      storePhoto convertedFile
    , (err) ->
      console.log err
      Template.userMessages.showMessage 
        type: 'error',
        title: 'Photo upload error',
        message: 'Please refresh the page and start over. We apologise for the inconvenience.'

processPhoto = ->
  filepicker.pick mimetypes: 'image/*'
    , (file) ->
      $('#photoImg').attr 'src', ''
      msg = '<h4 class="wait-message">Processing<br> your<br> photo</h4><img src="/img/loading.gif" class="loading" /><p>Please complete the form while you wait.</p>'
      $(msg).appendTo '#photoPlaceholder'
      $('#pickPhoto').attr 'disabled', 'disabled'
      resizePhoto file
    , (err) ->
      console.log err

initializeControls = ->
  $('.birthDatepicker').datepicker format: 'dd M yyyy'
  $('#birthdateIcon').click ->
    $('#birthdate').datepicker 'show'
  $('#pickPhoto').click ->
    processPhoto()
  $('#femaleGender, #maleGender').change ->
    $('#photoPlaceholder').toggleClass 'male female'

getUserFormValues = (template) ->
  return values = 
    _id: Meteor.userId()
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    email: template.find('#email').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value

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




Template.profileDetails.details = ->
  user = Meteor.user()
  details = user.profile || {}
  if details.photoFilename
    details.photoFile = photoRoot + details.photoFilename
  details.isMale = details.gender is 'male'
  return details || {}

Template.profileDetails.availableTournamentsExist = ->
  tournaments = Template.profileDetails.availableTournaments()
  # return tournaments.length > 0
  return false

Template.profileDetails.availableTournaments = ->
  tournaments = Tournaments.find({}, fields: { tournamentName: 1, days: 1 }).fetch()
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
  if Meteor.user().profile.photoFile
    $('.photo-placeholder').removeClass 'empty'

Template.profileEdit.details = ->
  user = Meteor.user()
  details = user.profile || {}
  details.isMale = details.gender is 'male'
  if details.photoFilename
    details.photoFile = photoRoot + details.photoFilename
  return details

Template.profileEdit.volunteerDetails = ->
  return Volunteers.findOne Meteor.userId()

Template.profileEdit.photoFilename = ->
	return Meteor.user().profile.photoFilename

Template.profileEdit.events
  'click #saveProfile': (event, template) ->
    userOptions = getUserFormValues template
    # Todo: add exception handling for these 2 calls
    Meteor.call 'updateUser', userOptions, (err) ->
      if err
        Template.userMessages.showMessage 
          type: 'error',
          title: 'Error. ',
          message: 'Your profile details were not saved. Reason: ' + err.reason
      else
        Template.userMessages.showMessage 
          type: 'info',
          title: 'Success!',
          message: 'Your profile details were saved successfully.'
    if Volunteers.findOne Meteor.userId()
      volunteerOptions = getVolunteerFormValues template
      Meteor.call 'updateVolunteer', volunteerOptions, (err) ->
        if err
          Template.userMessages.showMessage 
            type: 'error',
            title: 'Error.',
            message: 'Your profile details were not saved. Reason: ' + err.reason
        else
          Template.userMessages.showMessage 
            type: 'info',
            title: 'Success!',
            message: 'Your profile details were saved successfully.'
    Router.go 'profileDetails'

