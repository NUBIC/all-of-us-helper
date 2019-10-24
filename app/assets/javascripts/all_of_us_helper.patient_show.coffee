class AllOfUsHelper.PatientShow
  constructor: () ->
  render: (link) ->
    yearRange = "1900:#{(new Date()).getFullYear()}"
    $('.datepicker').datepicker(changeMonth: true, changeYear: true, yearRange: yearRange)
    $('.datepicker').datepicker("option", "dateFormat", "yy-mm-dd")
    $(':checkbox').change ->
      if $(this).data('text') == 'Unknown or Not Reported' && $(this).prop('checked') == true
          $("input[data-text!='Unknown or Not Reported']").prop('checked', false)
      if $(this).data('text') != 'Unknown or Not Reported' && $(this).prop('checked') == true
          $("input[data-text='Unknown or Not Reported']").prop('checked', false)

    $('.set-ethnicity-link').on 'click', (e) ->
      set_ethnicity = confirm('Overwrite Ethnicity?')
      if set_ethnicity == true
        ethnicity = $('#mapped_health_pro_ethnicity').val()
        $("#patient-form").find('#patient_ethnicity').val(ethnicity)
        e.preventDefault()
      return false

    $('.set-race-link').on 'click', (e) ->
      set_race = confirm('Overwrite Race?')
      if set_race == true
        mapped_race = $('#mapped_health_pro_race').val()
        $(".patient_race").each (index) ->
          $(this).prop('checked', false)
          $("input[data-text='#{mapped_race}']").prop('checked', true)
      e.preventDefault()
      return false

    $(link).on 'click', (e) ->
      $modal = $('#empi-lookup-modal')
      $empi_lookup = $('#empi-lookup-modal #empi-lookup')
      $.ajax(this.href).done (response) ->
        $modal.foundation 'open'
        $empi_lookup.html(response)
        yearRange = "1900:#{(new Date()).getFullYear()}"
        $('.datepicker').datepicker(changeMonth: true, changeYear: true, yearRange: yearRange)
        $('.datepicker').datepicker("option", "dateFormat", "yy-mm-dd")
        init = () ->
          $('#assign-empi-link').on 'click', (e) ->
            empi_patient = $('input[name=assign-empi-patient]:checked').parents('.empi_patient')
            first_name = empi_patient.find('.first_name').text().trim()
            last_name = empi_patient.find('.last_name').text().trim()
            gender = empi_patient.find('.gender').text().trim()
            ethnicity = empi_patient.find('.ethnicity').text().trim()
            races = empi_patient.find('.race').text().trim()
            races = races.split('|')
            nmhc_mrn = empi_patient.find('.nmhc_mrn').text().trim()
            birth_date = empi_patient.find('.birth_date').text().trim()
            $("#patient-form").find('.nmhc_mrn .value').text(nmhc_mrn)
            $("#patient-form").find('#patient_first_name').val(first_name)
            $("#patient-form").find('#patient_last_name').val(last_name)
            $("#patient-form").find('#patient_gender').val(gender)
            $("#patient-form").find('#patient_ethnicity').val(ethnicity)
            $("#patient-form").find('#patient_birth_date').val(birth_date)
            i = 0
            while i < races.length
              $("input[data-text='#{races[i]}']").prop('checked', true)
              i++
            $("#patient_nmhc_mrn").val(nmhc_mrn)

            $modal.foundation 'close'
            return
          $("#empi-lookup-form").on("ajax:beforeSend", (event) ->
            $('#empi-lookup-results').empty()
            $('#empi-lookup .loading').removeClass('hide')
          ).on("ajax:success", (event) ->
            [data, status, xhr] = event.detail
            $('#empi-lookup-results').html(data.body.innerHTML)
            $('input[type="radio"][name="assign-empi-patient"]').on 'change', (e) ->
              $('#assign-empi-link').removeClass('disabled')
              $('#assign-empi-link').attr('disabled', false)
            return
          ).on("ajax:error", (event) ->
            $('#empi-lookup-results').empty()
            $("#empi-lookup-results").append '<div data-closable="" class="callout small alert"><button aria-label="dismiss alert" class="close-button" data-close="" type="button"><span aria-hidden="true">×</span></button>Error calling EMPI</div>'
            return
          ).on("ajax:complete", (event) ->
            $('#empi-lookup .loading').addClass('hide')
            return
          )
          return

        init()

        $('#empi-lookup .cancel-link').on 'click', (e) ->
          $modal.foundation 'close'
          e.preventDefault()
          return false

        return
      e.preventDefault()
      return false
    return
$(document).on 'turbolinks:load', ->
  return unless $('.patients.show').length > 0 || $('.patients.update').length > 0
  ui = new AllOfUsHelper.PatientShow
  ui.render('.new-empi-link')