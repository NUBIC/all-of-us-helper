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
          $('#empi_gender').on 'change', (e) ->
            if ($(this).val())
              $('#empi-search-button').prop('disabled', false)
            else
              $('#empi-search-button').prop('disabled', true)

          $('#assign-empi-link').on 'click', (e) ->
            empi_patient = $('input[name=assign-empi-patient]:checked').parents('.empi_patient')
            gender = empi_patient.find('.gender').text().trim()
            nmhc_mrn = empi_patient.find('.nmhc_mrn').text().trim()
            match_id = $(this).parents('#empi-lookup').find('.match_id').val()
            $("#match_#{match_id}").find('tbody .gender').text(gender)
            $("#match_#{match_id}").find('tbody .nmhc_mrn').text(nmhc_mrn)
            $("#match_#{match_id}").find('#match_gender').val(gender)
            $("#match_#{match_id}").find('#match_nmhc_mrn').val(nmhc_mrn)

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
  return unless ($('.batch_health_pros.show').length > 0)
  ui = new AllOfUsHelper.BatchHealthProShow
  ui.render('.new-empi-link')