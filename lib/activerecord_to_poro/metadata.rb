module ActiverecordToPoro
  SourceObjectInfo = Yaoc::Helper::StructH(:class_name, :column, :value, :lock_version, :object_id) do

    include Equalizer.new(:class_name, :column, :value)

    def to_hash
      {
       class_name: class_name,
       primary_key: {column: column, value: value},
       object_id: object_id,
       lock_version: lock_version
      }
    end

    def as_scope_hash
      result = column.nil? ? {} : {column => value}
      result[:lock_version] = lock_version unless lock_version.nil?

      result
    end
  end

  class Metadata
    attr_accessor :source_object_info

    def initialize()
      self.source_object_info = Set.new()
    end

    def initialize_from_ar(ar_object=nil)
      unless ar_object.nil?
        set_source_info(ar_object)
      end
    end

    def for_ar_class(ar_class_name)
      Set.new.find
      source_object_info.find(->{SourceObjectInfo.new}){|data|
        data.class_name == ar_class_name
      }
    end

    def set_source_info(ar_object)
      self.source_object_info << SourceObjectInfo.new(class_name: ar_object.class.name,
                                                      column: ar_object.class.primary_key,
                                                      value: ar_object.send(ar_object.class.primary_key),
                                                      object_id: ar_object.object_id,
                                                      lock_version: ar_object.respond_to?(:lock_version) ? ar_object.lock_version : nil
                                                     )
    end

    def to_hash
      { source_objects_info: source_object_info.map(&:to_hash)  }
    end

  end
end