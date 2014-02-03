module ActiverecordToPoro

  module MappingToArClass
    def call(pre_created_object=nil)
      self.target_source._from_attrs_with_metadata(to_hash_or_array(), pre_created_object)
    end
  end

  class ObjectMapper < Yaoc::ObjectMapper
    include ColumnHelper
    include ActiverecordToPoro::MapperExtension

    attr_accessor :association_converters,
                  :use_lazy_loading,
                  :except_attributes,
                  :only_attributes

    class << self
      private :new
    end

    def self.create(ar_class,
                    use_lazy_loading=true,
                    except: nil,
                    only: nil,
                    load_source: DefaultPoroClassBuilder.new(ar_class).(),
                    convert_associations: {})

      new(load_source, ar_class).tap do|new_mapper|
        new_mapper.fetcher(:public_send)

        new_mapper.association_converters = convert_associations
        new_mapper.use_lazy_loading = use_lazy_loading

        new_mapper.except_attributes = Array(except)
        new_mapper.only_attributes = only.nil? ? nil : Array(only) # an empty array can be wanted, so that there is no default mapping @ all

        new_mapper.add_default_mapping_for_current_class
        new_mapper.add_mapping_for_associations
      end
    end

    alias_method :extend_mapping, :add_mapping

    def attributes_for_default_mapping
      self.only_attributes || (
                                columns(self.dump_result_source) -
                                primary_keys(self.dump_result_source) -
                                association_specific_columns(self.dump_result_source) -
                                associated_object_accessors(self.dump_result_source) -
                                self.except_attributes
                              )
    end

    def load_result_source=(new_load_result)
      @load_result_source = new_load_result.tap do |source|
        unless source.instance_methods.include?(:_metadata)
          source.send(:include, MetadataEnabled)
        end
      end
    end

    def dump_result_source=(new_dump_result)
      @dump_result_source = new_dump_result.tap do |source|
        unless source.respond_to? :_from_attrs_with_metadata
          source.send(:extend, MetadataEnabledAr)
        end
      end
    end

    def add_default_mapping_for_current_class
      add_mapping do
        rule to: attributes_for_default_mapping

        rule to: :_set_metadata,
             converter: ->(source, result){ self.class.fill_result_with_value(result, :_set_metadata_from_ar, source) },
             reverse_converter: ->(source, result){ self.class.fill_result_with_value(result, :_set_metadata_to_ar, source._metadata) }
      end
    end

    def add_mapping_for_associations
      association_converters.each_pair do |association_name, association_converter|

        add_mapping do
          association_rule to: association_name,
                           lazy_loading: use_lazy_loading,
                           converter: association_converter
        end
      end
    end

    def reverse_converter(fetch_able=nil)
      reverse_converter_builder.converter(fetch_able, dump_result_source).tap do |new_converter|
        new_converter.extend(MappingToArClass)
      end
    end

  end

end