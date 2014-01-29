module ActiverecordToPoro
  module ColumnHelper
    module_function
    def columns(ar_class)
      ar_class.column_names.map &:to_sym
    end

    def primary_keys(ar_class)
      [ar_class.primary_key].map &:to_sym
    end

    def association_specific_columns(ar_class)
      ar_class.reflect_on_all_associations(:belongs_to).map(&:foreign_key).map &:to_sym
    end

    def associated_object_accessors(ar_class)
      ar_class.reflections.keys.map &:to_sym
    end
  end


  class DefaultPoroClassBuilder
    include ColumnHelper

    attr_accessor :ar_class

    def initialize(ar_class)
      self.ar_class = ar_class
    end

    def call
      create_class
    end

    protected

    def create_class
      @create_dump_source_class ||= Yaoc::Helper::StructHE(*(attributes_for_poro))
    end

    def attributes_for_poro
      (columns(ar_class) - primary_keys(ar_class) - association_specific_columns(ar_class) + associated_object_accessors(ar_class)).map(&:to_sym)
    end

  end
end