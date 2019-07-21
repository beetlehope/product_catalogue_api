FactoryBot.define do
  factory :product do
    name { 'Awesome product' }
    price { 100 }
    category { 'Hardware' }
  end
end
