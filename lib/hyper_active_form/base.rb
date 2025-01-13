# frozen_string_literal: true

require "active_model"
require "action_controller"

module HyperActiveForm
  ##
  # Base class for HyperActiveForm objects
  #
  # HyperActiveForm objects are simple ActiveModel objects that encapsulate
  # form logic and validations. They are designed to be subclassed and
  # customized to fit the needs of your application.
  #
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    extend ActiveModel::Callbacks

    define_model_callbacks :assign_form_attributes, :submit

    # The list of attribute names that have been passed to the form
    # during the last call to `assign_form_attributes` or `submit`
    attr_reader :assigned_attribute_names

    # Defines to which object the form should delegate the active model methods
    # This is useful so `form_for`/`form_with` can automatically deduce the url and method to use
    #
    # @param klass [Class] the class of the object to proxy
    # @param object [Object] where to delegate the object to, for example: `:@user`
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

    # Assigns the attributes of the form from the params
    # This method is called by the `submit` method, but can also be called
    # directly if you need to assign the attributes without submitting the form
    # for example if you want to refresh the form with new data
    #
    # @param params [Hash] the params to assign the attributes from
    def assign_form_attributes(params)
      run_callbacks :assign_form_attributes do
        params = ActionController::Parameters.new(params) unless params.is_a?(ActionController::Parameters)
        attribute_names.each do |attribute|
          default_value = self.class._default_attributes[attribute]&.value_before_type_cast
          public_send(:"#{attribute}=", params&.dig(attribute) || default_value)
        end
        @assigned_attribute_names = params.slice(*attribute_names).keys
      end
    end

    # Submits the form, assigning the attributes from the params,
    # running validations and calling the `perform` method if the form is valid
    #
    # @param params [Hash] the params to assign the attributes from
    # @return [Boolean] true if the form is valid and the `perform` method returned something truthy
    def submit(params)
      run_callbacks :submit do
        assign_form_attributes(params)
        !!(valid? && perform)
      end
    rescue HyperActiveForm::CancelFormSubmit
      false
    end

    # Same as `submit` but raises a `FormDidNotSubmitError` if the form is not valid
    #
    # @param params [Hash] the params to assign the attributes from
    # @return [Boolean] true if the form is valid and the `perform` method returned something truthy
    def submit!(params)
      submit(params) || raise(HyperActiveForm::FormDidNotSubmitError)
    end

    # Adds the errors from a model to the form
    #
    # @param model [ActiveModel::Model] the model to add the errors from
    def add_errors_from(model)
      model.errors.each do |error|
        Array.wrap(error.message).each { |e| errors.add(error.attribute, e) }
      end

      false
    end
  end
end
