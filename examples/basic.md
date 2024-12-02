# Basic form example

## Form
```ruby
class ContactForm < ApplicationForm
  proxy_for Contact, :@contact

  attribute :first_name
  attribute :last_name
  attribute :birth_date, :date

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birth_date, presence: true


  def setup(contact)
    @contact = contact
    self.first_name = @contact.first_name
    self.last_name = @contact.last_name
    self.birth_date = @contact.birth_date
    ## You could also do :
    # self.attributes = @contact.attributes.slice(:first_name, :last_name, birth_date)
  end

  def perform
    @contact.update!(
      first_name:,
      last_name:,
      birth_date:
    )
  end
end
```

## Controller
```ruby
class ContactsController
  def new
    @form = ContactForm.new(Contact.new)
  end

  def create
    @form = ContactForm.new(Contact.new)

    if @form.submit(params[:contact])
      redirect_to root_path, notice: "Contact created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @contact = Contact.find(params[:id])
    @form = ContactForm.new(@contact)
  end

  def update
    @contact = Contact.find(params[:id])
    @form = ContactForm.new(@contact)

    if @form.submit(params[:contact])
      redirect_to root_path, notice: "Contact updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
```

## Views
### new.html.erb and edit.html.erb
```erb
<%= render "form", form: @form %>
```

### _form.html.erb
```erb
<%= form_with(model: form) do |f| %>
  <%= f.text_field :first_name, placeholder: "First name" %>
  <%= f.text_field :last_name, placeholder: "Last name" %>
  <%= f.date_field :birth_date %>
  <%= f.submit "Save" %>
<% end %>
```
