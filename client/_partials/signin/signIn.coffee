# Globals
signInForm = null
registerForm = null
recoveryForm = null
resetPasswordForm = null

Template.signIn.rendered = ->
  config =
    trigger: 'change'
    errorClass: 'error'
    successClass: 'success'
    errorsWrapper: '<span class=\"help-inline\"></span>'
    errorTemplate: '<span></span>'
    classHandler: (el) ->
      el.$element.closest('.control-group')

  signInForm = $('#signInForm').parsley config
  registerForm = $('#registerForm').parsley config
  if Session.get('active-home-tab') isnt 'reset'
    recoveryForm = $('#recoveryForm').parsley config
  else
    resetPasswordForm = $('#resetPasswordForm').parsley config


Template.signIn.resettingPassword = ->
  Session.get('active-home-tab') is 'reset'

Template.signIn.isActive = (tab) ->
  if Session.get('active-home-tab') is tab is 'reset'
    'active'
  else if Session.get('active-home-tab') isnt 'reset' and tab is 'signin'
    'active'
  else
    false


Template.signIn.events
  'click #facebookButton': (evnt, template) ->
    Meteor.loginWithFacebook (err) ->
      if err and err.details
        Template.userMessages.showMessage
          type: 'error',
          title: err.reason || 'Unknown error. ',
          message: err.details || 'Unable to authenticate you with
            your Facebook account.'

  'click #googleButton': (evnt, template) ->
    Meteor.loginWithGoogle (err) ->
      if err and err.details
        Template.userMessages.showMessage
          type: 'error',
          title: err.reason || 'Unknown error. ',
          message: err.details || 'Unable to authenticate you with
            your Google account.'

  'submit #signInForm': (evnt, template) ->
    evnt.preventDefault()
    unless signInForm and signInForm.validate() then return
    Meteor.loginWithPassword { email: template.find('#signInEmail').value },
      template.find('#signInPassword').value, (err) ->
        if err
          Template.userMessages.showMessage
            type: 'error',
            title: 'Sign-in unsuccessful.',
            message: 'A user with that email and password could not be found.'
        else
          Template.userMessages.clear()
    false

  'submit #registerForm': (evnt, template) ->
    evnt.preventDefault()
    unless registerForm and registerForm.validate() then return
    firstName = template.find('#firstName').value
    lastName = template.find('#lastName').value
    email = template.find('#registerEmail').value
    newUser = new models.NewUser(firstName, lastName, email)
    newUser.password = template.find('#registerPassword').value
    services.accountService.createNewUser newUser
    return false

  'submit #recoveryForm': (evnt, template) ->
    evnt.preventDefault()
    unless recoveryForm and recoveryForm.validate() then return
    email = template.find('#recoverEmail').value
    template.find('#recoverEmail').value = ''

    Template.userMessages.showMessage
      type: 'info',
      timeout: 10000,
      title: 'Sending email.',
      message: 'We\'ll let you know very shortly if the email was sent.'
    Accounts.forgotPassword email: email, (err) ->
      if err
        Template.userMessages.showMessage
          type: 'error',
          title: 'Email not sent.',
          message: 'Unable to send password reset email.
            Please ensure the accuracy of the address.'
      else
        Template.userMessages.showMessage
          type: 'info',
          title: 'Email sent.',
          message: 'Please check your email for a message that will
            help you recover your password.'
    false

  'submit #resetPasswordForm': (evnt, template) ->
    evnt.preventDefault()
    unless resetPasswordForm and resetPasswordForm.validate() then return
    password = template.find('#resetPassword').value
    token = Session.get 'reset-token'

    Accounts.resetPassword token, password, (err) ->
      if err
        Template.userMessages.showMessage
          type: 'error',
          title: 'Password not reset.',
          message: 'Unable to reset your password.
            Please use the most recent password recovery email.'
      else
        Template.userMessages.showMessage
          type: 'info',
          title: 'Success.',
          message: 'Your password has been changed successfully.'
          Session.set 'active-home-tab', 'home'
          Session.set 'reset-token', null
          Router.go '/'
    false

