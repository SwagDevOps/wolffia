# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concurrent'

# Provide a factory on top of ``concurrent-ruby``.
#
# In a application context container SHOULD BE privileged.
class Wolffia::Concurrent::Factory
  def initialize
    @registry = ::Wolffia::Concurrent::Registry.instance
  end

  # @return [Concurrent::Agent]
  # @return [Concurrent::Array]
  # @return [Concurrent::Atom]
  # @return [Concurrent::AtomicBoolean]
  # @return [Concurrent::AtomicFixnum]
  # @return [Concurrent::AtomicMarkableReference]
  # @return [Concurrent::AtomicReference]
  # @return [Concurrent::CRubySet]
  # @return [Concurrent::CachedThreadPool]
  # @return [Concurrent::CountDownLatch]
  # @return [Concurrent::CyclicBarrier]
  # @return [Concurrent::Delay]
  # @return [Concurrent::DependencyCounter]
  # @return [Concurrent::Event]
  # @return [Concurrent::Exchanger]
  # @return [Concurrent::FixedThreadPool]
  # @return [Concurrent::Future]
  # @return [Concurrent::Hash]
  # @return [Concurrent::IVar]
  # @return [Concurrent::ImmediateExecutor]
  # @return [Concurrent::IndirectImmediateExecutor]
  # @return [Concurrent::LockFreeStack]
  # @return [Concurrent::MVar]
  # @return [Concurrent::Map]
  # @return [Concurrent::Maybe]
  # @return [Concurrent::MutexAtomicBoolean]
  # @return [Concurrent::MutexAtomicFixnum]
  # @return [Concurrent::MutexAtomicReference]
  # @return [Concurrent::MutexCountDownLatch]
  # @return [Concurrent::MutexSemaphore]
  # @return [Concurrent::Promise]
  # @return [Concurrent::ReadWriteLock]
  # @return [Concurrent::ReentrantReadWriteLock]
  # @return [Concurrent::RubyExchanger]
  # @return [Concurrent::RubyExecutorService]
  # @return [Concurrent::RubySingleThreadExecutor]
  # @return [Concurrent::RubyThreadLocalVar]
  # @return [Concurrent::RubyThreadPoolExecutor]
  # @return [Concurrent::SafeTaskExecutor]
  # @return [Concurrent::ScheduledTask]
  # @return [Concurrent::Semaphore]
  # @return [Concurrent::SerializedExecution]
  # @return [Concurrent::SerializedExecutionDelegator]
  # @return [Concurrent::Set]
  # @return [Concurrent::SimpleExecutorService]
  # @return [Concurrent::SingleThreadExecutor]
  # @return [Concurrent::SynchronizedDelegator]
  # @return [Concurrent::TVar]
  # @return [Concurrent::ThreadLocalVar]
  # @return [Concurrent::ThreadPoolExecutor]
  # @return [Concurrent::TimerSet]
  # @return [Concurrent::TimerTask]
  # @return [Concurrent::Transaction]
  # @return [Concurrent::Tuple]
  def make(key, *args, **kwargs, &block)
    registry.resolve(key).new(*args, **kwargs, &block)
  end

  protected

  # @return [Wolffia::Concurrent::Registry]
  attr_reader :registry
end
