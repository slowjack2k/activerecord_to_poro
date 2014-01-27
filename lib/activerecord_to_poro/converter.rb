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
      mapper.load(to_convert).tap do |poro|
        poro._metadata.initialize_from_ar(to_convert)
        load_associations(to_convert, poro)
      end
    end

    def dump(to_convert)
      mapper.dump(to_convert).tap do |ar_object|
        to_convert._metadata.apply_to_ar_object(ar_object)
        dump_associations(to_convert, ar_object)
      end
    end

    def dump_source_class=(new_dump_source)
      @dump_source_class = new_dump_source.tap {|source_class| source_class.send(:include, MetadataEnabled)}
    end



    def mapper
      tmp_quirk = plain_columns

      @mapper||= Yaoc::ObjectMapper.new(self.dump_source_class, self.load_source_class).tap do |mapper|
        mapper.add_mapping do
          fetcher :public_send
          rule to: tmp_quirk
        end
      end
    end

    protected

    def plain_columns
      columns(self.load_source_class) -
      primary_keys(self.load_source_class) -
      association_specific_columns(self.load_source_class) -
      associated_object_accessors(self.load_source_class)
    end

    def load_associations(to_convert, poro)
      association_converters.each_pair do |association_name, association_converter|
        next if to_convert.send(association_name).nil?

        if self.load_source_class.reflections[association_name].collection?
          values = to_convert.send(association_name).map { |record| association_converter.load(record) }
          poro.send("#{association_name}=", values)
        else
          poro.send("#{association_name}=", association_converter.load(to_convert.send(association_name)))
        end
      end
    end

    def dump_associations(to_convert, ar_object)
      association_converters.each_pair do |association_name, association_converter|
        next if to_convert.send(association_name).nil?

        if self.load_source_class.reflections[association_name].collection?
          values = to_convert.send(association_name).map { |poro| association_converter.dump(poro) }
          ar_object.send("#{association_name}=", values)
        else
          ar_object.send("#{association_name}=", association_converter.dump(to_convert.send(association_name)))
        end
      end
    end


  end
end