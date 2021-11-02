# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Webhooks::Handlers::Base do
  subject(:handler) { described_class.new({}) }

  it { expect(described_class).to respond_to(:call).with(1).arguments }

  it { expect(handler).to respond_to(:call).with(0).arguments }

  it { expect { handler.call }.to raise_exception(NotImplementedError) }
end
