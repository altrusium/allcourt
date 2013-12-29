removeWhitespace = (namePart) ->
  unless namePart then return ''
  return namePart.replace /\s/g, ''

makeLowercase = (string) ->
  unless string then return ''
  return string.toLowerCase()

@emailHelper =

  addressSuffix: '@has-no-email.allcourt.co.nz'

  prepareName: (first, last) ->
    unless first then return ''
    prepped = removeWhitespace first
    prepped = makeLowercase prepped
    if last then prepped = prepped + '.' + this.prepareName last
    prepped
