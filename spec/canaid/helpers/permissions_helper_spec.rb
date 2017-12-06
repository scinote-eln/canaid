require 'spec_helper'

describe Canaid::Helpers::PermissionsHelper do
  let(:class_instance) do
    (Class.new { include Canaid::Helpers::PermissionsHelper }).new
  end

  before(:each) do
    Canaid::PermissionsHolder.instance.unregister_all
  end

  it 'Factory definition should work' do
    factory = Canaid::Factories::Factory.new
    factory.can('haz_true_cheeseburger', String) { true }
    expect(class_instance).to respond_to(:can_haz_true_cheeseburger?)
    expect(class_instance.can_haz_true_cheeseburger?(nil, 'test')).to be true
    factory.can('haz_false_cheeseburger', String) { false }
    expect(class_instance).to respond_to(:can_haz_false_cheeseburger?)
    expect(class_instance.can_haz_false_cheeseburger?(nil, 'test')).to be false
  end

  it 'FactoryForObjClass definition should work' do
    factory = Canaid::Factories::FactoryForObjClass.new(String)
    factory.can('haz_true_cheeseburger') { true }
    expect(class_instance).to respond_to(:can_haz_true_cheeseburger?)
    expect(class_instance.can_haz_true_cheeseburger?(nil, 'test')).to be true
    factory.can('haz_false_cheeseburger') { false }
    expect(class_instance).to respond_to(:can_haz_false_cheeseburger?)
    expect(class_instance.can_haz_false_cheeseburger?(nil, 'test')).to be false
  end

  it 'FactoryGeneric definition should work' do
    factory = Canaid::Factories::FactoryGeneric.new
    factory.can('haz_true_cheeseburger') { true }
    expect(class_instance).to respond_to(:can_haz_true_cheeseburger?)
    expect(class_instance.can_haz_true_cheeseburger?(nil)).to be true
    factory.can('haz_false_cheeseburger') { false }
    expect(class_instance).to respond_to(:can_haz_false_cheeseburger?)
    expect(class_instance.can_haz_false_cheeseburger?(nil)).to be false
  end

  it 'Permission arguments validation' do
    factory = Canaid::Factories::Factory.new
    factory.can('haz_cheeseburger', String) { true }
    expect(class_instance).to respond_to(:can_haz_cheeseburger?)
    expect(class_instance).to respond_to(:can_haz_cheesecake?)
    expect(class_instance.can_haz_cheeseburger?(nil, 'test')).to be true
    expect { class_instance.can_haz_cheeseburger?(nil, 'test', 12) }.to raise_error(ArgumentError)
    expect { class_instance.can_haz_cheesecake?(nil, 'test') }.to raise_error(ArgumentError)
  end

  it 'Scope should be passed to permissions holder for normal permissions' do
    factory = Canaid::Factories::Factory.new
    factory.can('haz_cheeseburger', String) { true }
    factory.can('haz_cheesecake', String) { |user, str| can_haz_cheeseburger?(user, str) && false }
    expect(class_instance).to respond_to(:can_haz_cheeseburger?)
    expect(class_instance).to respond_to(:can_haz_cheesecake?)
    expect(class_instance.can_haz_cheeseburger?(nil, 'test')).to be true
    expect(class_instance.can_haz_cheesecake?(nil, 'test')).to be false

    holder = Canaid::PermissionsHolder.instance
    expect(holder.eval(:haz_cheeseburger, nil, 'test')).to be true
    expect(holder.eval(:haz_cheeseburger, nil, 'test', class_instance)).to be true
    expect { holder.eval(:haz_cheesecake, nil, 'test') }.to raise_error(NoMethodError)
    expect(holder.eval(:haz_cheesecake, nil, 'test', class_instance)).to be false
  end

  it 'Scope should be passed to permissions holder for generic permissions' do
    factory = Canaid::Factories::FactoryGeneric.new
    factory.can('haz_cheeseburger') { true }
    factory.can('haz_cheesecake') { |user| can_haz_cheeseburger?(user) && false }
    expect(class_instance).to respond_to(:can_haz_cheeseburger?)
    expect(class_instance).to respond_to(:can_haz_cheesecake?)
    expect(class_instance.can_haz_cheeseburger?(nil)).to be true
    expect(class_instance.can_haz_cheesecake?(nil)).to be false

    holder = Canaid::PermissionsHolder.instance
    expect(holder.eval_generic(:haz_cheeseburger, nil)).to be true
    expect(holder.eval_generic(:haz_cheeseburger, nil, class_instance)).to be true
    expect { holder.eval_generic(:haz_cheesecake, nil) }.to raise_error(NoMethodError)
    expect(holder.eval_generic(:haz_cheesecake, nil, class_instance)).to be false
  end
end