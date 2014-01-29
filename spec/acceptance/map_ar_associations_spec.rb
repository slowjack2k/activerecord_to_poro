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

  given!(:permissions_converter){
    ActiverecordToPoro::Converter.new(Permission)
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

  given(:a_custom_poro_class){
    ActiverecordToPoro::DefaultPoroClassBuilder.new(a_active_record_class).().tap do |new_class|
      new_class.send(:attr_accessor, :some_other_name)
    end
  }

  given(:mapper_with_custom_source){
    ActiverecordToPoro::Converter.new(a_active_record_class,
                                      load_source: a_custom_poro_class,
                                      except: [:lock_version]
    )
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

  scenario 'add custom association mappings' do
    quirk_converter = permissions_converter

    mapper_with_custom_source.extend_mapping do

      association_rule to: :some_other_name,
                       from: :permissions,
                       converter: quirk_converter,
                       lazy_loading: true

    end

    user_poro = mapper_with_custom_source.load(a_active_record_object)

    expect(user_poro.some_other_name.size).to eq 3
  end

end