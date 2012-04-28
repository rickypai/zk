require 'spec_helper'

# tests for the top-level module methods of ZK

describe ZK do
  describe :new do
    let(:chroot_path) { '/zktest/path/to/chroot' }

    after do
      mute_logger do
        @zk.close! if @zk and not @zk.closed?
      end
    end

    describe 'with no arguments' do
      before { @zk = ZK.new }

      it %[should create a default connection] do
        @zk.should be_connected
      end
    end

    describe %[with a chroot] do
      before do
        mute_logger do
          @unchroot = ZK.new
        end
      end

      after do
        mute_logger do
          @unchroot.rm_rf('/zktest')
          @unchroot.close! if @unchroot and not @unchroot.closed?
        end
      end

      describe %[that doesn't exist] do
        before { @unchroot.rm_rf('/zktest') }

        describe %[with no host and a :chroot => '/path' argument] do
          before { @zk = ZK.new(:chroot => chroot_path) }

          it %[should use the default connection string, create the chroot and return the connection] do
            @zk.exists?('/').should be_true
            @zk.create('/blah', 'data')

            @unchroot.get("#{chroot_path}/blah").first.should == 'data'
          end
        end

        describe %[as a connection string] do
          describe %[and no explicit option] do
            before do
              @zk = ZK.new("localhost:2181#{chroot_path}")    # implicit create
            end

            it %[should create the chroot path and then return the connection] do
              @zk.exists?('/').should be_true
              @zk.create('/blah', 'data')

              @unchroot.get("#{chroot_path}/blah").first.should == 'data'
            end
          end

          describe %[and an explicit :chroot => :create] do
            before do
              @zk = ZK.new("localhost:2181#{chroot_path}", :chroot => :create)
            end

            it %[should create the chroot path and then return the connection] do
              @zk.exists?('/').should be_true
              @zk.create('/blah', 'data')

              @unchroot.get("#{chroot_path}/blah").first.should == 'data'
            end
          end

          describe %[and :chroot => :check] do
            it %[should barf with a ChrootPathDoesNotExistError] do
              lambda do
                # assign in case of a bug, that way this connection will get torn down
                @zk = ZK.new("localhost:2181#{chroot_path}", :chroot => :check)
              end.should raise_error(ZK::Exceptions::ChrootPathDoesNotExistError)
            end
          end

          describe %[and :chroot => :ignore] do
            it %[should return a connection in a weird state] do
              @zk = ZK.new("localhost:2181#{chroot_path}", :chroot => :ignore)
              lambda { @zk.get('/') }.should raise_error(ZK::Exceptions::NoNode)
            end
          end

          describe %[and :chroot => '/path'] do
            before { @zk = ZK.new("localhost:2181", :chroot => chroot_path) }

            it %[should create the chroot path and then return the connection] do
              @zk.exists?('/').should be_true
              @zk.create('/blah', 'data')

              @unchroot.get("#{chroot_path}/blah").first.should == 'data'
            end
          end
        end # as a connection string
      end # that doesn't exist

      describe %[that exists] do
        before { @unchroot.mkdir_p(chroot_path) }

        describe %[with no host and a :chroot => '/path' argument] do
          before { @zk = ZK.new(:chroot => chroot_path) }

          it %[should use the default connection string and totally work] do
            @zk.exists?('/').should be_true
            @zk.create('/blah', 'data')

            @unchroot.get("#{chroot_path}/blah").first.should == 'data'
          end
        end

        describe %[as a connection string] do
          describe %[and no explicit option] do
            before do
              @zk = ZK.new("localhost:2181#{chroot_path}")    # implicit create
            end

            it %[should totally work] do
              @zk.exists?('/').should be_true
              @zk.create('/blah', 'data')

              @unchroot.get("#{chroot_path}/blah").first.should == 'data'
            end
          end

          describe %[and an explicit :chroot => :create] do
            before do
              @zk = ZK.new("localhost:2181#{chroot_path}", :chroot => :create)
            end

            it %[should totally work] do
              @zk.exists?('/').should be_true
              @zk.create('/blah', 'data')

              @unchroot.get("#{chroot_path}/blah").first.should == 'data'
            end
          end

          describe %[and :chroot => :check] do
            it %[should totally work] do
              lambda do
                # assign in case of a bug, that way this connection will get torn down
                @zk = ZK.new("localhost:2181#{chroot_path}", :chroot => :check)
              end.should_not raise_error
            end
          end

          describe %[and :chroot => :ignore] do
            it %[should totally work] do
              @zk = ZK.new("localhost:2181#{chroot_path}", :chroot => :ignore)
              lambda { @zk.get('/') }.should_not raise_error
            end
          end

          describe %[and :chroot => '/path'] do
            before { @zk = ZK.new("localhost:2181", :chroot => chroot_path) }

            it %[should totally work] do
              @zk.exists?('/').should be_true
              @zk.create('/blah', 'data')

              @unchroot.get("#{chroot_path}/blah").first.should == 'data'
            end
          end
        end # as a connection string
      end # that exists
    end # with a chroot 
  end # :new
end # ZK
