updatePage = (file) ->
  $('#photoImg').fadeIn(400).attr 'src', allcourt.photoRoot + file.key
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

getActiveVolunteer = ->
  id = Session.get('active-user')._id
  volunteer = Volunteers.findOne id
  Session.set 'active-volunteer', volunteer
  volunteer

getUserFormValues = (template) ->
  values = 
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    email: template.find('#email').value
    photoFilename: template.find('#photoFilename').value
    admin: if template.find('#siteAdmin:checked') then true else false
    isNew: if template.find('#isNew:checked') then true else false
    gender: template.find('input:radio[name=gender]:checked').value

getVolunteerFormValues = (template) ->
  values = 
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
  template.find('#email').value = ''
  template.find('#homePhone').value = ''
  template.find('#mobilePhone').value = ''
  template.find('#address').value = ''
  template.find('#suburb').value = ''
  template.find('#city').value = ''
  template.find('#postalCode').value = ''
  template.find('#notes').value = ''
  $('#photoPlaceholder').addClass('empty').find('p, h4').remove()
  $('#photoImg').attr('src', '').fadeOut 400

showResultOfVolunteerCreation = (err) ->
  if err
    Template.userMessages.showMessage 
      type: 'error',
      title: 'Uh oh!',
      message: 'The new volunteer was not saved. Reason: ' + err.reason
  else
    Template.userMessages.showMessage 
      type: 'info',
      title: 'Success!',
      message: 'The new volunteer was saved successfully.'

showResultOfVolunteerUpdate = (err) ->
  if err
    Template.userMessages.showMessage 
      type: 'error',
      title: 'Uh oh!',
      message: 'The volunteer was not updated. Reason: ' + err.reason
  else
    Template.userMessages.showMessage 
      type: 'info',
      title: 'Success!',
      message: 'The volunteer was updated successfully.'

showResultOfUserCreation = (err) ->
  if err
    Template.userMessages.showMessage 
      type: 'error',
      title: 'Uh oh!',
      message: 'The new user was not saved. Reason: ' + err.reason
  else
    Template.userMessages.showMessage 
      type: 'info',
      title: 'Success!',
      message: 'The new user was saved successfully.'

showResultOfUserUpdate = (err) ->
  if err
    Template.userMessages.showMessage 
      type: 'error',
      title: 'Uh oh!',
      message: 'The user was not updated. Reason: ' + err.reason
  else
    Template.userMessages.showMessage 
      type: 'info',
      title: 'Success!',
      message: 'The user was updated successfully.'

saveNewUserAndVolunteer = (userOptions, volunteerOptions) ->
  isVolunteer = $('#isVolunteer').prop('checked')
  Meteor.call 'createNewUser', userOptions, (err, id) ->
    showResultOfUserCreation err
    unless err
      if isVolunteer
        volunteerOptions._id = id
        createNewVolunteer volunteerOptions, (err) ->
          if id then clearFormValues template
          showResultOfVolunteerCreation err

updateUserAndVolunteer = (userOptions, volunteerOptions) ->
  isVolunteer = $('#isVolunteer').prop('checked')
  Meteor.call 'updateUser', userOptions, (err) ->
    showResultOfUserUpdate err
    unless err
      if isVolunteer
        volunteerOptions._id = Session.get('active-user')._id
        if Session.get('active-volunteer')
          updateVolunteer volunteerOptions, (err) ->
            showResultOfVolunteerUpdate err
        else
          createNewVolunteer volunteerOptions, (err) ->
            showResultOfVolunteerCreation err

Template.userCreate.rendered = ->
  initializeControls()
  user = Session.get 'active-user'
  if user?.profile.photoFilename
    $('.photo-placeholder').removeClass 'empty'

Template.userCreate.userDetails = ->
  details = Session.get('active-user')
  unless details then return hasProfileAccess: 'checked' # creating new user
  profile = details.profile
  details.isMale = profile.gender is 'male'
  details.photoFilename = profile.photoFilename
  if profile.photoFilename
    details.photoPath = allcourt.photoRoot + profile.photoFilename
  details.firstName = profile.firstName
  details.lastName = profile.lastName
  details.email = profile.email
  details.siteAdmin = if profile.admin then 'checked' else ''
  details.isNew = if profile.isNew then 'checked' else ''
  details.volunteer = if getActiveVolunteer() then 'checked'

  if profile.email isnt 'no.email@tennisauckland.co.nz'
    details.emailDisabled = ''
    details.hasProfileAccess = 'checked'
  else 
    details.hasProfileAccess = ''
    details.emailDisabled = 'disabled'
    details.email = 'no.email@tennisauckland.co.nz'

  details

Template.userCreate.volunteerDetails = ->
  Session.get('active-volunteer') or { 'hidden': 'hidden' }

Template.userCreate.events
  'click #saveProfile': (event, template) ->
    activeUser = Session.get('active-user')
    userOptions = getUserFormValues template
    volunteerOptions = getVolunteerFormValues template
    if activeUser
      userOptions._id = activeUser._id
      updateUserAndVolunteer userOptions, volunteerOptions
    else
      saveNewUserAndVolunteer userOptions, volunteerOptions
    Router.go 'userDetails', userSlug: Session.get('active-user').profile.slug

  'change #hasProfileAccess': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#email').prop('disabled', false).val('')
      $('#siteAdmin').prop('disabled', false)
    else
      $('#email').prop('disabled', true).val('no.email@tennisauckland.co.nz')
      $('#siteAdmin').prop('disabled', true)
      $('#siteAdmin').prop('checked', false)

  'change #isVolunteer': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('.volunteer-details').removeClass('hidden')
    else
      $('.volunteer-details').addClass('hidden')

