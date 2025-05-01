def ask_yes_or_no(question)
  valid_answers = { "yes" => true, "y" => true, "no" => false }

  answer = nil
  until valid_answers.key?(answer)
    answer = ask("\n#{question} (yes/no)").strip.downcase
  end

  valid_answers[answer]
end

apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/minimal.rb"

if ask_yes_or_no("Install Bootstrap?")
  apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/bootstrap.rb"
end

if ask_yes_or_no("Install Devise?")
  apply "https://raw.githubusercontent.com/jotaEmeCortat/rails_templates/refs/heads/main/devise.rb"
end
