require 'spec_helper'

describe JSONAPI::Param do
  it 'has a version number' do
    expect(JSONAPI::Param::VERSION).not_to be nil
  end

  describe '.param' do
    class GenderParam
      include JSONAPI::Param
    end

    class FakeParam
      include JSONAPI::Param

      param :name
      param :full_name

      belongs_to :gender
    end

    it 'adds a dasherized attribute to whitelist of attributes' do
      expect(FakeParam.whitelist_attributes).to eq(['name', 'full-name', 'full_name'])
    end
  end

  describe '.params' do
    class FakeParams
      include JSONAPI::Param

      params :name, :full_name
    end

    it 'adds a dasherized attributes to whitelist of attributes' do
      expect(FakeParams.whitelist_attributes).to eq(['name', 'full-name', 'full_name'])
    end
  end

  describe '.belongs_to' do
    class FakeBelongsToParam
      include JSONAPI::Param

      belongs_to :author
    end

    it 'adds a one-to-one relationship to the whitelist of relationships' do
      expect(FakeBelongsToParam.whitelist_relationships).to eq(['author'])
    end
  end

  describe '#id' do
    subject(:param) { FakeParam.new('data' => {'id' => 123}) }

    it 'returns the id from data object' do
      expect(param.id).to eq(123)
    end
  end

  describe '#type' do
    subject(:param) { FakeParam.new('data' => {'type' => 'fake'}) }

    it 'returns the type from data object' do
      expect(param.type).to eq('fake')
    end
  end

  describe '#attributes' do
    subject(:param) {
      FakeParam.new(
        'data' => {
          'attributes' => {
            'name' => 'Jony',
            'full-name' => 'Jony Santos',
            'gender' => 'm'
          },
          'relationships' => {
            'author' => {
              'data' => {
                'id' => 1,
                'type' => 'authors'
              }
            },
            'gender' => {
              'data' => {
                'id' => 99,
                'type' => 'genders'
              }
            }
          }
        }
      )
    }

    it 'returns attribute list and their relationships based on whitelist' do
      expect(param.attributes).to eq({name: 'Jony', full_name: 'Jony Santos', gender_id: 99})
    end
  end

  describe '#relationships' do
    subject(:param) {
      FakeParam.new(
        'data' => {
          'relationships' => {
            'author' => {
              'data' => {
                'id' => 1,
                'type' => 'authors'
              }
            },
            'gender' => {
              'data' => {
                'id' => 99,
                'type' => 'genders'
              }
            }
          }
        }
      )
    }

    it 'returns relationship list based on whitelist' do
      expect(param.relationships).to eq({'gender_id' => 99})
    end
  end
end
