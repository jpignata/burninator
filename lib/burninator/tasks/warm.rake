task :environment

namespace :burninator do
  desc "Warm follower database"
  task warm: :environment do
    Burninator.new.warm
  end
end
