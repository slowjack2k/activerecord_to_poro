module ActiverecordToPoro
  SourceObjectInfo = Yaoc::Helper::StructHE(:class_name, :column, :value, :object_id) do

    def to_hash
      {
       class_name: class_name,
       primary_key: {column: column, value: value},
       object_id: object_id
      }
    end
  end

  class Metadata
    attr_accessor :source_object_info

    def initialize()
      self.source_object_info = Set.new()
    end

    def initialize_from_ar(ar_object=nil)
      unless ar_object.nil?
        set_primary_key(ar_object)
      end
    end

    def set_primary_key(ar_object)
      self.source_object_info << SourceObjectInfo.new(class_name: ar_object.class.name,
                                                      column: ar_object.class.primary_key,
                                                      value: ar_object.send(ar_object.class.primary_key),
                                                      object_id: ar_object.object_id
                                                     )
    end

    def to_hash
      { source_objects_info: source_object_info.map(&:to_hash)  }
    end

  end
end