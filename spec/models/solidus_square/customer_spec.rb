# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Customer, type: :model do
  it { is_expected.to belong_to(:user).class_name('Spree::User') }
end
