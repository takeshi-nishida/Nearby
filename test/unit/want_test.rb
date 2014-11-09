require 'test_helper'

class WantTest < ActiveSupport::TestCase
  test 'priority is an integer' do
    assert wants(:one).priority.is_a? Integer
    assert wants(:two).priority.is_a? Integer
    assert wants(:three).priority.is_a? Integer
  end

  test 'keys in priorities are sorted' do
    p1, p2, p3 = Want.priorities
    assert p1.all?{ |key, value| key[0] < key[1] }
    assert p2.all?{ |key, value| key[0] < key[1] }
    assert p3.all?{ |key, value| key[0] < key[1] }
  end
end
