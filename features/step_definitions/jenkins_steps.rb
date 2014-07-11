
Given(/^the plain Jenkins server$/) do
  %w(job node view).each {|t| api.send(t.to_sym).delete_all! }
end

Then(/^the Jenkins has following (job|node|view)s:$/) do |type, table|
  jenkins_has_following_configs type, table
end

Given(/^the Jenkins server has following (job|node|view)s:$/) do |type, table|
  step 'the plain Jenkins server'
  table.hashes.each do |row|
    args = [row['Name'], row['Description'], row['Disabled']].compact
    send("create_#{type}".to_sym, *args)
  end
  # TODO want to call Then step with table inside of Given step, but have no idea.
  # step "Given the Jenkins has following #{type}s:", table
  jenkins_has_following_configs type, table
end
