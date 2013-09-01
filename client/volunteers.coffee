photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'

updatePage = (file) ->
  $('#photoImg').fadeIn(400).attr 'src', Template.volunteersList.photoRoot() + file.key
  $('#photoPlaceholder').removeClass('empty').find('h4, p, .loading').remove()
  $('#photoFilename').val file.key
  $('#pickPhoto').removeAttr 'disabled'

storePhoto = (file) ->
  filepicker.store file
  , (storedFile) ->
    updatePage storedFile
  , (err) ->
    console.log err

resizePhoto = (file) ->
  filepicker.convert file,
    {width: 200, height: 200, align: 'faces', format: 'png', fit: 'crop'}
    , (convertedFile) ->
      storePhoto convertedFile
    , (err) ->
      console.log err

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

Template.volunteersCreate.rendered = ->
  $('.birthDatepicker').datepicker format: 'dd M yyyy'
  $('#birthdateIcon').click ->
    $('#birthdate').datepicker 'show'
  $('#pickPhoto').click ->
    processPhoto()
  $('#femaleGender, #maleGender').change ->
    $('#photoPlaceholder').toggleClass 'male female'


Template.volunteersCreate.events
  'click #saveProfile': (event, template) ->
    options = 
      photoFilename: template.find('#photoFilename').value
      firstName: template.find('#firstName').value
      lastName: template.find('#lastName').value
      birthdate: template.find('#birthdate').value
      gender: template.find('input:radio[name=gender]:checked').value
      shirtSize: template.find('#shirtSize').value
      primaryEmail: template.find('#primaryEmail').value
      homePhone: template.find('#homePhone').value
      workPhone: template.find('#workPhone').value
      mobilePhone: template.find('#mobilePhone').value
      address: template.find('#address').value
      suburb: template.find('#suburb').value
      city: template.find('#city').value
      postalCode: template.find('#postalCode').value
      notes: template.find('#notes').value

    Meteor.call 'saveVolunteer', options, ->
      Template.userMessages.showMessage 
        type: 'info',
        title: 'Success!',
        message: 'The volunteer ' + options.firstName + ' ' + options.lastName + ' was saved'

    template.find('#photoFilename').value = ''
    template.find('#firstName').value = ''
    template.find('#lastName').value = ''
    template.find('#birthdate').value = ''
    template.find('input:radio[name=gender]:checked').value = ''
    template.find('#shirtSize').value = 'M'
    template.find('#primaryEmail').value = ''
    template.find('#homePhone').value = ''
    template.find('#workPhone').value = ''
    template.find('#mobilePhone').value = ''
    template.find('#address').value = ''
    template.find('#suburb').value = ''
    template.find('#city').value = ''
    template.find('#postalCode').value = ''
    template.find('#notes').value = ''

    $('#photoPlaceholder').addClass('empty').find('p, h4').remove()
    $('#photoImg').attr('src', '').fadeOut 400
    $('.wait-message').hide()



Template.volunteersList.volunteers = ->
  return Volunteers.find() 

Template.volunteersList.photoRoot = ->
  return photoRoot




Template.volunteerDetails.detail = ->
  id = Session.get 'active-volunteer-id'
  Volunteers.findOne id

Template.volunteerDetails.photoRoot = ->
  return photoRoot

Template.volunteerDetails.availableTournamentsExist = ->
  tournaments = Template.volunteerDetails.availableTournaments()
  return tournaments.length > 0

Template.volunteerDetails.availableTournaments = ->
  tournaments = Tournaments.find({}, fields: {tournamentName: 1, days: 1}).fetch()
  futureTournaments = for tournament in tournaments
    tournamentStartDate = new Date tournament.days[0]
    tournament if new Date() - tournamentStartDate < 0

Template.volunteerDetails.myTournamentsExist = ->
  return false

Template.volunteerDetails.myTournaments = ->
  return []

Template.volunteerDetails.events =
  'click #deleteVolunteer': (evnt, template) ->
    $('#deleteModal').modal()
  'click #deleteConfirmed': (evnt, template) ->
    id = Session.get 'active-volunteer-id'
    Volunteers.remove id
    Meteor.Router.to 'volunteersList'
    Template.userMessages.showMessage 
      type: 'info',
      title: 'Deleted!',
      message: 'The volunteer was deleted'
  'click #deleteCancelled': (evnt, template) ->
    $('#deleteModal').hide()





