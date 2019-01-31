# frozen_string_literal: true

require 'active_record'

require 'active_serialize/version'
require 'active_serialize/class_methods'

module ActiveSerialize
  extend ActiveSupport::Concern
  cattr_accessor :configs, default: { }

  class_methods do
    def active_serialize rmv: [ ], add: [ ], recursive: [ ]
      extend   ClassMethods
      include  ToH
      delegate :active_serialize_keys, :_active_serialize, to: self

      active_serialize_rmv *rmv
      active_serialize_add *add
      active_serialize_add *recursive, recursive: true
    end
  end

  module ToH
    def to_h(rmv: [ ], add: [ ], merge: { })
      tran_key = ->(key) { (_active_serialize[:map][key] || key).to_s }
      recursion = _active_serialize[:recursive].map { |key| [ tran_key.(key), public_send(key)&.to_ha ] }.to_h
      active_serialize_keys(rmv: rmv, add: add)
          .map{ |key| [ tran_key.(key), public_send(key) ] }.to_h
          .merge(merge).merge(recursion)
    end
  end
end

ActiveRecord::Base.include ActiveSerialize