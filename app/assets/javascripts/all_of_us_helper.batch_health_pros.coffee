class AllOfUsHelper.BatchHealthPros
  constructor: () ->
  render: (link) ->
    set_delay = 3000
    stop = false

    callout = ->
      pendng = $(".batch_health_pro .status:contains('pending')")
      if pendng.length == 0
        return
      else
        if !stop
          reload = ->
            $.ajax({ url: window.location, dataType: 'script', method: 'GET' })
            callout()
            return
          setTimeout reload, set_delay
      return

    callout()
    return

$(document).on 'turbolinks:load', ->
  return unless ($('.batch_health_pros.index').length > 0)
  ui = new AllOfUsHelper.BatchHealthPros
  ui.render()