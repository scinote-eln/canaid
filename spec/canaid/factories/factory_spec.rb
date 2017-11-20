require 'spec_helper'

describe Canaid::Factories::Factory do
  before do
    @factory = Canaid::Factories::Factory.new
  end

  it 'respond to "can" method' do
    expect(@factory).to respond_to(:can)
  end

  describe 'can(name, obj_class, priority, &block)' do
    it 'should evaluate with correct arguments' do
      expect { @factory.can('haz_cheeseburger', String, 10) {} }.to_not raise_error
    end

    it 'should raise error without provided block' do
      expect { @factory.can('haz_cheeseburger', String, 10) }.to raise_error(ArgumentError)
    end
  end
end