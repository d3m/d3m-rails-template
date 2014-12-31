LATEST_STABLE_RUBY = '2.1.3'
CURRENT_RUBY = RUBY_VERSION

def outdated_ruby_version?
  LATEST_STABLE_RUBY.gsub('.', '').to_i > CURRENT_RUBY.gsub('.', '').to_i
end

def ask_with_default_yes(question)
  answer = ask question
  answer = ['n', 'N', 'no', 'No'].include?(answer) ? false : true
end

def ask_with_default_no(question)
  answer = ask question
  answer = ['y', 'Y', 'yes', 'Yes'].include?(answer) ? true : false
end

def source_paths
  Array(super) + [File.join(File.expand_path(File.dirname(__FILE__)),'files')]
end

install_devise = ask_with_default_yes("Do you want to install Devise? [Y/n]")
if install_devise
  generate_devise_user  = ask_with_default_yes("Do you want to create a Devise User Class? [Y/n]")
  generate_devise_views = ask_with_default_yes("Do you want to generate Devise views? [Y/n]")
end

install_sidekiq = ask_with_default_yes("Do you want to install Sidekiq? [Y/n]")
if install_sidekiq
  install_sidetiq = ask_with_default_yes("Do you want to install Sidetiq? [Y/n]")
end

install_curb = ask_with_default_yes("Do you want to install Curb? [Y/n]")
install_hipchat = ask_with_default_no("Do yoy want to install Hipchat? [y/N]")

insert_into_file 'Gemfile', "\nruby '#{CURRENT_RUBY}'", after: "source 'https://rubygems.org'\n"

gsub_file "Gemfile", /^# Use sqlite3 as the database for Active Record$/, "# Use MySQL as the database for Active Record"
gsub_file "Gemfile", /^gem\s+["']sqlite3["'].*$/, "gem 'mysql2'"

uncomment_lines "Gemfile", /capistrano-rails/

######################################
#                                    #
# Gemfile manipulation               #
#                                    #
######################################

gem 'devise' if install_devise
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'kaminari'
gem 'russian'
gem 'paranoia'
gem 'settingslogic'
gem 'unicode'
gem 'puma'
gem 'hipchat' if install_hipchat

gem 'validates_email_format_of'
gem 'curb' if install_curb
gem 'syck'
gem 'yajl-ruby'
gem 'sidekiq' if install_sidekiq
gem 'slim' if install_sidekiq
gem 'sinatra' if install_sidekiq
gem 'sidetiq' if install_sidetiq


gem_group :development do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  #gem 'capistrano-rails'
  gem 'capistrano3-puma'
  gem 'capistrano-sidekiq'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'sextant'
  gem 'pry'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'letter_opener'
end

######################################
#                                    #
# Gem installation                   #
#                                    #
######################################

run 'bundle install'
run 'bundle exec cap install'

######################################
#                                    #
# Modification and addition of files #
#                                    #
######################################
run "rm -rf test/"

uncomment_lines 'Capfile', /'capistrano\/rvm'/
uncomment_lines 'Capfile', /'capistrano\/bundler'/
uncomment_lines 'Capfile', /capistrano\/rails\/assets/
uncomment_lines 'Capfile', /capistrano\/rails\/migrations/
uncomment_lines 'Capfile', /hipchat\/capistrano/ if install_hipchat
uncomment_lines 'Capfile', /capistrano\/puma/
uncomment_lines 'Capfile', /capistrano\/puma\/workers/
uncomment_lines 'Capfile', /capistrano\/sidekiq/ if install_sidekiq

inside "app" do
  inside "assets" do
    inside "stylesheets" do
      copy_file "mail.scss"
    end
  end
  inside "views" do
    inside "layouts" do
      remove_file "application.html.erb"
      copy_file "application.html.haml"
      copy_file "mail.html.haml"
    end
  end
end

inside "config" do
  remove_file "database.yml"
  template "database.yml.example"
  run "cp database.yml.example database.yml"
  
  inside "environments" do
    insert_into_file 'development.rb', after: "config.action_mailer.raise_delivery_errors = false\n" do
      <<-DEV
      # Action Mailer default options
      config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
      DEV
    end
  end
end

######################################
#                                    #
# Running installed gems generators  #
#                                    #
######################################
if install_devise
  generate "devise:install"
  generate "devise user"  if generate_devise_user

  if generate_devise_views
    generate "devise:views"
    #run "for file in app/views/devise/**/*.erb; do html2haml -e $file ${file%erb}haml > /dev/null 2>&1 && rm $file; done"
  end
end

######################################
#                                    #
# Overriding default bundle install  #
#                                    #
######################################
def run_bundle ; end

######################################
#                                    #
# Info for the user                  #
#                                    #
######################################
say("\nPlease note that you're using ruby #{CURRENT_RUBY}. Latest ruby version is #{LATEST_STABLE_RUBY}. Should you want to change it, please amend the Gemfile accordingly.\n", "\e[33m") if outdated_ruby_version?

create_database = ask_with_default_no("Do you want me to create and migrate the database for you? [y/N]")


if create_database
  run "bundle exec rake db:create"
  run "bundle exec rake db:migrate"

end