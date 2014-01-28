module ActiverecordToPoro
  class Metadata
    attr_accessor :primary_key_column, :primary_key_value


    def initialize_from_ar(ar_object=nil)
      unless ar_object.nil?
        set_primary_key(ar_object)
      end
    end

    def set_primary_key(ar_object)
      self.primary_key_column = ar_object.class.primary_key
      self.primary_key_value = ar_object.send(self.primary_key_column)
    end

    def to_hash
      { self.primary_key_column => self.primary_key_value }
    end

  end
end