module EmpiHelper
  def format_address(empi_patient)
    [empi_patient['address_line1'], empi_patient['city'], empi_patient['state'], empi_patient['zip']].compact.join(' ')
  end
end
