initializeControls = ->
  $('#birthdate').datepicker format: 'dd M yyyy', autoclose: true

createEmailAddress = ->
  firstName = $('#firstName').val()
  lastName = $('#lastName').val()
  name = emailHelper.prepareName firstName, lastName
  unless $('#hasProfileAccess').prop('checked')
    $('#email').val(name + emailHelper.addressSuffix)

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

showSuccess = (msg) ->
  Template.userMessages.showMessage
    type: 'info',
    title: 'Success!',
    message: msg

showError = (msg) ->
  Template.userMessages.showMessage
    type: 'error',
    title: 'Uh oh!',
    message: msg + ' Reason: ' + err.reason

showResultOfVolunteerCreation = (err) ->
  if err
    showError 'The new volunteer was not saved.'
  else
    showSuccess 'The new volunteer was saved successfully.'

showResultOfVolunteerUpdate = (err) ->
  if err
    showError 'The volunteer was not updated.'
  else
    showSuccess 'The volunteer was updated successfully.'

showResultOfUserCreation = (err) ->
  if err
    showError 'The new user was not saved.'
  else
    showSuccess 'The new user was saved successfully.'

showResultOfUserUpdate = (err) ->
  if err
    showError 'The user was not updated.'
  else
    showSuccess 'The user was updated successfully.'

saveNewUserAndVolunteer = (userOptions, volunteerOptions) ->
  Meteor.call 'createNewUser', userOptions, (err, id) ->
    showResultOfUserCreation err
    unless err
      if $('#isVolunteer').prop('checked')
        volunteerOptions._id = id
        Meteor.call 'createNewVolunteer', volunteerOptions, (vErr, vId) ->
          if vId then clearFormValues template
          showResultOfVolunteerCreation vErr

updateUserAndVolunteer = (userOptions, volunteerOptions) ->
  Meteor.call 'updateUser', userOptions, (err) ->
    showResultOfUserUpdate err
    unless err
      if $('#isVolunteer').prop('checked')
        volunteerOptions._id = Session.get('active-user')._id
        if Session.get('active-volunteer')
          Meteor.call 'updateVolunteer', volunteerOptions, (vErr) ->
            showResultOfVolunteerUpdate vErr
        else
          Meteor.call 'createNewVolunteer', volunteerOptions, (vErr) ->
            showResultOfVolunteerCreation vErr



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
  $.extend details, profile
  if details.photoFilename
    details.photoPath = photoHelper.photoRoot + profile.photoFilename
  details.siteAdmin = if profile.admin then 'checked' else ''
  details.isNew = if profile.isNew then 'checked' else ''
  details.volunteer = if getActiveVolunteer() then 'checked'

  if details.email.indexOf(emailHelper.addressSuffix) > 1
    # user has a fake email and doesn't have access to their profile
    details.emailDisabled = ''
    details.hasProfileAccess = 'checked'
  else
    details.hasProfileAccess = ''
    details.emailDisabled = 'disabled'
    details.email = 'no.email' + emailHelper.addressSuffix

  details

Template.userCreate.volunteerDetails = ->
  Session.get('active-volunteer') or { 'hidden': 'hidden' }

Template.userCreate.events
  'click #pickPhoto': (evnt, template) ->
    photoHelper.processPhoto()

  'click #birthdateIcon': (evnt, template) ->
    $('#birthdate').datepicker 'show'

  'click #saveProfile': (event, template) ->
    activeUser = Session.get('active-user')
    userOptions = getUserFormValues template
    volunteerOptions = getVolunteerFormValues template
    if activeUser # edit existing user
      userOptions._id = activeUser._id
      updateUserAndVolunteer userOptions, volunteerOptions
    else # add new user
      saveNewUserAndVolunteer userOptions, volunteerOptions
    Router.go 'userDetails', userSlug: Session.get('active-user').profile.slug

  'change #hasProfileAccess': (evnt, template) ->
    firstName = $('#firstName').val()
    lastName = $('#lastName').val()
    name = emailHelper.prepareName firstName, lastName
    if $(evnt.currentTarget).prop('checked')
      $('#email').prop('disabled', false).val('')
      $('#siteAdmin').prop('disabled', false)
    else
      $('#email').prop('disabled', true).val(name + emailHelper.addressSuffix)
      $('#siteAdmin').prop('disabled', true)
      $('#siteAdmin').prop('checked', false)

  'change #isVolunteer': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('.volunteer-details').removeClass('hidden')
    else
      $('.volunteer-details').addClass('hidden')

  'change #firstName': (evnt, template) ->
    createEmailAddress()

  'change #lastName': (evnt, template) ->
    createEmailAddress()

  'change #femaleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('male').addClass('female')

  'change #maleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('female').addClass('male')
