RSpec::Matchers.define :contain_error_key do
  match do |actual|
    error_response = JSON.parse(actual)
    error_response.has_key?("error")
  end
end
