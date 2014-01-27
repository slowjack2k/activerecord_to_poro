require 'unit_spec_helper'

describe ActiverecordToPoro::Metadata do
  let(:ar_object){
    Struct.new(:id) do
      def self.primary_key
        "id"
      end

      def new_record?
        @new_record
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

  describe "#apply_to_ar_object" do
    subject!{
      ActiverecordToPoro::Metadata.new.tap do |subject|
        subject.initialize_from_ar(ar_object)
      end
    }

    it "sets the primary_key" do
      ar_object.id = nil
      subject.apply_to_ar_object(ar_object)

      expect(ar_object.id).to eq 1
    end

    it "sets new_record to false when an primary key value exists" do
      ar_object.id = nil
      subject.apply_to_ar_object(ar_object)

      expect(ar_object.new_record?).to be_falsy
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