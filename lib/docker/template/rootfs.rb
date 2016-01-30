# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Rootfs < Builder
      extend Forwardable::Extended
      rb_delegate :keep?, {
        :key => :keep_rootfs,
        :to => :"@repo.metadata",
        :type => :hash
      }

      # ----------------------------------------------------------------------

      def data
        Template.get(:rootfs, {
          :rootfs_base_img => @repo.metadata["rootfs_base_img"]
        })
      end

      # ----------------------------------------------------------------------
      # During a simple copy you store all the data (includin rootfs) data
      # as a single unit, this helps us clean up data that is known to be for
      # just the rootfs image and remove it so it doesn't impact.
      # ----------------------------------------------------------------------

      def simple_cleanup(dir)
        return unless simple_copy?
        file = dir.join("usr/local/bin/mkimg")
        file.delete if file.exist?
      end

      # ----------------------------------------------------------------------

      def cleanup(img: true)
        @context.rmtree if @context && @context.directory?
        @img.delete "force" => true if @img && img && !keep? \
          rescue nil
      end

      # ----------------------------------------------------------------------

      private
      def setup_context
        @context = @repo.tmpdir("rootfs")
        @context.join("Dockerfile").write(data)
        @copy = @context.join(@repo.metadata["copy_dir"])
        @copy.mkdir
        copy_rootfs
      end

      # ----------------------------------------------------------------------

      private
      def copy_rootfs
        return simple_rootfs_copy if simple_copy?
        @repo.copy_dir("rootfs").safe_copy(@copy, {
          :root => Template.root
        })
      end

      # ----------------------------------------------------------------------
      # When the user is doing a simple layout we detect inline mkimg.
      # ----------------------------------------------------------------------

      private
      def simple_rootfs_copy
        file = @repo.copy_dir.join("usr/local/bin/mkimg")

        if file.file?
          then file.safe_copy(@copy, {
            :root => Template.root
          })
        end
      end

      # ----------------------------------------------------------------------
      # Check to see if the user has the mkimg at all and it's in context.
      # ----------------------------------------------------------------------

      private
      def verify_context
        unless @copy.join("usr/local/bin/mkimg").file?
          raise Error::NoRootfsMkimg
        end
      end
    end
  end
end
