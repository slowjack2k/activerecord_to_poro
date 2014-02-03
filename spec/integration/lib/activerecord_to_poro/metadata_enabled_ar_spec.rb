require 'integration_spec_helper'

describe ActiverecordToPoro::MetadataEnabledAr do
  subject{
    User.extend ActiverecordToPoro::MetadataEnabledAr
    User
  }

  let(:ar_object){
    User.create!(name: 'my name', email: 'my_name@example.com')
  }

  let(:metadata){
    ActiverecordToPoro::Metadata.new.tap do |meta|
      meta.initialize_from_ar(ar_object)
    end
  }

  describe '._from_attrs_with_metadata' do
    it 'loads a record from db' do
      new_user = subject._from_attrs_with_metadata({_set_metadata_to_ar: metadata })
      expect(new_user.new_record?).to be_falsy
    end

    it 'uses a precreated object' do
      new_user = subject._from_attrs_with_metadata({_set_metadata_to_ar: metadata }, ar_object)
      expect(new_user.object_id).to eq ar_object.object_id
    end

  end

end