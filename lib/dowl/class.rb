module DOWL
  class Class < DOWL::LabelledDocObject
    include Comparable

    attr_reader :resource
    attr_reader :subClasses
    attr_reader :associations

    private
    def initialize(resource, schema)
      super(resource, schema)
      @super_classes = nil
      @subClasses = nil
      @associations = nil
    end

    public

    def Class.withUri(resource, schema)
      if resource.anonymous?
        warn "WARNING: Ignoring class with uri #{resource.to_s}"
        return
      end
      klass = schema.classes[resource.to_s]
      if klass
        return klass
      end
      klass = Class.new(resource, schema)
      schema.classes[resource.to_s] = klass
      puts "Created class #{klass.short_name}"
      return klass
    end

    public

    def see_alsos()
      links = []
      @schema.model.query(
      RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.seeAlso)
      ) do |statement|
        links << statement.object.to_s
      end
      return links
    end

    public

    def super_classes()
      if not @super_classes.nil?
        return @super_classes
      end

      @super_classes = []

      @schema.model.query(
      RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.subClassOf)
      ) do |statement|
        #
        # Only look at statements like these:
        #
        # <rdfs:subClassOf rdf:resource="<uri>"/>
        #
        # And ignore statements like these:
        #
        # <rdfs:subClassOf>
        #   <owl:Restriction>
        #     <owl:onProperty rdf:resource="<uri>"/>
        #     <owl:allValuesFrom rdf:resource="<uri>"/>
        #   </owl:Restriction>
        # </rdfs:subClassOf>
        #
        if statement.object.uri?
          superClass = Class.withUri(statement.object, @schema)
          if superClass
            if superClass != self
              @super_classes << superClass
            end
          else
            warn "WARNING: Could not find super class #{statement.object.to_s}"
          end
        end
      end
      return @super_classes
    end

    public

    def hasSuperClasses?
      return ! super_classes.empty?()
    end

    public

    def hasSuperClassesInSchema?
      super_classes.each() do |klass|
        if @schema.classes.include?(klass.uri)
          return true
        end
      end
      return false
    end

    public

    def subClasses()
      if @subClasses
        @subClasses.each do |subclass|
          puts "Returning subclass of #{short_name}: #{subclass.short_name}"
        end
        return @subClasses
      end
      @subClasses = Set.new

      @schema.model.query(
      RDF::Query::Pattern.new(nil, DOWL::Namespaces::RDFS.subClassOf, @resource)
      ) do |statement|
        subClass = Class.withUri(statement.object, @schema)
        if subClass
          if subClass != self
            @subClasses << subClass
          end
        else
          warn "WARNING: Could not find sub class of #{short_name} with uri #{statement.object.to_s}"
        end
      end
      #@subClasses.sort! { |x,y| x <=> y }
      @subClasses.each do |subclass|
        puts "Returning subclass #{short_name}: #{subclass.short_name}..."
      end
      return @subClasses
    end

    public

    def hasSubClasses?
      return ! subClasses.empty?()
    end

    public

    def associations()
      if not @associations.nil?
        return @associations
      end
      @associations = Set.new

      if @schema.options.verbose
        puts "Searching for associations of class #{short_name}"
      end

      query = RDF::Query.new do
        pattern [:property, DOWL::Namespaces::RDFS.domain, @resource]
        pattern [:property, RDF.type, DOWL::Namespaces::OWL.ObjectProperty]
        pattern [:property, DOWL::Namespaces::RDFS.range, :range]
      end
      solution = query.execute(@schema.model)
      if @schema.options.verbose
        puts " - Found #{solution.count} solutions"
      end
      solution.distinct!
      if @schema.options.verbose
        puts " - Found #{solution.count} distinct solutions"
      end

      solution.each do |solution|
        property = solution[:property]
        range = solution[:range]
        if @schema.options.verbose
          puts " - Found Association from #{short_name} to #{@schema.prefixedUri(range)}: #{@schema.prefixedUri(property.to_s)}"
        end
        rangeClass = Class.withUri(range, @schema)
        if @schema.options.verbose
          puts "   - Found this class for it: #{rangeClass}"
        end
        if rangeClass
          @associations << Association.new(property, @schema, self, rangeClass)
        end
      end
      if @schema.options.verbose
        puts " - Returning #{@associations.size} associations"
      end
      return @associations
    end

  end

end