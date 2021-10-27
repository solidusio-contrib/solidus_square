# frozen_string_literal: true

FactoryBot.define do
  factory :square_payment_method, class: SolidusSquare::PaymentMethod do
    name { 'Square' }
  end
end
