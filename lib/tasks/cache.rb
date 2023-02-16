namespace :cache do
  task :clear do
    FileUtils.rm_rf(Dir['tmp/cache/[^.]*'])
    `mkdir -p tmp/cache/001/000/`
  end
end
