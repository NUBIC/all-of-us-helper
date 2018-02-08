class AllOfUsHelper.BatchHealthPro
  constructor: () ->
  render: () ->
    $('.remove-health-pro-file-link').on 'click', (e) ->
      if $('#batch-helath_pro-health-pro-file').hasClass('hide')
        $('#batch-helath_pro-health-pro-file').removeClass('hide')
        $(this).addClass('hide')
        $('.health-pro-file-url').addClass('hide')
        $('#batch_health_pro_health_pro_file').val('')
        $('#batch-health-pro-health-pro-file-cache').val('')
      else
        alert('hello booch')
        $('#batch-helath_pro-health-pro-file').addClass('hide')
      e.preventDefault()

$(document).on 'turbolinks:load', ->
  return unless ($('.batch_health_pros.new').length > 0 || $('.batch_health_pros.create').length > 0)
  ui = new AllOfUsHelper.BatchHealthPro
  ui.render()