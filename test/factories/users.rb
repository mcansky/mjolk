FactoryGirl.define do
  factory :user do
    email 'riboulet@gmail.com'
    password 'acedfD&fz'
    name "thom"
  end

  # This will use the User class (Admin would have been guessed)
  factory :bob, :class => User do
    email 'thomas@arbousier.info'
    password 'acefz'
    name "bob"
  end
end