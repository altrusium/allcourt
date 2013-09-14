Template.setupNewUser.events
	'click #saveRole': (evnt, template) ->
		unless template.find('#userType').value isnt 'blank'
			Template.userMessages.showMessage
				type: 'error',
				title: 'Must choose a role.',
				message: 'Please select a role to continue.'
	'change #userType': (evnt, template) ->
		if template.find('#userType').value isnt 'blank'
			Template.userMessages.clear()