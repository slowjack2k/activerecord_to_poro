require 'acceptance_spec_helper'

feature 'Map active record associations', %q{
   In order to use plain old ruby objects instead of active record objects
   as a lib user
   I want to map automatically associations
} do

  given!(:mapper){
    ActiverecordToPoro::Converter.new(a_active_record_class, roles: roles_converter, salutation: salutation_converter)
  }

  given!(:roles_converter){
    ActiverecordToPoro::Converter.new(Role)
  }

  given!(:salutation_converter){
    ActiverecordToPoro::Converter.new(Salutation)
  }

  given!(:a_active_record_class){
    User
  }

  given!(:a_active_record_object){
    a_active_record_class.create!(name: "my name", email: "my_name@example.com").tap do |user|
      user.roles.create!(name: "admin")
      user.roles.create!(name: "guest")

      user.roles.first.permissions.create!(name: "first_permission")
      user.roles.first.permissions.create!(name: "second_permission")

      user.roles.last.permissions.create!(name: "third_permission")

      user.salutation = Salutation.create!(name: "Mister")

      user.address = Address.create!(street: 'Westminster Abbey')

      user.save!

      user.reload
    end
  }


  scenario "creates a poro out of an ActiveRecord object with associations set" do
    expect(mapper.load(a_active_record_object).roles.size).to eq 2
    expect(mapper.load(a_active_record_object).salutation.name).to eq "Mister"
  end

  scenario "creates an ActiveRecord object from a poro object with associations set" do
    poro = mapper.load(a_active_record_object)
    expect(mapper.dump(poro).roles.size).to eq 2
    expect(mapper.dump(poro).permissions.size).to eq 3
  end

  scenario "lazy loads associated objects" do
    expect(a_active_record_object).not_to receive :salutation
    expect(a_active_record_object).not_to receive :roles

    mapper.load(a_active_record_object)
  end

end