# type can be 'error', 'success', and 'info'

Template.userMessages.message = ->
  msg = Session.get 'user-message'
  return msg || type: '', title: '', message: ''

Template.userMessages.showMessage = (options) ->
  Session.set 'user-message',
    title: options.title,
    message: options.message,
    type: 'alert alert-' + options.type
  setTimeout ->
    Template.userMessages.clear()
  , options.timeout || 4000 unless options.type is 'error'

Template.userMessages.clear = ->
  Session.set 'user-message',
    type: '', title: '', message: ''

Template.userMessages.events
  'click button[data-dismiss]': ->
    Template.userMessages.clear()

