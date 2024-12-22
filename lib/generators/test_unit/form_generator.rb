module TestUnit
  module Generators
    class FormGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_form_test
        template "form_test.rb", File.join("test/forms", class_path, "#{file_name}_form_test.rb")
      end
    end
  end
end
