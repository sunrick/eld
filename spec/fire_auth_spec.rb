# frozen_string_literal: true

RSpec.describe FireAuth do
  it "has a version number" do
    expect(FireAuth::VERSION).not_to be nil
  end

  context ".build" do
    it "cannot be built without a project id" do
      expect { authenticator = FireAuth.build }.to raise_error(ArgumentError)
    end

    it "can be built with one project id" do
      authenticator = FireAuth.build(firebase_id: "test1")

      expect(authenticator.firebase_id).to eq(["test1"])
    end

    it "can be built with multiple project ids" do
      authenticator = FireAuth.build(firebase_id: %w[test1 test2])
      expect(authenticator.firebase_id).to eq(%w[test1 test2])
    end
  end
end
