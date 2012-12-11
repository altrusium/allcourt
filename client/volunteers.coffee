updatePage = (file) ->
  $('#photoImg').attr 'src', Template.volunteersList.photoRoot() + file.key
  $('#photoPlaceholder').removeClass('empty').find('p, h4').remove()
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
      msg = '<h4>Processing<br> your<br> photo</h4><p>Please complete the form while you wait.</p>'
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
      secondaryEmail: template.find('#secondaryEmail').value
      homePhone: template.find('#homePhone').value
      workPhone: template.find('#workPhone').value
      mobilePhone: template.find('#mobilePhone').value
      address: template.find('#address').value
      city: template.find('#city').value
      suburb: template.find('#suburb').value
      postalCode: template.find('#postalCode').value
      notes: template.find('#notes').value

    Meteor.call 'saveVolunteer', options




Template.volunteersList.volunteers = ->
  return Volunteers.find() 

Template.volunteersList.photoRoot = ->
  return 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/' 




Template.volunteerDetails.detail = ->
  id = Session.get 'active-volunteer-id'
  Volunteers.findOne id

Template.volunteerDetails.photoRoot = ->
  return 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/' 

Template.volunteerDetails.availableTournaments = ->
  tournaments = Tournaments.find {}, fields: {tournamentName: 1, days: 1}
  futureTournaments = for tournament in tournaments.fetch()
    tournamentStartDate = new Date tournament.days[0]
    if new Date() - tournamentStartDate < 0
      tournament

Template.volunteerDetails.availableTournamentsExist = ->
  tournaments = Template.volunteerDetails.availableTournaments()
  return tournaments.length > 0

Template.volunteerDetails.myTournamentsExist = ->
  return false