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
      end

      it 'converts also associated objects' do
        expect(subject.load(ar_object).roles.size).to eq 2
      end

      it 'lazy loads associated objects' do
        expect(ar_object).not_to receive :roles
        subject.load(ar_object)
      end

      it 'fills an existing poro' do
        poro_to_fill = subject.load_result_class.new
        expect(subject.load(ar_object, poro_to_fill).object_id).to eq poro_to_fill.object_id
      end

    end

    describe '#dump' do
      it 'creates an ActiveRecord object' do
        expect(subject.dump(loaded_poro_object)).to be_kind_of ActiveRecord::Base
      end

      it 'converts also associated objects' do
        count_roles = ar_object.roles.size

        expect(subject.dump(loaded_poro_object).roles.size).to eq count_roles
      end

      it 'fills an existing ActiveRecord object' do
        new_ar_object = User.new
        expect(subject.dump(loaded_poro_object, new_ar_object).object_id).to eq new_ar_object.object_id
      end
    end

  end
end