module Rspec
  module Generators
    class FormGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_form_spec
        template "form_spec.rb", File.join("spec/forms", class_path, "#{file_name}_form_spec.rb")
      end
    end
  end
end
