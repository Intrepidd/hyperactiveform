module HyperActiveForm
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_application_form
        template 'form.rb', File.join('app/forms', class_path, "#{file_name}_form.rb")
      end
    end
  end
end
