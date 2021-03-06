# Copyright 2019, Google LLC
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google LLC nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "test_helper"

require "google/gax/config"

class NestedConfig
  extend Google::Gax::Config

  config_attr :str, "default str", String
  config_attr :str_nil, nil, String, nil
  config_attr :bool, true, true, false
  config_attr :bool_nil, nil, true, false, nil
  config_attr :enum, :one, :one, :two, :three
  config_attr :opt_regex, "hi", /^[a-z]+$/
  config_attr :opt_class, "hi", String, Symbol

  def initialize parent_config = nil
    @parent_config = parent_config unless parent_config.nil?
    yield self if block_given?
  end
end

class NestedConfigTest < Minitest::Spec
  def setup
    @parent_config = NestedConfig.new do |config|
      config.str = "updated str"
      config.bool = false
      config.enum = :two
      config.opt_regex = "hello"
      config.opt_class = :hi
    end
  end

  def test_str
    config = NestedConfig.new @parent_config
    assert_equal "updated str", config.str

    config.str = "FooBar"
    assert_equal "FooBar", config.str

    config.str = nil
    assert_equal "updated str", config.str # reset to parent

    @parent_config.str = nil
    assert_equal "default str", config.str # reset to default
  end

  def test_str_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.str = 1
    end

    assert_raises ArgumentError do
      config.str = true
    end

    assert_raises ArgumentError do
      config.str = :one
    end

    assert_raises ArgumentError do
      config.str = { hello: :world }
    end
  end

  def test_bool
    config = NestedConfig.new @parent_config
    assert_equal false, config.bool

    config.bool = true
    assert_equal true, config.bool

    config.bool = nil
    assert_equal false, config.bool # reset to parent

    @parent_config.bool = nil
    assert_equal true, config.bool # reset to default
  end

  def test_bool_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.bool = 1
    end

    assert_raises ArgumentError do
      config.bool = "hi"
    end

    assert_raises ArgumentError do
      config.bool = :one
    end

    assert_raises ArgumentError do
      config.bool = { hello: :world }
    end
  end

  def test_enum
    config = NestedConfig.new @parent_config
    assert_equal :two, config.enum

    config.enum = :one
    assert_equal :one, config.enum

    config.enum = :three
    assert_equal :three, config.enum

    config.enum = nil
    assert_equal :two, config.enum # reset to parent

    @parent_config.enum = nil
    assert_equal :one, config.enum # reset to default
  end

  def test_enum_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.enum = 1
    end

    assert_raises ArgumentError do
      config.enum = "hi"
    end

    assert_raises ArgumentError do
      config.enum = true
    end

    assert_raises ArgumentError do
      config.enum = { hello: :world }
    end
  end

  def test_opt_regex
    config = NestedConfig.new @parent_config
    assert_equal "hello", config.opt_regex

    config.opt_regex = "world"
    assert_equal "world", config.opt_regex

    config.opt_regex = nil
    assert_equal "hello", config.opt_regex # reset to parent

    @parent_config.opt_regex = nil
    assert_equal "hi", config.opt_regex # reset to default
  end

  def test_opt_regex_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.opt_regex = "hello world"
    end

    assert_raises ArgumentError do
      config.opt_regex = "Hi"
    end

    assert_raises ArgumentError do
      config.opt_regex = "hi!"
    end

    assert_raises ArgumentError do
      config.enum = 1
    end

    assert_raises ArgumentError do
      config.enum = true
    end

    assert_raises ArgumentError do
      config.opt_regex = { hello: :world }
    end
  end

  def test_opt_class
    config = NestedConfig.new @parent_config
    assert_equal :hi, config.opt_class

    config.opt_class = "Hello World!"
    assert_equal "Hello World!", config.opt_class

    config.opt_class = nil
    assert_equal :hi, config.opt_class # reset to parent

    @parent_config.opt_class = nil
    assert_equal "hi", config.opt_class # reset to default
  end

  def test_opt_class_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.enum = 1
    end

    assert_raises ArgumentError do
      config.enum = true
    end

    assert_raises ArgumentError do
      config.opt_class = { hello: :world }
    end
  end
end
