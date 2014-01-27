require "acceptance_spec_helper"

feature "Map active record objects", %q{
   In order to use plain old ruby objects instead of active record objects
   as a lib user
   I want to map active record objects from to plain old ruby objects and reverse
} do

  given(:mapper){
    ActiverecordToPoro::Converter.new(a_active_record_class)
  }

  given(:a_active_record_class){
    MyArClass
  }

  given(:a_active_record_object){
    a_active_record_class.new(name: "my name", email: "my_name@example.com")
  }

  given(:expected_poro_class){
    Yaoc::Helper::StructHE(:name, :email)
  }

  given(:expected_poro_object){
    expected_poro_class.new(name: "my name", email: "my_name@example.com")
  }


  scenario "creates a poro out of an active record object" do
    #Ar.relations
    #Ar.asso.loaded?
    #...
    expect(mapper.load(a_active_record_object)).to eq expected_poro_object
  end

end