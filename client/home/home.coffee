Template.home.created = ->
  Session.set 'active-tournament', null

Template.home.isAdmin = ->
  allcourt.isAdmin()

Template.home.rendered = ->
  token = Session.get('email-verification-token')
  if token
    Template.userMessages.showMessage
      type: 'info',
      timeout: 10000,
      title: 'Email verification.',
      message: 'Completing verification of your email.'
    Accounts.verifyEmail token, (err) ->
      if err
        Template.userMessages.showMessage
          type: 'error',
          title: err.reason || 'Unknown error.',
          message: err.details || 'Unable to complete email verification.'
      else
        Template.userMessages.showMessage
          type: 'info',
          title: 'Success.',
          message: 'Thank you for verifying your email address.'
    Session.set 'email-verification-token', null
    Router.go '/'
