require 'rubygems'
require 'spec/rake/spectask'
require 'rake'
require 'echoe'

Echoe.new('strawman', '0.2') do |p|
  p.description    = "Allows you fetch pages using glype proxies."
  p.url            = "http://github.com/mattcolyer/strawman"
  p.author         = "Matt Colyer"
  p.email          = "matt @nospam@ colyer.name"
  p.ignore_pattern = []
  p.development_dependencies = ["rspec"]
  p.dependencies = ["eventmachine", "em-http-request", "json"]
end


desc "Run all examples"
Spec::Rake::SpecTask.new('tests') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
end
