require 'unit_spec_helper'

describe ActiverecordToPoro::Metadata do
  let(:ar_class){
    Struct.new(:id) do
      def self.primary_key
        "id"
      end

      def self.name
        "MyNameIsStruct"
      end

    end
  }

  let(:ar_object_1){
    ar_class.new(1)
  }

  let(:ar_object_2){
    ar_class.new(2)
  }


  describe "#initialize_from_ar" do

    it "sets the primary_key" do
      subject.initialize_from_ar(ar_object_1)

      expect(subject.to_hash).to include( source_objects_info: [{class_name: "MyNameIsStruct",
                                                                 primary_key: {:column=>"id", :value=>1},
                                                                 object_id: ar_object_1.object_id,
                                                                 lock_version: nil
                                                                }])
    end

    it "adds multiple objects" do
      subject.initialize_from_ar(ar_object_1)
      subject.initialize_from_ar(ar_object_2)

      expect(subject.to_hash[:source_objects_info].size).to eq 2
    end

    it "adds the same object only once" do
      subject.initialize_from_ar(ar_class.new(1))
      subject.initialize_from_ar(ar_class.new(1))

      expect(subject.to_hash[:source_objects_info].size).to eq 1
    end

  end

  describe '#for_ar_class' do
    it 'returns metadata for a ActiveRecord class' do
      subject.initialize_from_ar(ar_object_1)

      expect(subject.for_ar_class(ar_class.name).to_hash).to include({primary_key: {column: "id", value: 1}})
    end
  end

end