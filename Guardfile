guard(:bundler) do
  watch(/\.gemspec\z/)
  watch("Gemfile")
end

guard(:test, all_after_pass: true, test_paths: %w(test)) do
  %w(
    Gemfile.lock
    test/test_helper.rb
  ).each do |path|
    watch(path) {
      "test"
    }
  end

  watch(%r{\Atest/(.*)\.rb\z})

  watch(%r{\Alib/(.*)\.rb\z}) { |m|
    "test/#{m[1]}_test.rb"
  }
end
