desc "Replace the session secret"
task :new_secret => :environment do
  config_file_name = Rails.root.join('config', 'initializers', 'secret_token.rb')
  config_file_data = File.read(config_file_name)
  File.open(config_file_name, 'w') do |file|
    file.write(config_file_data.sub('7ac05153f62d3439860597cd3b2bddf9222e2fd9566372a93c14c9bf7bbdb883f415c13eff436062564a04eac091a70032ec10f558ce3dffe2af73f18bee3bc5', ActiveSupport::SecureRandom.hex(64)))
  end
end

desc 'Load an initial set of data and ready the app'
task :bootstrap => :environment do
  Rake::Task["db:create"].invoke
  Rake::Task["db:migrate"].invoke
  Rake::Task["new_secret"].invoke
end