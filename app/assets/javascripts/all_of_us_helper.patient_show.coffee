class AllOfUsHelper.PatientShow
  constructor: () ->
  render: () ->
    $(':checkbox').change ->
      if $(this).data('text') == 'Unknown or Not Reported' && $(this).prop('checked') == true
          $("input[data-text!='Unknown or Not Reported']").prop('checked', false)
      if $(this).data('text') != 'Unknown or Not Reported' && $(this).prop('checked') == true
          $("input[data-text='Unknown or Not Reported']").prop('checked', false)
      return

$(document).on 'turbolinks:load', ->
  return unless $('.patients.show').length > 0
  ui = new AllOfUsHelper.PatientShow
  ui.render()