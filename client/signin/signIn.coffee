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
