require "spec_helper"

class User
  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end
end

RSpec.describe HyperActiveForm::Base do
  let(:callable) { double }
  let(:dummy_class) do
    Class.new(HyperActiveForm::Base) do
      attribute :name
      attribute :age

      def self.model_name
        ActiveModel::Name.new(self, nil, "Dummy")
      end

      validates :name, presence: true
      validates :age, numericality: { greater_than: 18 }

      def setup(name:, age:, perform_return_value: true, callable: nil)
        self.name = name
        self.age = age
        @perform_return_value = perform_return_value
        @callable = callable
      end

      def perform
        @callable&.call
        @perform_return_value
      end
    end
  end

  describe "#setup" do
    it "assigns attributes" do
      form = dummy_class.new(name: "John", age: 20)
      expect(form.name).to eq("John")
      expect(form.age).to eq(20)
    end
  end

  describe "#submit" do
    context "when the form is valid" do
      it "returns true and performs the form" do
        form = dummy_class.new(name: "John", age: 20, callable:)
        expect(callable).to receive(:call)
        expect(form.submit(name: "Fred", age: 19)).to eq(true)
      end

    end

    context "when the form is invalid" do
      it "returns false and does not perform the form" do
        form = dummy_class.new(name: "John", age: 20, callable:)
        expect(callable).not_to receive(:call)
        expect(form.submit(name: nil, age: 19)).to eq(false)
        expect(form.errors.messages).to eq(name: ["can't be blank"])
      end
    end

    context "when the form returns false" do
      it "returns false" do
        form = dummy_class.new(name: "John", age: 20, perform_return_value: false)
        expect(form.submit(name: "Fred", age: 19)).to eq(false)
      end
    end

    context "when the form raises a CancelFormSubmit" do
      it "returns false" do
        expect(callable).to receive(:call).and_raise(HyperActiveForm::CancelFormSubmit)
        form = dummy_class.new(name: "John", age: 20, callable:)
        expect(form.submit(name: "Fred", age: 19)).to eq(false)
      end
    end
  end

  describe "#submit!" do
    context "when the form submits successfully" do
      it "returns true" do
        form = dummy_class.new(name: "John", age: 20)
        expect(form).to receive(:submit).and_return(true)
        expect(form.submit!(name: "Fred", age: 19)).to eq(true)
      end
    end

    context "when the form does not submit" do
      it "raises a FormDidNotSubmitError" do
        form = dummy_class.new(name: "John", age: 20)
        expect(form).to receive(:submit).and_return(false)
        expect { form.submit!(name: "Fred", age: 19) }.to raise_error(HyperActiveForm::FormDidNotSubmitError)
      end
    end
  end

  describe ".proxy_for" do
    let(:dummy_class) do
      Class.new(HyperActiveForm::Base) do
        proxy_for User, :@user
        attribute :name
        attribute :age

        def setup(user:)
          @user = user
        end
      end
    end

    it "delegates the model name to the class" do
      user = User.new
      form = dummy_class.new(user:)
      expect(form.model_name).to eq(User.model_name)
    end

    it "delegates to the object" do
      user = User.new
      allow(user).to receive(:new_record?).and_return(false)
      allow(user).to receive(:persisted?).and_return(true)
      allow(user).to receive(:id).and_return(42)

      form = dummy_class.new(user:)

      expect(form.new_record?).to eq(false)
      expect(form.persisted?).to eq(true)
      expect(form.id).to eq(42)

      allow(user).to receive(:new_record?).and_return(true)
      allow(user).to receive(:persisted?).and_return(false)

      expect(form.new_record?).to eq(true)
      expect(form.persisted?).to eq(false)
    end
  end
end
