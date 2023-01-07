# frozen_string_literal: true

require "test_helper"

module LittleJohnTester
  extend LittleJohn

  class LittleJohnTest < Minitest::Test
    def initialize
      puts "Creating test config"
    end

    def test_that_it_has_a_version_number
      refute_nil ::LittleJohn::VERSION
    end

    def test_it_does_something_useful
      assert false
    end

    def test_lj_mongodb
      p TestApp.mdb
    end
  end
end
