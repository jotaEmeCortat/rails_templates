chosen_templates = []

apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/minimal.rb"
chosen_templates << "Minimal"

if yes?("Install Bootstrap?")
  apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/bootstrap.rb"
  chosen_templates << "Bootstrap"
end

if yes?("Install Devise?")
  apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/devise.rb"
  chosen_templates << "Devise"
end

say "\n🎉 Setup completed successfully!", :green
say "👉 Chosen templates: #{chosen_templates.join(', ')}", :blue
