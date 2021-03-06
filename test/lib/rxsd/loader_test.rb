# tests the loader module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test_helper'

describe RXSD::Loader do

  it "should load file" do
     File.write("/tmp/rxsd-test", "foobar")
     data = RXSD::Loader.load("file:///tmp/rxsd-test")
     assert_equal "foobar", data
  end

  it "should load http uri" do
     # uploaded a minimal test to projects.morsi.org
     data = RXSD::Loader.load("http://projects.morsi.org/rxsd/test-schema1.xsd")
     assert_equal "foobar\n", data
  end

  # context 'when there is an included file' do
  #   let(:uri) { "file://#{Dir.pwd}/test/support/base.xsd" }
  #   subject(:loaded) { described_class.load(uri) }
  #
  #   it { is_expected.to include 'xsd:boolean' }
  # end
end
