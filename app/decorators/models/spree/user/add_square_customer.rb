# frozen_string_literal: true

module Spree::User::AddSquareCustomer # rubocop:disable Style/ClassAndModuleChildren
  def self.prepended(base)
    base.has_one :square_customer, class_name: 'SolidusSquare::Customer'
  end

  Spree::User.prepend(self)
end
