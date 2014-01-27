require "acceptance_spec_helper"

feature "Map active record objects", %q{
   In order to use plain old ruby objects instead of active record objects
   as a lib user
   I want to map from active record objects to plain old ruby objects and reverse
} do

  given(:mapper){
    ActiverecordToPoro::Converter.new(a_active_record_class)
  }

  given(:a_active_record_class){
    User
  }

  given(:a_active_record_object){
    a_active_record_class.create!(name: "my name", email: "my_name@example.com")
  }

  given(:expected_poro_class_attributes){
    [:name, :email, :roles, :salutation]
  }


  scenario "creates a poro out of an ActiveRecord object" do
    expect(mapper.load(a_active_record_object).members).to eq expected_poro_class_attributes
  end

  scenario "creates an ActiveRecord object from a poro object" do
    poro = mapper.load(a_active_record_object)
    expect(mapper.dump(poro)).to eq a_active_record_object
  end

end