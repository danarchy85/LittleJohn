# frozen_string_literal: true

require "test_helper"

module LittleJohnTester
  extend LittleJohn

  class LittleJohnTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::LittleJohn::VERSION
    end

    def test_it_does_something_useful
      assert true
    end

    def test_that_lj_mongodb_active
      p LittleJohnTester.mdb.client.cluster.servers
      LittleJohnTester.mdb.client.cluster.servers.any?
    end
  end
end
