class Burninator::Tasks < Rails::Railtie
  rake_tasks do
    Dir[File.join(File.dirname(__FILE__), "tasks/*.rake")].each do |rake_task|
      load rake_task
    end
  end
end
