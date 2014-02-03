module ActiverecordToPoro

  module MetadataEnabledAr

    def _from_attrs_with_metadata(attrs={}, pre_created_object= nil)
      record_by_primary_key = _record_from_metadata!(attrs)

      record = pre_created_object || record_by_primary_key || new

      record.tap do |new_obj|
        new_obj.attributes = attrs
      end

    end

    def _as_scope(attr)
      attr.empty? ? none : where(attr)
    end

    def _extract_metadata!(attrs)
      metadata = (attrs || {}).delete(:_set_metadata_to_ar) {|*| Metadata.new}
      metadata.for_ar_class(self.name)
    end

    def _record_from_metadata!(attrs)
      specific_metadata = _extract_metadata!(attrs)
      _as_scope(specific_metadata.as_scope_hash).first
    end

  end

end