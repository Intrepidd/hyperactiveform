# ✨ HyperActiveForm ✨

HyperActiveForm is a simple form object implementation for Rails.

Form objects are objects that encapsulate form logic and validations, they allow to extract the business logic out of the controller and models into specialized objects.

HyperActiveForm's form objects mimic the ActiveModel API, so they work out of the box with Rails' form helpers, and allow you to use the ActiveModel validations you already know.

This allows you to only keep strictly necessary validations in the model, and have business logic validations in the form object. This is especially useful when you want different validations to be applied depending on the context.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hyperactiveform'
```

And then execute:

    $ bundle install

Run the install generator:

    $ rails generate hyper_active_form:install

this will create an `ApplicationForm` class in your app/forms directory. You can use it as a base class for your form objects.

## Usage

Here is an example of an `HyperActiveForm` form object:

```ruby
class ProfileForm < ApplicationForm
  # proxy_for is used to delegate the model name to the class, and some methods to the object
  # this helps use `form_with` in views without having to specify the url
  proxy_for User, :@user

  # Define the form fields, using ActiveModel::Attributes
  attribute :first_name
  attribute :last_name
  attribute :birth_date, :date

  # Define the validations, using ActiveModel::Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birth_date, presence: true

  # Pre-fill the form if needed
  def setup(user)
    @user = user
    self.first_name = user.first_name
    self.last_name = user.last_name
    self.birth_date = user.birth_date
  end

  # Perform the form logic
  def perform
    @user.update!(
      first_name: first_name,
      last_name: last_name,
      birth_date: birth_date
    )
  end
end
```

The controller would look like this:

```ruby
class UsersController < ApplicationController

  def edit
    @form = ProfileForm.new(user: current_user)
  end

  def update
    @form = ProfileForm.new(user: current_user)
    if @form.submit(params[:user])
      redirect_to root_path, notice: "Profile updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end
```

And the view would look like this:

```erb
<%= form_with(model: @form) do |f| %>
  <%= f.text_field :first_name %>
  <%= f.text_field :last_name %>
  <%= f.date_field :birth_date %>

  <%= f.submit %>
<% end %>
```

### Understanding `proxy_for`

`HyperActiveForm` mimics a model object, you can use `proxy_for` to tell it which class and object to delegate to.

When using `form_for` or `form_with`, Rails will choose the URL and method based on the object, according to the persisted state of the object and its model name.

The first argument of `proxy_for` is the class of the object, and the second argument is the name of the instance variable that holds the object.

```ruby
class ProfileForm < ApplicationForm
  proxy_for User, :@user # Will delegate to @user
end
```

If you pass an url and method yourself, you don't need to use `proxy_for`.

### Understanding `setup`

`setup` is called just after the form is initialized, and is used to pre-fill the form with data from the object.

`setup` will receive the same arguments as the initializer, so you can use it to pass any data you need to the form.

```ruby
class ProfileForm < ApplicationForm
  def setup(user)
    @user = user
    self.first_name = user.first_name
    self.last_name = user.last_name
    self.birth_date = user.birth_date
  end
end
```

### Understanding `perform`

When using `submit` or `submit!`, `HyperActiveForm` will first assign the form attributes to the object, then perform the validations, then call `perform` on the object if the form is valid.

The `perform` method is where you should do the actual form logic, like updating the object or creating a new one.

If the return value of `perform` is not truthy, `HyperActiveForm` will consider the form encountered an error and `submit` will return `false`, or `submit!` will raise a `HyperActiveForm::FormDidNotSubmitError`.

At any point during the form processing, you can raise `HyperActiveForm::CancelForm` to cancel the form submission, this is the same as returning `false`.

## Understanding add_errors_from

`HyperActiveForm` provides a method to add errors from a model and apply them fo the form.

This is useful when the underlying model has validations that are not set up in the form object, and you want them to be applied to the form.

```ruby
class User < ApplicationRecord
  validates :first_name, presence: true
end

class ProfileForm < ApplicationForm
  proxy_for User, :@user
  attribute :first_name

  def setup(user)
    @user = user
    self.first_name = user.first_name
  end

  def perform
    @user.update!(first_name: first_name) || add_errors_from(@user)
  end
end
```

### Not all forms map to a single model

The power of `HyperActiveForm` is that you can use it to create forms that don't map to a single model.

Some forms can be used to create several models at once. Doing so without form objects can be tedious especially with nested attributes.

Some forms dont map to any model at all, like a simple contact form that only sends an email and saves nothing in the database, or a sign in form that would only validate the credentials and return the instance of the connected user.

One great example of such forms are search forms. You can use a form object to encapsulate the search logic :

```ruby
class UserSearchForm < ApplicationForm
  attribute :name
  attribute :email
  attribute :min_age, :integer

  attr_reader :results # So the controller can access the results

  def perform
    @results = User.all

    if name.present?
      @results = @results.where(name: name)
    end
    if email.present?
      @results = @results.where(email: email)
    end
    if age.present?
      @results = @results.where("age >= ?", age)
    end

    true
  end
end
```

And in the controller:

```ruby
class UsersController < ApplicationController
  def index
    @form = UserSearchForm.new
    @form.submit!(params[:user])
    @users = @form.results
  end
end
