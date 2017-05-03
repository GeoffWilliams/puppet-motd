require 'spec_helper'
require 'puppet_factset'

describe 'motd::register', :type => :define do

  system_name = 'CentOS-7.0-64'

  let :facts do
    PuppetFactset::factset_hash(system_name)
  end

  let :title do
    "An extra message"
  end

  context 'compiles ok' do
    it { should compile }
  end
end
