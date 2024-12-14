# frozen_string_literal: true

require "active_model"
require "action_controller"

module HyperActiveForm
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    def self.proxy_for(klass, object)
      delegate :new_record?, :persisted?, :id, to: object
      singleton_class.delegate :model_name, to: klass
    end

    def initialize(*, **)
      super()
      setup(*, **)
    end

    def setup; end

    def perform
      raise NotImplementedError
    end

    def assign_form_attributes(params)
      params = ActionController::Parameters.new(params) unless params.is_a?(ActionController::Parameters)
      attribute_names.each do |attribute|
        default_value = self.class._default_attributes[attribute]&.value_before_type_cast
        public_send(:"#{attribute}=", params&.dig(attribute) || default_value)
      end
    end

    def submit(params)
      assign_form_attributes(params)
      !!(valid? && perform)
    rescue HyperActiveForm::CancelFormSubmit
      false
    end

    def submit!(params)
      submit(params) || raise(HyperActiveForm::FormDidNotSubmitError)
    end

    def add_errors_from(model)
      model.errors.each do |error|
        Array.wrap(error.message).each { |e| errors.add(error.attribute, e) }
      end

      false
    end
  end
end
