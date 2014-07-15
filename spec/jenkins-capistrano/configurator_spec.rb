require 'spec_helper'
require 'jenkins-capistrano/configurator'

describe Jenkins::Capistrano::Configurator do
  subject do
    described_class.new(server_url: 'http://example.org')
  end

  describe '.name_for' do

    [
      { file: 'name.xml'     , expected: 'name' },
      { file: 'name.erb'     , expected: 'name' },
      { file: 'name.xml.erb' , expected: 'name' },
      { file: 'n.a.m.e.xml'  , expected: 'n.a.m.e' },
      { file: 'name.erb.xml' , expected: 'name.erb' }
    ].each do |param|
      it "returns `#{param[:expected]}` when `#{param[:file]}` specified" do
        file = Pathname.new(param[:file])
        expect(subject.send(:name_for, file)).to eql param[:expected]
      end
    end
  end
end
