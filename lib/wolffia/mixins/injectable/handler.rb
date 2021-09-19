# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../injectable'

# Handler to prepare subject class to receive dependencies injection.
#
# Handler define a protected ``auto_inject`` method, intended to be called
# from the constructor and set attributes from the injection.
class Wolffia::Mixins::Injectable::Handler
  def initialize(subject, functor = nil)
    @container_retriever = functor || ::Wolffia::Mixins::Injectable.container_retriever
    @subject = subject
    @injectables = subject.__send__(:injectables)

    self.freeze
  end

  # @return [Hash, nil]
  def call(inject: false)
    prepare(injectables)

    inject ? injection : nil
  end

  # Retrieve injection from given injectables declaration.
  #
  # @return [Hash{Symbol => Object}]
  def injection
    injectables.map { |k, v| [k.to_sym, container[v]] }.to_h
  end

  protected

  # @return [Class]
  attr_reader :subject

  # Get injection declaration.
  #
  # @return [Hash{Symbol => Symbol}]
  attr_reader :injectables

  # @return [Proc]
  attr_reader :container_retriever

  # @return [Wolffia::Container]
  def container
    container_retriever.call
  end

  # Prepare subject receive injection.
  #
  # @return [Class]
  def prepare(injectables)
    subject.tap do
      injectables.to_h.each { |attr_name, _| self.prepare_attribute(attr_name) }
      # define the auto_inject instance method
      injectables.to_h.transform_keys(&:to_sym).keys.tap do |attributes|
        prepare_method(:auto_inject) do |**injection|
          attributes.each { |attr| self.__send__("#{attr}=", injection[attr]) }
        end
      end
    end
  end

  # @param [String, Symbol] method_name
  #
  # @return [Class]
  def prepare_method(method_name, access: :protected, &block)
    subject.tap do
      subject.__send__(:define_method, method_name, &block)
      subject.__send__(access, method_name)
    end
  end

  # @param [String, Symbol] attr_name
  #
  # @return [Class]
  def prepare_attribute(attr_name, access: :protected)
    subject.tap do
      self.prepare_attribute_reader(attr_name, access: access)
      self.prepare_attribute_writer(attr_name, access: access)
    end
  end

  # @param [String, Symbol] attr_name
  #
  # @return [Class]
  def prepare_attribute_reader(attr_name, access: :protected)
    subject.tap do
      unless subject.instance_methods.include?(attr_name.to_sym)
        subject.__send__(:attr_reader, attr_name)
        subject.__send__(access, attr_name)
      end
    end
  end

  # @param [String, Symbol] attr_name
  #
  # @return [Class]
  def prepare_attribute_writer(attr_name, access: :protected)
    subject.tap do
      unless subject.instance_methods.include?(:"#{attr_name}=")
        subject.__send__(:attr_writer, attr_name)
        subject.__send__(access, "#{attr_name}=")
      end
    end
  end
end
