Meteor.subscribe 'volunteers'

Meteor.Router.add
  '/': 'home',
  '/volunteers': 'volunteers',
  '/volunteers/create': 'volunteersCreate',
  '/volunteers/list': 'volunteersList',
  '/shifts': 'shifts',
  '/setup': 'setup',
  '/setup/tournament': 'setupTournament',
  '/setup/roles': 'setupRoles',
  '/setup/shifts': 'setupShifts'

Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected_tab', tabName 

tabIsSelected = (tab) ->
  return tab is Session.get 'selected_tab'


# The Tabs Template
Template.tabs.tabSelected = (tab) ->
  return if tabIsSelected tab then 'active' else ''


# The Create Template
Template.create.events
  'click input[type=button]': (event, template) ->
    fileinput = template.find('[type=file]') 
    options = 
      firstname: template.find('[name=firstname]').value
      lastname: template.find('[name=lastname]').value
      address: template.find('[name=address]').value
      suburb: template.find('[name=suburb]').value
      postalcode: template.find('[name=postalcode]').value
      email: template.find('[name=email]').value
      homephone: template.find('[name=homephone]').value
      workphone: template.find('[name=workphone]').value
      mobilephone: template.find('[name=mobilephone]').value
      birthdate: template.find('[name=birthdate]').value
      notes: template.find('[name=notes]').value
      asbshirtsize: template.find('[name=asbshirtsize]').value
      heinekenshirtsize: template.find('[name=heinekenshirtsize]').value 

    if fileinput.value
      filepicker.store fileinput, (file) ->
        options['photo'] = file.key
        Meteor.call 'saveVolunteer', options
    else
      Meteor.call 'saveVolunteer', options


# The List Template
Template.list.volunteers = ->
  return Volunteers.find() 
