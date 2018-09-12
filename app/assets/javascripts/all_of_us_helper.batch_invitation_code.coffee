class AllOfUsHelper.BatchInvitationCode
  constructor: () ->
  render: () ->
    $('.remove_invitation_code_file_link ').on 'click', (e) ->
      if $('#batch_invitation_code_invitation_code_file').hasClass('hide')
        $('#batch_invitation_code_invitation_code_file').removeClass('hide')
        $(this).addClass('hide')
        $('.invitation_code_file_url').addClass('hide')
        $('#batch_invitation_code_invitation_code_file').val('')
        $('#batch_invitation_code_invitation_code_file_cache').val('')
      else
        $('#batch_invitation_code_invitation_code_file').addClass('hide')
      e.preventDefault()

$(document).on 'turbolinks:load', ->
  return unless ($('.batch_invitation_codes.new').length > 0 || $('.batch_invitation_codes.create').length > 0)
  ui = new AllOfUsHelper.BatchInvitationCode
  ui.render()