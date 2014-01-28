module ActiverecordToPoro
  class Converter
    include ColumnHelper

    attr_accessor :load_source_class, :dump_source_class, :association_converters

    def initialize(ar_class, **association_converters)
      self.load_source_class = ar_class
      self.dump_source_class = DefaultPoroClassBuilder.new(ar_class).()
      self.association_converters = association_converters
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

    protected

    def add_mapping_for_current_class(mapper)
      tmp_quirk = plain_attributes

      mapper.add_mapping do
        fetcher :public_send
        rule to: tmp_quirk

        rule to: :_set_metadata,
             converter: ->(source, result){ fill_result_with_value(result, :_set_metadata_from_ar, source) },
             reverse_converter: ->(source, result){ fill_result_with_value(result,:_set_metadata_to_ar, source._metadata.to_hash) }
      end
    end

    def add_mapping_for_associations(mapper)
      association_converters.each_pair do |association_name, association_converter|
        map_collection = self.load_source_class.reflections[association_name].collection?

        mapper.add_mapping do
          fetcher :public_send
          rule to: association_name,
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

    def plain_attributes
      columns(self.load_source_class) -
      primary_keys(self.load_source_class) -
      association_specific_columns(self.load_source_class) -
      associated_object_accessors(self.load_source_class)
    end

  end
end