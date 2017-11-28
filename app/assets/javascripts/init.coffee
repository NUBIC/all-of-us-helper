window.AllOfUsHelper ||= {}

AllOfUsHelper.init = ->
  $(document).foundation()

$(document).on 'turbolinks:load', ->
  AllOfUsHelper.init()
