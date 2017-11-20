require 'spec_helper'

describe Canaid do
  it 'has a version number' do
    expect(Canaid::VERSION).not_to be nil
  end

  describe 'configuration' do
    it 'has configuration' do
      expect(Canaid::Configuration).not_to be nil
    end
  end

end