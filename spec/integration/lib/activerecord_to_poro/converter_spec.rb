require 'integration_spec_helper'

describe ActiverecordToPoro::Converter do

  describe '.new' do
    subject{
      ActiverecordToPoro::Converter
    }

    it 'removes "except" attributes from default mapping' do
      object = subject.new(User, except: :lock_version)
      expect(object.attributes_for_default_mapping).not_to include :lock_version
    end

    it 'uses "only" attributes for default mapping' do
      object = subject.new(User, only: :id)
      expect(object.attributes_for_default_mapping).to eq [:id]
    end

  end

  context 'instance methods' do
    subject!{
      ActiverecordToPoro::Converter.new(User,  convert_associations: {roles: roles_converter, salutation: salutation_converter})
    }

    let(:roles_converter){
      ActiverecordToPoro::Converter.new(Role)
    }

    let(:salutation_converter){
      ActiverecordToPoro::Converter.new(Salutation)
    }

    let(:ar_object){
      User.create!(name: 'my name', email: 'my_name@example.com').tap do |user|
        user.roles.create!(name: 'admin')
        user.roles.create!(name: 'guest')
      end
    }

    let!(:loaded_poro_object){
      subject.load(ar_object)
    }

    describe '#load' do
      it 'creates a poro' do
        expect(subject.load(ar_object)).not_to be_kind_of ActiveRecord::Base
      end

      it 'sets metadata for loaded objects' do
        expect(loaded_poro_object._metadata).not_to be_nil
        expect(loaded_poro_object._metadata.primary_key_value).to eq ar_object.id
      end

      it 'converts also associated objects' do
        expect(subject.load(ar_object).roles.size).to eq 2
      end

      it 'lazy loads associated objects' do
        expect(ar_object).not_to receive :roles
        subject.load(ar_object)
      end

    end

    describe '#dump' do
      it 'creates an ActiveRecordObject' do
        expect(subject.dump(loaded_poro_object)).to be_kind_of ActiveRecord::Base
      end

      it 'sets the primary key when it existed before' do
        expect(subject.dump(loaded_poro_object).id).to eq ar_object.id
      end

      it 'sets new_record to false when it is an existing record' do
        expect(subject.dump(loaded_poro_object).new_record?).to be_falsy
      end

      it 'converts also associated objects' do
        count_roles = ar_object.roles.size

        expect(subject.dump(loaded_poro_object).roles.size).to eq count_roles
      end
    end

  end
end