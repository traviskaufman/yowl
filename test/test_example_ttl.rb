$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'yowl'
require 'test/unit'

class OntologyTest < Test::Unit::TestCase
  
  @schema = nil
  
  def setup
    
    argv = [
      '-i', 'test/input/example.ttl',
      '--no-vann',
      '--quiet'
    ]
    options = YOWL::OptionsParser.parse(argv)
    repository = YOWL::Repository.new(options)
    repository.ontologies.each() do | ontology |
      if (ontology.short_name == 'example')
        @schema = ontology.schema
      end
    end
    assert_not_nil(@schema)
  end
  
  def test_read_classes_from_sample()
    classes = @schema.classes()
    assert_not_nil classes
    assert_equal(2, classes.length)
  end
  

  def test_get_title
    assert_equal("An Example", @schema.ontology.title)
  end
  
  def test_get_comment
    assert_equal("This is a simple example", @schema.ontology.comment)
  end

  def test_get_created
    assert_equal("2010-02-19", @schema.ontology.created)
  end
  
  def test_get_created
    assert_equal("2010-09-28", @schema.ontology.modified)
  end

  def test_get_authors
    assert_equal(2 , @schema.ontology.authors.length)
    author = @schema.ontology.authors[0]
    assert_equal("http://www.ldodds.com#me", author.uri)
    assert_equal("Leigh Dodds", author.name)
    
    author = @schema.ontology.authors[1]
    assert_equal("http://www.example.org/unknown", author.uri)
    assert_equal("http://www.example.org/unknown", author.name)
    
  end
  
        
end