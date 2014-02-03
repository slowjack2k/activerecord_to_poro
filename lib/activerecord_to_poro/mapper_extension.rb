module ActiverecordToPoro
  module MapperExtension

    def association_rule(to: nil,
        from: to,
        reverse_to: from,
        reverse_from: to,
        converter: nil,
        reverse_converter: converter,
        is_collection: false,
        lazy_loading: nil
    )

      map_collection =  ActiverecordToPoro::MapperExtension.is_an_ar_collection?(self.dump_result_source, from) || is_collection

      options ={
          to: to,
          from: from,
          reverse_to: reverse_to,
          reverse_from: reverse_from,
          reverse_lazy_loading: false, #AR doesn't like ToProcDelegator
          is_collection: map_collection,
          lazy_loading: lazy_loading
      }

      if converter.nil?
        options[:converter] = noop
        options[:object_converter] = nil
      else
        options[:object_converter] = converter#.mapper
      end

      if reverse_converter.nil? ||  ActiverecordToPoro::MapperExtension.is_an_has_many_through(self.dump_result_source, from)
        options[:reverse_converter] = noop
        options[:reverse_object_converter] = nil
      else
        options[:reverse_object_converter] =  reverse_converter#.mapper
      end

      rule options

    end

    module_function

    def is_an_ar_collection?(ar_class, association_name)
      (ar_class.reflections[association_name] &&
       ar_class.reflections[association_name].collection?)
    end

    def is_an_has_many_through(ar_class, association_name)
      ar_class.reflections[association_name] &&
      ar_class.reflections[association_name].macro == :has_many &&
      ar_class.reflections[association_name].options.has_key?(:through)
    end

  end
end