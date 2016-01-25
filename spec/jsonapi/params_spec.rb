require 'spec_helper'

describe JSONAPI::Params do
  it 'has a version number' do
    expect(JSONAPI::Params::VERSION).not_to be nil
  end
end
