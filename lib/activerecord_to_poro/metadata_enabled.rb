module ActiverecordToPoro
  module MetadataEnabled
    def _metadata
      @_metadata ||= Metadata.new
    end


    def _set_metadata_from_ar=(ar_object)
      _metadata.initialize_from_ar(ar_object)
    end

  end

end