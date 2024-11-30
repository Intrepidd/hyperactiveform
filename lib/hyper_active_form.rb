# frozen_string_literal: true

module HyperActiveForm
  class CancelFormSubmitError < StandardError; end
  class FormDidNotSubmitError < StandardError; end
end

require_relative "hyper_active_form/version"
require_relative "hyper_active_form/base"
require_relative "hyper_active_form/generators"
