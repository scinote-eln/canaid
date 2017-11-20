require 'spec_helper'

describe Canaid::Factories::FactoryGeneric do
  before(:each) do
    @factory = Canaid::Factories::FactoryGeneric.new
    Canaid::PermissionsHolder.instance.unregister_all
  end

  it 'respond to "can" method' do
    expect(@factory).to respond_to(:can)
  end

  describe 'can(name, priority?, &block)' do
    it 'should evaluate with correct arguments' do
      expect { @factory.can('haz_cheeseburger') {} }.to_not raise_error
      expect { @factory.can(:haz_cheeseburger, 10) {} }.to_not raise_error

      cans = Canaid::PermissionsHolder.instance.instance_variable_get(:@cans)
      expect(cans.length).to eq(1)
      expect(cans.keys[0]).to eq('haz_cheeseburger')
      expect(cans['haz_cheeseburger'].length).to eq(2)
    end

    it 'should raise error with name not a Symbol or String' do
      [nil, {}, [], 12, 5.6].each do |name|
        expect { @factory.can(name) {} }.to raise_error(ArgumentError)
        expect { @factory.can(name, 10) {} }.to raise_error(ArgumentError)
      end

      cans = Canaid::PermissionsHolder.instance.instance_variable_get(:@cans)
      expect(cans).to be_empty
    end

    it 'should raise error with priority not an Integer' do
      [{}, [], 5.6, "test", :test].each do |priority|
        expect { @factory.can('haz_cheeseburger', priority) {} }.to raise_error(ArgumentError)
      end
    end

    it 'should raise error without block' do
      expect { @factory.can('haz_cheeseburger', 10) }.to raise_error(ArgumentError)
    end
  end
end