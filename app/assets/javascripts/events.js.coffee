# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $("#select_user").jQselectable() if $("#select_user").length
  $("#select_who").jQselectable() if $("#select_who").length
  $("#select_wantable").jQselectable() if $("#select_wantable").length
