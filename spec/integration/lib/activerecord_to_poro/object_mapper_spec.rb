require 'integration_spec_helper'

describe ActiverecordToPoro::ObjectMapper do

  describe '.new' do
    subject{
      ActiverecordToPoro::ObjectMapper
    }

    it 'removes "except" attributes from default mapping' do
      object = subject.create(User, except: :lock_version)
      expect(object.attributes_for_default_mapping).not_to include :lock_version
    end

    it 'uses "only" attributes for default mapping' do
      object = subject.create(User, only: :id)
      expect(object.attributes_for_default_mapping).to eq [:id]
    end

    it 'wraps the poro constructor if no massassignment is wanted' do

      object = subject.create(User, only: :id, use_mass_assignment_constructor: false)
      expect(object.load_result_source).to be_kind_of Proc
    end

    it 'wraps the poro constructor if no massassignment is wanted' do
      result_class = Struct.new(:id)
      object = subject.create(User, load_source: result_class, only: :id, use_mass_assignment_constructor: false)
      expect(object.load_result_source).to be_kind_of Proc
    end

    it 'does not wrap the poro constructor if massassignment is wanted' do
      result_class = Struct.new(:id)
      object = subject.create(User, load_source: result_class, only: :id, use_mass_assignment_constructor: true)
      expect(object.load_result_source).to be result_class
    end

  end

  context 'instance methods' do
    subject!{
      ActiverecordToPoro::ObjectMapper.create(User,  convert_associations: {roles: roles_converter,
                                                                            salutation: salutation_converter})
    }

    let(:roles_converter){
      ActiverecordToPoro::ObjectMapper.create(Role)
    }

    let(:salutation_converter){
      ActiverecordToPoro::ObjectMapper.create(Salutation)
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
        poro_to_fill = subject.load_result_source.new
        expect(subject.load(ar_object, poro_to_fill).object_id).to eq poro_to_fill.object_id
      end

      it 'resets changes flag if a method is given, mass assignment not used and no prefilled object given' do
        result_class = Struct.new(:id) do
          def reset_changes_flag
            @reset_changes = :called
          end

          def reset_changes
            @reset_changes ||= :not_called
          end
        end
        mapper = ActiverecordToPoro::ObjectMapper.create(User,
                                                         load_source: result_class,
                                                         only: :id,
                                                         use_mass_assignment_constructor: false)


        poro = mapper.load(ar_object)

        expect(poro.reset_changes).to eq :called
      end

    end

    describe '#dump' do
      it 'creates an ActiveRecord object' do
        expect(subject.dump(loaded_poro_object)).to be_kind_of ActiveRecord::Base
      end

      it 'loads the object from database when primary key and value are given in metadata' do
        expect(subject.dump(loaded_poro_object).new_record?).to be_falsy
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