FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name  'Doe'
    email 'riboulet@gmail.com'
    password 'acefz'
    password_confirm 'acefz'
    admin false
  end

  # This will use the User class (Admin would have been guessed)
  factory :admin, :class => User do
    first_name 'Admin'
    last_name  'User'
    email 'thomas@arbousier.info'
    admin true
  end
end