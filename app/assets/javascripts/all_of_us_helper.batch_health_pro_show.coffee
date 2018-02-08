class AllOfUsHelper.BatchHealthProShow
  constructor: () ->
  render: (link) ->
    $(link).on 'click', (e) ->
      $modal = $('#empi-lookup-modal')
      $empi_lookup = $('#empi-lookup-modal #empi-lookup')
      $.ajax(this.href).done (response) ->
        $modal.foundation 'open'
        $empi_lookup.html(response)
        init = () ->
          $('#assign-empi-link').on 'click', (e) ->
            empi_patient = $('input[name=assign-empi-patient]:checked').parents('.empi_patient')
            first_name = empi_patient.find('.first_name').text()
            last_name = empi_patient.find('.last_name').text()
            birth_date = empi_patient.find('.birth_date').text()
            gender = empi_patient.find('.gender').text()
            nmhc_mrn = empi_patient.find('.nmhc_mrn').text()
            nmh_mrn = empi_patient.find('.nmh_mrn').text()
            nmff_mrn = empi_patient.find('.nmff_mrn').text()
            lfh_mrn = empi_patient.find('.lfh_mrn').text()
            alert(first_name)
            alert(last_name)
            alert(birth_date)
            alert(gender)
            alert(nmhc_mrn)
            alert(nmh_mrn)
            alert(nmff_mrn)
            alert(lfh_mrn)
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
            # $("#new_article").append "<p>ERROR</p>"
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
  return unless ($('.batch_health_pros.show').length > 0)
  ui = new AllOfUsHelper.BatchHealthProShow
  ui.render('.new-empi-link')