require "acceptance_spec_helper"

feature "Map active record objects", %q{
   In order to use plain old ruby objects instead of active record objects
   as a lib user
   I want to map from active record objects to plain old ruby objects and reverse
} do

  given(:mapper){
    ActiverecordToPoro::Converter.new(a_active_record_class)
  }

  given(:mapper_with_custom_source){
    ActiverecordToPoro::Converter.new(a_active_record_class,
                                      load_source: custom_target_class,
                                      except: [:lock_version]
    )
  }

  given(:a_active_record_class){
    User
  }

  given(:a_active_record_object){
    a_active_record_class.create!(name: "my name", email: "my_name@example.com")
  }

  given(:custom_target_class){
    ActiverecordToPoro::DefaultPoroClassBuilder.new(a_active_record_class).()
  }

  scenario "creates a poro out of an ActiveRecord object" do
    expect(mapper.load(a_active_record_object)).not_to be_kind_of ActiveRecord::Base
  end

  scenario "creates an ActiveRecord object from a poro object" do
    poro = mapper.load(a_active_record_object)
    expect(mapper.dump(poro)).to eq a_active_record_object
  end

  scenario "use my own source class for converting ActiveRecord objects" do
    expect(mapper_with_custom_source.load(a_active_record_object)).to be_kind_of custom_target_class
  end

end