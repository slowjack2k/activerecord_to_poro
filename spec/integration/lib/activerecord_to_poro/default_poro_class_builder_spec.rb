require 'integration_spec_helper'

describe ActiverecordToPoro::DefaultPoroClassBuilder do
  subject{
    ActiverecordToPoro::DefaultPoroClassBuilder.new(User)
  }

  let(:expected_poro_class){
    Yaoc::Helper::StructHE(:name, :email, :roles, :salutation, :address, :permissions)
  }

  describe "#call" do

    it "creates a poro class for an ActiveRecord class" do
      expect(subject.call.members.sort).to eq expected_poro_class.members.sort
    end

  end
end