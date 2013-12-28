Handlebars.registerHelper 'select', (value, options) ->
  $el = $('<select />').html options.fn(this)
  $el.find('[value=' + value + ']').attr({'selected':'selected'})
  return $el.html()

Handlebars.registerHelper 'debug', (optionalValue) ->
  console.log 'Current context'
  console.log '----------------------'
  console.log this
  if optionalValue
    console.log 'Value'
    console.log '----------------------'
    console.log optionalValue