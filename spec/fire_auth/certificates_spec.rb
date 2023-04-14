# frozen_string_literal: true

require_relative "../setup_helper"

RSpec.describe FireAuth::Certificate do
  include_context "Setup"

  let(:expires_at) { Time.parse("Fri, 24 Mar 2023 02:01:54 GMT").utc.to_i }
  let(:first_kid) { "1e973ee0e16f7eef4f921d50dc61d70b2efefc19" }
  let(:second_kid) { "979ed15597ab35f7829ce744307b793b7ebeb2f0" }

  describe ".find" do
    context "with redis", cache: :redis do
      context "when certificate has not been cached" do
        it "finds certificates" do
          expect(HTTParty).to receive(
            :get
          ).with(
            "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
          ).once.and_call_original

          expect(described_class.find(first_kid)).not_to be_nil
          expect(described_class.find(second_kid)).not_to be_nil
        end
      end

      context "when certificate has been cached" do
        before { described_class.all }

        it "finds certificates" do
          expect(HTTParty).not_to receive(:get)

          expect(described_class.find(first_kid)).not_to be_nil
          expect(described_class.find(second_kid)).not_to be_nil
        end
      end

      context "when certificate has expired" do
        it "finds certificates" do
          expect(HTTParty).to receive(
            :get
          ).with(
            "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
          ).twice.and_call_original

          described_class.all

          allow(redis).to receive(:get).and_return(nil)

          Timecop.freeze(expires_at + 10) do
            expect(redis).to receive(:set).with(
              "fire_auth/certificates",
              anything,
              ex: anything
            )

            expect(described_class.find(first_kid)).not_to be_nil
          end
        end
      end
    end

    context "with memory" do
      context "when certificate has not been cached" do
        it "finds certificates" do
          expect(HTTParty).to receive(
            :get
          ).with(
            "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
          ).once.and_call_original

          expect(described_class.find(first_kid)).not_to be_nil
          expect(described_class.find(second_kid)).not_to be_nil
        end
      end

      context "when certificate has been cached" do
        before { described_class.all }

        it "finds certificates" do
          expect(HTTParty).not_to receive(:get)

          expect(described_class.find(second_kid)).not_to be_nil
        end
      end

      context "when certificate has expired" do
        it "finds certificates" do
          expect(HTTParty).to receive(
            :get
          ).with(
            "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
          ).twice.and_call_original

          described_class.all

          Timecop.freeze(expires_at + 10) do
            expect(described_class.find(first_kid)).not_to be_nil
          end
        end
      end
    end
  end

  describe ".refresh" do
    context "with redis", cache: :redis do
      context "when certificate has not been cached" do
        it "refreshes" do
          expect(HTTParty).to receive(:get).and_call_original
          expect(described_class.refresh).not_to be_nil
        end
      end

      context "when certificate has been cached" do
        before { described_class.all }

        it "refreshes" do
          expect(HTTParty).to receive(:get).and_call_original
          expect(described_class.refresh).not_to be_nil
        end
      end
    end

    context "with memory" do
      context "when certificate has not been cached" do
        it "refreshes" do
          expect(HTTParty).to receive(:get).and_call_original
          expect(described_class.refresh).not_to be_nil
        end
      end

      context "when certificate has been cached" do
        before { described_class.all }

        it "refreshes" do
          expect(HTTParty).to receive(:get).and_call_original
          expect(described_class.refresh).not_to be_nil
        end
      end
    end
  end
end
