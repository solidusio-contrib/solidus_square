require 'spec_helper'

RSpec.describe SolidusSquare::PaymentSource, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:token) }
  end
end
