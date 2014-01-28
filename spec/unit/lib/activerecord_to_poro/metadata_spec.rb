require 'unit_spec_helper'

describe ActiverecordToPoro::Metadata do
  let(:ar_object){
    Struct.new(:id) do
      def self.primary_key
        "id"
      end

    end.new(1)
  }

  describe "#initialize_from_ar" do

    it "sets the primary_key" do
      subject.initialize_from_ar(ar_object)

      expect(subject.primary_key_column).to eq "id"
      expect(subject.primary_key_value).to eq 1
    end

  end

  describe "set_primary_key" do
    it "sets the primary_key" do
      subject.set_primary_key(ar_object)

      expect(subject.primary_key_column).to eq "id"
      expect(subject.primary_key_value).to eq 1
    end
  end
end