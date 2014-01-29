module ActiverecordToPoro
  class Converter
    include ColumnHelper

    attr_accessor :load_source_class,
                  :dump_source_class,
                  :association_converters,
                  :use_lazy_loading,
                  :except_attributes,
                  :only_attributes

    def initialize(ar_class,
                   use_lazy_loading=true,
                   except: nil,
                   only: nil,
                   load_source: nil,
                   convert_associations: {})
      self.load_source_class = ar_class
      self.dump_source_class = load_source || DefaultPoroClassBuilder.new(ar_class).()
      self.association_converters = convert_associations
      self.use_lazy_loading = use_lazy_loading
      self.except_attributes = Array(except)
      self.only_attributes = only.nil? ? nil : Array(only) # an empty array can be wanted, so that there is no default mapping @ all
    end

    def load(to_convert)
      mapper.load(to_convert)
    end

    def dump(to_convert)
      mapper.dump(to_convert)
    end

    def extend_mapping(&block)
      mapper.add_mapping &block
    end


    def mapper
      @mapper||= Yaoc::ObjectMapper.new(self.dump_source_class, self.load_source_class).tap do |mapper|
        mapper.extend ActiverecordToPoro::MapperExtension
        mapper.fetcher(:public_send)

        add_default_mapping_for_current_class(mapper)
        add_mapping_for_associations(mapper)
      end
    end

    def attributes_for_default_mapping
      self.only_attributes || (
                                columns(self.load_source_class) -
                                primary_keys(self.load_source_class) -
                                association_specific_columns(self.load_source_class) -
                                associated_object_accessors(self.load_source_class) -
                                self.except_attributes
                              )
    end

    protected

    def add_default_mapping_for_current_class(mapper)
      tmp_quirk = attributes_for_default_mapping

      mapper.add_mapping do
        rule to: tmp_quirk

        rule to: :_set_metadata,
             converter: ->(source, result){ fill_result_with_value(result, :_set_metadata_from_ar, source) },
             reverse_converter: ->(source, result){ result }
      end
    end

    def add_mapping_for_associations(mapper)
      association_converters.each_pair do |association_name, association_converter|

        lazy_quirk = self.use_lazy_loading

        mapper.add_mapping do
          association_rule to: association_name,
                           lazy_loading: lazy_quirk,
                           converter: association_converter
        end
      end
    end

    def dump_source_class=(new_dump_source)
      @dump_source_class = new_dump_source.tap do |source|
        unless source.respond_to? :_metadata
          source.send(:include, MetadataEnabled)
        end
      end
    end

    def load_source_class=(new_source)
      @load_source_class=new_source
    end

  end
end