photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'

photoParameters =
  width: 200
  height: 200
  align: 'faces'
  format: 'png'
  fit: 'crop'

updatePage = (file) ->
  $('#photoImg').fadeIn(400).attr 'src', photoRoot + file.key
  $('#photoPlaceholder').removeClass('empty').find('h4, p, .loading').remove()
  $('#photoFilename').val file.key
  $('#pickPhoto').removeAttr 'disabled'

displayError = (err) ->
  console.log err
  Template.userMessages.showMessage
    type: 'error',
    title: 'Photo upload error',
    message: 'Please refresh the page and start over.
      We apologise for the inconvenience.'

storePhoto = (file) ->
  filepicker.store file, updatePage, displayError

resizePhoto = (file) ->
  filepicker.convert file, photoParameters, storePhoto, displayError

showProcessingMessage = (file) ->
  $('#photoImg').attr 'src', ''
  msg = '<h4 class="wait-message">Processing<br> your<br>
    photo</h4><img src="/img/loading.gif" class="loading" /><p>
    Please complete the form while you wait.</p>'
  $(msg).appendTo '#photoPlaceholder'
  $('#pickPhoto').attr 'disabled', 'disabled'
  resizePhoto file

@photoHelper =

  photoRoot: photoRoot

  processPhoto: ->
    filepicker.pick mimetypes: 'image/*', showProcessingMessage, displayError

