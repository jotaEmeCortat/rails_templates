# Ensure the template is being used with --database=postgresql
unless options[:database] == "postgresql"
  say "❌ This template requires '--database=postgresql'.", :red
  say "👉 Please re-run: rails new myapp --database=postgresql -m path/to/template.rb", :yellow
  exit 1
end

# Kill any running Spring process on macOS
run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################

inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    # Standard Ruby library, required in Ruby 3.3+ to avoid deprecation warnings
    gem 'ostruct', '~> 0.1.0'
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
    gem "sassc-rails"

  RUBY
end

inject_into_file "Gemfile", after: "group :development, :test do\n" do
  <<~RUBY
      gem "dotenv-rails"
      gem "hotwire-livereload"
  RUBY
end

# Assets
########################################

# Clean default stylesheets and vendor directory
run "rm -rf app/assets/stylesheets"
run "rm -rf vendor"

# Create necessary directories for stylesheets and assets
run "mkdir -p app/assets/stylesheets"
run "mkdir -p app/assets/stylesheets/components"
run "mkdir -p app/assets/stylesheets/config"
run "mkdir -p app/assets/javascripts"
run "mkdir app/views/shared"


# Create components/_forms.scss for form-specific styles
file "app/assets/stylesheets/components/_form_legend_clear.scss", <<~SCSS
  // In bootstrap 5 legend floats left and requires the following element
  // to be cleared. In a radio button or checkbox group the element after
  // the legend will be the automatically generated hidden input; the fix
  // in https://github.com/twbs/bootstrap/pull/30345 applies to the hidden
  // input and has no visual effect. Here we try to fix matters by
  // applying the clear to the div wrapping the first following radio button
  // or checkbox.
  legend ~ div.form-check:first-of-type {
    clear: left;
  }
SCSS

# Create components/_index.scss
file "app/assets/stylesheets/components/_index.scss", <<~SCSS
  @import "form_legend_clear";
SCSS

# Create custom.scss for additional custom styles
file "app/assets/stylesheets/custom.scss", <<~SCSS
  // Custom styles
SCSS

# Create application.scss to import all styles
file "app/assets/stylesheets/application.scss", <<~SCSS
  // External libraries
  @import "font-awesome";

  // Your CSS
  @import "components/index";
  @import "custom";
SCSS


# Generators
########################################

# Configure Rails generators to skip assets, helpers, and fixtures
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY
environment generators

# General Config
########################################

# Disable raising errors for missing callback actions in controllers
general_config = <<~RUBY
  config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
RUBY
environment general_config

########################################
# After bundle
########################################
after_bundle do

  # Generators: db + simple form
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate("simple_form:install", "--bootstrap")

  # Dotenv
  ########################################
  run "touch '.env'"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'rails new'"
end
