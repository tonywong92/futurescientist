# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file is used by web_steps.rb, which you should also delete
#
# You have been warned
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'
    when /^the problems page$/
      '/problems'
    
    when /^the create account page$/, /^the create admin page$/
      new_account_path

    when /^the problem submission page$/
      new_problem_path
      
    when /^the login page$/
      '/accounts/login_form'
      
    when /^log out$/
      '/accounts/logout'

    when /^the edit account page$/
      edit_account_path @account_id

    when /^the skills verification page$/
      '/accounts/skills_verification'

    when /^the profile page$/
      account_path @account_id
      
    when /^the problem details page for the first problem$/
      problem_path(1)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
