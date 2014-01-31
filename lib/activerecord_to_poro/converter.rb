module ActiverecordToPoro
  class Converter
    include ColumnHelper

    attr_accessor :dump_result_class,
                  :load_result_class,
                  :association_converters,
                  :use_lazy_loading,
                  :except_attributes,
                  :only_attributes

    def self.create(ar_class,
                    use_lazy_loading=true,
                    except: nil,
                    only: nil,
                    load_source: nil,
                    convert_associations: {})
      new.tap do|new_mapper|
        new_mapper.dump_result_class = ar_class
        new_mapper.load_result_class = load_source || DefaultPoroClassBuilder.new(ar_class).()
        new_mapper.association_converters = convert_associations
        new_mapper.use_lazy_loading = use_lazy_loading
        new_mapper.except_attributes = Array(except)
        new_mapper.only_attributes = only.nil? ? nil : Array(only) # an empty array can be wanted, so that there is no default mapping @ all
      end
    end

    class << self
      private :new
    end

    def load(to_convert, object_to_fill=nil)
      mapper.load(to_convert, object_to_fill)
    end

    def dump(to_convert, ar_object=nil)
      mapper.dump(to_convert, ar_object)
    end

    def extend_mapping(&block)
      mapper.add_mapping &block
    end


    def mapper
      @mapper||= Yaoc::ObjectMapper.new(self.load_result_class, self.dump_result_class).tap do |mapper|
        mapper.extend ActiverecordToPoro::MapperExtension
        mapper.fetcher(:public_send)

        add_default_mapping_for_current_class(mapper)
        add_mapping_for_associations(mapper)
      end
    end

    def attributes_for_default_mapping
      self.only_attributes || (
                                columns(self.dump_result_class) -
                                primary_keys(self.dump_result_class) -
                                association_specific_columns(self.dump_result_class) -
                                associated_object_accessors(self.dump_result_class) -
                                self.except_attributes
                              )
    end

    def load_result_class=(new_load_result)
      @load_result_class = new_load_result.tap do |source|
        unless source.respond_to? :_metadata
          source.send(:include, MetadataEnabled)
        end
      end
    end

    protected

    def add_default_mapping_for_current_class(mapper)
      tmp_quirk = attributes_for_default_mapping

      mapper.add_mapping do
        rule to: tmp_quirk

        rule to: :_set_metadata,
             converter: ->(source, result){ self.class.fill_result_with_value(result, :_set_metadata_from_ar, source) },
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

  end
end