module SinatraDoc
  module Model
    extend ActiveSupport::Concern

    included do
      SinatraDoc.add_model(self)
      doc_ref(self.to_s.demodulize.tableize.singularize)
    end

    class_methods do
      attr_reader :doc_attributes

      def doc_ref(value = nil)
        @doc_ref = value.to_sym if value
        @doc_ref
      end

      def doc_attribute(name, type: nil, description: nil)
        @doc_attributes ||= {}
        @doc_attributes[name.to_sym] = { type: type, description: description }
      end
    end
  end

  class ModelProxy
    attr_reader :klass, :ref, :attributes

    def initialize(klass)
      @klass = klass
      @ref = nil
      process
    end

    private

    def process
      @ref = @klass.doc_ref
      process_attributes
    end

    def process_attributes
      @attributes = @klass.columns.map do |column|
        [
          column.name.to_sym,
          { type: SinatraDoc::Endpoint::PropTypes.convert(column.sql_type_metadata.sql_type), description: nil }
        ]
      end.to_h
      @attributes.merge!(@klass.doc_attributes)
    end
  end
end
