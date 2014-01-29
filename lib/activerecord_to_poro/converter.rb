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
                  **association_converters)
      self.load_source_class = ar_class
      self.dump_source_class = load_source || DefaultPoroClassBuilder.new(ar_class).()
      self.association_converters = association_converters
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

    def mapper
      @mapper||= Yaoc::ObjectMapper.new(self.dump_source_class, self.load_source_class).tap do |mapper|
        add_mapping_for_current_class(mapper)
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

    def add_mapping_for_current_class(mapper)
      tmp_quirk = attributes_for_default_mapping

      mapper.add_mapping do
        fetcher :public_send
        rule to: tmp_quirk

        rule to: :_set_metadata,
             converter: ->(source, result){ fill_result_with_value(result, :_set_metadata_from_ar, source) },
             reverse_converter: ->(source, result){

               needs_conversion = if source.respond_to?("_needs_conversion?")
                                    source._needs_conversion?
                                  else
                                    ! source.nil? #would trigger lazy loading when it is a ToProcDelegator
                                  end

               fill_result_with_value(result, :_set_metadata_to_ar, source._metadata.to_hash) if needs_conversion
             }
      end
    end

    def add_mapping_for_associations(mapper)
      association_converters.each_pair do |association_name, association_converter|
        map_collection = self.load_source_class.reflections[association_name].collection?

        lazy_quirk = self.use_lazy_loading

        mapper.add_mapping do
          fetcher :public_send
          rule to: association_name,
               lazy_loading: lazy_quirk,
               reverse_lazy_loading: false, #AR doesn't like ToProcDelegator
               object_converter: association_converter.mapper,
               is_collection: map_collection
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
      @load_source_class=new_source.tap do |source|
        unless source.respond_to? :_set_metadata_to_ar=
          source.send(:include, ActiverecordToPoro::MetadataToAr)
        end
      end
    end

  end
end