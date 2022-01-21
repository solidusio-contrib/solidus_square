# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::User, type: :model do
  it { is_expected.to have_one(:square_customer).class_name('SolidusSquare::Customer') }
end
