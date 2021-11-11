# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSquare::Webhooks::Sorter do
  subject(:do_call) { described_class.call(params) }

  let(:event_type) { 'EVENT.TYPE' }
  let(:params) { { type: event_type, resource: {} } }

  it { expect(described_class).to respond_to(:new).with(1).arguments }

  it { expect(described_class).to respond_to(:call).with(1).arguments }

  it { expect(described_class.new({})).to respond_to(:call).with(0).arguments }

  describe '#call' do
    context 'when the handler is not defined' do
      it "returns nil" do
        expect(do_call).to be_nil
      end
    end

    context 'when the handler is defined' do
      let(:result) { 'result' }
      let(:event_type) { 'BASE' }
      let(:handler) { instance_double(SolidusSquare::Webhooks::Handlers::Base) }

      before do
        allow(SolidusSquare::Webhooks::Handlers::Base).to receive(:new).and_return(handler)
        allow(handler).to receive(:call).and_return(result)
      end

      it { expect { do_call }.not_to raise_exception }

      it { expect(do_call).to be result }
    end
  end
end
