# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::PaymentMethod, type: :model do
  it { is_expected.to delegate_method(:create_profile).to(:gateway) }

  describe '#payment_profiles_supported?' do
    it 'return true' do
      expect(described_class.new).to be_payment_profiles_supported
    end
  end
end
