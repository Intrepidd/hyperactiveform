require '<%= File.exist?('spec/rails_helper.rb') ? 'rails_helper' : 'spec_helper' %>'

RSpec.describe <%= class_name %>Form, type: :form do
  pending "add some examples to (or delete) #{__FILE__}"
end
