class AllOfUsHelper.PatientShow
  constructor: () ->
  render: (link) ->
    $(':checkbox').change ->
      if $(this).data('text') == 'Unknown or Not Reported' && $(this).prop('checked') == true
          $("input[data-text!='Unknown or Not Reported']").prop('checked', false)
      if $(this).data('text') != 'Unknown or Not Reported' && $(this).prop('checked') == true
          $("input[data-text='Unknown or Not Reported']").prop('checked', false)

    $(link).on 'click', (e) ->
      $modal = $('#empi-lookup-modal')
      $empi_lookup = $('#empi-lookup-modal #empi-lookup')
      $.ajax(this.href).done (response) ->
        $modal.foundation 'open'
        $empi_lookup.html(response)
        init = () ->
          $('#assign-empi-link').on 'click', (e) ->
            empi_patient = $('input[name=assign-empi-patient]:checked').parents('.empi_patient')
            # gender = empi_patient.find('.gender').text().trim()
            nmhc_mrn = empi_patient.find('.nmhc_mrn').text().trim()
            # nmh_mrn = empi_patient.find('.nmh_mrn').text().trim()
            # nmff_mrn = empi_patient.find('.nmff_mrn').text().trim()
            # lfh_mrn = empi_patient.find('.lfh_mrn').text().trim()
            # $("#match_#{match_id}").find('.value .gender').text(gender)
            $("#patient-form").find('.nmhc_mrn .value').text(nmhc_mrn)
            # $("#patient-show").find('.nmh_mrn .value').text(nmh_mrn)
            # $("#patient-show").find('.nmff_mrn .value').text(nmff_mrn)
            # $("#patient-show").find('.lfh_mrn .value').text(lfh_mrn)
            #
            # $("#patient-form").find('#patient_gender').val(gender)
            $("#patient_nmhc_mrn").val(nmhc_mrn)
            # $("#patient-form").find('#patient_nmh_mrn').val(nmh_mrn)
            # $("#patient-form").find('#patient_nmff_mrn').val(nmff_mrn)
            # $("#patient-form").find('#patient_lfh_mrn').val(lfh_mrn)

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
            alert('hello booch error')
            # $("#new_article").append "<p>ERROR</p>"
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
  return unless $('.patients.show').length > 0
  ui = new AllOfUsHelper.PatientShow
  ui.render('.new-empi-link')