photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'




Template.users.rendered = ->
  Session.set 'active-volunteer', null




Template.userList.volunteers = ->
  Session.set 'active-volunteer', null
  Meteor.users.find().map (user) ->
    user.isMale = ->
      return user.profile.gender is 'male'
    user

Template.userList.photoRoot = ->
  return photoRoot




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
  firstName = template.find('#firstName').value
  lastName = template.find('#lastName').value
  email = template.find('#primaryEmail').value
  return values = 
    email: email
    profile:
      email: email
      firstName: firstName
      lastName: lastName
      slug: firstName + lastName
      fullName: firstName + ' ' + lastName
      photoFilename: template.find('#photoFilename').value
      admin: if template.find('#siteAdmin:checked') then true
      gender: template.find('input:radio[name=gender]:checked').value

getVolunteerFormValues = (template) ->
  return values = 
    shirtSize: template.find('#shirtSize').value
    birthdate: template.find('#birthdate').value
    homePhone: template.find('#homePhone').value
    mobilePhone: template.find('#mobilePhone').value
    address: template.find('#address').value
    suburb: template.find('#suburb').value
    city: template.find('#city').value
    postalCode: template.find('#postalCode').value
    notes: template.find('#notes').value

createNewVolunteer = (options, callback) ->
  Volunteers.insert { 
    _id: options._id,
    birthdate: options.birthdate || '',
    shirtSize: options.shirtSize || '',
    homePhone: options.homePhone || '',
    mobilePhone: options.mobilePhone || '',
    address: options.address || '',
    city: options.city || '',
    suburb: options.suburb || '',
    postalCode: options.postalCode || '',
    notes: options.notes || ''
  }, callback

updateVolunteer = (options, callback) ->
  Volunteers.update { _id: options._id }, { $set: {
    birthdate: options.birthdate || ''
    shirtSize: options.shirtSize || ''
    homePhone: options.homePhone || ''
    mobilePhone: options.mobilePhone || ''
    address: options.address || ''
    city: options.city || ''
    suburb: options.suburb || ''
    postalCode: options.postalCode || ''
    notes: options.notes || ''
  }}, callback

clearFormValues = (template) ->
  template.find('#photoFilename').value = ''
  template.find('#firstName').value = ''
  template.find('#lastName').value = ''
  template.find('#birthdate').value = ''
  template.find('input:radio[name=gender]:checked').value = ''
  template.find('#shirtSize').value = 'M'
  template.find('#primaryEmail').value = ''
  template.find('#homePhone').value = ''
  template.find('#mobilePhone').value = ''
  template.find('#address').value = ''
  template.find('#suburb').value = ''
  template.find('#city').value = ''
  template.find('#postalCode').value = ''
  template.find('#role').value = 'blank'
  template.find('#notes').value = ''

  $('#photoPlaceholder').addClass('empty').find('p, h4').remove()
  $('#photoImg').attr('src', '').fadeOut 400



Template.userCreate.rendered = ->
  initializeControls()
  user = Session.get 'active-user'
  if user && user.profile.photoFilename
    $('.photo-placeholder').removeClass 'empty'

Template.userCreate.detail = ->
  volunteer = Session.get('active-volunteer') or {}
  if volunteer.userDetails # editing, not creating
    profile = volunteer.userDetails.profile
    volunteer.isMale = profile.gender is 'male'
    volunteer.photoFilename = profile.photoFilename
    if volunteer.photoFilename
      volunteer.photoPath = photoRoot + profile.photoFilename
    volunteer.firstName = profile.firstName
    volunteer.lastName = profile.lastName
    volunteer.primaryEmail = profile.email
    volunteer.siteAdmin = if profile.admin then 'checked="checked"' else ''
  else
    volunteer.detail = {}

  if volunteer.profile?.primaryEmail
    volunteer.emailDisabled = ''
    volunteer.hasProfileAccess = 'checked'
  else 
    volunteer.hasProfileAccess = ''
    volunteer.emailDisabled = 'disabled'
    volunteer.primaryEmail = 'no.mail@tennisauckland.co.nz'
  return volunteer

Template.userCreate.events
  'click #saveProfile': (event, template) ->
    activeVolunteer = Session.get 'active-volunteer'
    userOptions = getUserFormValues template
    volunteerOptions = getVolunteerFormValues template
    unless activeVolunteer # new user
      Meteor.call 'createNewUser', userOptions, (err, id) ->
        if err
          Template.userMessages.showMessage 
            type: 'error',
            title: 'Uh oh!',
            message: 'The volunteer was not saved. Reason: ' + err.reason
        else
          volunteerOptions._id = id
          createNewVolunteer volunteerOptions, (err) ->
            if id then clearFormValues template
            Template.userMessages.showMessage 
              type: 'info',
              title: 'Success!',
              message: 'The volunteer ' + userOptions.profile.fullName + ' was saved'
        $('.wait-message').hide()
    else # updating exiting volunteer
      userOptions._id = activeVolunteer._id
      Meteor.call 'updateUser', userOptions, (err) ->
        if err
          Template.userMessages.showMessage 
            type: 'error',
            title: 'Uh oh!',
            message: 'The volunteer was not saved. Reason: ' + err.reason
        else
          volunteerOptions._id = activeVolunteer._id
          updateVolunteer volunteerOptions, (err) ->
            Template.userMessages.showMessage 
              type: 'info',
              title: 'Success!',
              message: 'The volunteer ' + userOptions.profile.fullName + ' was saved'
        $('.wait-message').hide()
  'change #hasProfileAccess': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#primaryEmail').prop('disabled', false).val('')
      $('#siteAdmin').prop('disabled', false)
    else
      $('#primaryEmail').prop('disabled', true).val('no.mail@tennisauckland.co.nz')
      $('#siteAdmin').prop('disabled', true)
      $('#siteAdmin').prop('checked', false)




Template.userDetails.detail = ->
  volunteer = Session.get 'active-volunteer'
  profile = volunteer.userDetails.profile
  volunteer.isMale = profile.gender is 'male'
  volunteer.photoFilename = profile.photoFilename
  volunteer.firstName = profile.firstName
  volunteer.lastName = profile.lastName
  volunteer.primaryEmail = profile.email
  volunteer.role = profile.role
  return volunteer

Template.userDetails.photoRoot = ->
  return photoRoot

Template.userDetails.availableTournamentsExist = ->
  tournaments = Template.volunteerDetails.availableTournaments()
  return tournaments.length > 0

Template.userDetails.availableTournaments = ->
  tournaments = Tournaments.find({}, fields: {tournamentName: 1, days: 1}).fetch()
  futureTournaments = for tournament in tournaments
    tournamentStartDate = new Date tournament.days[0]
    tournament if new Date() - tournamentStartDate < 0

Template.userDetails.myTournamentsExist = ->
  return false

Template.userDetails.myTournaments = ->
  return []

Template.userDetails.events =
  'click #deleteVolunteer': (evnt, template) ->
    $('#deleteModal').modal()
  'click #deleteConfirmed': (evnt, template) ->
    id = Session.get('active-volunteer')._id
    Volunteers.remove id, ->
      Meteor.users.remove id, ->
      Meteor.Router.to '/volunteer/list'
      Template.userMessages.showMessage 
        type: 'info',
        title: 'Deleted!',
        message: 'The volunteer was deleted'
  'click #deleteCancelled': (evnt, template) ->
    $('#deleteModal').hide()
  'click #editProfile': (evnt, template) ->
    Meteor.Router.to '/volunteer/edit/' + Session.get('active-volunteer').userDetails.profile.slug





