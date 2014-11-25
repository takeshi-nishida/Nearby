require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test 'seat planning works for tables' do
    e = events(:tables)
    e.plan_seating(Want.priorities)

    # alice and bob are assigned to the same table
    t1 = users(:alice).tables.where(event_id: e.id)
    t2 = users(:bob).tables.where(event_id: e.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # charlie and david are assigned to the same table
    t1 = users(:charlie).tables.where(event_id: e.id)
    t2 = users(:david).tables.where(event_id: e.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # everyone has one seat
    assert_equal(User.included.sort, e.users.sort)
  end

  test 'seat planning works for rows' do
    e = events(:rows)
    e.plan_seating(Want.priorities)

    # alice and bob are assigned to the same table
    t1 = users(:alice).tables.where(event_id: e.id)
    t2 = users(:bob).tables.where(event_id: e.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # charlie and david are assigned to the same table
    t1 = users(:charlie).tables.where(event_id: e.id)
    t2 = users(:david).tables.where(event_id: e.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # everyone has one seat
    assert_equal(User.included.sort, e.users.sort)
  end

  test 'seat planning works for zashiki' do
    e = events(:zashiki1)
    e.plan_seating(Want.priorities)

    # alice and bob are assigned to the same table
    t1 = users(:alice).tables.where(event_id: e.id)
    t2 = users(:bob).tables.where(event_id: e.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # charlie and david are assigned to the same table
    t1 = users(:charlie).tables.where(event_id: e.id)
    t2 = users(:david).tables.where(event_id: e.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # everyone has one seat
    assert_equal(User.included.sort, e.users.sort)
  end


  test 'wishes get satisfied only once' do
    e1 = events(:tables)
    e1.plan_seating(Want.priorities)
    e2 = events(:rows)
    e2.plan_seating(Want.priorities)

    # alice and bob are assigned to the same table at e1
    t1 = users(:alice).tables.where(event_id: e1.id)
    t2 = users(:bob).tables.where(event_id: e1.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # alice and bob are not assigned to the same table at e2
    # this test sometimes fail!
    t1 = users(:alice).tables.where(event_id: e2.id)
    t2 = users(:bob).tables.where(event_id: e2.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_not_equal(t1.first, t2.first)

    # charlie and david are not assigned to the same table at e2
    t1 = users(:charlie).tables.where(event_id: e2.id)
    t2 = users(:david).tables.where(event_id: e2.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_not_equal(t1.first, t2.first)
  end


  test 'wishes get satisfied only once at zashiki' do
    e1 = events(:zashiki1)
    e1.plan_seating(Want.priorities)
    e2 = events(:zashiki2)
    e2.plan_seating(Want.priorities)

    # alice and bob are assigned to the same table at e1
    t1 = users(:alice).tables.where(event_id: e1.id)
    t2 = users(:bob).tables.where(event_id: e1.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_equal(t1.first, t2.first)

    # alice and bob are not assigned to the same table at e2
    # this test sometimes fail!
    t1 = users(:alice).tables.where(event_id: e2.id)
    t2 = users(:bob).tables.where(event_id: e2.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_not_equal(t1.first, t2.first)

    # charlie and david are not assigned to the same table at e2
    t1 = users(:charlie).tables.where(event_id: e2.id)
    t2 = users(:david).tables.where(event_id: e2.id)
    assert_equal(1, t1.count)
    assert_equal(1, t2.count)
    assert_not_equal(t1.first, t2.first)
  end

end
