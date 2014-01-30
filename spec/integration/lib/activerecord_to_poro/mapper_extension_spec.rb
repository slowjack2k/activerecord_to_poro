require 'integration_spec_helper'

describe ActiverecordToPoro::MapperExtension do
  subject{
    Yaoc::ObjectMapper.new(target, source).tap do |mapper|
      mapper.extend ActiverecordToPoro::MapperExtension
      mapper.fetcher(:public_send)
    end
  }

  let(:source){ User }

  let(:target){ActiverecordToPoro::DefaultPoroClassBuilder.new(source).()}

  let(:default_expected_params){
    {
        :to=>:roles,
        :from=>:roles,
        :reverse_to=>:roles,
        :reverse_from=>:roles,
        :reverse_lazy_loading=>false,
        :is_collection=>true,
        :lazy_loading=>nil,
        :object_converter=>mapper,
        :reverse_object_converter=>mapper
    }
  }

  let(:mapper){
    double("mapper")
  }

  let(:converter){
    double("converter", mapper: mapper)
  }

  describe '#association_rule' do
    it "uses defaults" do
      expect(subject).to receive(:rule).with default_expected_params
      subject.association_rule(to: :roles,
                               converter: converter
      )
    end

    it "does not convert forward when converter is nil" do
      expected_params = default_expected_params.merge(converter: kind_of(Proc),
                                                      reverse_converter: kind_of(Proc),
                                                      object_converter: nil,
                                                      reverse_object_converter: nil
      )

      expect(subject).to receive(:rule).with expected_params

      subject.association_rule(
          to: :roles,
          converter: nil
      )
    end

    it "does not convert reverse when reverse converter is nil" do
      expected_params = default_expected_params.merge(
                                                      reverse_converter: kind_of(Proc),
                                                      reverse_object_converter: nil
      )

      expect(subject).to receive(:rule).with expected_params

      subject.association_rule(
          to: :roles,
          converter: converter,
          reverse_converter: nil
      )
    end

    it "disables reverse converter when the association is kind of has many through (no setter from rails)" do
      expected_params = default_expected_params.merge(
          reverse_converter: kind_of(Proc),
          reverse_object_converter: nil,
          :to=>:permissions,
          :from=>:permissions,
          :reverse_to=>:permissions,
          :reverse_from=>:permissions,
      )

      expect(subject).to receive(:rule).with expected_params

      subject.association_rule(
          to: :permissions,
          converter: converter
      )
    end
  end
end