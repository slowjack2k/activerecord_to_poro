module ActiverecordToPoro
  module MetadataEnabled
    def _metadata
      @_metadata ||= Metadata.new
    end


    def _set_metadata_from_ar=(ar_object)
      _metadata.initialize_from_ar(ar_object)
    end

  end

  module MetadataToAr
    def _set_metadata_to_ar=(metadata)
      metadata.each_pair do |attr, value|
        self.send("#{attr}=", value)
        @new_record = false
      end
    end
  end
end