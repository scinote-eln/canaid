require 'spec_helper'

describe Canaid::PermissionsHolder do
  before(:each) do
    @holder = Canaid::PermissionsHolder.instance
    @holder.unregister_all
  end

  it 'should respond to public methods' do
    expect(@holder).to respond_to(:register).with(3).arguments
    expect(@holder).to respond_to(:register_generic).with(2).arguments
    expect(@holder).to respond_to(:has_permission?).with(1).arguments
    expect(@holder).to respond_to(:is_generic?).with(1).arguments
    expect(@holder).to respond_to(:eval).with(3).arguments
    expect(@holder).to respond_to(:eval_generic).with(2).arguments
    expect(@holder).to respond_to(:unregister_all).with(0).arguments
  end

  describe 'register(name, obj_class, priority, &block)' do
    it 'should evaluate with correct arguments' do
      expect { @holder.register('haz_cheeseburger', String, nil) {} }.to_not raise_error
      expect { @holder.register(:haz_cheeseburger, String, 10) {} }.to_not raise_error

      cans = @holder.instance_variable_get(:@cans)
      expect(cans.length).to eq(1)
      expect(cans.keys[0]).to eq('haz_cheeseburger')
      expect(cans['haz_cheeseburger'].length).to eq(2)
    end

    it 'should raise error with name not a Symbol or String' do
      [nil, {}, [], 12, 5.6].each do |name|
        expect { @holder.register(name, String) {} }.to raise_error(ArgumentError)
        expect { @holder.register(name, String, 10) {} }.to raise_error(ArgumentError)
      end

      cans = @holder.instance_variable_get(:@cans)
      expect(cans).to be_empty
    end

    it 'should raise error with obj_class == nil' do
      expect { @holder.register('haz_cheeseburger', nil) {} }.to raise_error(ArgumentError)
      expect { @holder.register('haz_cheeseburger', nil, 10) {} }.to raise_error(ArgumentError)
    end

    it 'should raise error with priority not an Integer' do
      [{}, [], 5.6, "test", :test].each do |priority|
        expect { @holder.register('haz_cheeseburger', String, priority) {} }.to raise_error(ArgumentError)
      end
    end

    it 'should raise error without block' do
      expect { @holder.register('haz_cheeseburger', String, 10) }.to raise_error(ArgumentError)
    end

    it 'should raise error if 2 different object classes are provided' do
      @holder.register(:haz_cheeseburger, String, 10) {}
      expect { @holder.register(:haz_cheeseburger, Fixnum, 10) {} }.to raise_error(ArgumentError)
    end
  end

  describe 'register_generic(name, priority, &block)' do
    it 'should evaluate with correct arguments' do
      expect { @holder.register_generic('haz_cheeseburger', nil) {} }.to_not raise_error
      expect { @holder.register_generic(:haz_cheeseburger, 10) {} }.to_not raise_error

      cans = @holder.instance_variable_get(:@cans)
      expect(cans.length).to eq(1)
      expect(cans.keys[0]).to eq('haz_cheeseburger')
      expect(cans['haz_cheeseburger'].length).to eq(2)
    end

    it 'should raise error with name not a Symbol or String' do
      [nil, {}, [], 12, 5.6].each do |name|
        expect { @holder.register_generic(name, nil) {} }.to raise_error(ArgumentError)
        expect { @holder.register_generic(name, 10) {} }.to raise_error(ArgumentError)
      end

      cans = @holder.instance_variable_get(:@cans)
      expect(cans).to be_empty
    end

    it 'should raise error with priority not an Integer' do
      [{}, [], 5.6, "test", :test].each do |priority|
        expect { @holder.register_generic('haz_cheeseburger', priority) {} }.to raise_error(ArgumentError)
      end
    end

    it 'should raise error without block' do
      expect { @holder.register_generic('haz_cheeseburger', 10) }.to raise_error(ArgumentError)
    end
  end

  describe 'has_permission?(name)' do
    it 'should evaluate with correct arguments' do
      @holder.register(:haz_cheeseburger, String, 10) { true }
      @holder.register('haz_cheeseburger', String, 11) { true }
      expect(@holder.has_permission?(:haz_cheeseburger)).to be true
    end

    it 'should return false with non-existent permission' do
      expect(@holder.has_permission?(:haz_cheesecake)).to be false
    end

    it 'should raise error if name is not String or Symbol' do
      [nil, 12, 3.5, {}, []].each do |name|
        expect { @holder.has_permission?(name)}.to raise_error(ArgumentError)
      end
    end
  end

  describe 'is_generic?(name)' do
    it 'should evaluate with correct arguments' do
      @holder.register_generic(:haz_cheeseburger, 10) { true }
      @holder.register(:haz_cheesecake, String, 11) { true }
      expect(@holder.is_generic?(:haz_cheeseburger)).to be true
      expect(@holder.is_generic?(:haz_cheesecake)).to be false
    end

    it 'should raise error if name isn\'t registered' do
      expect { @holder.is_generic?(:haz_cheesecake) }.to raise_error(ArgumentError)
    end

    it 'should raise error if name is not String or Symbol' do
      [nil, 12, 3.5, {}, []].each do |name|
        expect { @holder.is_generic?(name)}.to raise_error(ArgumentError)
      end
    end
  end

  describe 'eval(name, user, obj)' do
    it 'should evaluate with correct arguments' do
      @holder.register(:haz_cheeseburger, String, 10) { true }
      expect(@holder.eval(:haz_cheeseburger, nil, "lala")).to be true
      @holder.register(:haz_cheesecake, Fixnum, 10) { true }
      expect(@holder.eval(:haz_cheesecake, nil, 15)).to be true
    end

    it 'should raise error if name is not String or Symbol' do
      [nil, 12, 3.5, {}, []].each do |name|
        expect { @holder.register(name, String, 10) {} }.to raise_error(ArgumentError)
      end
    end

    it 'should raise error if object of invalid class is provided' do
      @holder.register(:haz_cheeseburger, String, 10) { true }
      expect { @holder.eval(:haz_cheeseburger, nil, 15) }.to raise_error(ArgumentError)
    end
  end

  describe 'eval_generic(name, user)' do
    it 'should evaluate with correct arguments' do
      @holder.register_generic(:haz_cheeseburger, 10) { true }
      @holder.register(:haz_cheesecake, String, 11) { true }
      expect(@holder.is_generic?(:haz_cheeseburger)).to be true
      expect(@holder.is_generic?(:haz_cheesecake)).to be false
    end

    it 'should raise error if name is not String or Symbol' do
      [nil, 12, 3.5, {}, []].each do |name|
        expect { @holder.register_generic(name, 10) {} }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'unregister_all' do
    it 'should unregister all permissions' do
      @holder.register(:haz_cheeseburger, String, 11) { true }
      @holder.register_generic(:haz_cheesecake, 10) { true }
      expect(@holder.eval(:haz_cheeseburger, nil, "test")).to be true
      expect(@holder.eval_generic(:haz_cheesecake, nil)).to be true
      @holder.unregister_all
      expect(@holder.has_permission?(:haz_cheeseburger)).to be false
      expect { @holder.eval(:haz_cheeseburger, nil, "test") }.to raise_error(ArgumentError)
      expect { @holder.eval_generic(:haz_cheesecake, nil) }.to raise_error(ArgumentError)
      expect(@holder.has_permission?(:haz_cheesecake)).to be false
    end
  end
end