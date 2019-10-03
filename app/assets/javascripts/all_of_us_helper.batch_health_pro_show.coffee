class AllOfUsHelper.BatchHealthProShow
  constructor: () ->
  render: (link) ->
    $(link).on 'click', (e) ->
      $modal = $('#empi-lookup-modal')
      $empi_lookup = $('#empi-lookup-modal #empi-lookup')
      $.ajax(this.href).done (response) ->
        $modal.foundation 'open'
        $empi_lookup.html(response)
        initEmpi = () ->
          $('#assign-empi-link').on 'click', (e) ->
            empi_patient = $('input[name=assign-empi-patient]:checked').parents('.empi_patient')
            first_name = empi_patient.find('.first_name').text().trim()
            last_name = empi_patient.find('.last_name').text().trim()
            gender = empi_patient.find('.gender').text().trim()
            ethnicity = empi_patient.find('.ethnicity').text().trim()
            races = empi_patient.find('.race').text().trim()
            races = races.split('|')
            nmhc_mrn = empi_patient.find('.nmhc_mrn').text().trim()
            $("#patient-form").find('.nmhc_mrn .value').text(nmhc_mrn)
            $("#patient-form").find('.first_name .value').text(first_name)
            $("#patient-form").find('.last_name .value').text(last_name)
            $("#patient-form").find('#patient_gender').val(gender)
            $("#patient-form").find('#patient_ethnicity').val(ethnicity)
            i = 0
            while i < races.length
              $("input[data-text='#{races[i]}']").prop('checked', true)
              i++

            $("#patient_nmhc_mrn").val(nmhc_mrn)
            $("#patient_first_name").val(first_name)
            $("#patient_last_name").val(last_name)

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

        initEmpi()

        $('#empi-lookup .cancel-link').on 'click', (e) ->
          $modal.foundation 'close'
          e.preventDefault()
          return false

        return
      e.preventDefault()
      return false
    init = () ->
      $('input[name=assign-empi-match]').on 'change', (e) ->
        if $(this).is(':checked')
          $(this).parents('.health_pro').find('.match-form .empi_match_id').val($(this).val())
        else
          $(this).parents('.health_pro').find('.match-form .empi_match_id').val(undefined)

      $('.add-match-link').on 'click', (e) ->
        $(this).addClass('hide')
        $(this).parents('.health_pro').find('.match-patient-form').addClass('hide')
        $(this).parents('.health_pro').find('.match-create-form').removeClass('hide')

        $(this).parents('.health_pro').find('.patient_id').val('')
        $(this).parents('.health_pro').find('.patient_id').trigger('change')
        e.preventDefault()
        return false

      $('.match-create-form .cancel-link').on 'click', (e) ->
        $(this).parents('.health_pro').find('.match-patient-form').removeClass('hide')
        $(this).parents('.health_pro').find('.match-create-form').addClass('hide')
        $(this).parents('.health_pro').find('.add-match-link').removeClass('hide')
        e.preventDefault()
        return false

      $('.match-create-form .patient_id').select2(width: '150%')

    init()
    return

$(document).on 'turbolinks:load', ->
  return unless ($('.batch_health_pros.show').length > 0)
  ui = new AllOfUsHelper.BatchHealthProShow
  ui.render('.new-empi-link')