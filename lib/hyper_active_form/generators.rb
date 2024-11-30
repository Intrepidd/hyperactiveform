require "rails/generators"

module HyperActiveForm
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def create_application_form
        create_file "app/forms/application_form.rb", <<~RUBY
          class ApplicationForm < HyperActiveForm::Base
          end
        RUBY
      end
    end
  end
end
