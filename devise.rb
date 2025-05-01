# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "devise"

  RUBY
end

# Assets
########################################

# Create components/_alert.scss for flash messages
file "app/assets/stylesheets/components/_alert.scss", <<~SCSS
  .alert {
    position: fixed;
    bottom: 16px;
    right: 16px;
    z-index: 1000;
  }
SCSS

# Ensure components/_index.scss exists and append @import "alert";
append_to_file "app/assets/stylesheets/components/_index.scss", <<~SCSS
  @import "alert";
SCSS

# Create Navbar
file "app/views/shared/_navbar.html.erb", <<~HTML
<div class="navbar navbar-expand-sm navbar-light">
<div class="container-fluid">
  <%= link_to root_path, class: "navbar-brand" do %>
    Navbar
  <% end %>

  <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>

  <div class="collapse navbar-collapse" id="navbarSupportedContent">
    <ul class="navbar-nav me-auto">
      <li class="nav-item">
         <%= link_to "Home", root_path, class: "nav-link" %>
        </li>
    </ul>

    <% if user_signed_in? %>
      <div class="nav-item">
        <%= link_to "Log out", destroy_user_session_path, data: {turbo_method: :delete}, class: "nav-link" %>
      </div>
    <% else %>
      <div class="nav-item">
        <%= link_to "Login", new_user_session_path, class: "nav-link" %>
      </div>
    <% end %>
  </div>
</div>
</div>
HTML

# Create Flashes
file "app/views/shared/_flashes.html.erb", <<~HTML
  <% if notice %>
    <div class="alert alert-success alert-dismissible fade show m-1" role="alert">
      <%= notice %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
      </button>
    </div>
  <% end %>
  <% if alert %>
    <div class="alert alert-warning alert-dismissible fade show m-1" role="alert">
      <%= alert %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
      </button>
    </div>
  <% end %>
HTML

# Layout
########################################

# Add shared navbar and flashes to the body (devise)
gsub_file "app/views/layouts/application.html.erb", /<body>.*?<\/body>/m do
  <<~HTML
    <body>
      <%= render "shared/navbar" %>
      <%= yield %>
      <%= render "shared/flashes" %>
    </body>
  HTML
end

########################################
# After bundle
########################################
after_bundle do

  # Generate a Pages controller with a home action (no routes or test framework)
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")

  # Set the root route to the home action of the Pages controller
  route 'root to: "pages#home"'

  # Install Devise for authentication
  generate("devise:install")

  # Generate a Devise User model
  generate("devise", "User")

  # migrate
  rails_command "db:migrate"

  # devise views
  generate("devise:views")

  # Environments
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: "development"
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: "production"
end
