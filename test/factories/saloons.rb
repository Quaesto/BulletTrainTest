FactoryBot.define do
  factory :saloon do
    association :team
    name { "MyString" }
  end
end
