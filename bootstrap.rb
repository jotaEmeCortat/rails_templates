# Gemfile
########################################

inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "bootstrap", "~> 5.2"

  RUBY
end

# Assets
########################################

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

# Create config/_fonts.scss for fonts
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

# Create application.scss to import all styles
append_to_file "app/assets/stylesheets/application.scss", <<~SCSS
  // Graphical variables
  @import "config/fonts";
  @import "config/colors";
  @import "config/bootstrap_variables";

  // External libraries
  @import "bootstrap";

SCSS

# Layout
########################################

# Improve viewport meta tag for Bootstrap compatibility
gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)



########################################
# After bundle
########################################
after_bundle do

  # Bootstrap & Popper
  ########################################

  # Add Bootstrap and Popper.js to the importmap
  append_file "config/importmap.rb", <<~RUBY
    pin "bootstrap", to: "bootstrap.min.js", preload: true
    pin "@popperjs/core", to: "popper.js", preload: true
  RUBY

  # Configure Rails to precompile Bootstrap and Popper.js assets
  append_file "config/initializers/assets.rb", <<~RUBY
    Rails.application.config.assets.precompile += %w(bootstrap.min.js popper.js)
  RUBY

  # Import Bootstrap and Popper.js in the JavaScript entry point
  append_file "app/javascript/application.js", <<~JS
    import "@popperjs/core"
    import "bootstrap"
  JS

  # Add Bootstrap and Popper.js to the asset manifest
  append_file "app/assets/config/manifest.js", <<~JS
    //= link popper.js
    //= link bootstrap.min.js
  JS
end
