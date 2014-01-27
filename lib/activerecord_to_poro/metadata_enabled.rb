module ActiverecordToPoro
  module MetadataEnabled
    def _metadata
      @_metadata ||= Metadata.new
    end
  end
end