Gem::Specification.new do |s|
  s.name = 'logstash-output-azureblob'
  s.version         = "0.1.0"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "This output plugin uploads data to Azure blob storage."
  s.description     = "This gem is a Logstash output plugin. It uploads data to Azure blob storage."
  s.authors = ["Yiju"]
  s.email = "yiju@microsoft.com"
  s.homepage = "https://github.com/YingjiJu/logstash-output-azureblob"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0"
  s.add_runtime_dependency "azure"
  s.add_development_dependency "logstash-devutils"
end
