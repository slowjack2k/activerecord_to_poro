module ActiverecordToPoro

  module MetadataEnabledAr
    require 'active_support/concern'

    extend ActiveSupport::Concern

    included do
      after_save :_update_poro_metadata
    end

    def _referenced_poros
      @_referenced_poros ||= []
    end

    def _update_poro_metadata
      _referenced_poros.each do |entity|
        entity._set_metadata_from_ar = self if entity.respond_to? :_set_metadata_from_ar=

        [:id, :updated_at, :created_at, :lock_version,].each do |magic_col|
           entity.send("#{magic_col}=", send(magic_col)) if [entity, self].all? { |obj| obj.respond_to? magic_col }
        end
      end

      @_referenced_poros = nil # one way method to prevent circular references

      true
    end



    module ClassMethods

      def _from_attrs_with_metadata(attrs={}, pre_created_object= nil)
        record_by_primary_key = _record_from_metadata!(attrs)

        record = pre_created_object || record_by_primary_key || new

        record.tap do |new_obj|

          new_obj.attributes = attrs || {}

          _patch_has_many_members(attrs, new_obj) unless new_obj.new_record?
        end

      end

      def _patch_has_many_members(attrs, new_obj)
        has_many_attrs = attrs.slice(* _has_many_attr_names(new_obj))

        has_many_attrs.each_pair do |name, updated_records|

          new_obj.public_send(name).each do |attached_record|
            record_with_updated_values = updated_records.find { |r| r == attached_record }
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
        metadata = (attrs || {}).delete(:_set_metadata_to_ar){ |*| Metadata.new }
        metadata.for_ar_class(self.name)
      end

      def _record_from_metadata!(attrs)
        specific_metadata = _extract_metadata!(attrs)

        if respond_to?(:query_from_cache) && query_from_cache(specific_metadata.as_scope_hash)
          query_from_cache(specific_metadata.as_scope_hash)
        else
          _as_scope(specific_metadata.as_scope_hash).first
        end
      end
    end

  end

end