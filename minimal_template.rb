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
    gem "bootstrap", "~> 5.2"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
    gem "sassc-rails"
  RUBY
end

inject_into_file "Gemfile", after: "group :development, :test do" do
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

# Create global variables
file "app/assets/stylesheets/config/_colors.scss", <<~SCSS
  // Define variables for your color scheme

  // For example:
  $red: #FD1015;
  $blue: #0D6EFD;
  $yellow: #FFC65A;
  $orange: #E67E22;
  $green: #1EDD88;
  $gray: #0E0000;
  $light-gray: #F4F4F4;
SCSS

file "app/assets/stylesheets/config/_fonts.scss", <<~SCSS
  // Import Google fonts
  @import url('https://fonts.googleapis.com/css?family=Nunito:400,700|Work+Sans:400,700&display=swap');

  // Define fonts for body and headers
  $body-font: "Work Sans", "Helvetica", "sans-serif";
  $headers-font: "Nunito", "Helvetica", "sans-serif";

  // To use a font file (.woff) uncomment following lines
  // @font-face {
  //   font-family: "Font Name";
  //   src: font-url('FontFile.eot');
  //   src: font-url('FontFile.eot?#iefix') format('embedded-opentype'),
  //        font-url('FontFile.woff') format('woff'),
  //        font-url('FontFile.ttf') format('truetype')
  // }
  // $my-font: "Font Name";
SCSS

# Create config/_bootstrap_variables.scss for Bootstrap custom variables
file "app/assets/stylesheets/config/_bootstrap_variables.scss", <<~SCSS
  // This is where you override default Bootstrap variables
  // 1. Find all Bootstrap variables that you can override at the end of each component's documentation under the `Sass variables` anchor
  // e.g. here are the ones you can override for the navbar https://getbootstrap.com/docs/5.2/components/navbar/#sass-variables
  // 2. These variables are defined with default value (see https://robots.thoughtbot.com/sass-default)
  // 3. You can override them below!

  // General style
  $font-family-sans-serif: $body-font;
  $headings-font-family:   $headers-font;
  $body-bg:                $light-gray;
  $font-size-base:         1rem;

  // Colors
  $body-color: $gray;
  $primary:    $blue;
  $success:    $green;
  $info:       $yellow;
  $danger:     $red;
  $warning:    $orange;

  // Buttons & inputs' radius
  $border-radius-sm:            .0625rem;
  $border-radius:               .125rem;
  $border-radius-lg:            .25rem;
  $border-radius-xl:            .5rem;
  $border-radius-xxl:           1rem;

  // Override other variables below!
SCSS

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
  // Graphical variables
  @import "config/fonts";
  @import "config/colors";
  @import "config/bootstrap_variables";

  // External libraries
  @import "bootstrap";
  @import "font-awesome";

  // Your CSS
  @import "components/index";
  @import "custom";
SCSS

# Layout
########################################

# Add hotwire-livereload client script in development
layout_file = "app/views/layouts/application.html.erb"
if File.exist?(layout_file)
  inject_into_file layout_file, before: "</head>" do
    <<~ERB
      <%# Hotwire Livereload script (only in development) %>
      <%= hotwire_livereload_tags if Rails.env.development? %>
    ERB
  end
end

# Improve viewport meta tag for Bootstrap compatibility
gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# Generators
########################################
#
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

# Add general config for Rails 7.1
general_config = <<~RUBY
  config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
RUBY
environment general_config

########################################
# After bundle
########################################
after_bundle do

# Generators: db + simple form + pages controller
########################################

# Setup DB and install simple_form with Bootstrap
rails_command "db:drop db:create db:migrate"
generate("simple_form:install", "--bootstrap")


# Bootstrap & Popper
########################################
append_file "config/importmap.rb", <<~RUBY
  pin "bootstrap", to: "bootstrap.min.js", preload: true
  pin "@popperjs/core", to: "popper.js", preload: true
RUBY

# Tell Rails to precompile Bootstrap and Popper assets
append_file "config/initializers/assets.rb", <<~RUBY
  Rails.application.config.assets.precompile += %w(bootstrap.min.js popper.js)
RUBY

append_file "app/javascript/application.js", <<~JS
  import "@popperjs/core"
  import "bootstrap"
JS

append_file "app/assets/config/manifest.js", <<~JS
  //= link popper.js
  //= link bootstrap.min.js
JS

# Dotenv
########################################
run "touch '.env'"

# Rubocop
########################################
run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

# Gitignore
########################################

# Add common ignores to .gitignore
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
git commit: "rails new"
end
