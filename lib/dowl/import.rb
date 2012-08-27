require 'dowl'

module DOWL

  class Import < DOWL::LabelledDocObject
 
    def initialize(resource, schema)
      super(resource, schema)
    end
    
    def resourceNameHtml
      
      return "#{@schema.name}.html"
    end

  end
end
