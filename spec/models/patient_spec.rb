require 'rails_helper'
require 'active_support'

RSpec.describe Patient, type: :model do
  before(:each) do
    @patient_1 = FactoryGirl.create(:patient, record_id: '1', first_name: 'Little', last_name: 'My', email: 'little.my@moomin.com')
    @patient_2 = FactoryGirl.create(:patient, record_id: '2', first_name: 'The', last_name: 'Groke', email: 'the.groke@moomin.com')
  end

  it 'can search across fields (by first_name)', focus: false do
    expect(Patient.search_across_fields('Little')).to match_array([@patient_1])
  end

  it 'can search across fields (by first_name) case insensitively', focus: false do
    expect(Patient.search_across_fields('little')).to match_array([@patient_1])
  end

  it 'can search across fields (and sort ascending/descending by a passed in column first_name)', focus: false do
    expect(Patient.search_across_fields(nil, { sort_column: 'first_name', sort_direction: 'asc' })).to eq([@patient_1, @patient_2])
    expect(Patient.search_across_fields(nil, { sort_column: 'first_name', sort_direction: 'desc' })).to eq([@patient_2, @patient_1])
  end

  it 'can search across fields (by last_name)', focus: false do
    expect(Patient.search_across_fields('My')).to match_array([@patient_1])
  end

  it 'can search across fields (by last_name) case insensitively', focus: false do
    expect(Patient.search_across_fields('my')).to match_array([@patient_1])
  end

  it 'can search across fields (and sort ascending/descending by a passed in column last_name)', focus: false do
    expect(Patient.search_across_fields(nil, { sort_column: 'last_name', sort_direction: 'asc' })).to eq([@patient_2, @patient_1])
    expect(Patient.search_across_fields(nil, { sort_column: 'last_name', sort_direction: 'desc' })).to eq([@patient_1, @patient_2])
  end

  it 'can search across fields (by email)', focus: false do
    expect(Patient.search_across_fields('little.my@moomin.com')).to match_array([@patient_1])
  end

  it 'can search across fields (by email) case insensitively', focus: false do
    expect(Patient.search_across_fields('LITTLE.MY@MOOMIN.COM')).to match_array([@patient_1])
  end

  it 'can search across fields (and sort ascending/descending by a passed in column email)', focus: false do
    expect(Patient.search_across_fields(nil, { sort_column: 'email', sort_direction: 'asc' })).to eq([@patient_1, @patient_2])
    expect(Patient.search_across_fields(nil, { sort_column: 'email', sort_direction: 'desc' })).to eq([@patient_2, @patient_1])
  end

  it 'can search across fields (by record_id)', focus: false do
    expect(Patient.search_across_fields('2')).to match_array([@patient_2])
  end

  it 'can search across fields (and sort ascending/descending by a passed in column record_id)', focus: false do
    expect(Patient.search_across_fields(nil, { sort_column: 'email', sort_direction: 'asc' })).to eq([@patient_1, @patient_2])
    expect(Patient.search_across_fields(nil, { sort_column: 'email', sort_direction: 'desc' })).to eq([@patient_2, @patient_1])
  end
end