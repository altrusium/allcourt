validateInput = (target) ->
	valid = true
	if $(target).hasClass('btn') then return true
	if target.value is ''
		$(target).closest('.control-group').removeClass('success').addClass('error')
		$(target).siblings('.required.help-inline').show()
		valid = false
	else
		$(target).closest('.control-group').removeClass('error').addClass('success')
		$(target).siblings('.required.help-inline').hide()
	valid

registrationPasswordsMatch = (form) ->
	match = true
	password1 = $('#registerPassword', form)
	password2 = $('#registerConfirmPassword', form)
	if password1.val() isnt password2.val()
		password2.closest('.control-group').addClass('error').removeClass('success')
		password2.siblings('.match.help-inline').show()
		match = false
	else
		password2.closest('.control-group').removeClass('error').addClass('success')
		password2.siblings('.match.help-inline').hide()
	match

registrationFormIsValid = (form) ->
	valid = true
	$('input', form).each ->
		valid = valid && validateInput this
	valid

Template.signIn.events 
	'click #facebookButton': (evnt, template) ->
		Meteor.loginWithFacebook (err) ->
			if err && err.details
				Template.userMessages.showMessage
					type: 'error',
					title: err.details.title,
					message: err.details.message
	'click #googleButton': (evnt, template) ->
		Meteor.loginWithGoogle (err) ->
			if err && err.details
				Template.userMessages.showMessage
					type: 'error',
					title: err.details.title,
					message: err.details.message
	'submit #signInForm': (evnt, template) ->
		evnt.preventDefault()
		unless registrationFormIsValid(evnt.currentTarget) then return
		Meteor.loginWithPassword { email: template.find('#signInEmail').value },
			template.find('#signInPassword').value, (err) ->
				if err
					Template.userMessages.showMessage
						type: 'error',
						title: 'Sign-in unsuccessful.',
						message: 'A user with that email and password could not be found.'
		false
	'submit #registerForm': (evnt, template) ->
		evnt.preventDefault()
		unless registrationFormIsValid(evnt.currentTarget) then return
		unless registrationPasswordsMatch(evnt.currentTarget) then return
		email = template.find('#registerEmail').value
		firstName = template.find('#firstName').value
		lastName = template.find('#lastName').value
		options = 
			email: email
			username: email
			password: template.find('#registerPassword').value
			profile: 
				email: email
				firstName: firstName
				lastName: lastName
				fullName: firstName + ' ' + lastName
				slug: firstName + lastName 
		Accounts.createUser options, (err) ->
			if err
				Template.userMessages.showMessage
					type: 'error',
					title: 'Registration unsuccessful.',
					message: 'Unable to save your registration. Please try agin and let us know if you continue to have trouble.'
		false
	'submit #recoveryForm': (evnt, template) ->
		evnt.preventDefault()
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
					message: 'Unable to send password reset email. Please ensure the accuracy of the address.'
			else
				Template.userMessages.showMessage
					type: 'info',
					title: 'Email sent.',
					message: 'Please check your email for a message that will help you recover your password.'
		false
	'keydown, blur input': (evnt, template) ->
		validateInput evnt.currentTarget
		true



