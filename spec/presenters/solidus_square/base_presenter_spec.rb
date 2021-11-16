# frozen_string_literal: true

RSpec.describe SolidusSquare::BasePresenter do
  subject(:handler) { described_class.new }

  it { expect(described_class).to respond_to(:square_payload).with(1).arguments }

  it { expect(handler).to respond_to(:square_payload).with(0).arguments }

  it { expect { handler.square_payload }.to raise_exception(NotImplementedError) }
end
