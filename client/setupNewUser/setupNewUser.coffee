Template.setupNewUser.events
	'click #saveRole': (evnt, template) ->
		userType = template.find('#userType').value
		if userType is 'blank'
			Template.userMessages.showMessage
				type: 'error',
				title: 'Must choose a role.',
				message: 'Please select a role to continue.'
		else
			Meteor.users.update Meteor.userId(), { $set: { 'profile.type': userType } }, (err) ->
				console.log 'update successful'
	'change #userType': (evnt, template) ->
		if template.find('#userType').value isnt 'blank'
			Template.userMessages.clear()