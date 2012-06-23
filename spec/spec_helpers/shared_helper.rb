def read_fixture(filename)
  return File.read(File.join(File.dirname(__FILE__), '..', '..', 'spec', 'fixtures', filename))
end

def load_settings(category)
  settings_file = File.join(File.dirname(__FILE__), '..', '..', 'settings.yml.example')
  YAML::load(File.open(settings_file))[category]
end
