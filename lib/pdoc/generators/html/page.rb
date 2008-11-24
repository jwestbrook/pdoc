module PDoc
  module Generators
    module Html
      class Page
        include Helpers::BaseHelper
        
        def initialize(template, layout, variables = {})
          @template = template
          @layout = layout
          assign_variables(variables)
        end
        
        # Renders the page as a string using the assigned layout.
        def render
          if @layout
            @content_for_layout = Template.new(@template, @templates_directory).result(binding)
            Template.new(@layout, @templates_directory).result(binding)
          else
            Template.new(@template, @templates_directory).result(binding)
          end
        end
        
        # Creates a new file and renders the page to it
        # using the assigned layout.
        def render_to_file(filename)
          File.open(filename, "w+") { |f| f << render }
        end
        
        def include(path, options)
          if object = options[:object]
            Template.new(path, @templates_directory).result(binding)
          else
            options[:collection].map { |object| Template.new(path, @templates_directory).result(binding) }.join("\n")
          end
        end
        
        private
          def assign_variables(variables)
            variables.each { |key, value| instance_variable_set("@#{key}", value) }
          end
      end

      class DocPage < Page
        include Helpers::LinkHelper, Helpers::MenuHelper
        
        attr_reader :doc_instance, :depth, :root
        
        def initialize(template, layout = "layout", variables = {})
          if layout.is_a?(Hash)
            variables = layout
            layout = "layout"
          end
          super(template, layout, variables)
        end
        
        def htmlize(markdown)
          super(auto_link_content(markdown))
        end
      end
      
    end
  end
end
