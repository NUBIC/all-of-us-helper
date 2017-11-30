namespace :setup do
  desc 'Load dummy patients'
  task(load_dummy_patients: :environment) do  |t, args|
    Patient.where(record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com').first_or_create
    Patient.where(record_id: '2', first_name: 'Moomintroll', last_name: 'Moomin', email: 'moomintroll.moomin@moomin.com').first_or_create
    Patient.where(record_id: '3', first_name: 'Moominmamma', last_name: 'Moomin', email: 'moominmamma.moomin@moomin.com').first_or_create
    Patient.where(record_id: '4', first_name: 'Moominpappa', last_name: 'Moomin', email: 'moominpappa.moomin@moomin.com').first_or_create
    Patient.where(record_id: '5', first_name: 'Snorkmadien', last_name: 'Moomin', email: 'snorkmadien.moomin@moomin.com').first_or_create
    Patient.where(record_id: '6', first_name: 'Snufkin', last_name: 'Moomin', email: 'snufkin.moomin@moomin.com').first_or_create
    Patient.where(record_id: '7', first_name: 'Sniff', last_name: 'Moomin', email: 'sniff.moomin@moomin.com').first_or_create
    Patient.where(record_id: '8', first_name: 'Stinky', last_name: 'Moomin', email: 'stinky.moomin@moomin.com').first_or_create
    Patient.where(record_id: '9', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com').first_or_create
    Patient.where(record_id: '10', first_name: 'The', last_name: 'Hemulen', email: 'the.hemulen@moomin.com').first_or_create
    Patient.where(record_id: '11', first_name: 'Toffle', last_name: 'Moomin', email: 'toffle.moomin@moomin.com').first_or_create
  end
end