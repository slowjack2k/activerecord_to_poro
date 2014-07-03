module ActiverecordToPoro

  module MetadataEnabledAr

    def _from_attrs_with_metadata(attrs={}, pre_created_object= nil)
      record_by_primary_key = _record_from_metadata!(attrs)

      record = pre_created_object || record_by_primary_key || new

      record.tap do |new_obj|

        new_obj.attributes = attrs

        _patch_has_many_members(attrs, new_obj) unless new_obj.new_record?
      end

    end

    def _patch_has_many_members(attrs, new_obj)
      has_many_attrs = attrs.slice(* _has_many_attr_names(new_obj))

      has_many_attrs.each_pair do |name, updated_records|

        new_obj.public_send(name).each do |attached_record|
          record_with_updated_values = updated_records.find {|r| r == attached_record}
          next unless record_with_updated_values

          _apply_change_set_to_record(attached_record, record_with_updated_values.changes)
        end

      end
    end

    def _has_many_attr_names(obj_or_class)
      class_to_check = obj_or_class.respond_to?(:reflect_on_all_associations) ? obj_or_class : obj_or_class.class
      class_to_check.reflect_on_all_associations(:has_many).map(&:name)
    end

    def _apply_change_set_to_record(attached_record, changes)
      changes.each_pair do |attr_name, (_, new_value)|
        attached_record.public_send("#{attr_name}=", new_value)
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