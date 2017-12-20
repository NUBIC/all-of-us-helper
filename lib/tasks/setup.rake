require 'yaml'
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

  desc 'Load dummy invitation codes'
  task(load_dummy_invitation_codes: :environment) do  |t, args|
    (1...20)  .to_a.each do |invitation_code|
      InvitationCode.where(code: invitation_code.to_s).first_or_create
    end
  end

  desc "Load settings"
  task(settings: :environment) do  |t, args|
    if Setting.count == 0
      Setting.create!(auto_assign_invitation_codes: true)
    end
  end

  desc "Setup roles and role assignments"
  task(roles_and_role_assignments: :environment) do  |t, args|
    Role.setup
    users_from_file = YAML.load(ERB.new(File.read("lib/setup/data/users.yml")).result)

    users_from_file.each_pair do |username, user_from_file|
      user = User.where(user_from_file).first_or_create
      if user && !user.has_role?(Role::ROLE_ALL_OF_US_HELPER_USER)
        user.roles << Role.where(name: Role::ROLE_ALL_OF_US_HELPER_USER).first
        user.save!
      end
    end
  end
end