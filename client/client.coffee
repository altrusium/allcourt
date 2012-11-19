Meteor.subscribe 'volunteers'

tabIsSelected = (tab) ->
  return tab is Session.get 'selected_tab'

# The Tabs Template
Template.tabs.create_selected = ->
  return if tabIsSelected 'create' then 'active' else ''

Template.tabs.find_selected = ->
  return if tabIsSelected 'find' then 'active' else ''

Template.tabs.list_selected = ->
  return if tabIsSelected 'list' then 'active' else ''

Template.tabs.events
  'click a': (event, template) ->
    Session.set 'selected_tab', $(event.currentTarget).data 'tab'


# The Page Template
Template.page.create_selected = ->
  return tabIsSelected 'create'

Template.page.find_selected = ->
  return tabIsSelected 'find'

Template.page.list_selected = ->
  return tabIsSelected 'list'

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
