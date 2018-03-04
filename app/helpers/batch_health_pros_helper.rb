module BatchHealthProsHelper
  def determine_callout(status)
    case status
    when BatchHealthPro::STATUS_PENDING
      'warning'
    when BatchHealthPro::STATUS_READY
      'success'
    end
  end
end
