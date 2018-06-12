class AllOfUsHelper.BatchHealthProShow
  constructor: () ->
  render: (link) ->
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

      $('.match-create-form .patient_id').select2(width: '100%')

    init()

    # $('.match-create-form').on 'ajax:error', (event) ->
    #   [data, status, xhr] = event.detail
    #   $('.match-create-patient-form-container').html(data.body.innerHTML)
    #   init()

    return

$(document).on 'turbolinks:load', ->
  return unless ($('.batch_health_pros.show').length > 0)
  ui = new AllOfUsHelper.BatchHealthProShow
  ui.render('.new-empi-link')