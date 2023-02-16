namespace :update do
  desc 'Updating existing users initials using keycloak api'
  task existing_usernames: :environment do
    token = Keycloak::AccessToken.new.execute
    users_hash = Keycloak::GetUsers.new(token).execute if token.present?

    users_hash.each do |user_data|
      user = Spree::User.find_by(email: user_data['email'])
      next unless user.present?

      user.update(nombres: user_data['firstName'], apellidos: user_data['lastName'])
      puts 'User initials updated successfully'
    rescue Exception => e
      puts "Exception occurs: #{e}"
      next
    end
  end
end
