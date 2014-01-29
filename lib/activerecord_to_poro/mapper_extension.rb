module ActiverecordToPoro
  module MapperExtension

    def association_rule(to: nil,
                         from: to,
                         reverse_to: from,
                         reverse_from: to,
                         converter: nil,
                         is_collection: false,
                         lazy_loading: nil
                        )

      map_collection = (self.dump_result_source.reflections[from] &&
                        self.dump_result_source.reflections[from].collection?) || is_collection

      rule to: to,
           from: from,
           reverse_to: reverse_to,
           reverse_from: reverse_from,
           reverse_lazy_loading: false, #AR doesn't like ToProcDelegator
           object_converter: converter.mapper,
           is_collection: map_collection,
           lazy_loading: lazy_loading

    end
  end
end