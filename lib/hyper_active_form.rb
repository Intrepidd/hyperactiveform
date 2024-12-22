# frozen_string_literal: true

module HyperActiveForm
  class CancelFormSubmit < StandardError; end
  class FormDidNotSubmitError < StandardError; end
end

require_relative "hyper_active_form/version"
require_relative "hyper_active_form/base"
